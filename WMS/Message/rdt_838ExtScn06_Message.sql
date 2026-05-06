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
EXECUTE rdt.rdtAddMsg 253207, 10, '253207^SKUPacked',             'us_english', 838, 0, '253207 SKU is packed'
EXECUTE rdt.rdtAddMsg 253208, 10, '253208^SKUPacked',             'us_english', 838, 0, '253208 SKU is packed or SKU is in different Carton'
EXECUTE rdt.rdtAddMsg 253209, 10, '253209^SKUNotInDropID',        'us_english', 838, 0, '253209 SKU not in DropID'
EXECUTE rdt.rdtAddMsg 253210, 10, '253210^PackInfoNotFnd',        'us_english', 838, 0, '253210 Pack info not found'
EXECUTE rdt.rdtAddMsg 253211, 10, '253211^SKUPacked',             'us_english', 838, 0, '253211 SKU is packed'
EXECUTE rdt.rdtAddMsg 253221, 10, '253221^LabelDone',             'us_english', 838, 0, '253221 Label is pack done'
EXECUTE rdt.rdtAddMsg 253222, 10, '253222^UpdPackInfoFail',       'us_english', 838, 0, '253222 Update PackInfo Failed'


--FCR-12450
execute rdt.rdtAddMsg 253212, 10, '253212^Need PS/DropID',        'us_english', 838, 0, '253212 Need PS/FromDropID'
execute rdt.rdtAddMsg 253213, 10, '253213^ScanPSorDropID',        'us_english', 838, 0, '253213 Scan PS or FromDropID'
execute rdt.rdtAddMsg 253214, 10, '253214^NotB2B',                'us_english', 838, 0, '253214 Not B2B order'
execute rdt.rdtAddMsg 253215, 10, '253215^ToDropIDNotSupport',    'us_english', 838, 0, '253215 Not support To DropID'
execute rdt.rdtAddMsg 253216, 10, '253216^UpdPDFail',             'us_english', 838, 0, '253216 Update PickDetail Failed'
execute rdt.rdtAddMsg 253217, 10, '253217^DelPDFail',             'us_english', 838, 0, '253217 Delete PickDetail Failed'
execute rdt.rdtAddMsg 253218, 10, '253218^NoUOM6Picking',         'us_english', 838, 0, '253218 No UOM6 PickDetail to pack'
execute rdt.rdtAddMsg 253219, 10, '253219^FromDropIDDisabled',    'us_english', 838, 0, '253219 Must enable PackbyFromDropID'
execute rdt.rdtAddMsg 253220, 10, '253220^PSNOClosed',            'us_english', 838, 0, '253220 Closed PSNO Exists'


SELECT * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 253201 AND 253250