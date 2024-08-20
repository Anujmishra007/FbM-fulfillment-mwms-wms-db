-- rdt_TM_CycleCount_SerialNo
exec rdt.rdtDropMsg 220401 , 220450

execute rdt.rdtAddMsg 220401, 10, '220451INS RDSNo Fail',   'us_english', 1768
execute rdt.rdtAddMsg 220402, 10, '220452 SNO Diff SKU ',   'us_english', 1768
execute rdt.rdtAddMsg 220403, 10, '220453 SNO Diff QTY ',   'us_english', 1768
execute rdt.rdtAddMsg 220404, 10, '220454 SNO ady rcv  ',   'us_english', 1768
execute rdt.rdtAddMsg 220405, 10, '220455 UPD RSNO Fail',   'us_english', 1768
execute rdt.rdtAddMsg 220406, 10, '220456SNOMultiRecord',   'us_english', 1768

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 220401 AND 220450