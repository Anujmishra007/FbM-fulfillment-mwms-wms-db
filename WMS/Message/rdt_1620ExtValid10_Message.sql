--rdt_1620ExtValid10
execute rdt.rdtdropmsg 158451 , 158500

execute rdt.rdtAddMsg 158451, 10, '58451^DropIDNotEmpty', 'us_english', 1620

--WMS-17497
execute rdt.rdtAddMsg 158452, 10, '58452^OtherWavInTote', 'us_english', 1620

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 158451 AND 158500
