-- rdt_838ExtVal40
-- Message ID range: 263951 - 264000
EXECUTE rdt.rdtDropMsg 263951, 264000

EXECUTE rdt.rdtAddMsg 263951, 10, '263951^InvalidOption', 'us_english', 838, 0, '263951: UCC disabled under B2B UOM6'

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 263951 AND 264000
