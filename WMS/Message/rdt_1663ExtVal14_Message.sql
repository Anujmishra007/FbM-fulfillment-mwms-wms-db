-- rdt_1663ExtVal14
exec rdt.rdtdropmsg 174001, 174050

execute rdt.rdtAddMsg 174001, 10, '174001Country Diff  ', 'us_english', 1663
execute rdt.rdtAddMsg 174002, 10, '174002ShipperKeyDiff', 'us_english', 1663

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 174001 AND 174050