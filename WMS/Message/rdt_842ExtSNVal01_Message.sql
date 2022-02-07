--rdt_842ExtSNVal01
execute rdt.rdtdropmsg 162901 , 162950

execute rdt.rdtAddMsg 162901, 10, '62901^NeedDTSITFName',   'us_english', 842
execute rdt.rdtAddMsg 162902, 10, '62902^SendRequestErr',   'us_english', 842
execute rdt.rdtAddMsg 162903, 10, '62903^Inv Gift Card',    'us_english', 842


SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 162901 AND 162950