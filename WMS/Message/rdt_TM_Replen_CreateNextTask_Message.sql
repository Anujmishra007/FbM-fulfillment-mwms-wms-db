-- rdt_TM_Replen_CreateNextTask
execute rdt.rdtdropmsg 74301, 74350

execute rdt.rdtAddMsg '74301', 10, '74301^nspg_getkey   ', 'us_english', 1764
execute rdt.rdtAddMsg '74302', 10, '74302^nspg_getkey   ', 'us_english', 1764
execute rdt.rdtAddMsg '74303', 10, '74303^InsTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg '74304', 10, '74304^InsTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg '74305', 10, '74305^InsTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg '74306', 10, '74306^nspg_getkey   ', 'us_english', 1764
execute rdt.rdtAddMsg '74307', 10, '74307^InsTaskDetFail', 'us_english', 1764
