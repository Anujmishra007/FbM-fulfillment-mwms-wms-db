--rdt_701ExtValidSP02
exec rdt.rdtDropMsg 191951 , 192000

execute rdt.rdtAddMsg 191951, 10, '191951 Invalid LOC  ',   'us_english', 701
execute rdt.rdtAddMsg 191952, 10, '191952 Invalid USER ',   'us_english', 701
execute rdt.rdtAddMsg 191953, 10, '191953 Job Not Done ',   'us_english', 701


SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 191951 AND 192000
