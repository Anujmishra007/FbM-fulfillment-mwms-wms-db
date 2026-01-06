--isp_GetEcomPicklsipNo
exec API.TouchPadDropMsg 1001051 , 1001100

execute API.TouchPadAddMsg 1001051, 10, '1001051 ToteID is from a different Storrer. Please use valid ToteID.: isp_GetEcomPicklsipNo',    'us_english'
execute API.TouchPadAddMsg 1001052, 10, '1001052 Scanned ToteID is not valid to be reuse. Function : isp_GetEcomPicklsipNo',    'us_english'
execute API.TouchPadAddMsg 1001053, 10, '1001053 Packing Document No has completed packing.Please enter valid Packing Document No. Function : isp_GetEcomPicklsipNo',    'us_english'
execute API.TouchPadAddMsg 1001054, 10, '1001054 Packing Document No has completed packing.Please enter valid Packing Document No. Function : isp_GetEcomPicklsipNo',    'us_english'