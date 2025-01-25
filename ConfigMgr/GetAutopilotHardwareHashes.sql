SELECT S.Name0, B.SerialNumber0, M.DeviceHardwareData0
FROM v_R_System S JOIN v_GS_PC_BIOS B ON S.ResourceID = B.ResourceID
JOIN v_GS_MDM_DEVDETAIL_EXT01 M ON S.ResourceID = M.ResourceID
JOIN v_GS_OPERATING_SYSTEM OS ON S.ResourceID = OS.ResourceID
WHERE OS.ProductType0 = 1
ORDER BY S.Name0
