-- rdt_ConReceive_RefNoLookup
exec rdt.rdtdropmsg 169251, 169300

execute rdt.rdtAddMsg 169251, 10, '169251Bad RefNoSetup', 'us_english', 598
execute rdt.rdtAddMsg 169252, 10, '169252Bad RefNoSetup', 'us_english', 598
execute rdt.rdtAddMsg 169253, 10, '169253RefNo NotInASN', 'us_english', 598

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 169251 and 169300