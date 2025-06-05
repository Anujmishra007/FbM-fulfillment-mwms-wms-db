--isp_TPS_ExtValidP06
exec API.TouchPadDropMsg 1001501 , 1001550

execute API.TouchPadAddMsg 1001501, 10, '1001501 Err Scan QRCode : isp_TPS_ExtValidP06',    'us_english'
execute API.TouchPadAddMsg 1001502, 10, '1001502 Duplicate QRCode : isp_TPS_ExtValidP06',    'us_english'
