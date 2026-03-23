-- 235851 - 235900

execute rdt.rdtDropMsg 261001 , 261050

execute rdt.rdtAddMsg 261001, 10, '261001Invalid ReasonCode',      'us_english', 830, 0, ''
execute rdt.rdtAddMsg 261002, 10, '261002',      'us_english', 830, 0, '261002LOC for SHORT move is not maintained'
execute rdt.rdtAddMsg 261003, 10, '261003InvalidShortLoc',      'us_english', 830, 0, ''
execute rdt.rdtAddMsg 261004, 10, '261004ConfigError',      'us_english', 830, 0, ''
execute rdt.rdtAddMsg 261005, 10, '261005ReallocSPNotFound',      'us_english', 830, 0, ''
execute rdt.rdtAddMsg 261006, 10, '261006ReallocFailed',      'us_english', 830, 0, ''
execute rdt.rdtAddMsg 261007, 10, '261007',      'us_english', 830, 0, ''

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 261001 and 261050
