
exec rdt.rdtdropmsg 244501, 244550

execute rdt.rdtAddMsg 244501, 10, '244501UPDPackInfFail',    'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 244501 AND 244550
