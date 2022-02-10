-- rdt_882ExtUpd01
execute rdt.rdtDropMsg 152101, 152150

execute rdt.rdtAddMsg 152101, 10, '52101^UPDSortQty Err' ,     'us_english', 882

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 152101 AND 152150
