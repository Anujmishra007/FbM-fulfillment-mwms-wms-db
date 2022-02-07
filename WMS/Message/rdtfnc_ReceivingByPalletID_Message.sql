--rdtfnc_ReceivingByPalletID
execute rdt.rdtdropmsg 165501 , 165550	

execute rdt.rdtAddMsg 165501, 10, '65501^Invalid RefNo',    'us_english', 647
execute rdt.rdtAddMsg 165502, 10, '65502^RefNo NotInASN',   'us_english', 647
execute rdt.rdtAddMsg 165503, 10, '65503^RefNo MultiASN',   'us_english', 647
execute rdt.rdtAddMsg 165504, 10, '65504^Need ASN or PO',   'us_english', 647
execute rdt.rdtAddMsg 165505, 10, '65505^ASN&PONotExist',   'us_english', 647
execute rdt.rdtAddMsg 165506, 10, '65506^INV FROMLOC',      'us_english', 647
execute rdt.rdtAddMsg 165507, 10, '65507^PO Not Exist',     'us_english', 647
execute rdt.rdtAddMsg 165508, 10, '65508^PO Not In ASN',    'us_english', 647
execute rdt.rdtAddMsg 165509, 10, '65509^ASN not exist',    'us_english', 647
execute rdt.rdtAddMsg 165510, 10, '65510^IMultiPO In ASN',  'us_english', 647
execute rdt.rdtAddMsg 165511, 10, '65511^PO not exist',     'us_english', 647
execute rdt.rdtAddMsg 165512, 10, '65512^MultiASN in PO',   'us_english', 647
execute rdt.rdtAddMsg 165513, 10, '65513^Diff facility',    'us_english', 647
execute rdt.rdtAddMsg 165514, 10, '65514^NotInStorerGrp',   'us_english', 647
execute rdt.rdtAddMsg 165515, 10, '65515^Diff storer',      'us_english', 647
execute rdt.rdtAddMsg 165516, 10, '65516^ASN is closed',    'us_english', 647
execute rdt.rdtAddMsg 165517, 10, '65517^ASN cancelled',    'us_english', 647
execute rdt.rdtAddMsg 165518, 10, '65518^Need LOC',         'us_english', 647
execute rdt.rdtAddMsg 165519, 10, '65519^Invalid LOC',      'us_english', 647
execute rdt.rdtAddMsg 165520, 10, '65520^Diff facility',    'us_english', 647
execute rdt.rdtAddMsg 165521, 10, '65521^SKU needed',       'us_english', 647
execute rdt.rdtAddMsg 165522, 10, '65522^Invalid SKU',      'us_english', 647
execute rdt.rdtAddMsg 165523, 10, '65523^MultiSKUBarcod',   'us_english', 647
execute rdt.rdtAddMsg 165524, 10, '65524^SKU Not in ASN',   'us_english', 647
execute rdt.rdtAddMsg 165525, 10, '65525^Invalid QTY',      'us_english', 647
execute rdt.rdtAddMsg 165526, 10, '65526^Invalid Format',   'us_english', 647
execute rdt.rdtAddMsg 165527, 10, '65527^Duplicate ID',     'us_english', 647


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 165501 AND 165550