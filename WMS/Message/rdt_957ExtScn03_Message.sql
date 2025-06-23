--rdt_957ExtScn03
--FCR-1168
execute rdt.rdtdropmsg 230601, 230650

execute rdt.rdtAddMsg 230601, 10, '230601 DropIDBlank',     'us_english', 957, 0, '230601 Drop ID cannot be blank'

--FCR-2704
execute rdt.rdtAddMsg 230602, 10, '230602 Option required',       'us_english', 957, 0, '230602 Option required'
execute rdt.rdtAddMsg 230603, 10, '230603 Invalid Option',        'us_english', 957, 0, '230603 Invalid Option'
execute rdt.rdtAddMsg 230604, 10, '230604 ReallocationFail',      'us_english', 957, 0, '230604 Reallocation Fail'

SELECT * FROM RDT.RDTMSG WITH(NOLOCK) WHERE Message_ID BETWEEN 230601 AND 230650