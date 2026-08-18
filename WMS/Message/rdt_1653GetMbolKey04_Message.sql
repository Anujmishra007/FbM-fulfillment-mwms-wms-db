--rdt_1653GetMbolKey04
--FCR-950
exec rdt.rdtDropMsg 219101 , 219150

execute rdt.rdtAddMsg 219101, 10, '219101No MBOL found',    'us_english', 1653
execute rdt.rdtAddMsg 219102, 10, '219102MBOL SHIPPED',     'us_english', 1653
execute rdt.rdtAddMsg 219103, 10, '219103INS PalletFail',   'us_english', 1653
execute rdt.rdtAddMsg 219104, 10, '219104INS PLDtl Err',    'us_english', 1653
execute rdt.rdtAddMsg 219105, 10, '219105Del PLDtl Err',    'us_english', 1653
execute rdt.rdtAddMsg 219106, 10, '219106Del PltHdr Err',   'us_english', 1653
execute rdt.rdtAddMsg 219107, 10, '219107Select LLI Err',   'us_english', 1653
execute rdt.rdtAddMsg 219108, 10, '219108NoPLTGroup',       'us_english', 1653, 0, '219108 PLT Group logic missing'
execute rdt.rdtAddMsg 219109, 10, '219109SQLFail',          'us_english', 1653, 0, '219109 Execute SQL Statement Fail'
execute rdt.rdtAddMsg 219110, 10, '219110SQLFail',          'us_english', 1653, 0, '219110 Execute SQL Statement Fail'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 219101 AND 219150