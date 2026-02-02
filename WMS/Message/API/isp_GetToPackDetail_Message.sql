--isp_GetToPackDetail
exec API.TouchPadDropMsg 1000851 , 1000900

execute API.TouchPadAddMsg 1000851, 10, '1000851 Please scan or enter Packing Document No to proceed. Function : isp_GetToPackDetail',    'us_english'
execute API.TouchPadAddMsg 1000852, 10, '1000852 Packing Cannot Be Done Without Scanning In Pickslips: isp_GetToPackDetail',    'us_english'
execute API.TouchPadAddMsg 1000853, 10, '1000853 Insert PickingInfo fail: isp_GetToPackDetail',    'us_english'
execute API.TouchPadAddMsg 1000854, 10, '1000854 Update PickingInfo fail: isp_GetToPackDetail',    'us_english'
execute API.TouchPadAddMsg 1000855, 10, '1000855 Error Column name From Order table: isp_GetToPackDetail',    'us_english'
execute API.TouchPadAddMsg 1000856, 10, '1000856 Please setup Cartonization in SCE/WMS to proceed. Function : isp_GetToPackDetail',    'us_english'
execute API.TouchPadAddMsg 1000857, 10, '1000857 Incorrect dynamic SKU Weight column setup. Function : isp_GetToPackDetail',    'us_english'
execute API.TouchPadAddMsg 1000858, 10, '1000858 Incorrect dynamic SKU Cube column setup. Function : isp_GetToPackDetail',    'us_english'
execute API.TouchPadAddMsg 1000859, 10, '1000859 Incorrect dynamic E-Comm Carton Weight column setup. Function : isp_GetToPackDetail',    'us_english'
execute API.TouchPadAddMsg 1000860, 10, '1000860 Incorrect dynamic E-Comm Cube column setup. Function : isp_GetToPackDetail',    'us_english'
execute API.TouchPadAddMsg 1000861, 10, '1000861 Execute Custom SQL Failed. Function : isp_GetToPackDetail',    'us_english'
execute API.TouchPadAddMsg 1000862, 10, '1000862 QTY Over Packed. Function : isp_GetToPackDetail',    'us_english'
execute API.TouchPadAddMsg 1000863, 10, '1000863 Execute Custom SQL Failed. Function : isp_GetToPackDetail',    'us_english'
execute API.TouchPadAddMsg 1000864, 10, 'Result No PickDetail found. Function : isp_GetToPackDetail',    'us_english'
