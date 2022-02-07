--rdt_840ExtUpd15
execute rdt.rdtDropMsg 171401 , 171450

execute rdt.rdtAddMsg 171401, 10, '171401 ORD PACK CFM ',   'us_english', 840
execute rdt.rdtAddMsg 171402, 10, '171402 DEL PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 171403, 10, '171403 DEL PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 171404, 10, '171404 GetRightFail ',   'us_english', 840
execute rdt.rdtAddMsg 171405, 10, '171405 AutoMBOLPack ',   'us_english', 840
execute rdt.rdtAddMsg 171406, 10, '171406 PACKCFM FAIL ',   'us_english', 840
execute rdt.rdtAddMsg 171407, 10, '171407 DWNOTSETUP   ',   'us_english', 840
execute rdt.rdtAddMsg 171408, 10, '171408TGETDB NOT SET',   'us_english', 840
execute rdt.rdtAddMsg 171409, 10, '171409 INSERTPRTFAIL',   'us_english', 840
execute rdt.rdtAddMsg 171410, 10, '171410INV SHIPPERKEY',   'us_english', 840
execute rdt.rdtAddMsg 171411, 10, 'Pack Data Exists    ',   'us_english', 840
execute rdt.rdtAddMsg 171412, 10, 'And Deleted         ',   'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 171401 and 171450