--rdt_1764ExtUpd23
--242101 - 242150

execute rdt.rdtdropmsg 242101, 242150


execute rdt.rdtAddMsg 242101, 10, '242101^UpdTaskFail', 'us_english', 1764

select * from rdt.rdtmsg WITH (NOLOCK) WHERE message_id between 242101 and 242150