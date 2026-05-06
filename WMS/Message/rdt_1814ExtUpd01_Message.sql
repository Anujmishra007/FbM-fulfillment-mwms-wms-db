--rdt_1814ExtUpd01
--execute rdt.rdtdropmsg 263301 - 263350
execute rdt.rdtDropMsg 263301, 263350

execute rdt.rdtAddMsg 263301, 10, '263301^Mobl not found',      'us_english', 1814, 0, '263301: Mobl not found'
execute rdt.rdtAddMsg 263302, 10, '263302^No Door Provided',    'us_english', 1814, 0, '263302: No Door Provided'
execute rdt.rdtAddMsg 263303, 10, '263303^Invalid Door',        'us_english', 1814, 0, '263303: Invalid Door'
execute rdt.rdtAddMsg 263304, 10, '263304^Upd taskdetail fail', 'us_english', 1814, 0, '263304: Upd taskdetail fail'

select * from rdt.rdtmsg (nolock) where message_id between 263301 and 263350
