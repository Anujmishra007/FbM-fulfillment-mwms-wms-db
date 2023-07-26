--rdt_1641ExtValidSP20
rdt.rdtDropMsg 202701 , 202750

execute rdt.rdtAddMsg 202701, 10, '202701Pallet Closed',    'us_english', 1641
execute rdt.rdtAddMsg 202702, 10, '202702Invalid Ctn Id',   'us_english', 1641
execute rdt.rdtAddMsg 202703, 10, '202703SUSR1 Is Blank',   'us_english', 1641
execute rdt.rdtAddMsg 202704, 10, '202704Ctn Id scan B4',   'us_english', 1641
execute rdt.rdtAddMsg 202705, 10, '202705CtnIn OtherPlt',   'us_english', 1641
execute rdt.rdtAddMsg 202706, 10, '202706Wrong Route',      'us_english', 1641
execute rdt.rdtAddMsg 202707, 10, '202707Inv field name',   'us_english', 1641
execute rdt.rdtAddMsg 202708, 10, '202708Inv field type',   'us_english', 1641
execute rdt.rdtAddMsg 202709, 10, '202709Value required',   'us_english', 1641
execute rdt.rdtAddMsg 202710, 10, '202710Inv route code',   'us_english', 1641
execute rdt.rdtAddMsg 202711, 10, '202711Wrong Route',      'us_english', 1641
execute rdt.rdtAddMsg 202712, 10, '202712Plt Mix Orders',   'us_english', 1641
execute rdt.rdtAddMsg 202713, 10, '202713ExceedOrders',   'us_english', 1641

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 202701 AND 202750