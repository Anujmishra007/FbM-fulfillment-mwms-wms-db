-- 279351 - 279400

rdt.rdtDropMsg 279351, 279400

execute rdt.rdtAddMsg 279351, 10, '279351 Cleanup Stale PackDetail Fail',   'us_english', 1864, 0, '279351 Cleanup Stale PackDetail Fail'
execute rdt.rdtAddMsg 279352, 10, '279352 Cleanup Stale PackHeader Fail',   'us_english', 1864, 0, '279352 Cleanup Stale PackHeader Fail'
execute rdt.rdtAddMsg 279353, 10, '279353 Insert PackHeader Fail',          'us_english', 1864, 0, '279353 Insert PackHeader Fail'
execute rdt.rdtAddMsg 279354, 10, '279354 Update PackHeader Status Fail',   'us_english', 1864, 0, '279354 Update PackHeader Status Fail'
execute rdt.rdtAddMsg 279355, 10, '279355 Insert PackDetail Fail',          'us_english', 1864, 0, '279355 Insert PackDetail Fail'

select * from rdt.rdtmsg (nolock) where message_id between 279351 and 279400

