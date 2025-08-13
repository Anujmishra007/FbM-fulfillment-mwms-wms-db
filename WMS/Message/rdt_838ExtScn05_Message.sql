--rdt_838ExtScn05_Message
--FCR-4325
EXEC rdt.rdtdropmsg 241551 , 241600

EXECUTE rdt.rdtAddMsg 241551, 10, '241551 DisableQTYField=1',     'us_english', 838, 0, '241551 DisableQTYField cannot be 1'
EXECUTE rdt.rdtAddMsg 241552, 10, '241552 Need SKU',              'us_english', 838, 0, '241552 Need SKU'
EXECUTE rdt.rdtAddMsg 241553, 10, '241553 Invalid SKU',           'us_english', 838, 0, '241553 Invalid SKU'
EXECUTE rdt.rdtAddMsg 241554, 10, '241554 MultiSKUBarcod',        'us_english', 838, 0, '241554 Multiple SKU Barcod'
EXECUTE rdt.rdtAddMsg 241555, 10, '241555 Invalid Qty',           'us_english', 838, 0, '241555 Invalid Qty'
EXECUTE rdt.rdtAddMsg 241556, 10, '241556 Invalid Qty',           'us_english', 838, 0, '241556 Invalid Qty'
EXECUTE rdt.rdtAddMsg 241557, 10, '241557 DEL PKInfoFail',        'us_english', 838, 0, '241557 Delete PackInfo fail'
EXECUTE rdt.rdtAddMsg 241558, 10, '241558 DEL PAKDtlFail',        'us_english', 838, 0, '241558 Delete PackDetail fail'

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE message_id BETWEEN 241551 AND 241600

