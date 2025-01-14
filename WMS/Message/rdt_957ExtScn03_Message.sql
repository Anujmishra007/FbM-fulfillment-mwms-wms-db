--rdt_957ExtScn03
--FCR-1168
execute rdt.rdtdropmsg 230601, 230650

execute rdt.rdtAddMsg 230601, 10, '230601 DropIDBlank',     'us_english', 957, 0, '230601 Drop ID cannot be blank'

SELECT * FROM RDT.RDTMSG WITH(NOLOCK) WHERE Message_ID BETWEEN 230601 AND 230650