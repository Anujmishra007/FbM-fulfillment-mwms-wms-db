--rdt_855ExtValid01
exec rdt.rdtDropMsg 117001 , 117050

execute rdt.rdtAddMsg 117001, 10, '17001^No Lbl Printer',     'us_english', 855
execute rdt.rdtAddMsg 117002, 10, '17002^No A4 Printer',      'us_english', 855

select * from rdt.rdtmsg (nolock) where message_id between 117001 and 117050



