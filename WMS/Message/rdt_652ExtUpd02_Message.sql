--252701 - 252750


execute rdt.rdtDropMsg 252701, 252750

execute rdt.rdtAddMsg 252701, 10, '252701^InsTranlog2Fail ', 'us_english', 652, 0, '252701 Ins TransmitLog2 Fail'
execute rdt.rdtAddMsg 252702, 10, '252702^InsTranlog2Fail ', 'us_english', 652, 0, '252702 Ins TransmitLog2 Fail'
execute rdt.rdtAddMsg 252703, 10, '252703^InsTranlog2Fail ', 'us_english', 652, 0, '252703 Ins TransmitLog2 Fail'

select * from rdt.rdtmsg(nolock) where message_id between 252701 and 252750