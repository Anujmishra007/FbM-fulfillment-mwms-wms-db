--rdt_1819ExtPASP52
--FCR-267
--FCR-954 
execute rdt.rdtDropMsg 216551, 216600

execute rdt.rdtAddMsg 216551, 10, '216551 MultiPAZone',      'us_english', 1819
execute rdt.rdtAddMsg 216552, 10, '216552 NoPutawayZone',    'us_english', 1819
execute rdt.rdtAddMsg 216553, 10, '216553 NoUCC',            'us_english', 1819
execute rdt.rdtAddMsg 216554, 10, '216554 NoAisleFound',     'us_english', 1819
execute rdt.rdtAddMsg 216555, 10, '216555 NoUCC',            'us_english', 1819
execute rdt.rdtAddMsg 216556, 10, '216556 BookPNDFail',      'us_english', 1819
execute rdt.rdtAddMsg 216557, 10, '216557 NoPNDFound',       'us_english', 1819
execute rdt.rdtAddMsg 216558, 10, '216558 BookUCCFail',      'us_english', 1819
execute rdt.rdtAddMsg 216559, 10, '216559 NoAisleFound',     'us_english', 1819
execute rdt.rdtAddMsg 216560, 10, '216560 NoLocFound',       'us_english', 1819
execute rdt.rdtAddMsg 216561, 10, '216561 EmptyPallet',      'us_english', 1819

SELECT * FROM RDT.RDTMsg WHERE Message_ID BETWEEN 216551 AND 216600