--rdt_1764GetTask10
execute rdt.rdtdropmsg 167651, 167700

execute rdt.rdtAddMsg 167651, 10, '167651NoTask.ClosePL', 'us_english', 1764
execute rdt.rdtAddMsg 167652, 10, '167652No more task  ', 'us_english', 1764

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 167651 AND 167700