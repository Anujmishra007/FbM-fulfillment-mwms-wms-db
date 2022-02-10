-- rdt_731ExtVal01
execute rdt.rdtDropMsg 99151 , 99200

execute rdt.rdtAddMsg 99151, 10, '99151^COUNTED QTY',    'us_english'
execute rdt.rdtAddMsg 99152, 10, '99152^LESS THAN',      'us_english'
execute rdt.rdtAddMsg 99153, 10, '99153^SYSTEM QTY',     'us_english'
execute rdt.rdtAddMsg 99154, 10, '99154^COUNTED QTY',    'us_english'
execute rdt.rdtAddMsg 99155, 10, '99155^MORE THAN',      'us_english'
execute rdt.rdtAddMsg 99156, 10, '99156^SYSTEM QTY',     'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 99151 and 99200