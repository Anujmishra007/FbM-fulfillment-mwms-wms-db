--rdt_TM_NMVFrom_CreateNextTask
execute rdt.rdtdropmsg 88051, 88100

execute rdt.rdtAddMsg '88051', 10, '88051^nspg_getkey   ', 'us_english', 1746
execute rdt.rdtAddMsg '88052', 10, '88052^InsTaskDetFail', 'us_english', 1746

