-- rdt_1663ExtVal17
exec rdt.rdtdropmsg 178301, 178350

execute rdt.rdtAddMsg 178301, 10, '178301DiffCarrier', 'us_english', 1663
execute rdt.rdtAddMsg 178302, 10, '178302OrderInDiffPLT', 'us_english', 1663
execute rdt.rdtAddMsg 178303, 10, '178303OrderInDiffPLT', 'us_english', 1663
execute rdt.rdtAddMsg 178304, 10, '178304NotAllScanned ', 'us_english', 1663


SELECT * FROM palletdetail (NOLOCK) WHERE palletkey='PS731753'