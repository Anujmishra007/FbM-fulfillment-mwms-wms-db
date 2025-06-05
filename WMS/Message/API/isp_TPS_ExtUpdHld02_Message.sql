--isp_TPS_ExtUpdHld02
exec API.TouchPadDropMsg 1001701 , 1001750

execute API.TouchPadAddMsg 1001701, 10, '1001701Fail to get SerialNo Key. Function : isp_TPS_ExtUpdHld02',    'us_english'
execute API.TouchPadAddMsg 1001702, 10, '1001702 Err Insert SerialNO Function : isp_TPS_ExtUpdHld02',    'us_english'
execute API.TouchPadAddMsg 1001703, 10, '1001703 Err Insert PackSerialNO Function : isp_TPS_ExtUpdHld02',    'us_english'
