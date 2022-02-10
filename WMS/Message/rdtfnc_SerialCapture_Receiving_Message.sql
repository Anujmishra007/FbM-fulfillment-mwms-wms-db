--rdtfnc_OrderTrackNoPicking
--execute rdt.rdtdropmsg 72641 - 72690

execute rdt.rdtAddMsg '72641', 10, '72641^ASN req', 'us_english'
execute rdt.rdtAddMsg '72642', 10, '72642^Invalid ASN', 'us_english'
execute rdt.rdtAddMsg '72643', 10, '72643^ASN & FAC DIFF', 'us_english'
execute rdt.rdtAddMsg '72644', 10, '72644^ASN DIFF STORER', 'us_english'
execute rdt.rdtAddMsg '72645', 10, '72645^ASN CLOSE', 'us_english'
execute rdt.rdtAddMsg '72646', 10, '72646^LOC Req', 'us_english'
execute rdt.rdtAddMsg '72647', 10, '72647^Inv LOC', 'us_english'
execute rdt.rdtAddMsg '72648', 10, '72648^Inv Facility', 'us_english'
execute rdt.rdtAddMsg '72649', 10, '72649^Option Req', 'us_english'
execute rdt.rdtAddMsg '72650', 10, '72650^Inv Option', 'us_english'
execute rdt.rdtAddMsg '72651', 10, '72651^Barcode Req', 'us_english'
execute rdt.rdtAddMsg '72652', 10, '72652^Barcode Exist', 'us_english'
execute rdt.rdtAddMsg '72653', 10, '72653^Barcode Scanned', 'us_english'
execute rdt.rdtAddMsg '72654', 10, '72654^Barcode Exist', 'us_english'
execute rdt.rdtAddMsg '72655', 10, '72655^Barcode Scanned', 'us_english'
execute rdt.rdtAddMsg '72656', 10, '72656^Barcode Exist', 'us_english'
execute rdt.rdtAddMsg '72657', 10, '72657^Barcode Scanned', 'us_english'
execute rdt.rdtAddMsg '72658', 10, '72658^Inv Packkey', 'us_english'
execute rdt.rdtAddMsg '72659', 10, '72659^UpdPackCfgFailed', 'us_english'
execute rdt.rdtAddMsg '72660', 10, '72660^No PackCfg', 'us_english'
execute rdt.rdtAddMsg '72661', 10, '72661^Barcode Scanned', 'us_english'
execute rdt.rdtAddMsg '72662', 10, '72662^Barcode Scanned', 'us_english'
execute rdt.rdtAddMsg '72663', 10, '72663^Barcode Scanned', 'us_english'
execute rdt.rdtAddMsg '72664', 10, '72664^Barcode Scanned', 'us_english'
execute rdt.rdtAddMsg '72665', 10, '72665^Barcode Scanned', 'us_english'
execute rdt.rdtAddMsg '72666', 10, '72666^Barcode Scanned', 'us_english'
execute rdt.rdtAddMsg '72667', 10, '72667^Inv Barcode', 'us_english'
execute rdt.rdtAddMsg '72668', 10, '72668^Inv Barcode', 'us_english'
execute rdt.rdtAddMsg '72669', 10, '72669^Inv Barcode', 'us_english'




select * from rdt.rdtmsg (nolock) where message_id between 72641 and 72690
