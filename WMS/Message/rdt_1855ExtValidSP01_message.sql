-- rdt_1855ExtValidSP01
execute rdt.rdtDropMsg 173301, 173350

execute rdt.rdtAddMsg 173301, 10, '173301 InvCartPrefix', 'us_english', 1855

-- WMS-22863
execute rdt.rdtAddMsg 173302, 10, 'Short Pick Not      ', 'us_english', 1855
execute rdt.rdtAddMsg 173303, 10, 'Allowed             ', 'us_english', 1855
execute rdt.rdtAddMsg 173304, 10, '173304 X Short Pick ', 'us_english', 1855

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN '173301' AND '173350'