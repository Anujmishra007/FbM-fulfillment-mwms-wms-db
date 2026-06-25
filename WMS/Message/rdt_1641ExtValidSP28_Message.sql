-- rdt_1641ExtValidSP28
-- FCR-13319
EXECUTE rdt.rdtDropMsg 271251, 271300

EXECUTE rdt.rdtAddMsg 271251, 10, '271251^InvUCC',  'us_english', 1641, 0, '271251 Scanned value does not exist in PackDetail'
EXECUTE rdt.rdtAddMsg 271252, 10, '271252^InvUCC',  'us_english', 1641, 0, '271252 Scanned value does not exist in PackDetail'
EXECUTE rdt.rdtAddMsg 271253, 10, '271253^InvUCC',  'us_english', 1641, 0, '271253 Invalid UCC'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 271251 AND 271300