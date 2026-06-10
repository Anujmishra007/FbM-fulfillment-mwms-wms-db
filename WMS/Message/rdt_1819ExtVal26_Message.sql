--rdt_1819ExtVal26
--FCR-12893
execute rdt.rdtDropMsg 268451, 268500

execute rdt.rdtAddMsg 268451, 10, '268451 IDNotExistInRcptDetail',      'us_english', 1819, 0, '268451 ID does not exist in ReceiptDetail'
execute rdt.rdtAddMsg 268453, 10, '268453 NotAllowMix',                 'us_english', 1819, 0, '268453 Not allow mix of Mono-SKU UCCs, Multi-SKU UCCs and Loose inventory'
execute rdt.rdtAddMsg 268454, 10, '268454 NotAllowMix',                 'us_english', 1819, 0, '268454 Not allow mix GOO and non-GOO inventory'
execute rdt.rdtAddMsg 268456, 10, '268456 LocMustBeVAS',                'us_english', 1819, 0, '268456 Location must be VAS for DAM inventory'
execute rdt.rdtAddMsg 268457, 10, '268457 NotAllowMixSKU',              'us_english', 1819, 0, '268457 Not allow to mix SKU on ToLoc'
execute rdt.rdtAddMsg 268458, 10, '268458 NotAllowMixSKU',              'us_english', 1819, 0, '268458 Not allow to mix SKU on ToLoc'
execute rdt.rdtAddMsg 268459, 10, '268459 NotAllowMixLottable02',       'us_english', 1819, 0, '268459 Not allow to mix Lottable02 on ToLoc'
execute rdt.rdtAddMsg 268460, 10, '268460 NotAllowMixLottable02',       'us_english', 1819, 0, '268460 Not allow to mix Lottable02 on ToLoc'
execute rdt.rdtAddMsg 268461, 10, '268461 ToLocMustBePND',              'us_english', 1819, 0, '268461 ToLoc must be PND for Mono-SKU UCC inventory'
execute rdt.rdtAddMsg 268462, 10, '268462 DifferentAisle',              'us_english', 1819, 0, '268462 Different aisle between PickAndDropLOC and ToLoc'
execute rdt.rdtAddMsg 268463, 10, '268463 NotEnoughSpace',              'us_english', 1819, 0, '268463 Not enough available space on ToLoc'
execute rdt.rdtAddMsg 268464, 10, '268464 LocMustBePND-MEZZA',          'us_english', 1819, 0, '268464 Location must be PND-MEZZA for None-DAM inventory'

SELECT * FROM RDT.RDTMsg WHERE Message_ID BETWEEN 268451 AND 268500