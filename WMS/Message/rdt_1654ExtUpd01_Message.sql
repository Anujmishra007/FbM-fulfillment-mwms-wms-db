--rdt_1654ExtUpd01
execute rdt.rdtDropMsg 192501 , 192550

execute rdt.rdtAddMsg 192501, 10, '192501Insert TL2 Err',   'us_english', 1654


SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 192501 AND 192550