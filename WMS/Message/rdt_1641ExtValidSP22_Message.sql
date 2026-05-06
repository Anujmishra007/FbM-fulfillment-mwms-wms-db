
execute rdt.rdtdropmsg 257541, 257560

execute rdt.rdtAddMsg 257541, 10, '257541:InvalidUCC',  'us_english', 1641, 0,     '257541: Invalid UCC'
execute rdt.rdtAddMsg 257542, 10, '257542:PackNotDone ',  'us_english', 1641, 0,   '257542: Pack Not Done '
execute rdt.rdtAddMsg 257543, 10, '257543:ScannedUCC',  'us_english', 1641, 0,     '257543: Scanned UCC'
execute rdt.rdtAddMsg 257544, 10, '257544:DiffType',  'us_english', 1641, 0,       '257544: Diff Type'
execute rdt.rdtAddMsg 257545, 10, '257545:DiffType',  'us_english', 1641, 0,       '257545: Diff Type'



SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 257541 AND 257560