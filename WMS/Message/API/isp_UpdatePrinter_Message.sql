

--isp_UpdatePrinter
exec API.TouchPadDropMsg 1000751 , 1000800

execute API.TouchPadAddMsg 1000751, 10, 'Unable to retrieve Workstation ID. Function : isp_UpdatePrinter',    'us_english'
execute API.TouchPadAddMsg 1000752, 10, 'Unable to retrieve Printer Type. Function : isp_UpdatePrinter',    'us_english'
execute API.TouchPadAddMsg 1000753, 10, 'PaperPrinter and LabelPrinter cannot be same . Function : isp_UpdatePrinter',    'us_english'
execute API.TouchPadAddMsg 1000754, 10, 'PaperPrinter and LabelPrinter cannot be same . Function : isp_UpdatePrinter',    'us_english'
execute API.TouchPadAddMsg 1000755, 10, 'Update Printer Fail. Function : isp_UpdatePrinter'
execute API.TouchPadAddMsg 1000756, 10, 'Insert Printer Fail. Function : isp_UpdatePrinter'
execute API.TouchPadAddMsg 1000757, 10, 'Unable to retrieve Printer ID. Function : isp_UpdatePrinter'