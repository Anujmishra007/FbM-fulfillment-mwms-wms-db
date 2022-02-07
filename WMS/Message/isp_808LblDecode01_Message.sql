--isp_808LblDecode01
execute rdt.rdtdropmsg 171051 , 171100

execute rdt.rdtAddMsg 171051, 10, '171051 Lottable04req',    'us_english', 808

select * from rdt.rdtmsg (nolock) where message_id between 171051 and 171100