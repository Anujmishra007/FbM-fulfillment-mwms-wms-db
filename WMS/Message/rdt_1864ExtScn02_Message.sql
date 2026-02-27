-- rdt_1864ExtScn01
--249251 - 249300

rdt.rdtDropMsg 249251, 249300

execute rdt.rdtAddMsg 249251, 10, '249251 OPTION REQUIRED',     'us_english', 1864, 0, '249251 Option is required'
execute rdt.rdtAddMsg 249252, 10, '249252 INVALID OPTION',      'us_english', 1864, 0, '249252 Invalid option'
execute rdt.rdtAddMsg 249253, 10, '249253 RealloFail',          'us_english', 1864, 0, '249253 Allocation fails'

select * from rdt.rdtmsg (nolock) where message_id between 249251 and 249300