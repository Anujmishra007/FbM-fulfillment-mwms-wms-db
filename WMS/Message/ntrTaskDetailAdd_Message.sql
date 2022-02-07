
-- ntrTaskDetailAdd Messages
-- **********************************************

--execute rdt.rdtDropMsg 67991, 67996

execute rdt.rdtAddMsg 67991, 10, '67991 Cannot Insert Completed Items! (ntrTaskDetailAdd)', 'us_english'
execute rdt.rdtAddMsg 67992, 10, '67992 Cannot Insert Items With A ReasonCode Filled In! (ntrTaskDetailAdd)', 'us_english'
execute rdt.rdtAddMsg 67993, 10, '67993 FromID is blank therefore LOT/FROMLOC/ID/QTY/STORERKEY/SKU must be filled in. (ntrTaskDetailAdd)', 'us_english'
execute rdt.rdtAddMsg 67994, 10, '67994 FromID has been filled in therefore LOT should be blank. (ntrTaskDetailAdd)', 'us_english'
execute rdt.rdtAddMsg 67995, 10, '67995 FromLOC should be filled in. (ntrTaskDetailAdd)', 'us_english'
execute rdt.rdtAddMsg 67996, 10, '67996 Update Failed To LOTxLOCxID. (ntrTaskDetailAdd)', 'us_english'
