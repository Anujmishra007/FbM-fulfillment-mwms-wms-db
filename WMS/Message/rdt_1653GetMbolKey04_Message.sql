--rdt_1653GetMbolKey04
exec rdt.rdtDropMsg 219101 , 219150

execute rdt.rdtAddMsg 219101, 10, '219101No MBOL found',   'us_english', 1653
execute rdt.rdtAddMsg 219102, 10, '219102MBOL SHIPPED',   'us_english', 1653
execute rdt.rdtAddMsg 219103, 10, '219103INS PalletFail',   'us_english', 1653
execute rdt.rdtAddMsg 219104, 10, '219104INS PLDtl Err',   'us_english', 1653
execute rdt.rdtAddMsg 219105, 10, '219105Del PLDtl Err',   'us_english', 1653
execute rdt.rdtAddMsg 219106, 10, '219106Del PltHdr Err',   'us_english', 1653
execute rdt.rdtAddMsg 219107, 10, '219107Select LLI Err',   'us_english', 1653

