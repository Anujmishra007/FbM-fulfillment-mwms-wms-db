--rdt_840DecodeSP02
exec rdt.rdtDropMsg 165801   , 165850	

execute rdt.rdtAddMsg 165801, 10, '165801InvalidBarcode',   'us_english', 840


select * from rdt.rdtmsg (nolock) where message_id between 133401 and 133450



