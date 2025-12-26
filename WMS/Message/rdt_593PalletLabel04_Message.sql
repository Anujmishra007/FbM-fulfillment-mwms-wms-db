

-- rdt_593PalletLabel04
-- FCR-8865
EXECUTE rdt.rdtDropMsg 254101, 254150

EXECUTE rdt.rdtAddMsg 254101, 10, '254101CannotBeBlank',                'us_english', 593, 0, '254101 QTY/Prefix cannot be blank'
EXECUTE rdt.rdtAddMsg 254102, 10, '254102InvalidQty',                   'us_english', 593, 0, '254102 Invalid Qty'
EXECUTE rdt.rdtAddMsg 254103, 10, '254103InvOBLPNLabelConfig',          'us_english', 593, 0, '254103 Invalid OBLPNLabel Config'
EXECUTE rdt.rdtAddMsg 254104, 10, '254104InvOBLPNLabelConfig',          'us_english', 593, 0, '254104 Invalid OBLPNLabel Qty'
EXECUTE rdt.rdtAddMsg 254105, 10, '254105InvOBLPNLabelConfig',          'us_english', 593, 0, '254105 Invalid OBLPNLabel Prefix'
EXECUTE rdt.rdtAddMsg 254106, 10, '254106InvOBLPNLabelConfig',          'us_english', 593, 0, '254106 Invalid Prefix'
EXECUTE rdt.rdtAddMsg 254107, 10, '254107ExceededMaxQty',               'us_english', 593, 0, '254107 Exceeded Max Qty'
EXECUTE rdt.rdtAddMsg 254108, 10, '254108WrongPrefix',                  'us_english', 593, 0, '254108 Wrong Prefix'

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 254101 AND 254150