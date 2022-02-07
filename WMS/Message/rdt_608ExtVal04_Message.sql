--rdt_608ExtVal04
execute rdt.rdtdropmsg 135501 , 135550

execute rdt.rdtAddMsg 135501, 10, '35501^NOT ALL QTY',   'us_english', 608
execute rdt.rdtAddMsg 135502, 10, '35502^RECEIVED',      'us_english', 608

select * from rdt.rdtmsg (nolock) where message_id between 135501 AND 135550
