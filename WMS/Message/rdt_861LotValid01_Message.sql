-- rdt_861LotValid01
-- FCR-2519
execute rdt.rdtDropMsg 233751, 233800

execute rdt.rdtAddMsg 233751, 10, '233751 Diff Lottable01', 'us_english', 861, 0, '233751 Diff Lottable01'
execute rdt.rdtAddMsg 233752, 10, '233752 Diff Lottable02', 'us_english', 861, 0, '233752 Diff Lottable02'
execute rdt.rdtAddMsg 233753, 10, '233753 Diff Lottable03', 'us_english', 861, 0, '233753 Diff Lottable03'
execute rdt.rdtAddMsg 233754, 10, '233754 Diff Lottable04', 'us_english', 861, 0, '233754 Diff Lottable04'
execute rdt.rdtAddMsg 233755, 10, '233755 Diff Lottable05', 'us_english', 861, 0, '233755 Diff Lottable05'
execute rdt.rdtAddMsg 233756, 10, '233756 Diff Lottable06', 'us_english', 861, 0, '233756 Diff Lottable06'
execute rdt.rdtAddMsg 233757, 10, '233757 Diff Lottable07', 'us_english', 861, 0, '233757 Diff Lottable07'
execute rdt.rdtAddMsg 233758, 10, '233758 Diff Lottable08', 'us_english', 861, 0, '233758 Diff Lottable08'
execute rdt.rdtAddMsg 233759, 10, '233759 Diff Lottable09', 'us_english', 861, 0, '233759 Diff Lottable09'
execute rdt.rdtAddMsg 233760, 10, '233760 Diff Lottable10', 'us_english', 861, 0, '233760 Diff Lottable10'
execute rdt.rdtAddMsg 233761, 10, '233761 Diff Lottable11', 'us_english', 861, 0, '233761 Diff Lottable11'
execute rdt.rdtAddMsg 233762, 10, '233762 Diff Lottable12', 'us_english', 861, 0, '233762 Diff Lottable12'
execute rdt.rdtAddMsg 233763, 10, '233763 Diff Lottable13', 'us_english', 861, 0, '233763 Diff Lottable13'
execute rdt.rdtAddMsg 233764, 10, '233764 Diff Lottable14', 'us_english', 861, 0, '233764 Diff Lottable14'
execute rdt.rdtAddMsg 233765, 10, '233765 Diff Lottable15', 'us_english', 861, 0, '233765 Diff Lottable15'

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 233751 AND 233800
