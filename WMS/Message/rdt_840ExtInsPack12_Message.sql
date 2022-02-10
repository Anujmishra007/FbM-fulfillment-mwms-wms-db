--rdt_840ExtInsPack12
execute rdt.rdtDropMsg 158651 , 158700

execute rdt.rdtAddMsg 158651, 10, '58651^UpdLog Failed',    'us_english', 840
execute rdt.rdtAddMsg 158652, 10, '58652^InsLog Failed',    'us_english', 840
execute rdt.rdtAddMsg 158653, 10, '58653^InsPKHDR Failed',  'us_english', 840
execute rdt.rdtAddMsg 158654, 10, '58654^UPDPKDET Failed',  'us_english', 840
execute rdt.rdtAddMsg 158655, 10, '58655^NO TRACKING #',    'us_english', 840
execute rdt.rdtAddMsg 158656, 10, '58656^NO TRACKING #',    'us_english', 840
execute rdt.rdtAddMsg 158657, 10, '58657^UPD TRACK# Err',   'us_english', 840
execute rdt.rdtAddMsg 158658, 10, '58658^GenLabelNoFail',   'us_english', 840
execute rdt.rdtAddMsg 158659, 10, '58659^Inv Doctype',      'us_english', 840
execute rdt.rdtAddMsg 158660, 10, '58660^GET LABEL Fail',   'us_english', 840
execute rdt.rdtAddMsg 158661, 10, '158661^INS PACK Fail',   'us_english', 840
execute rdt.rdtAddMsg 158662, 10, '158662^INS PACK Fail',   'us_english', 840
execute rdt.rdtAddMsg 158663, 10, '158663^Upd Case Fail',   'us_english', 840
execute rdt.rdtAddMsg 158664, 10, '158664^Upd Case Fail',   'us_english', 840
execute rdt.rdtAddMsg 158665, 10, '158665^Get PDKey Fail',  'us_english', 840
execute rdt.rdtAddMsg 158666, 10, '158666^Ins PDtl Fail',   'us_english', 840
execute rdt.rdtAddMsg 158667, 10, '158667^Upd Case Fail',   'us_english', 840


SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 158651 AND 158700