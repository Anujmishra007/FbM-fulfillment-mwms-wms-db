--nspTTMFC11
execute rdt.rdtdropmsg 275951, 276000

execute rdt.rdtAddMsg 275951, 10, '275951UpdTaskDtlFail',  'us_english', '1812'
execute rdt.rdtAddMsg 275952, 10, '275952SiblingLockFail', 'us_english', '1812'
execute rdt.rdtAddMsg 275953, 10, '275953UpdTaskDtlFail',  'us_english', '1812'

select * from rdt.rdtmsg (nolock) where message_id between 275951 and 276000