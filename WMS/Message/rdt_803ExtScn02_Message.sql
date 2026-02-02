-- rdt_803ExtScn02
-- FCR-8553
EXECUTE rdt.rdtDropMsg 250401, 250450

EXECUTE rdt.rdtAddMsg 250401, 10, '250401^InvOption', 'us_english', 803, 0, '250401 Invalid Option'


SELECT * FROM rdt.RDTMsg WHERE Message_ID BETWEEN 250401 AND 250450