--rdt_706Event05
rdt.rdtDropMsg 186101 , 186150		

execute rdt.rdtAddMsg 186101, 10, '186101 Invalid Label',    'us_english', 706
execute rdt.rdtAddMsg 186102, 10, '186102 Invalid UDF10',    'us_english', 706
execute rdt.rdtAddMsg 186103, 10, '186103 Inv Carrier  ',    'us_english', 706
execute rdt.rdtAddMsg 186104, 10, '186104 Label Exists ',    'us_english', 706
execute rdt.rdtAddMsg 186105, 10, '186105 Invalid Fac  ',    'us_english', 706
execute rdt.rdtAddMsg 186106, 10, '186106 Inv OrdStatus',    'us_english', 706
execute rdt.rdtAddMsg 186107, 10, '186107 Ins Rec Fail ',    'us_english', 706

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 186101 AND 186150	