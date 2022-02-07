--rdt_808ExtValid02
exec rdt.rdtdropmsg 165401, 165450

execute rdt.rdtAddMsg 165401, 10, '65401^VP Picked', 'us_english', 808

SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 165401 AND 165450


