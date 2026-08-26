--rdt_840DecodeSP09
--FCR-15090
EXECUTE rdt.rdtdropmsg 277651, 277700
EXECUTE rdt.rdtAddMsg 277651, 10, '277651 InvalidQRCode',  'us_english', 840, 0, '277651 Invalid QR Code'
EXECUTE rdt.rdtAddMsg 277652, 10, '277652 InvalidQRCode',  'us_english', 840, 0, '277652 Invalid QR Code'
EXECUTE rdt.rdtAddMsg 277653, 10, '277653 InvalidSerialNo','us_english', 840, 0, '277653 Invalid Serial No'
EXECUTE rdt.rdtAddMsg 277654, 10, '277654 LabelNoExceeded', 'us_english', 840, 0, '277654 LabelNo Exceeded'
EXECUTE rdt.rdtAddMsg 277655, 10, '277655 InsSerialNo Fail','us_english', 840, 0, '277655 Ins SerialNo Fail'
EXECUTE rdt.rdtAddMsg 277656, 10, '277656 UpdLog Fail',     'us_english', 840, 0, '277656 Upd TrackLog Fail'
EXECUTE rdt.rdtAddMsg 277657, 10, '277657 InsLog Fail',     'us_english', 840, 0, '277657 Ins TrackLog Fail'
EXECUTE rdt.rdtAddMsg 277658, 10, '277658 InsPKHDR Fail',   'us_english', 840, 0, '277658 Ins PackHeader Fail'
EXECUTE rdt.rdtAddMsg 277659, 10, '277659 UpdPickDet Fail', 'us_english', 840, 0, '277659 Upd PickDetail Fail'
EXECUTE rdt.rdtAddMsg 277660, 10, '277660 UpdPackDet Fail', 'us_english', 840, 0, '277660 Upd PackDetail Fail'
EXECUTE rdt.rdtAddMsg 277661, 10, '277661 InsPackDet Fail', 'us_english', 840, 0, '277661 Ins PackDetail Fail'
EXECUTE rdt.rdtAddMsg 277662, 10, '277662 InsPackDet2 Fail','us_english', 840, 0, '277662 Ins PackDetail2 Fail'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 277651 AND 277700
