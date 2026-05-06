-- UWP-54107
EXEC rdt.rdtDropMsg 263751, 263800

EXECUTE rdt.rdtAddMsg 263751 ,10, '263751 DiffLot03',                      'us_english', 1819, 0, '263751 Lootable03 is different'
EXECUTE rdt.rdtAddMsg 263752 ,10, '263752 Not Meet DOT Week rule',         'us_english', 1819, 0, '263752 Not Meet DOT Week rule'
EXECUTE rdt.rdtAddMsg 263753 ,10, '263753 Diff SKU',                       'us_english', 1819, 0, '263753 Diff Sku'
EXECUTE rdt.rdtAddMsg 263754 ,10, '263754 Diff pallet type',               'us_english', 1819, 0, '263754 Diff pallet type'
EXECUTE rdt.rdtAddMsg 263755 ,10, '263755 Loc Alloc',                      'us_english', 1819, 0, '263755 Loc Alloc'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 263751 AND 263800