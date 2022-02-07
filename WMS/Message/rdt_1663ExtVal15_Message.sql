--rdt_1663ExtVal15
exec rdt.rdtdropmsg 176101 , 176150

execute rdt.rdtAddMsg 176101, 10, '176101 Orders Cancel', 'us_english', 1663
execute rdt.rdtAddMsg 176102, 10, '176102OrderInDiffPLT', 'us_english', 1663
execute rdt.rdtAddMsg 176103, 10, '176103OrderInDiffPLT', 'us_english', 1663
execute rdt.rdtAddMsg 176104, 10, '176104NotAllScanned ', 'us_english', 1663

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 176101 AND 176150