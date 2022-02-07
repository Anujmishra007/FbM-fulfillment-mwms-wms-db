--rdt_1628ExtPackCfm01
rdt.rdtDropMsg 166501 , 166550	

execute rdt.rdtAddMsg 166501, 10, '166501Pack Cfm Fail',  'us_english', 1628

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 166501 AND 166550
