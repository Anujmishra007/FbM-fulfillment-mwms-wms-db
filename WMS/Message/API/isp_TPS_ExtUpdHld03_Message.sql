--isp_TPS_ExtUpdHld03
exec API.TouchPadDropMsg 1001801 , 1001850

execute API.TouchPadAddMsg 1001801, 10, 'No OrderKey and LoadKey found. Failed to proceed to update the SerialNo/PackSerialNo. Function : isp_TPS_ExtUpdHld03',    'us_english'
execute API.TouchPadAddMsg 1001802, 10, 'Codelkup ListName(REQEXP) and Code(ADBARCODE) not found. Function : isp_TPS_ExtUpdHld03',   'us_english'
execute API.TouchPadAddMsg 1001803, 10, 'Failed to insert SerialNo into PackSerialNo Table. Function : isp_TPS_ExtUpdHld03',   'us_english'
execute API.TouchPadAddMsg 1001804, 10, 'Failed to insert SerialNo into PackSerialNo Table. Records already exists. Function : isp_TPS_ExtUpdHld03',   'us_english'
execute API.TouchPadAddMsg 1001805, 10, 'Fail to get SerialNo Key. Function : isp_TPS_ExtUpdHld03',    'us_english'
execute API.TouchPadAddMsg 1001806, 10, 'Fail to Insert SerialNo table. Function : isp_TPS_ExtUpdHld03',   'us_english'
execute API.TouchPadAddMsg 1001807, 10, 'Failed to insert SerialNo into PackSerialNo Table. Function : isp_TPS_ExtUpdHld03',   'us_english'
execute API.TouchPadAddMsg 1001808, 10, 'Failed to insert SerialNo into PackSerialNo Table. Records already exists. Function : isp_TPS_ExtUpdHld03',   'us_english'
execute API.TouchPadAddMsg 1001809, 10, 'Fail to Update SerialNo table. Function : isp_TPS_ExtUpdHld03',   'us_english'
execute API.TouchPadAddMsg 1001810, 10, 'PackOtherUnit2 cannot be less than 1. Function : isp_TPS_ExtUpdHld03',   'us_english'
execute API.TouchPadAddMsg 1001811, 10, 'Failed to get the existing SerialNoKey from SerialNo Table. Records already been in used. Function : isp_TPS_ExtUpdHld03',   'us_english'
