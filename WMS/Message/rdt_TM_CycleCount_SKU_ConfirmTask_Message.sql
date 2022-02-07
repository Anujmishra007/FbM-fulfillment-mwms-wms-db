-- 
-- rdt_TM_CycleCount_SKU_ConfirmTask 74901 - 74950

--execute rdt.rdtdropmsg 74901 , 74950
-- **********************************************

--execute rdt.rdtdropmsg 74901, 74950

execute rdt.rdtAddMsg 74901 ,10, '74901^UpdCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74902 ,10, '74902^InsCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74903 ,10, '74903^UpdCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74904 ,10, '74904^UpdCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74905 ,10, '74905^UpdCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74906 ,10, '74906^UpdCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74907 ,10, '74907^UpdCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74908 ,10, '74908^UpdCCDetFail', 'us_english'
execute rdt.rdtAddMsg 74909 ,10, '74909^UpdSKUFail', 'us_english'
execute rdt.rdtAddMsg 74910 ,10, '74910^UpdLocFail', 'us_english'
execute rdt.rdtAddMsg 74911 ,10, '74911^UpdCCDetFail', 'us_english'

Update rdt.rdtmsg set Func = 1768 Where Message_ID Between  74901 AND 74950


