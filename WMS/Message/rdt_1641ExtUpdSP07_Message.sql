--rdt_1641ExtUpdSP07
execute rdt.rdtDropMsg 148151 , 148200

execute rdt.rdtAddMsg 148151, 10, '48151^CtnIn OtherPlt', 'us_english', 1641
execute rdt.rdtAddMsg 148152, 10, '48152^Ctn Exists',     'us_english', 1641
execute rdt.rdtAddMsg 148153, 10, '48153^Ins Pallet Err', 'us_english', 1641
execute rdt.rdtAddMsg 148154, 10, '48154^Ins PLTDet Err', 'us_english', 1641
execute rdt.rdtAddMsg 148155, 10, '48155^PLTKeyNotFound', 'us_english', 1641
execute rdt.rdtAddMsg 148156, 10, '48156^No Ctn Scanned', 'us_english', 1641
execute rdt.rdtAddMsg 148157, 10, '48157^Upd PLTDet Err', 'us_english', 1641
execute rdt.rdtAddMsg 148158, 10, '48158^Close Plt Fail', 'us_english', 1641
execute rdt.rdtAddMsg 148159, 10, '48159^Upd PLTDT Fail', 'us_english', 1641
execute rdt.rdtAddMsg 148160, 10, '48160^Upd PLTDT Fail', 'us_english', 1641
execute rdt.rdtAddMsg 148161, 10, '48161^PltShipped', 'us_english', 1641

SELECT * FROM RDT.RDTMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 148151 AND 148200
