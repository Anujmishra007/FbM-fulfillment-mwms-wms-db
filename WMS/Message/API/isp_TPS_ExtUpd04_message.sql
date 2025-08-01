
--isp_TPS_ExtUpd04
exec API.TouchPadDropMsg 1000301 , 1000350

execute API.TouchPadAddMsg 1000301, 10, 'Fail to get SerialNo Key. Function : isp_TPS_ExtUpd04',    'us_english'
execute API.TouchPadAddMsg 1000302, 10, 'Fail Insert SerialNo Function : isp_TPS_ExtUpd04',    'us_english'
execute API.TouchPadAddMsg 1000303, 10, 'Fail Insert PackSerialNo Function : isp_TPS_ExtUpd04',    'us_english'
