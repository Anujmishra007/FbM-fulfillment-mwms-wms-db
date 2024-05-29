-- rdt_1764ExtUpd18
exec rdt.rdtdropmsg 214801, 214850

execute rdt.rdtAddMsg 214801, 10, '214801UpdPKTaskFail', 'us_english', 1764

select * from rdt.rdtmsg (nolock) where message_id between 214801 and 214850
