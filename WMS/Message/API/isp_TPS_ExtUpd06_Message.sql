
--isp_TPS_ExtUpd06
exec API.TouchPadDropMsg 1001601 , 1001650

execute API.TouchPadAddMsg 1001601, 10, 'Fail to get SerialNo Key. Function : isp_TPS_ExtUpd06',    'us_english'
execute API.TouchPadAddMsg 1001602, 10, 'Fail to Insert PackSerialNo table. Function : isp_TPS_ExtUpd06',    'us_english'
execute API.TouchPadAddMsg 1001603, 10, 'Fail to Insert SerialNo table. Function : isp_TPS_ExtUpd06',    'us_english'
execute API.TouchPadAddMsg 1001604, 10, 'Fail to Insert PackSerialNo table. Function : isp_TPS_ExtUpd06',    'us_english'
