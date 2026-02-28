-- rdt_593VoidLabel01
-- FCR-1045
exec rdt.rdtDropMsg 228151, 228200

execute rdt.rdtAddMsg 228151, 10, '228151^CartonNo Need',       'us_english', 593
execute rdt.rdtAddMsg 228152, 10, '228152^StorerKey Lose',      'us_english', 593
execute rdt.rdtAddMsg 228153, 10, '228153^No Data',             'us_english', 593

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 228151 AND 228200