--isp_ResetCarton
exec API.TouchPadDropMsg 1000701 , 1000750

execute API.TouchPadAddMsg 1000701, 10, '1000701 Unable to update PackInfo. Function : isp_ResetCarton',    'us_english'
execute API.TouchPadAddMsg 1000702, 10, '1000702 Unable to delete PackInfo. Function : isp_ResetCarton',    'us_english'
execute API.TouchPadAddMsg 1000703, 10, '1000703 Unable to update UCCNo. Function : isp_ResetCarton',    'us_english'