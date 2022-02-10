--rdt_1638ExtVal10
execute rdt.rdtDropMsg 159251, 159300

execute rdt.rdtAddMsg 159251, 10, '159251^DiffContainer',   'us_english', 1638
execute rdt.rdtAddMsg 159252, 10, '159252^Diff DelDate',          'us_english', 1638

SELECT * FROM RDT.RDTMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 159251 AND 159300