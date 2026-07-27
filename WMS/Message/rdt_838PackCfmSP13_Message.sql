--rdt_838PackCfmSP13
--execute rdt.rdtdropmsg 273251, 273300
execute rdt.rdtDropMsg 273251, 273300

execute rdt.rdtAddMsg 273251, 10, '273251^InsPickDtlFail',   'us_english', 838, 0, '273251: Insert @tPickDetail failed'
execute rdt.rdtAddMsg 273252, 10, '273252^PackQty>PickQty',  'us_english', 838, 0, '273252: PackQty > PickQty. Skip Inv movement'
execute rdt.rdtAddMsg 273253, 10, '273253^UpdPKDDropIDFail', 'us_english', 838, 0, '273253: Update PickDetail DropID failed'
execute rdt.rdtAddMsg 273254, 10, '273254^UpdPKDStatusFail', 'us_english', 838, 0, '273254: Update PickDetail Status failed'
execute rdt.rdtAddMsg 273255, 10, '273255^UpdPHdrStatusFail',      'us_english', 838, 0, '273255: Update PackHeader Status failed'
execute rdt.rdtAddMsg 273256, 10, '273256^InsB2CSPickDtlFail',     'us_english', 838, 0, '273256: Insert @tPickDetail failed (B2C Single)'
execute rdt.rdtAddMsg 273257, 10, '273257^B2CSPackQty>ExpPackQty', 'us_english', 838, 0, '273257: PackQty > ExpPackQty (B2C Single over-pack)'
execute rdt.rdtAddMsg 273258, 10, '273258^InsPackDtlKeyFail',      'us_english', 838, 0, '273258: Insert @tPackDetail keys failed'
execute rdt.rdtAddMsg 273259, 10, '273259^UpdPackDtlDropIDFail',   'us_english', 838, 0, '273259: Update PackDetail DropID (ARCH) failed'

select * from rdt.rdtmsg (nolock) where message_id between 273251 and 273300
