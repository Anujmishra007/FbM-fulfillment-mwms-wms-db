-- rdt_LottableProcess_ValidateL01_L15
execute rdt.rdtdropmsg 133901 , 133950

execute rdt.rdtAddMsg 133901, 10, '33901^LOTTABLE01 REQ',   'us_english', 607
execute rdt.rdtAddMsg 133902, 10, '33902^INVALID LOT01',    'us_english', 607
execute rdt.rdtAddMsg 133903, 10, '33903^LOTTABLE02 REQ',   'us_english', 607
execute rdt.rdtAddMsg 133904, 10, '33904^INVALID LOT02',    'us_english', 607
execute rdt.rdtAddMsg 133905, 10, '33905^LOTTABLE03 REQ',   'us_english', 607
execute rdt.rdtAddMsg 133906, 10, '33906^INVALID LOT03',    'us_english', 607
execute rdt.rdtAddMsg 133907, 10, '33907^LOTTABLE04 REQ',   'us_english', 607
execute rdt.rdtAddMsg 133908, 10, '33908^INVALID LOT04',    'us_english', 607
execute rdt.rdtAddMsg 133909, 10, '33909^LOTTABLE06 REQ',   'us_english', 607
execute rdt.rdtAddMsg 133910, 10, '33910^INVALID LOT06',    'us_english', 607
execute rdt.rdtAddMsg 133911, 10, '33911^LOTTABLE07 REQ',   'us_english', 607
execute rdt.rdtAddMsg 133912, 10, '33912^INVALID LOT07',    'us_english', 607
execute rdt.rdtAddMsg 133913, 10, '33913^LOTTABLE08 REQ',   'us_english', 607
execute rdt.rdtAddMsg 133914, 10, '33914^INVALID LOT08',    'us_english', 607
execute rdt.rdtAddMsg 133915, 10, '33915^LOTTABLE09 REQ',   'us_english', 607
execute rdt.rdtAddMsg 133916, 10, '33916^INVALID LOT09',    'us_english', 607
execute rdt.rdtAddMsg 133917, 10, '33917^LOTTABLE10 REQ',   'us_english', 607
execute rdt.rdtAddMsg 133918, 10, '33918^INVALID LOT10',    'us_english', 607
execute rdt.rdtAddMsg 133919, 10, '33919^LOTTABLE11 REQ',   'us_english', 607
execute rdt.rdtAddMsg 133920, 10, '33920^INVALID LOT11',    'us_english', 607
execute rdt.rdtAddMsg 133921, 10, '33921^LOTTABLE12 REQ',   'us_english', 607
execute rdt.rdtAddMsg 133922, 10, '33922^INVALID LOT12',    'us_english', 607
execute rdt.rdtAddMsg 133923, 10, '33923^LOTTABLE13 REQ',   'us_english', 607
execute rdt.rdtAddMsg 133924, 10, '33924^INVALID LOT13',    'us_english', 607
execute rdt.rdtAddMsg 133925, 10, '33925^INVALID LOT14',    'us_english', 607
execute rdt.rdtAddMsg 133926, 10, '33926^LOTTABLE14 REQ',   'us_english', 607
execute rdt.rdtAddMsg 133927, 10, '33927^INVALID LOT15',    'us_english', 607
execute rdt.rdtAddMsg 133928, 10, '33928^LOTTABLE15 REQ',   'us_english', 607

select * from rdt.rdtmsg (nolock) where message_id between 133901 and 133950
