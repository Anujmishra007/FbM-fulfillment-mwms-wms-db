--rdt_1637ExtVal03
execute rdt.rdtDropMsg 215651 , 215700

execute rdt.rdtAddMsg 215651, 10, '215651 PltNotClosed ',   'us_english', 1637

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 215651 AND 215700