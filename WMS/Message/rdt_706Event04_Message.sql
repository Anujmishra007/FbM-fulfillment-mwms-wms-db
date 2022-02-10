--rdt_706Event04
rdt.rdtDropMsg 170101 , 170150	

execute rdt.rdtAddMsg 170101, 10, '170101 WayBill# req ', 'us_english', 706
execute rdt.rdtAddMsg 170102, 10, '170102Invalid Format', 'us_english', 706
execute rdt.rdtAddMsg 170103, 10, '170103WayBill Exists', 'us_english', 706

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 170101 AND 170150
