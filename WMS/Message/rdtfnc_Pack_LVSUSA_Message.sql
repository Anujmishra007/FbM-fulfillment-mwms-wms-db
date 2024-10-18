
--FCR-946
exec rdt.rdtdropmsg 226451 , 226500

execute rdt.rdtAddMsg 226451, 10, '226451NeedCart', 'us_english', 993, 0, '226451 Carton No. Required'
execute rdt.rdtAddMsg 226452, 10, '226452CartNotExist', 'us_english', 993, 0, '226452 Carton Not Exist'
execute rdt.rdtAddMsg 226453, 10, '226453ReopenPKHFail', 'us_english', 993, 0, '226453 Failed to Reopen PKH'


select * from rdt.rdtmsg (nolock) where message_id between 226451 AND 226500