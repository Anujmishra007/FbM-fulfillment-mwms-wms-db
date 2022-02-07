--rdt_840ExtInsPack13
execute rdt.rdtDropMsg 161701 , 161750	

execute rdt.rdtAddMsg 161701, 10, '61701^UpdLog Failed',    'us_english', 840
execute rdt.rdtAddMsg 161702, 10, '61702^InsLog Failed',    'us_english', 840
execute rdt.rdtAddMsg 161703, 10, '61703^InsPKHDR Failed',  'us_english', 840
execute rdt.rdtAddMsg 161704, 10, '61704^UPDPKDET Failed',  'us_english', 840
execute rdt.rdtAddMsg 161705, 10, '61705^NO TRACKING #',    'us_english', 840
execute rdt.rdtAddMsg 161706, 10, '61706^NO TRACKING #',    'us_english', 840
execute rdt.rdtAddMsg 161707, 10, '61707^UPD TRACK# Err',   'us_english', 840
execute rdt.rdtAddMsg 161708, 10, '61708^GET LABEL Fail',   'us_english', 840
execute rdt.rdtAddMsg 161709, 10, '61709^GenLabelNoFail',   'us_english', 840
execute rdt.rdtAddMsg 161710, 10, '61710^INS PACK Fail',    'us_english', 840
execute rdt.rdtAddMsg 161711, 10, '61712^Upd Case Fail',    'us_english', 840
execute rdt.rdtAddMsg 161713, 10, '61713^Upd Case Fail',    'us_english', 840
execute rdt.rdtAddMsg 161714, 10, '61714^Get PDKey Fail',   'us_english', 840
execute rdt.rdtAddMsg 161715, 10, '61715^Ins PDtl Fail',    'us_english', 840
execute rdt.rdtAddMsg 161716, 10, '61716^Upd Case Fail',    'us_english', 840
execute rdt.rdtAddMsg 161717, 10, '61717^GET LABEL Fail',   'us_english', 840


SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 161701 AND 161750	