-- rdt_1797ExtUpd01
execute rdt.rdtDropMsg 214151, 214200

execute rdt.rdtAddMsg 214151, 10, '214151 Different COD', 'us_english', 1797

SELECT * FROM rdt.RDTMsg WHERE Message_ID BETWEEN 214151 AND 214200
