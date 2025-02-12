-- rdt_922ExtVal15
--UWP-28347
EXECUTE rdt.rdtDropMsg 230701, 230750

EXECUTE rdt.rdtAddMsg 230701, 10, '230701Diff Door     ',      'us_english', 922
EXECUTE rdt.rdtAddMsg 230702, 10, '230702EmptyDoorEntry',      'us_english', 922
EXECUTE rdt.rdtAddMsg 230703, 10, '230703Diff Door     ',      'us_english', 922
EXECUTE rdt.rdtAddMsg 230704, 10, '230704EmptyVelEntry',       'us_english', 922, 0, '230704 Empty Vehicle Entry'
EXECUTE rdt.rdtAddMsg 230705, 10, '230705DiffVehicle',         'us_english', 922

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 230701 AND 230750