--rdt_625ExtVal01
exec rdt.rdtDropMsg 132851 , 132900

execute rdt.rdtaddmsg 132851, 10, '32851^Invalid UPC',       'us_english'
execute rdt.rdtaddmsg 132852, 10, '32852^Invalid Qty',       'us_english'
execute rdt.rdtaddmsg 132853, 10, '32853^Qty Exceed',        'us_english'
execute rdt.rdtaddmsg 132854, 10, '32854^InvalidSKU/UPC',    'us_english'
execute rdt.rdtaddmsg 132855, 10, '32855^InvalidSKU/UPC',    'us_english'


select * from rdt.rdtmsg with (nolock) where message_id between 132851 and 132900