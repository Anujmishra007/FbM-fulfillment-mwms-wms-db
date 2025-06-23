-- rdt_1836ExtValid02
-- FCR-1489
EXECUTE rdt.rdtDropMsg 230051, 230100

EXECUTE rdt.rdtAddMsg 230051, 10, '230051Invalid Loc.', 'us_english', 1836
EXECUTE rdt.rdtAddMsg 230052, 10, '230052 Fail unlock', 'us_english', 1836
EXECUTE rdt.rdtAddMsg 230053, 10, '230053Fail of lock', 'us_english', 1836



SELECT * FROM RDT.RDTMsg WHERE Message_ID BETWEEN 230051 AND 230100