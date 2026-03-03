EXECUTE rdt.rdtDropMsg 258951, 259000

EXECUTE rdt.rdtAddMsg 258951, 10, '258951 DropIDNeeded',    'us_english', 1641, 0,  '258951 DropID is needed'
EXECUTE rdt.rdtAddMsg 258952, 10, '258952 InvDropID',       'us_english', 1641, 0,  '258952 Invalid DropID'
EXECUTE rdt.rdtAddMsg 258953, 10, '258953 DropIDInUse',     'us_english', 1641, 0,  '258953 DropID is in use'
EXECUTE rdt.rdtAddMsg 258954, 10, '258954 PickNotDone',     'us_english', 1641, 0,  '258954 Picking is not completed yet'
EXECUTE rdt.rdtAddMsg 258955, 10, '258955 DropIDShipped',   'us_english', 1641, 0,  '258955 DropID is shipped'
EXECUTE rdt.rdtAddMsg 258956, 10, '258956 InvDropID',       'us_english', 1641, 0,  '258956 Invalid DropID'
EXECUTE rdt.rdtAddMsg 258957, 10, '258957 NoUCCOnDropID',       'us_english', 1641, 0,  ' '

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 258951 AND 259000
