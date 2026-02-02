--isp_TPS_ExtUpdHld05
exec API.TouchPadDropMsg 1003101, 1003150

execute API.TouchPadAddMsg 1003101, 10, 'OrderKey or LoadKey Not Found. Failed to proceed to update the SerialNo/PackSerialNo. Function : isp_TPS_ExtUpdHld05',    'us_english'
execute API.TouchPadAddMsg 1003102, 10, 'Codelkup ListName(REQEXP) and Code(ADBARCODE) not found. Function : isp_TPS_ExtUpdHld05',   'us_english'
execute API.TouchPadAddMsg 1003103, 10, 'No SkuBarcode or ADBarcode found. Function : isp_TPS_ExtUpdHld05',   'us_english'
execute API.TouchPadAddMsg 1003104, 10, 'Error: Serial No must be at least 5 characters long. Function : isp_TPS_ExtUpdHld05',   'us_english'
execute API.TouchPadAddMsg 1003105, 10, 'Error: Serial No must not be more than 18 characters long. Function : isp_TPS_ExtUpdHld05',    'us_english'
execute API.TouchPadAddMsg 1003106, 10, 'Error: Serial No cannot be same as SKU code. Function : isp_TPS_ExtUpdHld05',   'us_english'
execute API.TouchPadAddMsg 1003107, 10, 'Error: Serial No already been packed in PackSerialNo. Function : isp_TPS_ExtUpdHld05',   'us_english'
execute API.TouchPadAddMsg 1003108, 10, 'Error: Serial No been used in SerialNo table. Function : isp_TPS_ExtUpdHld05',   'us_english'
execute API.TouchPadAddMsg 1003109, 10, 'Fail to get SerialNo Key. Function : isp_TPS_ExtUpdHld05',   'us_english'
execute API.TouchPadAddMsg 1003110, 10, 'Fail Insert SerialNO Function : isp_TPS_ExtUpdHld05',   'us_english'
execute API.TouchPadAddMsg 1003111, 10, 'Fail Insert PackSerialNo Function : isp_TPS_ExtUpdHld05',   'us_english'
