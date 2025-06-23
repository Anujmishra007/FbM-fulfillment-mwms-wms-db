--rdt_1819ExtVal17
execute rdt.rdtdropmsg 222901 , 222950

execute rdt.rdtAddMsg 222901, 10, '222901 LocNotCommingle', 'us_english', 1819

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 222901 AND 222950