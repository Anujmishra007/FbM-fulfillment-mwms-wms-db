
--isp_TPS_ExtUpd08
exec API.TouchPadDropMsg 1002751 , 1002800

execute API.TouchPadAddMsg 1002751, 10, 'REQEXP Codelkup is not setup. Function : isp_TPS_ExtUpd08',    'us_english'
execute API.TouchPadAddMsg 1002752, 10, 'Current SKU is not found with AD value in Susr4. Function : isp_TPS_ExtUpd08',    'us_english'
execute API.TouchPadAddMsg 1002753, 10, 'No SkuBarcode or ADBarcode found. Function : isp_TPS_ExtUpd08',    'us_english'
execute API.TouchPadAddMsg 1002754, 10, 'Error: Serial No must be at least 5 characters long. Function : isp_TPS_ExtUpd08',    'us_english'
execute API.TouchPadAddMsg 1002755, 10, 'Error: Serial No must not be more than 18 characters long. Function : isp_TPS_ExtUpd08',    'us_english'
execute API.TouchPadAddMsg 1002756, 10, 'Error: Serial No cannot be same as SKU code. Function : isp_TPS_ExtUpd08',    'us_english'
execute API.TouchPadAddMsg 1002757, 10, 'Error: Serial No already been packed in PackSerialNo. Function : isp_TPS_ExtUpd08',    'us_english'
execute API.TouchPadAddMsg 1002758, 10, 'Error: Serial No been used in SerialNo table. Function : isp_TPS_ExtUpd08',    'us_english'
execute API.TouchPadAddMsg 1002759, 10, 'Fail to get SerialNo Key. Function : isp_TPS_ExtUpd08',    'us_english'
execute API.TouchPadAddMsg 1002760, 10, 'Fail Insert SerialNO Function : isp_TPS_ExtUpd08',    'us_english'
execute API.TouchPadAddMsg 1002761, 10, 'Fail Insert PackSerialNo Function : isp_TPS_ExtUpd08',    'us_english'