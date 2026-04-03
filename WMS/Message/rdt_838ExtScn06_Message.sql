--rdt_838ExtScn05_Message
--FCR-8931
EXEC rdt.rdtdropmsg 253201 , 253250

EXECUTE rdt.rdtAddMsg 253201, 10, '253201 DropIDNotExists',       'us_english', 838, 0, '253201 DropIDNotExists'
EXECUTE rdt.rdtAddMsg 253202, 10, '253202 InvalidOption',         'us_english', 838, 0, '253202 InvalidOption'

--FCR-11343
EXECUTE rdt.rdtAddMsg 253203, 10, '253203^SKUNotInDropID',        'us_english', 838, 0, '253203 SKU not in DropID'
EXECUTE rdt.rdtAddMsg 253204, 10, '253204^OrdLockedByUsr',        'us_english', 838, 0, '253204 Order locked by user'
EXECUTE rdt.rdtAddMsg 253205, 10, '253205^NoB2CSingleOrd',        'us_english', 838, 0, '253205 No B2C Single Order'
EXECUTE rdt.rdtAddMsg 253206, 10, '253206^PackInfoNotFnd',        'us_english', 838, 0, '253206 Pack info not found'

SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 253201 AND 253250