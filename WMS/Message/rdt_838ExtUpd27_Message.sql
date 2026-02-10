
--rdt_838ExtUpd27.sql
--250501 - 250550


exec rdt.rdtdropmsg 250501, 239350

execute rdt.rdtAddMsg 250501, 10, '250501^OrdNotFound',       'us_english', 838, 0, '250501 Order not found'

select * from rdt.rdtmsg (nolock) where message_id between 250501 AND 250550