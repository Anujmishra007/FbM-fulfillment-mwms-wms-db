-- rdt_1855ExtValidSP04
--FCR-10824
execute rdt.rdtDropMsg 266401, 266450

execute rdt.rdtAddMsg 266401, 10, '266401DiffToLoc', 'us_english', 1855, 0, '266401 Location override not allowed'
execute rdt.rdtAddMsg 266402, 10, '266402DiffToLoc', 'us_english', 1855, 0, '266402 Location override not allowed'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 266401 AND 266450