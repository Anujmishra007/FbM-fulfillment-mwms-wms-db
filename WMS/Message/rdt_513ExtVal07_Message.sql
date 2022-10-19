
--rdt_513ExtVal07
exec rdt.rdtdropmsg 158051, 158100

execute rdt.rdtAddMsg 158051, 10, '58051^Diff LOC', 'us_english', 513
execute rdt.rdtAddMsg 158052, 10, '58052^Diff LOC', 'us_english', 513

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 158051 AND 158100

