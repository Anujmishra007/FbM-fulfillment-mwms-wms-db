-- rdt_1764CreateTask05
execute rdt.rdtdropmsg 155151, 155200

execute rdt.rdtAddMsg 155151, 10, '55151^nspg_getkey   ', 'us_english', 1764
execute rdt.rdtAddMsg 155152, 10, '55152^nspg_getkey   ', 'us_english', 1764
execute rdt.rdtAddMsg 155153, 10, '55153^InsTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg 155154, 10, '55154^nspg_getkey   ', 'us_english', 1764
execute rdt.rdtAddMsg 155155, 10, '55155^InsTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg 155156, 10, '55156^InsTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg 155157, 10, '55157^InsTaskDetFail', 'us_english', 1764

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 155151 AND 155200
