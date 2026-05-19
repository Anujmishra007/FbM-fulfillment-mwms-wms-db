--rdt_898ExtVal12
execute rdt.rdtdropmsg 263901, 263950

execute rdt.rdtAddMsg 263901, 10, '263901^Mix ID Not Allowed',         'us_english', 898, 0, '263901 Mix ID Not Allowed'
execute rdt.rdtAddMsg 263902, 10, '263902^Mix Lottable01 Not Allowed', 'us_english', 898, 0, '263902 Mix Lottable01 Not Allowed On ID'
execute rdt.rdtAddMsg 263903, 10, '263903^Mix Lottable02 Not Allowed', 'us_english', 898, 0, '263903 Mix Lottable02 Not Allowed On ID'
execute rdt.rdtAddMsg 263904, 10, '263904^Mix Lottable03 Not Allowed', 'us_english', 898, 0, '263904 Mix Lottable03 Not Allowed On ID'
execute rdt.rdtAddMsg 263905, 10, '263905^Mix Lottable04 Not Allowed', 'us_english', 898, 0, '263905 Mix Lottable04 Not Allowed On ID'
execute rdt.rdtAddMsg 263906, 10, '263906^Mix SKU Not Allowed',        'us_english', 898, 0, '263906 Mix SKU Not Allowed'
execute rdt.rdtAddMsg 263907, 10, '263907^Invalid Length Barcode',     'us_english', 898, 0, '263907 Invalid length barcode'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 263901 AND 263950 ORDER BY Message_ID
