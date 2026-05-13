-- rdt_593ReleaseTote
-- FCR-12667
EXECUTE rdt.rdtDropMsg 266251, 266300

EXECUTE rdt.rdtAddMsg 266251, 10, '266251 DropIDRequired',                 'us_english', 593, 0, '266251 DropID Required'
EXECUTE rdt.rdtAddMsg 266252, 10, '266252 InvDropID',                      'us_english', 593, 0, '266252 Invalid DropID'
EXECUTE rdt.rdtAddMsg 266253, 10, '266253 InvDropID',                      'us_english', 593, 0, '266253 Invalid DropID'

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 266251 AND 266300