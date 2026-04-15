-- rdt_514ExtScn01
-- FCR-11631
execute rdt.rdtDropMsg 263451, 263500

execute rdt.rdtAddMsg 263451, 10, '263451 UCC needed',     'us_english', 514
execute rdt.rdtAddMsg 263452, 10, '263452 UCC DoubleScan', 'us_english', 514

EXECUTE rdt.rdtAddMsg 263453, 10, '263453 InvUCC',                'us_english', 514, 0, '263453 UCC belongs to an active task'
EXECUTE rdt.rdtAddMsg 263454, 10, '263454 InvUCC',                'us_english', 514, 0, '263454 UCC not received'
EXECUTE rdt.rdtAddMsg 263455, 10, '263455 InvUCC',                'us_english', 514, 0, '263455 UCC is allocated'
EXECUTE rdt.rdtAddMsg 263456, 10, '263456 InvUCC',                'us_english', 514, 0, '263456 UCC is picked'
EXECUTE rdt.rdtAddMsg 263457, 10, '263457 InvUCC',                'us_english', 514, 0, '263457 UCC is consumed'
EXECUTE rdt.rdtAddMsg 263458, 10, '263458 InvUCC',                'us_english', 514, 0, '263458 Invalid UCC status'
EXECUTE rdt.rdtAddMsg 263459, 10, '263459 InvUCC',                'us_english', 514, 0, '263459 UCC does not exist'
EXECUTE rdt.rdtAddMsg 263460, 10, '263460 InvUCC',                'us_english', 514, 0, '263460 UCC Status is 4'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 263451 AND 263500