--rdt_1819ExtVal11
exec rdt.rdtDropMsg 158251, 158300

execute rdt.rdtAddMsg 158251, 10, '158251^NoSuitableLOC', 'us_english', 1819

--SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 158251 AND 158300

