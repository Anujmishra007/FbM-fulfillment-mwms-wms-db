
exec rdt.rdtdropmsg 240901, 240950

execute rdt.rdtAddMsg 240901, 10, '240901UPD PickDetailFail', 'us_english', 838
execute rdt.rdtAddMsg 240902, 10, '240902UPD PackDetailFail', 'us_english', 838

select * from rdt.rdtmsg (nolock) where message_id between 240901 AND 240950
