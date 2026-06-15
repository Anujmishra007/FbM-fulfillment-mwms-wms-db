-- 269851 - 269900

EXECUTE rdt.rdtDropMsg 269851, 269900

EXECUTE rdt.rdtAddMsg 269851, 10, '269851^GetUPCFail',        'us_english', 838, 0, '269851 Get UPC data failed'
EXECUTE rdt.rdtAddMsg 269852, 10, '269852^NoUPCQtytoPack',    'us_english', 838, 0, '269852 No UPC quantity to pack'
EXECUTE rdt.rdtAddMsg 269853, 10, '269853^GetUPCFail',        'us_english', 838, 0, '269853 Get UPC data failed'
EXECUTE rdt.rdtAddMsg 269854, 10, '269854^NoUPCQtytoPack',    'us_english', 838, 0, '269854 No UPC quantity to pack'
EXECUTE rdt.rdtAddMsg 269855, 10, '269855^GetUPCFail',        'us_english', 838, 0, '269855 Get UPC data failed'
EXECUTE rdt.rdtAddMsg 269856, 10, '269856^NoUPCQtytoPack',    'us_english', 838, 0, '269856 No UPC quantity to pack'

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE message_id BETWEEN 269851 AND 269900
