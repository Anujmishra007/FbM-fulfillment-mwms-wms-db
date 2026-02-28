
--isp_TPS_ExtPrint01
exec API.TouchPadDropMsg 1002251 , 1002300

execute API.TouchPadAddMsg 1002251, 10, 'Label Printer setup not done. Please setup the Label Printer. Function : isp_TPS_ExtPrint01',    'us_english'
execute API.TouchPadAddMsg 1002252, 10, 'Paper Printer setup not done. Please setup the Paper Printer. Function : isp_TPS_ExtPrint01',    'us_english'