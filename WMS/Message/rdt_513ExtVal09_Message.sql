--rdt_513ExtVal09
execute rdt.rdtdropmsg 164301, 164350

execute rdt.rdtAddMsg '164301', 10, 'Allocated SKU', 'us_english', 513
execute rdt.rdtAddMsg '164302', 10, 'INACTIVE/DISABLE LOC', 'us_english', 513

SELECT * FROM rdt.rdtMsg (nolock) WHERE message_id BETWEEN 164301 and 164350

