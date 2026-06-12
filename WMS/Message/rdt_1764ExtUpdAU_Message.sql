-- 267551 - 267600

execute rdt.rdtdropmsg 267551, 267600


execute rdt.rdtAddMsg 267551, 10, '267551^UpdTaskFail',    'us_english', 1764
execute rdt.rdtAddMsg 267552, 10, '267552^UpdTaskFail',    'us_english', 1764
execute rdt.rdtAddMsg 267553, 10, '267553^UpdTaskFail',    'us_english', 1764
execute rdt.rdtAddMsg 267554, 10, '267554^UpdTaskFail',    'us_english', 1764
execute rdt.rdtAddMsg 267555, 10, '267555^UpdPickDtlFail', 'us_english', 1764
execute rdt.rdtAddMsg 267556, 10, '267556^UpdTaskDtlFail', 'us_english', 1764
execute rdt.rdtAddMsg 267557, 10, '267557^UpdTaskDtlFail', 'us_english', 1764
execute rdt.rdtAddMsg 267558, 10, '267558^UpdTaskDtlFail', 'us_english', 1764

select * from rdt.rdtmsg WITH (NOLOCK) WHERE message_id between 267551 and 267600