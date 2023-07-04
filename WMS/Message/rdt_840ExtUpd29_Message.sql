-- rdt_840ExtUpd29
execute rdt.rdtDropMsg 203301 , 203350

execute rdt.rdtAddMsg 203301, 10, '203301 NO TRACK NO  ',   'us_english', 840
execute rdt.rdtAddMsg 203302, 10, '203302 INV TRACK NO ',   'us_english', 840
execute rdt.rdtAddMsg 203303, 10, '203303 Upd Track Err',   'us_english', 840
execute rdt.rdtAddMsg 203304, 10, '203304UPD PACKINF Er',   'us_english', 840
execute rdt.rdtAddMsg 203305, 10, '203305 NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 203306, 10, '203306 ASSIGN TRK Er',   'us_english', 840
execute rdt.rdtAddMsg 203307, 10, '203307 REL TRACK# Er',   'us_english', 840
execute rdt.rdtAddMsg 203308, 10, '203308 UPD Orders Er',   'us_english', 840
execute rdt.rdtAddMsg 203309, 10, '203309 UPD PKDTL Err',   'us_english', 840
execute rdt.rdtAddMsg 203310, 10, '203310 UPD PKDTL Err',   'us_english', 840


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 203301 AND 203350

