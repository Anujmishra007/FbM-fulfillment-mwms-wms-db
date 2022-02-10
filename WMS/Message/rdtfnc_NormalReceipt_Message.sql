--execute rdt.rdtDropMsg 60401, 60500
--execute rdt.rdtDropMsg 67376, 67390
-- rdtfnc_NormalReceipt (range 60401 - 60500)
execute rdt.rdtAddMsg 60401, 10, '60401 ASN / PO is required', 'us_english'
execute rdt.rdtAddMsg 60402, 10, '60402 ASN / PO not exists', 'us_english'
execute rdt.rdtAddMsg 60403, 10, '60403 ASN does not exists', 'us_english'
execute rdt.rdtAddMsg 60404, 10, '60404 Multi PO in ASN', 'us_english'
execute rdt.rdtAddMsg 60405, 10, '60405 PO does not exists', 'us_english'
execute rdt.rdtAddMsg 60406, 10, '60406 Multi ASN in PO', 'us_english'
execute rdt.rdtAddMsg 60407, 10, '60407 ASN facility diff', 'us_english'
execute rdt.rdtAddMsg 60408, 10, '60408 ASN storer different', 'us_english'
execute rdt.rdtAddMsg 60409, 10, '60409 ASN is closed', 'us_english'
execute rdt.rdtAddMsg 60410, 10, '60410 LOC is required', 'us_english'
execute rdt.rdtAddMsg 60411, 10, '60411 Invalid LOC', 'us_english'
execute rdt.rdtAddMsg 60412, 10, '60412 LOC not in facility', 'us_english'
execute rdt.rdtAddMsg 60413, 10, '60413 Duplicate PAL ID', 'us_english'
execute rdt.rdtAddMsg 60414, 10, '60414 SKU is required', 'us_english'
execute rdt.rdtAddMsg 60415, 10, '60415 Invalid SKU', 'us_english'
execute rdt.rdtAddMsg 60416, 10, '60416 SKU not in ASN', 'us_english'
execute rdt.rdtAddMsg 60417, 10, '60417 Unmatch ASN LN', 'us_english'
execute rdt.rdtAddMsg 60418, 10, '60418 UOM is required', 'us_english'
execute rdt.rdtAddMsg 60419, 10, '60419 Invalid UOM', 'us_english'
execute rdt.rdtAddMsg 60420, 10, '60420 QTY is required', 'us_english'
execute rdt.rdtAddMsg 60421, 10, '60421 Invalid QTY', 'us_english'
execute rdt.rdtAddMsg 60422, 10, '60422 QTY must > 0', 'us_english'
execute rdt.rdtAddMsg 60423, 10, '60423 nspUOMCONV error', 'us_english'
execute rdt.rdtAddMsg 60424, 10, '60424 nspGetRight Allow_OverReceipt', 'us_english'
execute rdt.rdtAddMsg 60425, 10, '60425 Over receive', 'us_english'
execute rdt.rdtAddMsg 60426, 10, '60426 nspGetRight ByPassTolerance', 'us_english'
execute rdt.rdtAddMsg 60427, 10, '60427 Over tolerance', 'us_english'
execute rdt.rdtAddMsg 60428, 10, '60428 ReasonCode required', 'us_english'
execute rdt.rdtAddMsg 60429, 10, '60429 Invalid ReasonCode', 'us_english'
execute rdt.rdtAddMsg 60430, 10, '60430 Lottable01 required', 'us_english'
execute rdt.rdtAddMsg 60431, 10, '60431 Lottable02 required', 'us_english'
execute rdt.rdtAddMsg 60432, 10, '60432 Lottable03 required', 'us_english'
execute rdt.rdtAddMsg 60433, 10, '60433 Lottable04 required', 'us_english'
execute rdt.rdtAddMsg 60434, 10, '60434 Invalid date', 'us_english'
execute rdt.rdtAddMsg 60435, 10, '60435 Invalid QTY', 'us_english'
execute rdt.rdtAddMsg 60436, 10, '60436 Same barcode', 'us_english'
execute rdt.rdtAddMsg 60437, 10, '60437 Lottable05 required', 'us_english'
-- SOS#80652
execute rdt.rdtAddMsg 60438, 10, '60438 Option required', 'us_english'
execute rdt.rdtAddMsg 60439, 10, '60439 Invalid Option', 'us_english'
execute rdt.rdtAddMsg 60440, 10, '60440 Same barcode', 'us_english'

-- By FKLim
execute rdt.rdtAddMsg 60441, 10, '60441 Invalid SKU', 'us_english'
execute rdt.rdtAddMsg 60442, 10, '60442 SKU not in ASN', 'us_english'
execute rdt.rdtAddMsg 60443, 10, '60443 Same barcode', 'us_english'
execute rdt.rdtAddMsg 60444, 10, '60444 Unmatch ASN LN', 'us_english'
execute rdt.rdtAddMsg 60445, 10, '60445 Invalid UOM', 'us_english'

--SOS87607
execute rdt.rdtAddMsg 60446, 10, '60446^ASNPONotExists', 'us_english'
execute rdt.rdtAddMsg 60447, 10, '60447^ASN Not Exists', 'us_english'
execute rdt.rdtAddMsg 60448, 10, '60448^PO Not Exists', 'us_english'

-- SOS#131462
execute rdt.rdtAddMsg 60449, 10, '60449^GetIDKey Fail', 'us_english'
execute rdt.rdtAddMsg 60450, 10, '60450^Option required', 'us_english'
execute rdt.rdtAddMsg 60451, 10, '60451^Invalid Option', 'us_english'
execute rdt.rdtAddMsg 60452, 10, '60452^NoLoginPrinter', 'us_english'
execute rdt.rdtAddMsg 60453, 10, '60453^DWNOTSetup', 'us_english'
execute rdt.rdtAddMsg 60454, 10, '60454^TgetDB Not Set', 'us_english'
execute rdt.rdtAddMsg 60455, 10, '60455^InsertPRTFail', 'us_english'
execute rdt.rdtAddMsg 60456, 10, '60456^GetIDKey Fail', 'us_english'
execute rdt.rdtAddMsg 60457, 10, '60457^NoLoginPrinter', 'us_english'
execute rdt.rdtAddMsg 60458, 10, '60458^DWNOTSetup', 'us_english'
execute rdt.rdtAddMsg 60459, 10, '60459^TgetDB Not Set', 'us_english'
execute rdt.rdtAddMsg 60460, 10, '60460^InsertPRTFail', 'us_english'

-- SOS#137512
execute rdt.rdtAddMsg 60461, 10, '60461^PLT ID Exists', 'us_english'

-- SOS#164544
execute rdt.rdtAddMsg 60462, 10, '60462^UOMConvQTY < 1', 'us_english'

-- SOS#142253
execute rdt.rdtAddMsg 67376, 10, '67376^PK QTY needed', 'us_english'
execute rdt.rdtAddMsg 67377, 10, '67377^Invalid PK QTY', 'us_english'
execute rdt.rdtAddMsg 67378, 10, '67378^PK QTY must > 0', 'us_english'
execute rdt.rdtAddMsg 67379, 10, '67379^PK QTY not match', 'us_english'
execute rdt.rdtAddMsg 67380, 10, '67380^SKU NOT IN PO', 'us_english'
execute rdt.rdtAddMsg 67381, 10, '67381^SKU NOT IN PO', 'us_english'

-- SOS#160310
execute rdt.rdtAddMsg 67382, 10, '67382^Invalid PltID',  'us_english'
execute rdt.rdtAddMsg 67383, 10, '67383^Invalid QTY',    'us_english'
execute rdt.rdtAddMsg 67384, 10, '67384^Invalid QTY',    'us_english'
execute rdt.rdtAddMsg 67385, 10, '67385^Inv ReasonCode', 'us_english'

-- SOS275767
execute rdt.rdtAddMsg 67386, 10, '67386^GetIDKey Fail', 'us_english'

-- SOS305458
execute rdt.rdtAddMsg 67387, 10, '67387^Invalid PltID',  'us_english'

-- SOS315152
execute rdt.rdtAddMsg 67388, 10, '67388^GetIDKey Fail',  'us_english'
execute rdt.rdtAddMsg 67389, 10, '67389^GetIDKey Fail',  'us_english'

-- SOS#341736
execute rdt.rdtAddMsg 67370, 10, '67370^ASN is cancelled',  'us_english'