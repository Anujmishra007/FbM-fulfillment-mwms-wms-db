exec rdt.rdtdropmsg 251101, 251150

execute rdt.rdtAddMsg 251101, 10, '251101Lottable02NotMatch', 'us_english', 600 , 0, '251101 Lottable02 Not Match'
execute rdt.rdtAddMsg 251102, 10, '251102Lottable03NotMatch', 'us_english', 600 , 0, '251102 Lottable03 Not Match'
execute rdt.rdtAddMsg 251103, 10, '251103Lottable06NotMatch', 'us_english', 600 , 0, '251103 Lottable06 Not Match'

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 226601 AND 226650
