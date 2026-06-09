-- 269251 - 269300

execute rdt.rdtdropmsg 269251, 269300

execute rdt.rdtAddMsg 269251, 10, '269251^cant suggest loc', 'us_english', 1764

select * from rdt.rdtmsg WITH (NOLOCK) where message_id between 269251 and 269300