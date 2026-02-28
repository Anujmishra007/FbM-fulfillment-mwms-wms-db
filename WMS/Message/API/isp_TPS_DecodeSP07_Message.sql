--isp_TPS_DecodeSP07
exec API.TouchPadDropMsg 1000651 , 1000700

execute API.TouchPadAddMsg 1000651, 10, 'Error SerialNo format. Function : isp_TPS_DecodeSP07',    'us_english'
execute API.TouchPadAddMsg 1000652, 10, 'Error Insert Duplicate SerialNo. Function : isp_TPS_DecodeSP07',    'us_english'

