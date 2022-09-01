net start "SQL Server (MSSQLSERVER)" /m"Microsoft SQL Server Management Studio - Query"

net stop mssqlserver

net start "SQL Server (MSSQLSERVER)" /mSQLCMD

sqlcmd.exe -E -S CM01 -Q "CREATE LOGIN [DOMAIN\username] FROM WINDOWS; ALTER SERVER ROLE sysadmin ADD MEMBER [DOMAIN\username];"

net start "SQL Server (MSSQLSERVER)"
