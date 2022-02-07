
/*

 rdtfnc_PostPickPack_ExcStock_Scan_Message (range 67001 - 67050)

*/

-- Screen 1.
execute rdt.rdtAddMsg 67001, 10, '67001 WKSTA required', 'us_english'
execute rdt.rdtAddMsg 67002, 10, '67002 Invalid WKSTA',  'us_english'
execute rdt.rdtAddMsg 67003, 10, '67003 Batch required', 'us_english'
execute rdt.rdtAddMsg 67004, 10, '67004 Invalid Batch',  'us_english'
execute rdt.rdtAddMsg 67005, 10, '67005 BatchIsClosed',  'us_english'
execute rdt.rdtAddMsg 67006, 10, '67006 MisMatchStorer', 'us_english'

-- Screen 2.
execute rdt.rdtAddMsg 67007, 10, '67007 SKU required',   'us_english'
execute rdt.rdtAddMsg 67008, 10, '67008 Invalid SKU',    'us_english'
execute rdt.rdtAddMsg 67009, 10, '67009 No Open Record', 'us_english'

-- Screen 3.
execute rdt.rdtAddMsg 67010, 10, '67010 QTY required',   'us_english'
execute rdt.rdtAddMsg 67011, 10, '67011 Invalid QTY',    'us_english'
execute rdt.rdtAddMsg 67012, 10, '67012 Invalid QTY',    'us_english'
execute rdt.rdtAddMsg 67013, 10, '67013 QTY must > 0',   'us_english'
execute rdt.rdtAddMsg 67014, 10, '67014 PCKQTY>BALQTY',  'us_english'

-- Screen 4.
execute rdt.rdtAddMsg 67015, 10, '67015 Tote required',  'us_english'
execute rdt.rdtAddMsg 67016, 10, '67016 Double scan',    'us_english'
execute rdt.rdtAddMsg 67017, 10, '67017 ScanToDiffStor', 'us_english'
execute rdt.rdtAddMsg 67018, 10, '67018 ScanToDiffWKSt', 'us_english'
execute rdt.rdtAddMsg 67019, 10, '67019 Not a CaseID',   'us_english'
execute rdt.rdtAddMsg 67020, 10, '67020 DiffOpenBatch',  'us_english'

-- Screen 5.
execute rdt.rdtAddMsg 67021, 10, '67021 WrongRefno',     'us_english'

-- Screen 6.
execute rdt.rdtAddMsg 67022, 10, '67022 Option req',      'us_english'
execute rdt.rdtAddMsg 67023, 10, '67023 Invalid Option',  'us_english'

-- (Vicky01)
execute rdt.rdtAddMsg 67024, 10, '67024 Double Scan',  'us_english'



--execute rdt.rdtDropMsg <msg_id>
