--rdt_1764ExtUpd25
--252151 - 252200


execute rdt.rdtdropmsg 252151, 252200


execute rdt.rdtAddMsg 252151, 10, '252151^UpdTaskFail', 'us_english', 1764
execute rdt.rdtAddMsg 252152, 10, '252152^UpdTaskFail', 'us_english', 1764
execute rdt.rdtAddMsg 252153, 10, '252153^UpdTaskFail', 'us_english', 1764

select * from rdt.rdtmsg WITH (NOLOCK) WHERE message_id between 252151 and 252200