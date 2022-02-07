--rdt_1819ExtPASP34
exec rdt.rdtDropMsg 163251 , 163300

execute rdt.rdtAddMsg 163251, 10, '63251^MIXSKUUCC     ',   'us_english', 1819
execute rdt.rdtAddMsg 163252, 10, '63252^StrategyNotSet',   'us_english', 1819
execute rdt.rdtAddMsg 163253, 10, '63253^BadStrategyKey',   'us_english', 1819
execute rdt.rdtAddMsg 163254, 10, '63254^NoSuggestedLOC',   'us_english', 1819
execute rdt.rdtAddMsg 163255, 10, '63255UpdRFPutawayErr',   'us_english', 1819

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE message_id BETWEEN 163251 and 163300



