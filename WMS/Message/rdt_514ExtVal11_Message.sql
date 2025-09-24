-- rdt_514ExtVal11
-- FCR-8145
EXECUTE rdt.rdtDropMsg 247251, 247300

EXECUTE rdt.rdtAddMsg 247251, 10, '247251 ExceedMaxCarton',       'us_english', 514, 0, '247251 Exceed max carton for location'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 247251 AND 247300