--rdt_869ExtUpd01_Message
--246851 - 246900

EXEC rdt.rdtdropmsg 246851 , 246900

EXECUTE rdt.rdtAddMsg 246851, 10, '246851^InsPackFail',      'us_english', 869, 0, '246851 Fail to insert temp pack table'
EXECUTE rdt.rdtAddMsg 246852, 10, '246852^UpdPackDelFail',   'us_english', 869, 0, '246852 Fail to update PackDetail'
EXECUTE rdt.rdtAddMsg 246853, 10, '246853^DelPackHderFail',  'us_english', 869, 0, '246853 Fail to delete PackHeader'
EXECUTE rdt.rdtAddMsg 246854, 10, '246854^CantCommitTran',   'us_english', 869, 0, '246854 Cannot commit tran'

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE message_id BETWEEN 246851 AND 246900

