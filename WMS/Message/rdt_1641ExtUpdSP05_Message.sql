--rdt_1641ExtUpdSP05
execute rdt.rdtDropMsg 145651 , 145700

execute rdt.rdtAddMsg 145651, 10, '45651^CtnIn OtherPlt', 'us_english', 1641
execute rdt.rdtAddMsg 145652, 10, '45652^Ctn Exists',     'us_english', 1641
execute rdt.rdtAddMsg 145653, 10, '45653^Ins Pallet Err', 'us_english', 1641
execute rdt.rdtAddMsg 145654, 10, '45654^Ins PLTDet Err', 'us_english', 1641
execute rdt.rdtAddMsg 145655, 10, '45655^PLTKeyNotFound', 'us_english', 1641
execute rdt.rdtAddMsg 145656, 10, '45656^No Ctn Scanned', 'us_english', 1641
execute rdt.rdtAddMsg 145657, 10, '45657^Upd PLTDet Err', 'us_english', 1641
execute rdt.rdtAddMsg 145658, 10, '45658^Close Plt Fail', 'us_english', 1641


execute rdt.rdtAddMsg 145659, 10, '45659^UpdPltDtFail', 'us_english', 1641
execute rdt.rdtAddMsg 145660, 10, '45660^UpdPltFail', 'us_english', 1641
execute rdt.rdtAddMsg 145661, 10, '45661^PltShipped', 'us_english', 1641

SELECT * FROM RDT.RDTMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 145651 AND 145700
