-- rdt_514ExtVal02
-- FCR-8110
EXECUTE rdt.rdtDropMsg 247651, 247700

EXECUTE rdt.rdtAddMsg 247651, 10, '247651 Need Value',            'us_english', 1638, 0, '247651 Need OrderTracingkNo or ExternOrderKey'
EXECUTE rdt.rdtAddMsg 247652, 10, '247652 InvOrderTrackNo',       'us_english', 1638, 0, '247652 Invalid OrderTrackingNo'
EXECUTE rdt.rdtAddMsg 247653, 10, '247653 InvExternOrderKey',     'us_english', 1638, 0, '247653 Invalid ExternOrderKey'
EXECUTE rdt.rdtAddMsg 247654, 10, '247654 InvOrderType',          'us_english', 1638, 0, '247654 Order Type is not B2C or INF'
EXECUTE rdt.rdtAddMsg 247655, 10, '247655 No PickSlipNo',         'us_english', 1638, 0, '247655 No PickSliNo found'
EXECUTE rdt.rdtAddMsg 247656, 10, '247656 ConfirmFailed',         'us_english', 1638, 0, '247656 Confirm failed'
EXECUTE rdt.rdtAddMsg 247657, 10, '247657 DiffTypeOrShipperkey',  'us_english', 1638, 0, '247657 Different Order Type or ShipperKey'


SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 247651 AND 247700