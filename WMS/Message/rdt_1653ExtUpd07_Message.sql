--rdt_1653ExtUpd07
execute rdt.rdtDropMsg 201301 , 201350

execute rdt.rdtAddMsg 201301, 10, '201301 UPDStatusErr',    'us_english', 1653
execute rdt.rdtAddMsg 201302, 10, '201302 DelEcomLogErr',   'us_english', 1653
execute rdt.rdtAddMsg 201303, 10, '201303 UPDPLDWGT Err',   'us_english', 1653
execute rdt.rdtAddMsg 201304, 10, '201304 UPD PLTDL Err',   'us_english', 1653

--WMS-23471
execute rdt.rdtAddMsg 201305, 10, '201305 > Max Carton ',   'us_english', 1653
execute rdt.rdtAddMsg 201306, 10, '201306 > Max Carton ',   'us_english', 1653
execute rdt.rdtAddMsg 201307, 10, '201307 Upd PltTyp Er',   'us_english', 1653
execute rdt.rdtAddMsg 201308, 10, '201308 UPD PLTDL Err',   'us_english', 1653

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 201301 AND 201350