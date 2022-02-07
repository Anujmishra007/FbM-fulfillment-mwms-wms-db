-- rdt_PreRcvSort02
exec rdt.rdtDropMsg 118451 , 118500

execute rdt.rdtAddMsg 118451, 10, '18451^UPD PRERCV ERR',       'us_english', 1829
execute rdt.rdtAddMsg 118452, 10, '18452^INS PRERCV ERR',       'us_english', 1829
execute rdt.rdtAddMsg 118453, 10, '18453^INS PRERCV ERR',       'us_english', 1829
execute rdt.rdtAddMsg 118454, 10, '18454^INS PRERCV ERR',       'us_english', 1829
execute rdt.rdtAddMsg 118455, 10, '18455^INS PRERCV ERR',       'us_english', 1829

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 118451 AND 118500