-- rdt_629ExtVal01
execute rdt.rdtDropMsg 125851 , 125900

execute rdt.rdtAddMsg 125851, 10, '25851^QtyAvl<>Qty2Mv',     'us_english', 629



select * from rdt.rdtmsg (nolock) where message_id between 125851 and 125900
