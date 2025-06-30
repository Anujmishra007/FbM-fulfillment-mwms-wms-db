

--isp_GetPackCartonID
exec API.TouchPadDropMsg 1000451 , 1000500

execute API.TouchPadAddMsg 1000451, 10, 'Need LabelNo. Function : isp_GetPackCartonID',    'us_english'
execute API.TouchPadAddMsg 1000452, 10, 'Execution Error : Vat is not a numeric value. (isp_GLBL20). Function : isp_GetPackCartonID',    'us_english'
execute API.TouchPadAddMsg 1000453, 10, 'Fail to retrieve LableNo. Function : isp_GetPackCartonID',    'us_english'
