# This script allows updating PKI objects in Active Directory for the 
# cross-forest certificate enrollment
#This sample script is not supported under any Microsoft standard support 
#program or service. This sample script is provided AS IS without warranty of 
#any kind. Microsoft further disclaims all implied warranties including,
#without limitation, any implied warranties of merchantability or of fitness
#for a particular purpose. The entire risk arising out of the use or 
#performance of the sample scripts and documentation remains with you. In no 
#event shall Microsoft, its authors, or anyone else involved in the creation,
#production, or delivery of the scripts be liable for any damages whatsoever 
# (including, without limitation, damages for loss of business profits, business
#interruption, loss of business information, or other pecuniary loss) arising 
#out of the use of or inability to use this sample script or documentation, 
#even if Microsoft has been advised of the possibility of such damages.

# Command line variables
$SourceForestName = ""
$TargetForestName = ""
$SourceDC = ""
$TargetDC = ""

$ObjectType = "all"
$ObjectCN = $null

$DryRun = $FALSE
$DeleteOnly = $FALSE
$OverWrite = $FALSE

function ParseCommandLine()
{
    if (2 -gt $Script:args.Count)
    {
        write-warning "Not enough arguments"
        Usage 
        exit 87
    }
    
    for($i = 0; $i -lt $Script:args.Count; $i++)
    {
        switch($Script:args[$i].ToLower())
        {
            -sourceforest 
            {
                $i++
                $Script:SourceForestName = $Script:args[$i]
            }
            -targetforest 
            {
                $i++
                $Script:TargetForestName = $Script:args[$i]
            }                 
            -cn 
            {
                $i++
                $Script:ObjectCN = $Script:args[$i]
            }
            -type 
            {
                $i++
                $Script:ObjectType = $Script:args[$i].ToLower()
            }
            -f 
            {
                $Script:OverWrite = $TRUE
            }
            -whatif
            {
                $Script:DryRun = $TRUE
            }
            -deleteOnly
            {
                $Script:DeleteOnly = $TRUE
            }
            -targetdc
            {
                $i++
                $Script:TargetDC = $Script:args[$i]
            }
            -sourcedc
            {
                $i++
                $Script:SourceDC = $Script:args[$i]
            }
            default 
            {
                write-warning ("Unknown parameter: " + $Script:args[$i])
                Usage
                exit 87
            }
        }
    }
}

function Usage()
{
    write-host ""
    write-host "Script to copy or delete PKI objects (default is copy)"
    write-host ""
    write-host "  Copy Command:"
    write-host ""
    write-host "  .\PKISync.ps1 -sourceforest <SourceForestDNS> -targetforest <TargetForestDNS> [-sourceDC <SourceDCDNS>] [-targetDC <TargetDCDNS>] [-type <CA|Template|OID> [-cn <ObjectCN>]] [-f] [-whatif]"
    write-host ""
    write-host "  Delete Command:"
    write-host ""
    write-host "  .\PKISync.ps1 -targetforest <TargetForestDNS> [-targetDC <TargetDCDNS>] [-type <CA|Template|OID> [-cn <ObjectCN>]] [-deleteOnly] [-whatif]"
    write-host ""
    write-host "-sourceforest           -- DNS of the forest to process object from"
    write-host "-targetforest           -- DNS of the forest to process object to"
    write-host "-sourcedc               -- DNS of the DC in the source forest to process object from"
    write-host "-targetdc               -- DNS of the DC in the target forest to process object to"
    write-host "-type                   -- Type of object to process, if omitted then all object types are processed"
    write-host "                           CA         -- Process CA object(s)"
    write-host "                           Template   -- Process Template object(s)"
    write-host "                           OID        -- Process OID object(s)"
    write-host '-cn                     -- Common name of the object to process, do not include the cn= (ie "User" and not "CN=User"'
    write-host "                           This option is only valid if -type <> is also specified"
    write-host "-f                      -- Force overwrite of existing objects when copying. Ignored when deleting."
    write-host "-whatif                 -- Display what object(s) will be processed without processing"
    write-host "-deleteOnly             -- Will delete object in the target forest if it exists"            
    write-host ""
    write-host ""    
}

# Build a list of attributes to copy for some object type
function GetSchemaSystemMayContain($ForestContext, $ObjectType)
{
    # first get all attributes that are part of systemMayContain list
    $SchemaDE = [System.DirectoryServices.ActiveDirectory.ActiveDirectorySchemaClass]::FindByName($ForestContext, $ObjectType).GetDirectoryEntry()
    $SystemMayContain = $SchemaDE.systemMayContain

    # if schema was upgraded with adprep.exe, we need to check mayContain list as well
    if($null -ne $SchemaDE.mayContain)
    {
        $MayContain = $SchemaDE.mayContain
        foreach($attr in $MayContain)
        {
            $SystemMayContain.Add($attr)
        }
    }
        
    # special case some of the inherited attributes
    if (-1 -eq $SystemMayContain.IndexOf("displayName"))
    {
        $SystemMayContain.Add("displayName")
    }
    if (-1 -eq $SystemMayContain.IndexOf("flags"))
    {
        $SystemMayContain.Add("flags")
    }
    if ($objectType.ToLower().Contains("template") -and -1 -eq $SystemMayContain.IndexOf("revision"))
    {
        $SystemMayContain.Add("revision")
    }
    
    return $SystemMayContain
}

# Copy or delete all objects of some type
function ProcessAllObjects($SourcePKIServicesDE, $TargetPKIServicesDE, $RelativeDN)
{
    $SourceObjectsDE = $SourcePKIServicesDE.psbase.get_Children().find($RelativeDN)
    $ObjectCN = $null
    
    foreach($ChildNode in $SourceObjectsDE.psbase.get_Children())
    {
        # if some object failed, we will try to continue with the rest
        trap
        {
            # CN maybe null here, but its ok. Doing best effort. 
            write-warning ("Error while coping an object. CN=" + $ObjectCN)
            write-warning $_
            write-warning $_.InvocationInfo.PositionMessage
            continue
        }

        $ObjectCN = $ChildNode.psbase.Properties["cn"]
        ProcessObject $SourcePKIServicesDE $TargetPKIServicesDE $RelativeDN $ObjectCN
        $ObjectCN = $null
    }
    
}

# Copy or delete an object
function ProcessObject($SourcePKIServicesDE, $TargetPKIServicesDE, $RelativeDN, $ObjectCN)
{
    $SourceObjectContainerDE = $SourcePKIServicesDE.psbase.get_Children().find($RelativeDN)
    $TargetObjectContainerDE = $TargetPKIServicesDE.psbase.get_Children().find($RelativeDN)

    # when copying make sure there is an object to copy
    if($FALSE -eq $Script:DeleteOnly)
    {
        $DSSearcher =  [System.DirectoryServices.DirectorySearcher]$SourceObjectContainerDE
        $DSSearcher.Filter = "(cn=" +$ObjectCN+")"
        $SearchResult = $DSSearcher.FindAll()
        if (0 -eq $SearchResult.Count)
        {
            write-host ("Source object does not exist: CN=" + $ObjectCN + "," + $RelativeDN)
            return
        }
        $SourceObjectDE = $SourceObjectContainerDE.psbase.get_Children().find("CN=" + $ObjectCN)
    }
    
    # Check to see if the target object exists, if it does delete if overwrite is enabled.
    # Also delete is this a deletion only operation.
    $DSSearcher =  [System.DirectoryServices.DirectorySearcher]$TargetObjectContainerDE
    $DSSearcher.Filter = "(cn=" +$ObjectCN+")"
    $SearchResult = $DSSearcher.FindAll()
    if ($SearchResult.Count -gt 0)
    {
        $TargetObjectDE = $TargetObjectContainerDE.psbase.get_Children().find("CN=" + $ObjectCN)

        if($Script:DeleteOnly) 
        {
            write-host ("Deleting: " + $TargetObjectDE.DistinguishedName)
            if($FALSE -eq $DryRun)
            {
                $TargetObjectContainerDE.psbase.get_Children().Remove($TargetObjectDE)
            }
            return
        } 
        elseif ($Script:OverWrite)
        {
            write-host ("OverWriting: " + $TargetObjectDE.DistinguishedName)
            if($FALSE -eq $DryRun)
            {
                $TargetObjectContainerDE.psbase.get_Children().Remove($TargetObjectDE)
            }
        } 
        else 
        {
            write-warning ("Object exists, use -f to overwrite. Object: " + $TargetObjectDE.DistinguishedName)
            return
        }
    } 
    else 
    {
        if($Script:DeleteOnly) 
        {
            write-warning ("Can't delete object. Object doesn't exist. Object: " + $ObjectCN + ", " + $TargetObjectContainerDE.DistinguishedName)
            return
        } 
        else 
        {        
            write-host ("Copying Object: " + $SourceObjectDE.DistinguishedName)
        }
    }
    
    # Only update the object if this is not a dry run
    if($FALSE -eq $DryRun -and $FALSE -eq $Script:DeleteOnly)
    {
        #Create new AD object   
        $NewDE = $TargetObjectContainerDE.psbase.get_Children().Add("CN=" + $ObjectCN, $SourceObjectDE.psbase.SchemaClassName)

        #Obtain systemMayContain for the object type from the AD schema
        $ObjectMayContain = GetSchemaSystemMayContain $SourceForestContext $SourceObjectDE.psbase.SchemaClassName
        #Copy attributes defined in the systemMayContain for the object type
        foreach($Attribute in $ObjectMayContain)
        {
            $AttributeValue = $SourceObjectDE.psbase.Properties[$Attribute].Value
            if ($null -ne $AttributeValue)
            {
                $NewDE.psbase.Properties[$Attribute].Value = $AttributeValue
                $NewDE.psbase.CommitChanges()
            }
        }
        #Copy secuirty descriptor to new object. Only DACL is copied. 
        $BinarySecurityDescriptor = $SourceObjectDE.psbase.ObjectSecurity.GetSecurityDescriptorBinaryForm()
        $NewDE.psbase.ObjectSecurity.SetSecurityDescriptorBinaryForm($BinarySecurityDescriptor, [System.Security.AccessControl.AccessControlSections]::Access)
        $NewDE.psbase.CommitChanges()
    }
}

# Get parent container for all PKI objects in the AD
function GetPKIServicesContainer([System.DirectoryServices.ActiveDirectory.DirectoryContext] $ForestContext, $dcName)
{
    $ForObj = [System.DirectoryServices.ActiveDirectory.Forest]::GetForest($ForestContext)
    $DE = $ForObj.RootDomain.GetDirectoryEntry()
    
    if("" -ne $dcName)
    {
        $newPath = [System.Text.RegularExpressions.Regex]::Replace($DE.psbase.Path, "LDAP://\S*/", "LDAP://" + $dcName + "/")
        $DE = New-Object System.DirectoryServices.DirectoryEntry $newPath 
    } 

    $PKIServicesContainer = $DE.psbase.get_Children().find("CN=Public Key Services,CN=Services,CN=Configuration")
    return $PKIServicesContainer
}

#########################################################
# Main script code
#########################################################

# All errors are fatal by default unless there is another 'trap' with 'continue'
trap
{
    write-error "The script has encoutnered a fatal error. Terminating script."
    break
}

ParseCommandLine

# Get a hold of the containers in each forest
write-host ("Target Forest: " + $TargetForestName.ToUpper())
$TargetForestContext = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext Forest, $TargetForestName
$TargetPKIServicesDE = GetPKIServicesContainer $TargetForestContext $Script:TargetDC

# Only need source forest when copying
if($FALSE -eq $Script:DeleteOnly)
{
    write-host ("Source Forest: " + $SourceForestName.ToUpper())
    $SourceForestContext = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext Forest, $SourceForestName
    $SourcePKIServicesDE = GetPKIServicesContainer $SourceForestContext $Script:SourceDC
} 
else 
{
    $SourcePKIServicesDE = $TargetPKIServicesDE
}

if("" -ne $ObjectType) {write-host ("Object Category to process: " + $ObjectType.ToUpper())}

# Process the command
switch($ObjectType.ToLower())
{
    all
    {
        write-host ("Enrollment Serverices Container")
    ProcessAllObjects $SourcePKIServicesDE $TargetPKIServicesDE "CN=Enrollment Services"
        write-host ("Certificate Templates Container")
        ProcessAllObjects $SourcePKIServicesDE $TargetPKIServicesDE "CN=Certificate Templates"
        write-host ("OID Container")
        ProcessAllObjects $SourcePKIServicesDE $TargetPKIServicesDE "CN=OID"
    }
    ca
    {
        if($null -eq $ObjectCN)
        {
            ProcessAllObjects $SourcePKIServicesDE $TargetPKIServicesDE "CN=Enrollment Services"
        } 
        else 
        {
            ProcessObject $SourcePKIServicesDE $TargetPKIServicesDE "CN=Enrollment Services" $ObjectCN
        }
    }
    oid
    {
        if($null -eq $ObjectCN)
        {
            ProcessAllObjects $SourcePKIServicesDE $TargetPKIServicesDE "CN=OID"
        } 
        else 
        {
            ProcessObject $SourcePKIServicesDE $TargetPKIServicesDE "CN=OID" $ObjectCN
        }
    }
    template
    {
        if($null -eq $ObjectCN)
        {
            ProcessAllObjects $SourcePKIServicesDE $TargetPKIServicesDE "CN=Certificate Templates"
        } 
        else 
        {
            ProcessObject $SourcePKIServicesDE $TargetPKIServicesDE "CN=Certificate Templates" $ObjectCN
        }    
    }
    default
    {
        write-warning ("Unknown object type: " + $ObjectType.ToLower())
        Usage
        exit 87
    }
}