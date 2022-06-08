--rdt_1653ExtUpd04
execute rdt.rdtDropMsg 183701 , 183750

execute rdt.rdtAddMsg 183701, 10, '183701 Del ShtPickEr',   'us_english', 1653

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 183701 AND 183750