--rdt_1654ExtUpd02
execute rdt.rdtDropMsg 200151 , 200200

execute rdt.rdtAddMsg 200151, 10, '200151Insert TL2 Err',   'us_english', 1654
execute rdt.rdtAddMsg 200152, 10, '200152 Exec ITF Fail',   'us_english', 1654

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 200151 AND 200200