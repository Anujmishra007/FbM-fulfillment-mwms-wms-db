--isp_TPS_DecodeSP07
exec API.TouchPadDropMsg 1000651 , 1000700

execute API.TouchPadAddMsg 1000651, 10, '1000651 Err Scan UPC Barcode : isp_TPS_DecodeSP07',    'us_english'
execute API.TouchPadAddMsg 1000652, 10, '1000652 Err Must Scan UPC Barcode : isp_TPS_DecodeSP07',    'us_english'

