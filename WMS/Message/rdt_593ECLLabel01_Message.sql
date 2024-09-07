-- rdt_593ECLLabel01
-- FCR-727
exec rdt.rdtDropMsg 222951, 223000

execute rdt.rdtAddMsg 222951, 10, '222951LabelNoNeeded',       'us_english', 593


SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 222951 AND 223000