--rdt_LottableProcess_ManningsValidateL04
execute rdt.rdtdropmsg 172501 , 172550

execute rdt.rdtAddMsg 172501, 10, '172501 Lottable04 req',  'us_english', 600
execute rdt.rdtAddMsg 172502, 10, '172502 Invalid UDF03',   'us_english', 600
execute rdt.rdtAddMsg 172503, 10, '172503 Invalid UDF04',   'us_english', 600
execute rdt.rdtAddMsg 172504, 10, '172504 Invalid UDF05',   'us_english', 600
execute rdt.rdtAddMsg 172505, 10, '172505 <MinShelfLife',   'us_english', 600
execute rdt.rdtAddMsg 172506, 10, '172506 <MinShelfLife',   'us_english', 600
execute rdt.rdtAddMsg 172507, 10, '172507 Invalid UDF03',   'us_english', 600
execute rdt.rdtAddMsg 172508, 10, '172508 <MinShelfLife',   'us_english', 600

select * from rdt.rdtmsg (nolock) where message_id between 172501 and 172550