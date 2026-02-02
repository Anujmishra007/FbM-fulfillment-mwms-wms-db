
--isp_TPS_ExtValidP04
exec API.TouchPadDropMsg 1000501 , 1000550

execute API.TouchPadAddMsg 1000501, 10, 'Over Exceed Pack. Function : isp_TPS_ExtValidP04',    'us_english'
execute API.TouchPadAddMsg 1000502, 10, 'Err Scan QRCode. Function : isp_TPS_ExtValidP04',    'us_english'
execute API.TouchPadAddMsg 1000503, 10, 'Duplicate QRCode. Function : isp_TPS_ExtValidP04',    'us_english'
