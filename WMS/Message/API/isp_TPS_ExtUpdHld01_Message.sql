
--isp_TPS_ExtUpdHld01
exec API.TouchPadDropMsg 1002101, 1002150


execute API.TouchPadAddMsg 1002101, 10, 'Fail to get SerialNo Key. Function : isp_TPS_ExtUpdHld01',    'us_english'
execute API.TouchPadAddMsg 1002102, 10, 'Fail to Insert PackSerialNo table. Function : isp_TPS_ExtUpdHld01',    'us_english'
execute API.TouchPadAddMsg 1002103, 10, 'Fail to Insert SerialNo table. Function : isp_TPS_ExtUpdHld01',    'us_english'
execute API.TouchPadAddMsg 1002104, 10, 'Fail to Insert PackSerialNo table. Function : isp_TPS_ExtUpdHld01',    'us_english'
execute API.TouchPadAddMsg 1002105, 10, 'Fail to Update SerialNo table. Function : isp_TPS_ExtUpdHld01',    'us_english'
execute API.TouchPadAddMsg 1002106, 10, 'OrderKey is empty failed to proceed to update the SerialNo/PackSerialNo. Function : isp_TPS_ExtUpdHld01',    'us_english'
