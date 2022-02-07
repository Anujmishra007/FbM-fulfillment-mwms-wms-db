-- rdt_840ExtUpd04 
execute rdt.rdtDropMsg 101651 , 101700

execute rdt.rdtAddMsg 101651, 10, '01651^PACKCFM FAIL',     'us_english', 840
execute rdt.rdtAddMsg 101652, 10, '01652^DWNOTSETUP',       'us_english', 840
execute rdt.rdtAddMsg 101653, 10, '01653^TGETDB NOT SET',   'us_english', 840
execute rdt.rdtAddMsg 101654, 10, '01654^INSERTPRTFAIL',    'us_english', 840
execute rdt.rdtAddMsg 101655, 10, '01655^INV SHIPPERKEY',   'us_english', 840

-- WMS-15010
execute rdt.rdtAddMsg 101656, 10, '01656^GetRightFail',     'us_english', 840
execute rdt.rdtAddMsg 101657, 10, '01657^AutoMBOLPack',     'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 101651 and 101700