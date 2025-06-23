-- rdt_1855ExtValidSP02
--FCR-1755
execute rdt.rdtDropMsg 231201, 231250

execute rdt.rdtAddMsg 231201, 10, '231201DiffToLoc', 'us_english', 1855, 0, '231201 Location override not allowed'

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 231201 AND 231250