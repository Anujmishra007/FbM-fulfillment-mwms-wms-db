--rdtfnc_DataCapture9
exec rdt.rdtDropMsg 117151 , 117200

execute rdt.rdtaddmsg 117151, 10, '17151^LOC needed',       'us_english'
execute rdt.rdtaddmsg 117152, 10, '17152^Invalid LOC',      'us_english'
execute rdt.rdtaddmsg 117153, 10, '17153^Diff facility',    'us_english'
execute rdt.rdtaddmsg 117154, 10, '17154^ID Req',           'us_english'
execute rdt.rdtaddmsg 117155, 10, '17155^Invalid Format',   'us_english'
execute rdt.rdtaddmsg 117156, 10, '17156^Need UCC',         'us_english'
execute rdt.rdtaddmsg 117157, 10, '17157^Invalid Format',   'us_english'
execute rdt.rdtaddmsg 117158, 10, '17158^Duplicate UCC',    'us_english'
execute rdt.rdtaddmsg 117159, 10, '17159^Invalid SKU',      'us_english'
execute rdt.rdtaddmsg 117160, 10, '17160^SameBarcodeSKU',   'us_english'
execute rdt.rdtaddmsg 117161, 10, '17161^Invalid Qty',      'us_english'
execute rdt.rdtaddmsg 117162, 10, '17162^Invalid Qty',      'us_english'


select * from rdt.rdtmsg with (nolock) where message_id between 117151 and 117200