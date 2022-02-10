--rdt_1580RcptCfm08
execute rdt.rdtDropMsg 127851 , 127900

execute rdt.rdtAddMsg 127851, 10, '27851^SKU Not In L02',   'us_english', 1580
execute rdt.rdtAddMsg 127852, 10, '27852^SKU Multi Lot',    'us_english', 1580


select * from rdt.rdtmsg (nolock) where message_id between 127851 and 127900