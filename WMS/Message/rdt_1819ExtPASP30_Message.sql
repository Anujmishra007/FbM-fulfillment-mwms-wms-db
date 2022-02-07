--rdt_1819ExtPASP30
exec rdt.rdtDropMsg 151451 , 151500

execute rdt.rdtAddMsg 151451, 10, '51451^StrategyNotSet',      'us_english', 1819
execute rdt.rdtAddMsg 151452, 10, '51452^BadStrategyKey',      'us_english', 1819
execute rdt.rdtAddMsg 151453, 10, '51453^No Sugges LOC',       'us_english', 1819
execute rdt.rdtAddMsg 151454, 10, '51454^UpdRFPAway Err',      'us_english', 1819

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 151451 AND 151500


