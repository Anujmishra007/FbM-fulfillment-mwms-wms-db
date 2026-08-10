-- rdt_1641ExtValidSP28
-- FCR-13319
EXECUTE rdt.rdtDropMsg 271251, 271300

EXECUTE rdt.rdtAddMsg 271251, 10, '271251^InvUCC',           'us_english', 1641, 0, '271251 Scanned value does not exist in PickDetail'
EXECUTE rdt.rdtAddMsg 271252, 10, '271252^WrongPkSta',       'us_english', 1641, 0, '271252 Wrong pick status'
EXECUTE rdt.rdtAddMsg 271253, 10, '271253^InvUCC',           'us_english', 1641, 0, '271253 UCC has been scanned'
EXECUTE rdt.rdtAddMsg 271254, 10, '271254^DiffWaveKey',      'us_english', 1641, 0, '271254 Different WaveKey than the one packed'
EXECUTE rdt.rdtAddMsg 271255, 10, '271255^WrongPkSta',       'us_english', 1641, 0, '271255 Wrong pick status'
EXECUTE rdt.rdtAddMsg 271256, 10, '271256^InvUCC',           'us_english', 1641, 0, '271256 Scanned value does not exist in PackDetail'
EXECUTE rdt.rdtAddMsg 271257, 10, '271257^InvUCC',           'us_english', 1641, 0, '271257 Invalid UCC'
EXECUTE rdt.rdtAddMsg 271258, 10, '271258^InvUCC',           'us_english', 1641, 0, '271258 UCC has been scanned'
EXECUTE rdt.rdtAddMsg 271259, 10, '271259^DiffVehicle',      'us_english', 1641, 0, '271259 Different Intermodal Vehicle'
EXECUTE rdt.rdtAddMsg 271260, 10, '271260^DiffWaveKey',      'us_english', 1641, 0, '271260 Different WaveKey'
EXECUTE rdt.rdtAddMsg 271261, 10, '271261^DiffConsigneeKey', 'us_english', 1641, 0, '271261 Different ConsigneeKey'
EXECUTE rdt.rdtAddMsg 271262, 10, '271262^InvLoc',           'us_english', 1641, 0, '271262 Invalid Loc'

-- UWP-63642
EXECUTE rdt.rdtAddMsg 271263, 10, '271263^InvLocType',       'us_english', 1641, 0, '271263 Location Type must be POSTPICK or STAGEOB'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 271251 AND 271300
