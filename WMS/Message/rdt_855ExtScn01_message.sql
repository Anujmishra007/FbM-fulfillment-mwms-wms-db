--rdt_855ExtScn01
rdt.rdtDropMsg 217351, 217400

execute rdt.rdtAddMsg 217351, 10, '217351 InvalidOption',    'us_english', 855
execute rdt.rdtAddMsg 217352, 10, '217352 CtnIdReq',         'us_english', 855, 0, '217352: DropID or CaseID required'
execute rdt.rdtAddMsg 217353, 10, '217353 CaseIdInvalid',    'us_english', 855, 0, '217353: DropID or CaseID invalid'
execute rdt.rdtAddMsg 217354, 10, '217354 CaseIdInvalid',    'us_english', 855, 0, '217354: Miss PackDetail Data'
execute rdt.rdtAddMsg 217355, 10, '217355SKURequired',       'us_english', 855, 0, '217355: SKU is required'
execute rdt.rdtAddMsg 217356, 10, '217356InvalidSKU',        'us_english', 855, 0, '217356: Invalid SKU'
execute rdt.rdtAddMsg 217357, 10, '217357MultiSKUBarcode',   'us_english', 855, 0, '217357: Multiple SKU Barcode'
execute rdt.rdtAddMsg 217358, 10, '217358SKUNotInDropID',    'us_english', 855, 0, '217358: SKU not in carton'
execute rdt.rdtAddMsg 217359, 10, '217359SKUAllPacked',      'us_english', 855, 0, '217359: This SKU is all packed'
execute rdt.rdtAddMsg 217360, 10, '217360MulipleOrders',     'us_english', 855, 0, '217360: Muliple orders but MPOC is disallowed'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 217351 AND 217400