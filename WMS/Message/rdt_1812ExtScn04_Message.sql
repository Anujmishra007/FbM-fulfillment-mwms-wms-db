--rdt_1812ExtScn04   FCR-989
EXEC rdt.rdtdropmsg 228201 , 228250

EXECUTE rdt.rdtAddMsg 228201, 10, '228201^Option needed ', 'us_english', 1812 , 0, '228201^Option is needed.'
EXECUTE rdt.rdtAddMsg 228202, 10, '228202^Invalid Option', 'us_english', 1812 , 0, '228202^Invalid Option '


SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 228201 AND 228250
