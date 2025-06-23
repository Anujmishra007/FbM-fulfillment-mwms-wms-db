-- rdt_Lottable
--UWP-28462
execute rdt.rdtDropMsg 92301, 92350

/*
execute rdt.rdtAddMsg 92301, 10, 'LOTTABLE01          ', 'us_english'
execute rdt.rdtAddMsg 92302, 10, 'LOTTABLE02          ', 'us_english'
execute rdt.rdtAddMsg 92303, 10, 'LOTTABLE03          ', 'us_english'
execute rdt.rdtAddMsg 92304, 10, 'LOTTABLE04          ', 'us_english'
execute rdt.rdtAddMsg 92305, 10, 'LOTTABLE05          ', 'us_english'
execute rdt.rdtAddMsg 92306, 10, 'LOTTABLE06          ', 'us_english'
execute rdt.rdtAddMsg 92307, 10, 'LOTTABLE07          ', 'us_english'
execute rdt.rdtAddMsg 92308, 10, 'LOTTABLE08          ', 'us_english'
execute rdt.rdtAddMsg 92309, 10, 'LOTTABLE09          ', 'us_english'
execute rdt.rdtAddMsg 92310, 10, 'LOTTABLE10          ', 'us_english'
execute rdt.rdtAddMsg 92311, 10, 'LOTTABLE11          ', 'us_english'
execute rdt.rdtAddMsg 92312, 10, 'LOTTABLE12          ', 'us_english'
execute rdt.rdtAddMsg 92313, 10, 'LOTTABLE13          ', 'us_english'
execute rdt.rdtAddMsg 92314, 10, 'LOTTABLE14          ', 'us_english'
execute rdt.rdtAddMsg 92315, 10, 'LOTTABLE15          ', 'us_english'
*/


execute rdt.rdtAddMsg 92316, 10, '92316 Invalid Date  ', 'us_english'
execute rdt.rdtAddMsg 92317, 10, '92317 NeedLottable  ', 'us_english'
execute rdt.rdtAddMsg 92318, 10, '92318 Invalid Date  ', 'us_english'
execute rdt.rdtAddMsg 92319, 10, '92319 NeedLottable  ', 'us_english'
execute rdt.rdtAddMsg 92320, 10, '92320 Invalid Date  ', 'us_english'
execute rdt.rdtAddMsg 92321, 10, '92321 DateRequiredToBeBeforeThanToday', 'us_english'
execute rdt.rdtAddMsg 92322, 10, '92322 Invalid Date  ', 'us_english'
execute rdt.rdtAddMsg 92323, 10, '92323 Diff Lottable ', 'us_english'
execute rdt.rdtAddMsg 92324, 10, '92324 Invalid Date  ', 'us_english'
execute rdt.rdtAddMsg 92325, 10, '92325 NeedLottable  ', 'us_english'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 92301 AND 92350