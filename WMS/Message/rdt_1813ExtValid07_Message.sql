-- 
-- UWP-48189
execute rdt.rdtdropmsg 258301, 258350

execute rdt.rdtAddMsg 258301, 10, '258301:Only B2B',  'us_english',  1813, 0,  '258301: Only B2B'
execute rdt.rdtAddMsg 258302, 10, '258302:Only B2C',  'us_english',  1813, 0,  '258302: Only B2C'

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 258301 AND 258350