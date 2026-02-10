--isp_CheckCartonDetail
exec API.TouchPadDropMsg 1000951 , 1001000

execute API.TouchPadAddMsg 1000951, 10, 'Please scan or enter Packing Document No to proceed : isp_CheckCartonDetail',    'us_english'
execute API.TouchPadAddMsg 1000952, 10, 'Unable to identify Carton No for check carton function. Function : isp_CheckCartonDetail',    'us_english'
execute API.TouchPadAddMsg 1000953, 10, 'Please setup Cartonization in SCE/WMS to proceed. Function : isp_CheckCartonDetail',    'us_english'
execute API.TouchPadAddMsg 1000954, 10, 'Incorrect dynamic Weight and Cube columns setup. Function : isp_CheckCartonDetail',    'us_english'
execute API.TouchPadAddMsg 1000955, 10, 'Incorrect dynamic SKU Weight column setup. Function : isp_CheckCartonDetail',    'us_english'
execute API.TouchPadAddMsg 1000956, 10, 'Incorrect dynamic SKU Cube column setup. Function : isp_CheckCartonDetail',    'us_english'
execute API.TouchPadAddMsg 1000957, 10, 'Incorrect dynamic E-Comm Carton Weight column setup. Function : isp_CheckCartonDetail',    'us_english'
execute API.TouchPadAddMsg 1000958, 10, 'Incorrect dynamic E-Comm Cube column setup. Function : isp_CheckCartonDetail',    'us_english'
execute API.TouchPadAddMsg 1000959, 10, 'Result No PickDetail found. Function : isp_CheckCartonDetail',    'us_english'