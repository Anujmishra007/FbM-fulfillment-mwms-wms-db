--rdt_1641ExtValidSP09
rdt.rdtDropMsg 145801 , 145850

execute rdt.rdtAddMsg 145801, 10, '45801^Pallet Closed',    'us_english', 1641
execute rdt.rdtAddMsg 145802, 10, '45802^Invalid Ctn Id',   'us_english', 1641
execute rdt.rdtAddMsg 145803, 10, '45803^SUSR1 Is Blank',   'us_english', 1641
execute rdt.rdtAddMsg 145804, 10, '45804^Ctn Id scan B4',   'us_english', 1641
execute rdt.rdtAddMsg 145805, 10, '45805^CtnIn OtherPlt',   'us_english', 1641
execute rdt.rdtAddMsg 145806, 10, '45806^Wrong Route',      'us_english', 1641
execute rdt.rdtAddMsg 145807, 10, '45807^Inv field name',   'us_english', 1641
execute rdt.rdtAddMsg 145808, 10, '45808^Inv field type',   'us_english', 1641
execute rdt.rdtAddMsg 145809, 10, '45809^Value required',   'us_english', 1641
execute rdt.rdtAddMsg 145810, 10, '45810^Inv route code',   'us_english', 1641

--WMS-11855
execute rdt.rdtAddMsg 145811, 10, '45811^Wrong Route',      'us_english', 1641

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 145801 AND 145850