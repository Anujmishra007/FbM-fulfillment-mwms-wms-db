
--isp_TPS_DecodeSP08
exec API.TouchPadDropMsg 1001501 , 1001550

execute API.TouchPadAddMsg 1001501, 10, 'Invalid Barcode Format Prefix (69) not found. Function : isp_TPS_DecodeSP08',    'us_english'
execute API.TouchPadAddMsg 1001502, 10, 'Invalid Barcode. Record not found. Function : isp_TPS_DecodeSP08',    'us_english'

