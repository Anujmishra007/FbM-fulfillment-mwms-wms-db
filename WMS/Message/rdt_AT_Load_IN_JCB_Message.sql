-- UWP-38988
-- rdt_AT_Load_IN
EXECUTE rdt.rdtDropMsg 244301, 244350

EXECUTE rdt.rdtAddMsg 244301 ,10, '244301InvApptNo',     'us_english', 652
EXECUTE rdt.rdtAddMsg 244302, 10, '244302InvStatus',     'us_english', 652
EXECUTE rdt.rdtAddMsg 244303, 10, '244303UpdBOFail',     'us_english', 652
EXECUTE rdt.rdtAddMsg 244304, 10, '244304InsBEFail',     'us_english', 652
EXECUTE rdt.rdtAddMsg 244305, 10, '244305BOFinished',    'us_english', 652, 0, '244305 Book No is finished'
EXECUTE rdt.rdtAddMsg 244306, 10, '244306NoEventCode',   'us_english', 652, 0, '244306 No Event Code found'
EXECUTE rdt.rdtAddMsg 244307, 10, '24430InsBEFail',      'us_english', 652, 0, '244307 Insert Booking Vehicle failed'
EXECUTE rdt.rdtAddMsg 244308, 10, '244308UpdBEFail',     'us_english', 652, 0, '244308 Update Booking Vehicle failed'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 244301 AND 244350