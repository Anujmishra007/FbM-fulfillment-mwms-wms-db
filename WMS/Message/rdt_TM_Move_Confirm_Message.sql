--rdt_TM_Move_Confirm
execute rdt.rdtdropmsg 87501, 87550

execute rdt.rdtAddMsg '87501', 10, '87501^GetKey Fail   ', 'us_english', 1748
execute rdt.rdtAddMsg '87502', 10, '87502^InsTaskdetFail', 'us_english', 1748
execute rdt.rdtAddMsg '87503', 10, '87503^UpdTaskdetFail', 'us_english', 1748
