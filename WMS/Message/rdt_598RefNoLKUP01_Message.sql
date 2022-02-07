-- rdt_598RefNoLKUP01
exec rdt.rdtdropmsg 169651, 169700

execute rdt.rdtAddMsg 169651, 10, '169251Bad RefNoSetup', 'us_english', 598
execute rdt.rdtAddMsg 169652, 10, '169252Bad RefNoSetup', 'us_english', 598
execute rdt.rdtAddMsg 169653, 10, '169253RefNo NotInASN', 'us_english', 598

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 169651 and 169700

