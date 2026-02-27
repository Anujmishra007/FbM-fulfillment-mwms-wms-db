--rdt_830ExtVal06
--UWP-45993
EXECUTE rdt.rdtdropmsg 255101, 255150

EXECUTE rdt.rdtAddMsg 255101, 10, '255101 NeedDropID',         'us_english', 830, 0, '255101 Need DropID'
EXECUTE rdt.rdtAddMsg 255102, 10, '255102 DropIDIsUsed',       'us_english', 830, 0, '255102 DropID is used'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 255101 AND 255150