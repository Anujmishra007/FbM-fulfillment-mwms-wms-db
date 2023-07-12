-- rdt_1620ExtValid12
rdt.rdtDropMsg 202851 , 202900

execute rdt.rdtAddMsg 202851, 10, '202851Lottable01 req',   'us_english', 1620
execute rdt.rdtAddMsg 202852, 10, '202852L01 Not Exists',   'us_english', 1620


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 202851 AND 202900