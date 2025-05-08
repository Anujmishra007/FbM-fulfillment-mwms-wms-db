-- rdt_1764ExtUpd21
-- UWP-30476
exec rdt.rdtdropmsg 233651, 233700

execute rdt.rdtAddMsg 233651, 10, '233651UpdPKTaskFail',       'us_english', 1764

select * from rdt.rdtmsg (nolock) where message_id between 233651 and 233700
