
--isp_TPS_ExtUpd11
exec API.TouchPadDropMsg 1003201, 1003250

execute API.TouchPadAddMsg 1003201, 10, 'OrderKey cannot be empty. Function: isp_TPS_ExtUpd11',    'us_english'
execute API.TouchPadAddMsg 1003202, 10, 'ListName(REQEXP) and Code(ADBARCODE) is not found. Function: isp_TPS_ExtUpd11',    'us_english'
execute API.TouchPadAddMsg 1003203, 10, 'PackOtherUnit2 cannot be less than 1. Function: isp_TPS_ExtUpd11',    'us_english'
execute API.TouchPadAddMsg 1003204, 10, 'Invalid format: must contain "?" before "!". Function: isp_TPS_ExtUpd11',    'us_english'
execute API.TouchPadAddMsg 1003205, 10, 'This serial no already been used or exists in PackSerialNo Table. Function: isp_TPS_ExtUpd11',    'us_english'
execute API.TouchPadAddMsg 1003206, 10, 'This serial no already been used in SerialNo Table. Function: isp_TPS_ExtUpd11',    'us_english'
execute API.TouchPadAddMsg 1003207, 10, 'Fail to Update SerialNo table. Function : isp_TPS_ExtUpd11',    'us_english'
execute API.TouchPadAddMsg 1003208, 10, 'Fail to Insert SerialNo table. Function : isp_TPS_ExtUpd11',    'us_english'
execute API.TouchPadAddMsg 1003209, 10, 'Fail to Insert PackSerialNo table. Function : isp_TPS_ExtUpd11',    'us_english'
execute API.TouchPadAddMsg 1003210, 10, 'with current SKU does not found in UPC table. Function : isp_TPS_ExtUpd11',    'us_english'

execute API.TouchPadAddMsg 1003211, 10, 'Fail to Update the PackDetail table. Function : isp_TPS_ExtUpd11',    'us_english'
execute API.TouchPadAddMsg 1003212, 10, 'Fail to get SerialNo Key. Function : isp_TPS_ExtUpd11',    'us_english'