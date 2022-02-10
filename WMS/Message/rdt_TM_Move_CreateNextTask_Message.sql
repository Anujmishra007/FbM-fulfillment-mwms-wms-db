-- rdt_TM_Move_CreateNextTask
execute rdt.rdtdropmsg 87551, 87600

execute rdt.rdtAddMsg '87551', 10, '87551^nspg_getkey   ', 'us_english', 1748
execute rdt.rdtAddMsg '87552', 10, '87552^nspg_getkey   ', 'us_english', 1748
execute rdt.rdtAddMsg '87553', 10, '87553^InsTaskDetFail', 'us_english', 1748
execute rdt.rdtAddMsg '87554', 10, '87554^InsTaskDetFail', 'us_english', 1748
execute rdt.rdtAddMsg '87555', 10, '87555^InsTaskDetFail', 'us_english', 1748
