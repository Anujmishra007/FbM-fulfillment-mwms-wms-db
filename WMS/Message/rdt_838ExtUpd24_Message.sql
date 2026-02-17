
--rdt_838ExtUpd24.sql
--239301 - 239350

exec rdt.rdtdropmsg 239301, 239350

execute rdt.rdtAddMsg 239301, 10, '239301PackClosed',       'us_english', 838, 0, '239301 PackHeader Closed'
execute rdt.rdtAddMsg 239302, 10, '239302UpdPackSNFail',    'us_english', 838, 0, '239302 Update PackSerialNo Failed'
execute rdt.rdtAddMsg 239303, 10, '239303UpdSNFail',        'us_english', 838, 0, '239303 Update SerialNo Failed'

select * from rdt.rdtmsg (nolock) where message_id between 239301 AND 239350