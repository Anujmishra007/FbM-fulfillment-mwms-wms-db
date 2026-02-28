--fcr-8974
-- 251201 - 251250

execute rdt.rdtDropMsg 251201, 251250

execute rdt.rdtAddMsg 251201, 10, '251201^OnlyInput1Value',     'us_english', 652, 0, '251201: Scan Container or ASN'
execute rdt.rdtAddMsg 251202, 10, '251202^InvalidContainer',    'us_english', 652, 0, '251202: Invalid Container'
execute rdt.rdtAddMsg 251203, 10, '251203^InvalidASN',          'us_english', 652, 0, '251203: Invalid ASN'

select * from rdt.rdtmsg (nolock) where message_id between 251201 and 251250