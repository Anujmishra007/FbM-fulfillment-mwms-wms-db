--rdt_1812GetTask13
execute rdt.rdtdropmsg 277151, 277200

execute rdt.rdtAddMsg 277151, 10, '277151NoTask.ClosePL', 'us_english', 1812
execute rdt.rdtAddMsg 277152, 10, '277152No more task  ', 'us_english', 1812
execute rdt.rdtAddMsg 277153, 10, '277153UpdTaskDtlFail', 'us_english', 1812

select * from rdt.rdtmsg (nolock) where message_id between 277151 and 277200
