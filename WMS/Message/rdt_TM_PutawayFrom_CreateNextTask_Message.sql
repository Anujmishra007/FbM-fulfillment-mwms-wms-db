--rdt_TM_PutawayFrom_CreateNextTask
execute rdt.rdtdropmsg 80151, 80200

execute rdt.rdtAddMsg '80151', 10, '80151^nspg_getkey   ', 'us_english', 1797
execute rdt.rdtAddMsg '80152', 10, '80152^nspg_getkey   ', 'us_english', 1797
execute rdt.rdtAddMsg '80153', 10, '80153^InsTaskDetFail', 'us_english', 1797
execute rdt.rdtAddMsg '80154', 10, '80154^InsTaskDetFail', 'us_english', 1797

