--rdt_1819ExtVal16
execute rdt.rdtdropmsg 216001 , 216050

execute rdt.rdtAddMsg 216001, 10, '216001 NoPutawayStrategy', 'us_english', 1819
execute rdt.rdtAddMsg 216002, 10, '216002 PalletNotClosed',   'us_english', 1819

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 216001 AND 216050