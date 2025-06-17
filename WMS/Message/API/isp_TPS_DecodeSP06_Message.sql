--isp_TPS_DecodeSP06
exec API.TouchPadDropMsg 1000601 , 1000650

execute API.TouchPadAddMsg 1000601, 10, 'Invalid UPC. Scanned UPC not found in UPC table. Function : isp_TPS_DecodeSP06',    'us_english'
