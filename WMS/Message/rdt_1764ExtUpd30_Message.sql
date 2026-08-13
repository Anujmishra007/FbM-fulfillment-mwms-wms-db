--rdt_1764ExtUpd30
--277951 - 278000


execute rdt.rdtdropmsg 277951, 278000

execute rdt.rdtAddMsg 277951, 10, '277951^ReleaseFCPFail', 'us_english', 1764, 0, '277951: Failed to release FCP pick tasks'


select * from rdt.rdtmsg WITH (NOLOCK) WHERE message_id between 277951 and 278000
