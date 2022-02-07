--rdt_840ExtInsPack14
exec rdt.rdtDropMsg 165751  , 165800

execute rdt.rdtAddMsg 165751, 10, '165751UpdLog Failed',   'us_english', 840
execute rdt.rdtAddMsg 165752, 10, '165752InsLog Failed',   'us_english', 840
execute rdt.rdtAddMsg 165753, 10, '165753InsPKHDR Failed',  'us_english', 840
execute rdt.rdtAddMsg 165754, 10, '165754UPDPKDET Failed',  'us_english', 840
execute rdt.rdtAddMsg 165755, 10, '165755NO TRACKING #',  'us_english', 840
execute rdt.rdtAddMsg 165756, 10, '165756NO TRACKING #',  'us_english', 840
execute rdt.rdtAddMsg 165757, 10, '165757ASSIGN TRACK# Err',  'us_english', 840
execute rdt.rdtAddMsg 165758, 10, '165758GET LABEL Fail',  'us_english', 840
execute rdt.rdtAddMsg 165759, 10, '165759INS PACK Fail',  'us_english', 840
execute rdt.rdtAddMsg 165760, 10, '165760INS PACK Fail',  'us_english', 840
execute rdt.rdtAddMsg 165761, 10, '165761Upd Case Fail',   'us_english', 840
execute rdt.rdtAddMsg 165762, 10, '165762Upd Case Fail',   'us_english', 840
execute rdt.rdtAddMsg 165763, 10, '165763Get PDKey Fail',   'us_english', 840
execute rdt.rdtAddMsg 165764, 10, '165764Ins PDtl Fail',   'us_english', 840
execute rdt.rdtAddMsg 165765, 10, '165765Upd Case Fail',   'us_english', 840
execute rdt.rdtAddMsg 165766, 10, '165766InsPKSN Failed',   'us_english', 840
execute rdt.rdtAddMsg 165767, 10, '165767InsPKSN Failed',   'us_english', 840
execute rdt.rdtAddMsg 165768, 10, '165768InsPKSN Failed',   'us_english', 840
execute rdt.rdtAddMsg 165769, 10, '165769WrongSeialno',   'us_english', 840
execute rdt.rdtAddMsg 165770, 10, '165770Duplicateserialno',   'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 133401 and 133450



