--rdt_1620ExtValid09
execute rdt.rdtdropmsg 158101 , 158150

execute rdt.rdtAddMsg 158101, 10, '58101^DropIDNotMatch', 'us_english', 1620

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 158101 AND 158150