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
execute rdt.rdtAddMsg 262680, 10, '262680^UpdPackInfoFail',       'us_english', 838, 0, '262680: Update PackInfo failed'


--FCR-12450
execute rdt.rdtAddMsg 262658, 10, '262658^UpdPickDtlFail',        'us_english', 838, 0, '262658: Update pickdetail failed'
execute rdt.rdtAddMsg 262659, 10, '262659^UpdPKDDropIDFail',      'us_english', 838, 0, '262659: Update PickDetail DropID failed'
execute rdt.rdtAddMsg 262660, 10, '262660^MergePKDQtyFail',       'us_english', 838, 0, '262660: Merge PickDetail Qty failed'
execute rdt.rdtAddMsg 262661, 10, '262661^DelPKDDupFail',         'us_english', 838, 0, '262661: Delete PickDetail duplicates failed'
execute rdt.rdtAddMsg 262662, 10, '262662^UnalloPKDFail',         'us_english', 838, 0, '262662: Unallocate PickDetail duplicates failed'

select * from rdt.rdtmsg (nolock) where message_id between 262651 and 262700
