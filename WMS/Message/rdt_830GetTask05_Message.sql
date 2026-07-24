--rdt_830GetTask05
--execute rdt.rdtdropmsg 275351, 275400
execute rdt.rdtdropmsg 275351, 275400

execute rdt.rdtAddMsg 275351, 10, '275351 No More Task', 'us_english', 830
execute rdt.rdtAddMsg 275352, 10, '275352 No More Task', 'us_english', 830

select * from rdt.rdtmsg (nolock) where message_id between 275351 and 275400
