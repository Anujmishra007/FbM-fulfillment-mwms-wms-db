--rdt_1766ExtUpd01
exec rdt.rdtDropMsg 122901 , 122950

execute rdt.rdtAddMsg 122901, 10, '22901^ReleaseTaskErr',   'us_english', 1766
execute rdt.rdtAddMsg 122902, 10, '22902^ReleaseTaskErr',   'us_english', 1766
execute rdt.rdtAddMsg 122903, 10, '22903^Ins CCDtl Err',    'us_english', 1766

select * from rdt.rdtmsg (nolock) where message_id between 122901 and 122950



