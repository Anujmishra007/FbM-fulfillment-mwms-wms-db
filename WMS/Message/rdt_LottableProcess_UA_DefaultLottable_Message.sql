--rdt_LottableProcess_UA_DefaultLottable
execute rdt.rdtdropmsg 135551 , 135600

execute rdt.rdtAddMsg 135551, 10, '35551^Need Value',       'us_english', 607
execute rdt.rdtAddMsg 135552, 10, '35552^ValueNotMatch',    'us_english', 607
execute rdt.rdtAddMsg 135553, 10, '35553^ValueNoExists',    'us_english', 607

select * from rdt.rdtmsg (nolock) where message_id between 135551 AND 135600
