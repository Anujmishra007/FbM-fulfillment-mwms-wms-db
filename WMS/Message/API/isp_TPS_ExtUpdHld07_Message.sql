--isp_TPS_ExtUpdHld07
exec API.TouchPadDropMsg 1003401, 1003450

execute API.TouchPadAddMsg 1003401, 10, 'Quantity Not Match. Function : isp_TPS_ExtUpdHld07',    'us_english'
execute API.TouchPadAddMsg 1003402, 10, 'OrderKey cannot be empty. Function: isp_TPS_ExtUpdHld07',    'us_english'
execute API.TouchPadAddMsg 1003403, 10, 'ListName(REQEXP) and Code(ADBARCODE) is not found. Function: isp_TPS_ExtUpdHld07',    'us_english'
execute API.TouchPadAddMsg 1003404, 10, 'Fail to get SerialNo Key. Function : isp_TPS_ExtUpdHld07',    'us_english'
execute API.TouchPadAddMsg 1003405, 10, 'Fail to Insert SerialNo table. Function : isp_TPS_ExtUpdHld07',    'us_english'
execute API.TouchPadAddMsg 1003406, 10, 'Fail to Update SerialNo table. Function : isp_TPS_ExtUpdHld07',    'us_english'
execute API.TouchPadAddMsg 1003407, 10, 'Fail to Insert PackSerialNo table. Function : isp_TPS_ExtUpdHld07',    'us_english'
execute API.TouchPadAddMsg 1003408, 10, 'One or more duplicate serial numbers were detected.',    'us_english'
execute API.TouchPadAddMsg 1003409, 10, '',    'us_english'