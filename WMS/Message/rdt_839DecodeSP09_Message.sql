--rdt_839DecodeSP09
--FCR-9040
EXECUTE rdt.rdtdropmsg 255451 , 255500

EXECUTE rdt.rdtAddMsg 255451, 10, '255451 InvBarcode',         'us_english', 839, 0, '255451 Invalid barcode format'
EXECUTE rdt.rdtAddMsg 255452, 10, '255452 InvUCC',             'us_english', 839, 0, '255452 Invalid UCC'
EXECUTE rdt.rdtAddMsg 255453, 10, '255453 LocNotMatch',        'us_english', 839, 0, '255453 Loc does not match'
EXECUTE rdt.rdtAddMsg 255454, 10, '255454 SKUNotMatch',        'us_english', 839, 0, '255454 SKU does not match'
EXECUTE rdt.rdtAddMsg 255455, 10, '255455 LotNotMatch',        'us_english', 839, 0, '255455 LOT does not match'
EXECUTE rdt.rdtAddMsg 255456, 10, '255456 QtyNotMatch',        'us_english', 839, 0, '255456 Qty does not match'
EXECUTE rdt.rdtAddMsg 255457, 10, '255457 UCCAllocated',       'us_english', 839, 0, '255457 Scanned UCC is not available'
EXECUTE rdt.rdtAddMsg 255458, 10, '255458 InvSKU',             'us_english', 839, 0, '255458 BUSR5 or BUSR6 does not match'
EXECUTE rdt.rdtAddMsg 255459, 10, '255459 InvSerialNo',        'us_english', 839, 0, '255459 Invalid Serial Number'
EXECUTE rdt.rdtAddMsg 255460, 10, '255460 InvUCC',             'us_english', 839, 0, '255460 Invalid UCC'
EXECUTE rdt.rdtAddMsg 255461, 10, '255461 UCCAllocated',       'us_english', 839, 0, '255461 Scanned UCC is not available'
EXECUTE rdt.rdtAddMsg 255462, 10, '255462 LocNotMatch',        'us_english', 839, 0, '255462 Loc does not match'
EXECUTE rdt.rdtAddMsg 255463, 10, '255463 SKUNotMatch',        'us_english', 839, 0, '255463 SKU does not match'
EXECUTE rdt.rdtAddMsg 255464, 10, '255464 QtyNotMatch',        'us_english', 839, 0, '255464 Qty does not match'
EXECUTE rdt.rdtAddMsg 255465, 10, '255465 Lottable01NotMatch', 'us_english', 839, 0, '255465 Lottable01 does not match'
EXECUTE rdt.rdtAddMsg 255466, 10, '255466 MultipleSKU',        'us_english', 839, 0, '255466 Multi SKU UCC'
EXECUTE rdt.rdtAddMsg 255467, 10, '255467 MultipleSKU',        'us_english', 839, 0, '255467 Multi SKU UCC'
EXECUTE rdt.rdtAddMsg 255468, 10, '255468 InvSerialNo',        'us_english', 839, 0, '255468 SerialNo does not exist in MasterSerialNo'
EXECUTE rdt.rdtAddMsg 255469, 10, '255469 InvUCC',             'us_english', 839, 0, '255469 Invalid UCC'
EXECUTE rdt.rdtAddMsg 255470, 10, '255470 InvUCC',             'us_english', 839, 0, '255470 UCC does not exist in MasterSerialNo'
EXECUTE rdt.rdtAddMsg 255471, 10, '255471 StockAllocated',     'us_english', 839, 0, '255471 Stock is allocated'
EXECUTE rdt.rdtAddMsg 255472, 10, '255472 StockAllocated',     'us_english', 839, 0, '255472 Stock is allocated'
EXECUTE rdt.rdtAddMsg 255473, 10, '255473 UCCScanned',         'us_english', 839, 0, '255473 UCC is scanned'
EXECUTE rdt.rdtAddMsg 255474, 10, '255474 SerialNoScanned',    'us_english', 839, 0, '255474 SerialNo is scanned'
EXECUTE rdt.rdtAddMsg 255475, 10, '255475 SerialNoScanned',    'us_english', 839, 0, '255475 SerialNo is scanned'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 255451 AND 255500
