--rdt_LottableFormat_1841CheckNonBlank
exec rdt.rdtDropMsg 155801, 155850

execute rdt.rdtAddMsg 155801, 10, '155801^NeedLottable ',   'us_english', 1841
execute rdt.rdtAddMsg 155802, 10, '155802^Invalid date ',   'us_english', 1841

--WMS-16643
execute rdt.rdtAddMsg 155803, 10, '155803^Invalid Lot01',   'us_english', 1841
execute rdt.rdtAddMsg 155804, 10, '155804^Invalid Lot02',   'us_english', 1841
execute rdt.rdtAddMsg 155805, 10, '155805^MultipleLot01',   'us_english', 1841
execute rdt.rdtAddMsg 155806, 10, '155806^MultipleLot03',   'us_english', 1841
execute rdt.rdtAddMsg 155807, 10, '155807^MultipleLot06',   'us_english', 1841
execute rdt.rdtAddMsg 155808, 10, '155808^MultipleLot09',   'us_english', 1841
execute rdt.rdtAddMsg 155809, 10, '155809^MultipleLot12',   'us_english', 1841
execute rdt.rdtAddMsg 155810, 10, '155810^MultipleLot13',   'us_english', 1841
execute rdt.rdtAddMsg 155811, 10, '155811^MultipleLot14',   'us_english', 1841
execute rdt.rdtAddMsg 155812, 10, '155812RecQty<>UccQty',   'us_english', 1841
execute rdt.rdtAddMsg 155813, 10, '155813^Invalid Lot12',   'us_english', 1841
execute rdt.rdtAddMsg 155814, 10, '155814^Invalid Lot10',   'us_english', 1841

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE message_id BETWEEN 155801 and 155850



