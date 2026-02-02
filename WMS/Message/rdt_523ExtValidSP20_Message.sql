--rdt_523ExtValidSP20
--257151 - 257200


execute rdt.rdtdropmsg 257151, 257200

execute rdt.rdtAddMsg 257151, 10, '257151 IDRequired',  'us_english', 523
execute rdt.rdtAddMsg 257152, 10, '257152 NotAllowPA',      'us_english', 523, 0, '257152 Not allow to putaway in this loc type'
execute rdt.rdtAddMsg 257153, 10, '257153 ToLocNotLoseID',  'us_english', 523, 0, '257153 ToLoc must be lose ID'

select * from rdt.rdtmsg with (nolock) where message_id between 257151 and 257200