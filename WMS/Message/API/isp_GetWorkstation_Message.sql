--isp_GetWorkstation
exec API.TouchPadDropMsg 1001301 , 1001350

execute API.TouchPadAddMsg 1001301, 10, '1001301 No workstation available for device setup. Please ensure workstation has been setup. Funtion : isp_GetWorkstation',    'us_english'
execute API.TouchPadAddMsg 1001302, 10, '1001302 Device ID setup not done. Please setup the Device ID. Funtion : isp_GetWorkstation',    'us_english'
execute API.TouchPadAddMsg 1001303, 10, 'No Session context found. Function : isp_GetWorkstation',    'us_english'