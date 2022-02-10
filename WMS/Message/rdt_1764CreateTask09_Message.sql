-- rdt_1764CreateTask09
execute rdt.rdtdropmsg 180301, 180350

execute rdt.rdtAddMsg 180301, 10, '180301nspg_getkey   ', 'us_english', 1764
execute rdt.rdtAddMsg 180302, 10, '180302nspg_getkey   ', 'us_english', 1764
execute rdt.rdtAddMsg 180303, 10, '180303InsTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg 180304, 10, '180304nspg_getkey   ', 'us_english', 1764
execute rdt.rdtAddMsg 180305, 10, '180305InsTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg 180306, 10, '180306InsTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg 180307, 10, '180307InsTaskDetFail', 'us_english', 1764

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN  180301 and 180350


