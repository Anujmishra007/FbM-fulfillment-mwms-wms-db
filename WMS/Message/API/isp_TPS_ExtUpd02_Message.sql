
--isp_TPS_ExtUpd02
exec API.TouchPadDropMsg 1002651 , 1002700

execute API.TouchPadAddMsg 1002651, 10, 'Fail to get SerialNo Key. Function : isp_TPS_ExtUpd02',    'us_english'
execute API.TouchPadAddMsg 1002652, 10, 'Fail to Insert SerialNo table. Function : isp_TPS_ExtUpd02',    'us_english'
execute API.TouchPadAddMsg 1002653, 10, 'Fail to Update SerialNo table. Function : isp_TPS_ExtUpd02',    'us_english'
