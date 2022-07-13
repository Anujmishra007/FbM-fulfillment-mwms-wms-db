--rdt_1841UCCNoLKUP01
exec rdt.rdtDropMsg 165601 , 165650

execute rdt.rdtAddMsg 165601, 10, '65601^Invalid UCCNo',   'us_english', 1841

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 165601 AND 165650


