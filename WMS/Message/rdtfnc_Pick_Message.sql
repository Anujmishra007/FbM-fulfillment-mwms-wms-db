-- Message range 62601 - 62700 (rdtfnc_Pick)
execute rdt.rdtDropMsg 62601, 62700
execute rdt.rdtDropMsg 63901, 63950

-- Init
execute rdt.rdtAddMsg 62601, 10, '62601 UCC Config Off', 'us_english'
execute rdt.rdtAddMsg 62602, 10, '62602 CantPickUCC PL', 'us_english'

-- PSNO screen
execute rdt.rdtAddMsg 62611, 10, '62611 PSNO required ', 'us_english'
execute rdt.rdtAddMsg 62612, 10, '62612 Invalid PSNO  ', 'us_english'
execute rdt.rdtAddMsg 62613, 10, '62613 OrderShipped  ', 'us_english'
execute rdt.rdtAddMsg 62614, 10, '62614 Diff storer   ', 'us_english'
execute rdt.rdtAddMsg 62615, 10, '62615 OrderShipped  ', 'us_english'
execute rdt.rdtAddMsg 62616, 10, '62616 Diff storer   ', 'us_english'
execute rdt.rdtAddMsg 62617, 10, '62617 OrderShipped  ', 'us_english'
execute rdt.rdtAddMsg 62618, 10, '62618 Diff storer   ', 'us_english'
execute rdt.rdtAddMsg 62619, 10, '62619 PS not scan in', 'us_english'
execute rdt.rdtAddMsg 62620, 10, '62620 PS scanned out', 'us_english'

-- LOC screen
execute rdt.rdtAddMsg 62621, 10, '62621 LOC needed',     'us_english'
execute rdt.rdtAddMsg 62622, 10, '62622 Invalid LOC',    'us_english'
execute rdt.rdtAddMsg 62623, 10, '62623 Diff facility',  'us_english'
execute rdt.rdtAddMsg 62624, 10, '62624 No task in LOC', 'us_english'
execute rdt.rdtAddMsg 62625, 10, '62625 Invalid Format', 'us_english'

-- SKU screen
execute rdt.rdtAddMsg 62630, 10, '62630 Invalid SKU',    'us_english'
execute rdt.rdtAddMsg 62631, 10, '62631 Wrong SKU',      'us_english'
execute rdt.rdtAddMsg 62632, 10, '62632 MultiSKUBarcod', 'us_english'
execute rdt.rdtAddMsg 62633, 10, '62633 Different L01',  'us_english'
execute rdt.rdtAddMsg 62634, 10, '62634 Different L02',  'us_english'
execute rdt.rdtAddMsg 62635, 10, '62635 Different L03',  'us_english'
execute rdt.rdtAddMsg 62636, 10, '62636 Different L04',  'us_english'

-- QTY screen
execute rdt.rdtAddMsg 62640, 10, '62640 Invalid QTY',    'us_english'
execute rdt.rdtAddMsg 62641, 10, '62641 Invalid QTY',    'us_english'
execute rdt.rdtAddMsg 62642, 10, '62642 Over pick',      'us_english'

-- UCC screen
execute rdt.rdtAddMsg 62650, 10, '62650 UCC LotbleDiff', 'us_english'
execute rdt.rdtAddMsg 62651, 10, '62651 Over pick',      'us_english'
execute rdt.rdtAddMsg 62652, 10, '62652 Double scan',    'us_english'
execute rdt.rdtAddMsg 62653, 10, '62653 Upd UCC fail',   'us_english'

-- ID screen
execute rdt.rdtAddMsg 62660, 10, '62660 Wrong ID',       'us_english'

-- Dialog screens
execute rdt.rdtAddMsg 62670, 10, '62670 Option needed',  'us_english'
execute rdt.rdtAddMsg 62671, 10, '62671 Invalid Option', 'us_english'
execute rdt.rdtAddMsg 62672, 10, '62672 Option needed',  'us_english'
execute rdt.rdtAddMsg 62673, 10, '62673 Invalid Option', 'us_english'
execute rdt.rdtAddMsg 62674, 10, '62674 Del UCC fail',   'us_english'
execute rdt.rdtAddMsg 62675, 10, '62675 Option needed',  'us_english'
execute rdt.rdtAddMsg 62676, 10, '62676 Invalid Option', 'us_english'
execute rdt.rdtAddMsg 62677, 10, '62677 Del UCC fail',   'us_english'

--extend from SOS93811
execute rdt.rdtAddMsg 63901, 10, '63901 DROPID needed',  'us_english'
execute rdt.rdtAddMsg 63902, 10, '63902 Invalid DROPID', 'us_english'
execute rdt.rdtAddMsg 63903, 10, '63903 Option needed',  'us_english'
execute rdt.rdtAddMsg 63904, 10, '63904 Invalid Option', 'us_english'
execute rdt.rdtAddMsg 63905, 10, '63905 NoLoginPrinter', 'us_english'
execute rdt.rdtAddMsg 63906, 10, '63906 DWNOTSetup',     'us_english'
execute rdt.rdtAddMsg 63907, 10, '63907 TgetDB Not Set', 'us_english'
execute rdt.rdtAddMsg 63908, 10, '63908 InsertPRTFail', 'us_english'

-- SOS267939
execute rdt.rdtAddMsg 63909, 10, '63909^OrderShipped',  'us_english'
execute rdt.rdtAddMsg 63910, 10, '63910^OrderShipped',  'us_english'

-- SOS276108
execute rdt.rdtAddMsg 63911, 10, '63911^LOC NOT MATCH', 'us_english'
execute rdt.rdtAddMsg 63912, 10, '63912^Option needed',  'us_english'
execute rdt.rdtAddMsg 63913, 10, '63913^Invalid Option', 'us_english'

-- SOS367362
execute rdt.rdtAddMsg 63914, 10, '63914^Invalid Format', 'us_english'

-- WMS-12504
execute rdt.rdtAddMsg 63915, 10, '63915^Scan-In Fail',   'us_english'
execute rdt.rdtAddMsg 63916, 10, '63916^Scan-In Fail',   'us_english'