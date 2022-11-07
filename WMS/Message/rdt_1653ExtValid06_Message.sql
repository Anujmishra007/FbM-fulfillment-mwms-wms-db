--rdt_1653ExtValid06
execute rdt.rdtDropMsg 187651 , 187700

execute rdt.rdtAddMsg 187651, 10, '187651PltDiffShipper',   'us_english', 1653

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 187651 AND 187700

