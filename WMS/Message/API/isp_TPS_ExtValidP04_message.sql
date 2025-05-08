
--isp_TPS_ExtValidP04
exec API.TouchPadDropMsg 1000501 , 1000550

execute API.TouchPadAddMsg 1000501, 10, '1000501 Over Exceed Pack : isp_TPS_ExtValidP04',    'us_english'
execute API.TouchPadAddMsg 1000502, 10, '1000502 Err Scan QRCode : isp_TPS_ExtValidP06',    'us_english'
execute API.TouchPadAddMsg 1000503, 10, '1000503 Duplicate QRCode : isp_TPS_ExtValidP06',    'us_english'
