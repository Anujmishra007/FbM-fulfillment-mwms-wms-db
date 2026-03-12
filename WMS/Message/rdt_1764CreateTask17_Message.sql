-- rdt_1764CreateTask17
--256501 - 256550

execute rdt.rdtdropmsg 256501, 256550

execute rdt.rdtAddMsg 256501, 10, '256501^nspg_getkey   ', 'us_english', 1764
execute rdt.rdtAddMsg 256502, 10, '256502^nspg_getkey   ', 'us_english', 1764
execute rdt.rdtAddMsg 256503, 10, '256503^InsTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg 256504, 10, '256504^InsTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg 256505, 10, '256505^InsTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg 256506, 10, '256506^nspg_getkey   ', 'us_english', 1764
execute rdt.rdtAddMsg 256507, 10, '256507^InsTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg 256508, 10, '256508^UpdPKDFail'    , 'us_english', 1764
execute rdt.rdtAddMsg 256509, 10, '256509^UpdPKDFail'    , 'us_english', 1764


select * from rdt.rdtmsg (NOLOCK) where message_id between 256501 and 256550 