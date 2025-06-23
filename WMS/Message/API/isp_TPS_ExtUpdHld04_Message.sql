--isp_TPS_ExtUpdHld04
exec API.TouchPadDropMsg 1003001, 1003050

execute API.TouchPadAddMsg 1003001, 10, 'OrderKey not Found. Failed to proceed to update the SerialNo/PackSerialNo. Function : isp_TPS_ExtUpdHld04',    'us_english'
execute API.TouchPadAddMsg 1003002, 10, 'Codelkup ListName(REQEXP) and Code(ADBARCODE) not found. Function : isp_TPS_ExtUpdHld04',   'us_english'
execute API.TouchPadAddMsg 1003003, 10, 'Failed to insert SerialNo into PackSerialNo Table. Function : isp_TPS_ExtUpdHld04',   'us_english'
execute API.TouchPadAddMsg 1003004, 10, 'Failed to insert SerialNo into PackSerialNo Table. Records already exists. Function : isp_TPS_ExtUpdHld04',   'us_english'
execute API.TouchPadAddMsg 1003005, 10, 'Fail to get SerialNo Key. Function : isp_TPS_ExtUpdHld04',    'us_english'
execute API.TouchPadAddMsg 1003006, 10, 'Fail to Insert SerialNo table. Function : isp_TPS_ExtUpdHld04',   'us_english'
execute API.TouchPadAddMsg 1003007, 10, 'Failed to insert SerialNo into PackSerialNo Table. Function : isp_TPS_ExtUpdHld04',   'us_english'
execute API.TouchPadAddMsg 1003008, 10, 'Failed to insert SerialNo into PackSerialNo Table. Records already exists. Function : isp_TPS_ExtUpdHld04',   'us_english'
execute API.TouchPadAddMsg 1003009, 10, 'Fail to Update SerialNo table. Function : isp_TPS_ExtUpdHld04',   'us_english'
execute API.TouchPadAddMsg 1003010, 10, 'PackOtherUnit2 cannot be less than 1. Function : isp_TPS_ExtUpdHld04',   'us_english'
execute API.TouchPadAddMsg 1003011, 10, 'Failed to get the existing SerialNoKey from SerialNo Table. Records already been in used. Function : isp_TPS_ExtUpdHld04',   'us_english'
