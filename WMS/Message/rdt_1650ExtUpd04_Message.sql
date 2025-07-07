--FCR-1606
execute rdt.rdtdropmsg 231051, 231100

execute rdt.rdtAddMsg 231051, 10, '231051ExtUpd05Miss',     'us_english', 1650, 0, '231051 1650ExtUpd05 is Missing'
execute rdt.rdtAddMsg 231052, 10, '231052LoseTruckFailFail',   'us_english', 1650, 0, '231052 Drop Pallet Fail'
execute rdt.rdtAddMsg 231053, 10, '231053UpdatePltStatusFailed',   'us_english', 1650, 0, '231053 Update PltStatus fail'

select * from rdt.rdtmsg WITH(NOLOCK) where message_id between 231051 and 231100

