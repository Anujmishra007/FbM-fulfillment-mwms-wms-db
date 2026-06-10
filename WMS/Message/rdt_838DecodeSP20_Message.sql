-- rdt_838DecodeSP20
-- FCR-12178

EXECUTE rdt.rdtDropMsg 264701, 264750

EXECUTE rdt.rdtAddMsg 264701, 10, '264701^GetUPCFail,',           'us_english', 838, 0, '264701 Get UPC data failed'
EXECUTE rdt.rdtAddMsg 264702, 10, '264702^NoUPCQtytoPack,',       'us_english', 838, 0, '264702 No UPC quantity to pack'

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE message_id BETWEEN 264701 AND 264750
