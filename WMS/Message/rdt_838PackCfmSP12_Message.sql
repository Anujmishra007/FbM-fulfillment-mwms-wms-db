--rdt_838PackCfmSP12
--execute rdt.rdtdropmsg 262651, 262700
execute rdt.rdtDropMsg 262651, 262700

execute rdt.rdtAddMsg 262651, 10, '262651^InsPKInfoFail',         'us_english', 838, 0, '262651: Insert PackInfo failed'
execute rdt.rdtAddMsg 262652, 10, '262652^UpdPDStatusFail',       'us_english', 838, 0, '262652: Update PickDetail Status failed'
execute rdt.rdtAddMsg 262653, 10, '262653^MoveInvFail',           'us_english', 838, 0, '262653: Move Inventory failed'
execute rdt.rdtAddMsg 262654, 10, '262654^InvalidFromDropID',     'us_english', 838, 0, '262654: FromDropID Not Exists in LotxLocxID'
execute rdt.rdtAddMsg 262655, 10, '262655^MoveQtyPickOff',        'us_english', 838, 0, '262655: Must enable MoveQTYPick config'
execute rdt.rdtAddMsg 262656, 10, '262656^UpdPackDtlFail',        'us_english', 838, 0, '262656: Update PackDetail failed'

--FCR-11343
execute rdt.rdtAddMsg 262657, 10, '262657^UpdPackHdFail',         'us_english', 838, 0, '262657: Update PackHeader failed'

select * from rdt.rdtmsg (nolock) where message_id between 262651 and 262700
