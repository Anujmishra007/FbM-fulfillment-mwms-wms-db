-- rdt_922ExtVal17
EXECUTE rdt.rdtDropMsg 180021 , 180030

EXECUTE rdt.rdtAddMsg 180021, 10, '',       'us_english', 922, 0, '180021 Please Print PackSlip (Manifest) report to continue'

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 230701 AND 230750