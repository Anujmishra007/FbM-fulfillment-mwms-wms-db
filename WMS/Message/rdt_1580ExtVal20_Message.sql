-- rdt_1580ExtVal20
exec rdt.rdtdropmsg 162101, 162150

execute rdt.rdtAddMsg 162101, 10, '162101DuplicateValue', 'us_english', 1580


select top 10 * from rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 162101 and 162150