
--isp_TPS_ExtValidP07
exec API.TouchPadDropMsg 1001651 , 1001700

execute API.TouchPadAddMsg 1001651, 10, 'Invalid Scan. RetailSKU, AltSKU or ManufacturerSKU is not allow insert into SerialNo table. Function : isp_TPS_ExtValidP07',    'us_english'
execute API.TouchPadAddMsg 1001652, 10, 'Duplicate SerialNO. Function : isp_TPS_ExtValidP07',    'us_english'
