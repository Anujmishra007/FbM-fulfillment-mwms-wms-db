--rdt_1819ExtValVNM
execute rdt.rdtdropmsg 219971 , 219974

execute rdt.rdtAddMsg 219971, 10, '219971 NoMixedLottable03',           'us_english', 1819
execute rdt.rdtAddMsg 219972, 10, '219972 Not Meet 8 Week rule',        'us_english', 1819
execute rdt.rdtAddMsg 219973, 10, '219973 multideep loc not Mixed SKU', 'us_english', 1819
execute rdt.rdtAddMsg 219974, 10, '219974 Diff pallet type',            'us_english', 1819

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 219971 AND 219974