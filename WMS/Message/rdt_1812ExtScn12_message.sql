--rdt_1812ExtScn12
execute rdt.rdtdropmsg 276001, 276050

execute rdt.rdtAddMsg 276001, 10, '276001PickDetailNotFound', 'us_english', '1812'
execute rdt.rdtAddMsg 276002, 10, '276002GenDropIDFail',      'us_english', '1812'
execute rdt.rdtAddMsg 276003, 10, '276003GenDropIDFail',      'us_english', '1812'
execute rdt.rdtAddMsg 276004, 10, '276004UpdateMobrecFail',   'us_english', '1812'
execute rdt.rdtAddMsg 276005, 10, '276005IDNotMatch',         'us_english', '1812'

select * from rdt.rdtmsg (nolock) where message_id between 276001 and 276050
