--rdt_1819ExtUpd09
exec rdt.rdtDropMsg 152401 , 152450

execute rdt.rdtAddMsg 152401, 10, '52401^nspg_getkey',      'us_english', 1819
execute rdt.rdtAddMsg 152402, 10, '52402^InsTaskDetFail',   'us_english', 1819
execute rdt.rdtAddMsg 152403, 10, '52403^nspg_getkey',      'us_english', 1819
execute rdt.rdtAddMsg 152404, 10, '52404^InsTaskDetFail',   'us_english', 1819
execute rdt.rdtAddMsg 152405, 10, '52405^nspg_getkey',      'us_english', 1819
execute rdt.rdtAddMsg 152406, 10, '52406^InsTaskDetFail',   'us_english', 1819

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 152401 AND 152450

