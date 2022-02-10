-- rdt_PTLCart_GetTask_JW
execute rdt.rdtDropMsg 103101, 103150

execute rdt.rdtAddMsg 103101, 10, '03101^No Task In Loc',   'us_english', 819
execute rdt.rdtAddMsg 103102, 10, '03102^No More SKU',      'us_english', 819

select * from rdt.rdtmsg (nolock) where message_id between 103101 and 103150