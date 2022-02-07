--rdt_547ExtUpd01
exec rdt.rdtDropMsg 167401, 167450

execute rdt.rdtAddMsg 167401, 10, '167401Close Ctn Err', 'us_english', 547

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 167401 AND 167450



