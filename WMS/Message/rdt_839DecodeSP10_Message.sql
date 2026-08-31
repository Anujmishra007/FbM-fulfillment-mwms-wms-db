--rdt_839DecodeSP10
-- 270901 - 270950
EXECUTE rdt.rdtdropmsg 270901 , 270950

EXECUTE rdt.rdtAddMsg 270901, 10, '270901 InvBarcode',      'us_english', 839, 0, '270901 Invalid barcode format'
EXECUTE rdt.rdtAddMsg 270902, 10, '270902 WrongSKU',        'us_english', 839, 0, '270902 Wrong SKU'
EXECUTE rdt.rdtAddMsg 270903, 10, '270903 WrongLottable01', 'us_english', 839, 0, '270903 Wrong Lottable01'
EXECUTE rdt.rdtAddMsg 270904, 10, '270904 InvBarcode',      'us_english', 839, 0, '270904 Invalid barcode format'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 270901 AND 270950
