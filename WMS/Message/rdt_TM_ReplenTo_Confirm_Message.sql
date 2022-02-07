--rdt_TM_ReplenTo_Confirm
execute rdt.rdtdropmsg 128201, 128250

execute rdt.rdtAddMsg 128201, 10, '128201GetKey Fail   ', 'us_english', 1765
execute rdt.rdtAddMsg 128202, 10, '128202InsTaskdetFail', 'us_english', 1765
execute rdt.rdtAddMsg 128203, 10, '128203UPD PKDtl Fail', 'us_english', 1765
execute rdt.rdtAddMsg 128204, 10, '128204GetKey Fail   ', 'us_english', 1765
execute rdt.rdtAddMsg 128205, 10, '128205INS PKDtl Fail', 'us_english', 1765
execute rdt.rdtAddMsg 128206, 10, '128206UPD PKDtl Fail', 'us_english', 1765
execute rdt.rdtAddMsg 128207, 10, '128207UpdTaskDetFail', 'us_english', 1765
