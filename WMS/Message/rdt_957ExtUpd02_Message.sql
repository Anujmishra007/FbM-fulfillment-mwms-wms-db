--rdt_957ExtUpd02_Message
--FCR-770
exec rdt.rdtdropmsg 223451 , 223500

execute rdt.rdtAddMsg 223451, 10, '223451INS TLog2 Fail', 'us_english', 957
execute rdt.rdtAddMsg 223452, 10, '223452INS TLog2 Fail', 'us_english', 957

select * from rdt.rdtmsg (nolock) where message_id between 223451 AND 223500

