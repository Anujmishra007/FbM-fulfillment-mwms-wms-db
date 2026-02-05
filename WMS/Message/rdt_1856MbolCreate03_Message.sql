
execute rdt.rdtdropmsg 257601, 257620

execute rdt.rdtAddMsg 257601, 10, '257601:ORDERS IN MBOL',  'us_english',  1856, 0,  '257601: ORDERS IN MBOL'
execute rdt.rdtAddMsg 257602, 10, '257602:nspg_getkey',  'us_english',  1856, 0,     '257602: nspg_getkey'
execute rdt.rdtAddMsg 257603, 10, '257603:INS MBOL Err',  'us_english',  1856, 0,    '257603: INS MBOL Err'
execute rdt.rdtAddMsg 257604, 10, '257604:ORD X PICKED',  'us_english',  1856, 0,    '257604: ORD X PICKED'
execute rdt.rdtAddMsg 257605, 10, '257605:nspg_getkey',  'us_english',  1856, 0,     '257605: nspg_getkey'
execute rdt.rdtAddMsg 257606, 10, '257606:INS MBOL Err',  'us_english',  1856, 0,    '257606: INS MBOL Err'
execute rdt.rdtAddMsg 257607, 10, '257607:INS MBODtl Err',  'us_english',  1856, 0,  '257607: INS MBODtl Err'
execute rdt.rdtAddMsg 257608, 10, '257608:INS MBODtl Err',  'us_english',  1856, 0,  '257608: INS MBODtl Err'
execute rdt.rdtAddMsg 257609, 10, '257609:NO ORDERS ADD',  'us_english',  1856, 0,   '257609: NO ORDERS ADD'



SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 257601 AND 257620