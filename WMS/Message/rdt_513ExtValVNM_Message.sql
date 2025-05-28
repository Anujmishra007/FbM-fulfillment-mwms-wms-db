-- rdt_513ExtValVNM
execute rdt.rdtDropMsg 219981, 219984

execute rdt.rdtAddMsg 219981, 10, '219981 NoMixedLottable03',           'us_english', 513
execute rdt.rdtAddMsg 219982, 10, '219982 Not Meet 8 Week rule',        'us_english', 513
execute rdt.rdtAddMsg 219983, 10, '219983 multideep loc not Mixed SKU', 'us_english', 513
execute rdt.rdtAddMsg 219984, 10, '219984 Diff pallet type',            'us_english', 513


SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 219981 AND 219984