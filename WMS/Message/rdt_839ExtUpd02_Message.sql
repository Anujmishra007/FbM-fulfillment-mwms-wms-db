-- rdt_839ExtUpd02
execute rdt.rdtDropMsg 175301, 175350

execute rdt.rdtAddMsg 175301, 10, '175301^GenTLog2 Fail', 'us_english', 839

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 175301 and 175350

