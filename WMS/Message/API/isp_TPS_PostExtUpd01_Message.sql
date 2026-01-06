
--isp_TPS_PostExtUpd01
exec API.TouchPadDropMsg 1003301,1003350

execute API.TouchPadAddMsg 1003301, 10, 'OrderKey or LoadKey Not found, failed to proceed. Function : isp_TPS_PostExtUpd01',    'us_english'
execute API.TouchPadAddMsg 1003302, 10, 'No records found in PackSerialNo table. Function : isp_TPS_PostExtUpd01',    'us_english'
execute API.TouchPadAddMsg 1003303, 10, 'Fail to update into PACKSERIALNO. Function : isp_TPS_PostExtUpd01',    'us_english'