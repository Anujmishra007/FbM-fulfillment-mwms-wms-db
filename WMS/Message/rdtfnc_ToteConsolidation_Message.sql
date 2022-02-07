-- rdtfnc_ToteConsolidation
-- execute rdt.rdtDropMsg 70266 - 70315
-- execute rdt.rdtDropMsg 50601 - 50650


execute rdt.rdtAddmsg 70266, 10, '70266^ToteNo Req',     'us_english'
execute rdt.rdtAddmsg 70267, 10, '70267^Invalid Tote',   'us_english'
execute rdt.rdtAddmsg 70268, 10, '70268^Option Req',     'us_english'
execute rdt.rdtAddmsg 70269, 10, '70269^Invalid Option', 'us_english'
execute rdt.rdtAddmsg 70270, 10, '70270^SKU Req',        'us_english'
execute rdt.rdtAddmsg 70271, 10, '70271^Invalid QTY',    'us_english'
execute rdt.rdtAddmsg 70272, 10, '70272^QTY needed',     'us_english'
execute rdt.rdtAddmsg 70273, 10, '70273^QTY needed',     'us_english'
execute rdt.rdtAddmsg 70274, 10, '70274^QTYMV > QTYAVL', 'us_english'
execute rdt.rdtAddmsg 70275, 10, '70275^Invalid QTY',    'us_english'
execute rdt.rdtAddmsg 70276, 10, '70276^ToTote Req',     'us_english'
execute rdt.rdtAddmsg 70277, 10, '70277^NotSameStore',   'us_english'
execute rdt.rdtAddmsg 70278, 10, '70278^ToTote Req',     'us_english'
execute rdt.rdtAddmsg 70279, 10, '70279^NotSameStore',   'us_english'
execute rdt.rdtAddmsg 70280, 10, '70280^Option Req',     'us_english'
execute rdt.rdtAddmsg 70281, 10, '70281^Invalid Option', 'us_english'
execute rdt.rdtAddmsg 70282, 10, '70282^ToteNo Req',     'us_english'
execute rdt.rdtAddmsg 70283, 10, '70283^Wrong Tote',     'us_english'
execute rdt.rdtAddmsg 70284, 10, '70284^Manifest Print', 'us_english'
execute rdt.rdtAddmsg 70285, 10, '70285^Tote Closed',    'us_english'
execute rdt.rdtAddmsg 70286, 10, '70286^DoNotMixLoad',   'us_english'
execute rdt.rdtAddmsg 70287, 10, '70287^Invalid SKU',    'us_english'
execute rdt.rdtAddmsg 70288, 10, '70288^Invalid SKU',    'us_english'
execute rdt.rdtAddmsg 70289, 10, '70289^Inv Tote Conso', 'us_english'
execute rdt.rdtAddmsg 70290, 10, '70290^Tote Shipped',   'us_english'
execute rdt.rdtAddmsg 70291, 10, '70291^Invalid SKU',    'us_english'
execute rdt.rdtAddmsg 70292, 10, '70292^SameBarCodeSKU', 'us_english'

-- (ChewKP01)
execute rdt.rdtAddmsg 70293, 10, '70293^DoNotMixOrder', 'us_english'
execute rdt.rdtAddmsg 70294, 10, '70294^DoNotMixOrder', 'us_english'

-- (ChewKP02)
execute rdt.rdtAddmsg 70295, 10, '70295^Option req', 'us_english'
execute rdt.rdtAddmsg 70296, 10, '70296^Invalid Option', 'us_english'
execute rdt.rdtAddmsg 70297, 10, '70297^NoLabelPrinter', 'us_english'
execute rdt.rdtAddmsg 70298, 10, '70298^DWNOTSetup', 'us_english'
execute rdt.rdtAddmsg 70299, 10, '70299^TgetDBNotSet', 'us_english'
execute rdt.rdtAddmsg 70300, 10, '70300^InsertPRTFail', 'us_english'
execute rdt.rdtAddmsg 70301, 10, '70301^UpdDropIdFailed', 'us_english'
execute rdt.rdtAddmsg 70302, 10, '70302^NoPaperPrinter', 'us_english'
execute rdt.rdtAddmsg 70303, 10, '70303^DWNOTSetup', 'us_english'
execute rdt.rdtAddmsg 70304, 10, '70304^TgetDBNotSet', 'us_english'
execute rdt.rdtAddmsg 70305, 10, '70305^InsertPRTFail', 'us_english'
execute rdt.rdtAddmsg 70306, 10, '70306^UpdDropIdFailed', 'us_english'

-- SOS260282
execute rdt.rdtAddmsg 70307, 10, '70307^INV TOTENO LEN', 'us_english'
execute rdt.rdtAddmsg 70308, 10, '70308^INV TOTE NO',    'us_english'
execute rdt.rdtAddmsg 70309, 10, '70309^INV TOTENO LEN', 'us_english'
execute rdt.rdtAddmsg 70310, 10, '70310^INV TOTE NO',    'us_english'
execute rdt.rdtAddmsg 70311, 10, '70311^INV TOTENO LEN', 'us_english'
execute rdt.rdtAddmsg 70312, 10, '70312^INV TOTE NO',    'us_english'

-- SOS319877
execute rdt.rdtAddmsg 70313, 10, '70313^SKU req',        'us_english'
execute rdt.rdtAddmsg 70314, 10, '70314^Invalid UOM',    'us_english'
execute rdt.rdtAddmsg 70315, 10, '70315^NO STORE FOUND', 'us_english'
execute rdt.rdtAddmsg 50601, 10, '50601^NO LOC FOUND',   'us_english'
execute rdt.rdtAddmsg 50602, 10, '50602^LOC Required',   'us_english'
execute rdt.rdtAddmsg 50603, 10, '50603^Invalid TO LOC', 'us_english'
execute rdt.rdtAddmsg 50604, 10, '50604^UpdStr2LocFail', 'us_english'
execute rdt.rdtAddmsg 50605, 10, '50605^SKU & LOC Req',  'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 70266 and 70315