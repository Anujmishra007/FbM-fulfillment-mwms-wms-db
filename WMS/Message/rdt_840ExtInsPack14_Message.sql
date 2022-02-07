--rdt_840ExtInsPack14
rdt.rdtDropMsg 162701 , 162750

execute rdt.rdtAddMsg 162701, 10, '62701^UpdLog Failed',    'us_english', 840
execute rdt.rdtAddMsg 162702, 10, '62702^InsLog Failed',    'us_english', 840
execute rdt.rdtAddMsg 162703, 10, '62703^InsPKHDR Failed',  'us_english', 840
execute rdt.rdtAddMsg 162704, 10, '62704^UPDPKDET Failed',  'us_english', 840
execute rdt.rdtAddMsg 162705, 10, '62705^UPDPKDET Failed',  'us_english', 840
execute rdt.rdtAddMsg 162706, 10, '62706^GET LABEL Fail',   'us_english', 840
execute rdt.rdtAddMsg 162707, 10, '62707^GET LABEL Fail',   'us_english', 840
execute rdt.rdtAddMsg 162708, 10, '62708^GET LABEL Fail',   'us_english', 840
execute rdt.rdtAddMsg 162709, 10, '62709^INS PACK Fail',    'us_english', 840
execute rdt.rdtAddMsg 162710, 10, '62710^INS PACK Fail',    'us_english', 840
execute rdt.rdtAddMsg 162711, 10, '62711^Upd DropID Err',   'us_english', 840
execute rdt.rdtAddMsg 162712, 10, '62712^Upd DropID Err',   'us_english', 840
execute rdt.rdtAddMsg 162713, 10, '62713^Get PDKey Fail',   'us_english', 840
execute rdt.rdtAddMsg 162714, 10, '62714^Ins PDtl Fail',    'us_english', 840
execute rdt.rdtAddMsg 162715, 10, '62715^Upd DropID Err',    'us_english', 840
execute rdt.rdtAddMsg 162716, 10, '62716^Upd DropID Err',    'us_english', 840


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 162701 AND 162750