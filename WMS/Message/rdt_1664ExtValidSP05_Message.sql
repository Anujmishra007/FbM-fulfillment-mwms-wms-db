--rdt_1664ExtValidSP05
exec rdt.rdtDropMsg 173351 , 173400

execute rdt.rdtAddMsg 173351, 10, '173351 Mismatch MBOL', 'us_english', 1664
execute rdt.rdtAddMsg 173352, 10, '173352 Mismatch MBOL', 'us_english', 1664

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 173351 AND 173400

