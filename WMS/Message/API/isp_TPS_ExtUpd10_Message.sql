
--isp_TPS_ExtUpd10
exec API.TouchPadDropMsg 1002951 , 1003000

execute API.TouchPadAddMsg 1002951, 10, 'OrderKey cannot be empty. Function : isp_TPS_ExtUpd10',    'us_english'
execute API.TouchPadAddMsg 1002952, 10, 'ListName(REQEXP) and Code(ADBARCODE) is not found. Function : isp_TPS_ExtUpd10',    'us_english'
execute API.TouchPadAddMsg 1002953, 10, 'PackOtherUnit2 cannot be less than 1. Function : isp_TPS_ExtUpd10',    'us_english'
execute API.TouchPadAddMsg 1002954, 10, 'Invalid SerialNo. SerialNo Not found in the SerialNo Table Function : isp_TPS_ExtUpd10',    'us_english'
execute API.TouchPadAddMsg 1002955, 10, 'Fail to Insert PackSerialNo table. Function : isp_TPS_ExtUpd10',    'us_english'
execute API.TouchPadAddMsg 1002956, 10, 'Fail to Update SerialNo table. Function : isp_TPS_ExtUpd10',    'us_english'