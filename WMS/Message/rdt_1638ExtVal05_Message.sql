--rdt_1638ExtVal05
execute rdt.rdtDropMsg 127051, 127100

execute rdt.rdtAddMsg 127051, 10, '127051Diff Consignee',   'us_english', 1638
execute rdt.rdtAddMsg 127052, 10, '127052Diff BU',          'us_english', 1638

SELECT * FROM RDT.RDTMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 127051 AND 127100