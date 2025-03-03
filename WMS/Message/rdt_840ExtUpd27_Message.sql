--rdt_840ExtUpd27
execute rdt.rdtdropmsg 203801 , 203850

execute rdt.rdtAddMsg 203801, 10, '203801 Upd Wgt Err  ',   'us_english', 840
execute rdt.rdtAddMsg 203802, 10, '203802 Exec ITF Fail',   'us_english', 840

--WMS-23401
execute rdt.rdtAddMsg 203803, 10, '203803Upd PackInf Er',   'us_english', 840

--WMS-24295
execute rdt.rdtAddMsg 203804, 10, '203804 InsLog Failed',   'us_english', 840

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 203801 AND 203850