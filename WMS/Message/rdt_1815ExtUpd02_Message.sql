--rdt_1815ExtUpd02
--execute rdt.rdtdropmsg 263351 - 263400
execute rdt.rdtDropMsg 263351, 263400

execute rdt.rdtAddMsg 263351, 10, '263351^FromLocEmpty',    'us_english', 1815, 0, '263351: FromLoc is empty'
execute rdt.rdtAddMsg 263352, 10, '263352^FromIDEmpty',     'us_english', 1815, 0, '263352: FromID is empty'
execute rdt.rdtAddMsg 263353, 10, '263353^UpdMBOLFail',     'us_english', 1815, 0, '263353: Update MBOL Fail'
execute rdt.rdtAddMsg 263354, 10, '263354^UpdLOCFail',      'us_english', 1815, 0, '263354: Update LOC Fail'
execute rdt.rdtAddMsg 263355, 10, '263355^OrderIsEmpty',    'us_english', 1815, 0, '263355: OrderKey is empty'
execute rdt.rdtAddMsg 263356, 10, '263356^MBOLIsEmpty',     'us_english', 1815, 0, '263356: MBOLKEY is empty'

select * from rdt.rdtmsg (nolock) where message_id between 263351 and 263400
