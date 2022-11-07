--rdt_1653ExtUpd06
execute rdt.rdtDropMsg 192551 , 192600

execute rdt.rdtAddMsg 192551, 10, '192551 UPDStatusErr',    'us_english', 1653
execute rdt.rdtAddMsg 192552, 10, '192552 DelEcomLogErr',   'us_english', 1653
execute rdt.rdtAddMsg 192553, 10, '192553 UPDPLDWGT Err',   'us_english', 1653

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 192551 AND 192600