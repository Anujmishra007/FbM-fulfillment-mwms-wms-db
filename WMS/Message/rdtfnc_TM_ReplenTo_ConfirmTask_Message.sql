
-- RDT Task Manager - Move (rdtfnc_TM_ReplenTo_ConfirmTask) Messages
-- **********************************************

--execute rdt.rdtDropMsg 73801 - 73850



execute rdt.rdtAddMsg 73801, 10, '73801^QtyNotEnoughToMove', 'us_english'
execute rdt.rdtAddMsg 73802, 10, '73802^TASK GEN FAIL', 'us_english'
execute rdt.rdtAddMsg 73803, 10, '73803^InsTaskdetFail', 'us_english'







