--isp_TPS_ExtUpdHld06
exec API.TouchPadDropMsg 1003251,1003300

execute API.TouchPadAddMsg 1003251, 10, 'OrderKey cannot be empty. Function: isp_TPS_ExtUpdHld06',    'us_english'
execute API.TouchPadAddMsg 1003252, 10, 'ListName(REQEXP) and Code(ADBARCODE) is not found. Function: isp_TPS_ExtUpdHld06',    'us_english'
execute API.TouchPadAddMsg 1003253, 10, 'PackOtherUnit2 cannot be less than 1. Function: isp_TPS_ExtUpdHld06',    'us_english'
execute API.TouchPadAddMsg 1003254, 10, 'Invalid format: must contain "?" before "!". Function: isp_TPS_ExtUpdHld06',    'us_english'
execute API.TouchPadAddMsg 1003255, 10, 'This serial no already been used or exists in PackSerialNo Table. Function: isp_TPS_ExtUpdHld06',    'us_english'
execute API.TouchPadAddMsg 1003256, 10, 'This serial no already been used in SerialNo Table. Function: isp_TPS_ExtUpdHld06',    'us_english'
execute API.TouchPadAddMsg 1003257, 10, 'Fail to Update SerialNo table. Function : isp_TPS_ExtUpdHld06',    'us_english'
execute API.TouchPadAddMsg 1003258, 10, 'Fail to Insert SerialNo table. Function : isp_TPS_ExtUpdHld06',    'us_english'
execute API.TouchPadAddMsg 1003259, 10, 'Fail to Insert PackSerialNo table. Function : isp_TPS_ExtUpdHld06',    'us_english'
execute API.TouchPadAddMsg 1003260, 10, 'with current SKU does not found in UPC table. Function : isp_TPS_ExtUpdHld06',    'us_english'

execute API.TouchPadAddMsg 1003261, 10, 'Fail to Update the PackDetail table. Function : isp_TPS_ExtUpdHld06',    'us_english'
execute API.TouchPadAddMsg 1003262, 10, 'Fail to get SerialNo Key. Function : isp_TPS_ExtUpdHld06',    'us_english'