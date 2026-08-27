-- 279351 - 279400

rdt.rdtDropMsg 279351, 279400

execute rdt.rdtAddMsg 279351, 10, '279351 Cleanup Stale Pack Fail',         'us_english', 1864, 0, '249251 Cleanup Stale Pack Fail'
execute rdt.rdtAddMsg 279352, 10, '279352 Insert PackHeader Fail',          'us_english', 1864, 0, '249252 Insert PackHeader Fail'
execute rdt.rdtAddMsg 279353, 10, '279353 Update PackHeader Status Fail',   'us_english', 1864, 0, '249253 Update PackHeader Status Fail'

select * from rdt.rdtmsg (nolock) where message_id between 249251 and 249300