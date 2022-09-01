--rdt_1723BuildPltSP01
execute rdt.rdtdropmsg 177001, 177050

execute rdt.rdtAddMsg 177001, 10, '177001^SSCC REQ     ',  'us_english', 1723
execute rdt.rdtAddMsg 177002, 10, '177002^PLT CONSOLED ',  'us_english', 1723
execute rdt.rdtAddMsg 177003, 10, '177003^PLT CONSOLED ',  'us_english', 1723
execute rdt.rdtAddMsg 177004, 10, '177004^INS PLT FAIL ',  'us_english', 1723
execute rdt.rdtAddMsg 177005, 10, '177005^INV ASRS PLT ',  'us_english', 1723
execute rdt.rdtAddMsg 177006, 10, '177006INS PLTDT FAIL',  'us_english', 1723
execute rdt.rdtAddMsg 177007, 10, '177007UPD PLTDT FAIL',  'us_english', 1723
execute rdt.rdtAddMsg 177008, 10, '177008^INS LOG FAIL ',  'us_english', 1723
execute rdt.rdtAddMsg 177009, 10, '177009^GEN SSCC FAIL',  'us_english', 1723
execute rdt.rdtAddMsg 177010, 10, '177010^INS PLT FAIL ',  'us_english', 1723
execute rdt.rdtAddMsg 177011, 10, '177011INV SHIPER PLT',  'us_english', 1723
execute rdt.rdtAddMsg 177012, 10, '177012INS PLTDT FAIL',  'us_english', 1723
execute rdt.rdtAddMsg 177013, 10, '177013UPD PLTDT FAIL',  'us_english', 1723
execute rdt.rdtAddMsg 177014, 10, '177014INS PLTDT FAIL',  'us_english', 1723
execute rdt.rdtAddMsg 177015, 10, '177015UPD PLTDT FAIL',  'us_english', 1723
execute rdt.rdtAddMsg 177016, 10, '177016Get RFKey Fail',  'us_english', 1723
execute rdt.rdtAddMsg 177017, 10, '177017OffSetPDtlFail',  'us_english', 1723
execute rdt.rdtAddMsg 177018, 10, '177018^GetDetKeyFail',  'us_english', 1723
execute rdt.rdtAddMsg 177019, 10, '177019^Ins PDtl Fail',  'us_english', 1723
execute rdt.rdtAddMsg 177020, 10, '177020OffSetPDtlFail',  'us_english', 1723
execute rdt.rdtAddMsg 177021, 10, '177021UPD PLTDT FAIL',  'us_english', 1723
execute rdt.rdtAddMsg 177022, 10, '177022^REL PDTL FAIL',  'us_english', 1723
execute rdt.rdtAddMsg 177023, 10, '177023^INS LOG FAIL ',  'us_english', 1723


select * from rdt.rdtmsg (nolock) where message_id between 177001 and 177050