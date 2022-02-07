--rdt_1628ExtUpd03
execute rdt.rdtdropmsg 157401 , 157450

execute rdt.rdtAddMsg 157401, 10, '57401^InsertTL3 Fail',   'us_english', 1628

select * from rdt.rdtmsg (nolock) where message_id between 157401 AND 157450
