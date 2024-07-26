-- rdt_1581ExtSNVal01
execute rdt.rdtDropMsg 217651 , 217700

execute rdt.rdtAddMsg 217651, 10, '217651 SNO Diff SKU ', 'us_english', 1581
execute rdt.rdtAddMsg 217652, 10, '217652 SNO Diff QTY ', 'us_english', 1581
execute rdt.rdtAddMsg 217653, 10, '217653 SNO ady rcv  ', 'us_english', 1581
execute rdt.rdtAddMsg 217654, 10, '217654SNOMultiRecord', 'us_english', 1581

SELECT * FROM RDT.RDTMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 217651 AND 217700