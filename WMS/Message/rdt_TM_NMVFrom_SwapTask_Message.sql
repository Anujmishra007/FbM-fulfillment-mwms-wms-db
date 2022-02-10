--rdt_TM_NMVFrom_SwapTask
execute rdt.rdtDropMsg 88151, 88200

execute rdt.rdtAddMsg 88151, 10, '88151^NoTaskOnThisID', 'us_english', 1746
execute rdt.rdtAddMsg 88152, 10, '88152^UpdTaskdetFail', 'us_english', 1746
execute rdt.rdtAddMsg 88153, 10, '88153^UpdTaskdetFail', 'us_english', 1746
execute rdt.rdtAddMsg 88154, 10, '88154^LCK:          ', 'us_english', 1746
