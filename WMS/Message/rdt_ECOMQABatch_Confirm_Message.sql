-- rdt_ECOMQABatch_Confirm
execute rdt.rdtDropMsg 185001, 185050

execute rdt.rdtAddMsg 185001, 10, '185001Find Log Fail ', 'us_english', 650
execute rdt.rdtAddMsg 185002, 10, '185002UPD Log Fail  ', 'us_english', 650
execute rdt.rdtAddMsg 185003, 10, '185003DEL PTask Fail', 'us_english', 650
execute rdt.rdtAddMsg 185004, 10, '185004UPD PKDtl Fail', 'us_english', 650
execute rdt.rdtAddMsg 185005, 10, '185005Gen TLOG3 Fail', 'us_english', 650
execute rdt.rdtAddMsg 185006, 10, '185006DEL Log Fail  ', 'us_english', 650
