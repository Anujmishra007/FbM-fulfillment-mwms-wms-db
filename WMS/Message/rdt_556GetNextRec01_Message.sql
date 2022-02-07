-- rdt_556GetNextRec01
exec rdt.rdtdropmsg 181251, 181300

execute rdt.rdtAddMsg 181251, 10, '181251No pick LOC   ', 'us_english', 556
execute rdt.rdtAddMsg 181252, 10, '181252Empty, NoPKLOC', 'us_english', 556
execute rdt.rdtAddMsg 181253, 10, '181253No pick LOC   ', 'us_english', 556

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 181251 AND 175200