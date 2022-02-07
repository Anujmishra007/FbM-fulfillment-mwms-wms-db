--rdt_TM_Move_SwapTask
execute rdt.rdtDropMsg 87801, 87850

execute rdt.rdtAddMsg 87801, 10, '87801^NoTaskOnThisID', 'us_english', 1748
execute rdt.rdtAddMsg 87802, 10, '87802^UpdTaskdetFail', 'us_english', 1748
execute rdt.rdtAddMsg 87803, 10, '87803^UpdTaskdetFail', 'us_english', 1748
execute rdt.rdtAddMsg 87804, 10, '87804^LCK:          ', 'us_english', 1748
