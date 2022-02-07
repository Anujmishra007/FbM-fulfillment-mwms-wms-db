
-- rdt_TM_CycleCount_InsertCCDetail 76401 - 76450

--execute rdt.rdtdropmsg  76401 , 76450
-- **********************************************



execute rdt.rdtAddMsg 76401 ,10, '76401^DelCCDetFail', 'us_english'
execute rdt.rdtAddMsg 76402 ,10, '76402^InsCCDetFail', 'us_english'
execute rdt.rdtAddMsg 76403 ,10, '76403^InsCCParmFail', 'us_english'


Update rdt.rdtmsg set Func = 1766 Where Message_ID Between  76401 AND 76450








