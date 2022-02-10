-- 

-- rdtfnc_TM_CycleCount_UCC_ConfirmTask_Message 74851 - 74900


--execute rdt.rdtdropmsg 74851 , 74900
-- **********************************************


execute rdt.rdtAddMsg 74851 ,10, '74851^InsCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74852 ,10, '74852^UpdCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74853 ,10, '74853^UpdCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74854 ,10, '74854^InsCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74855 ,10, '74855^UpdCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74856 ,10, '74856^InsCCDetFail', 'us_english'

execute rdt.rdtAddMsg 74857 ,10, '74857^UpdSKUFail', 'us_english'
execute rdt.rdtAddMsg 74858 ,10, '74858^UpdLocFail', 'us_english'

Update rdt.rdtmsg set Func = 1767 Where Message_ID Between  74851 AND 74900


