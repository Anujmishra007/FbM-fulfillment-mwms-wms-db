--rdt_1620ExtPackCfm02
rdt.rdtDropMsg 168801 , 168850	

execute rdt.rdtAddMsg 168801, 10, '168801 Pack Cfm Fail', 'us_english', 1620

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 168801 AND 168850
