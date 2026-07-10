
--rdt_838ExtUpd37.sql
--FCR-14271 - Carton Split for Columbia UK
--273651 - 273700

exec rdt.rdtdropmsg 273651, 273700

execute rdt.rdtAddMsg 273651, 10, '273651^Pack detail not found ',                 'us_english', 838, 0, '273651 Pack detail not found'
execute rdt.rdtAddMsg 273652, 10, '273652^Insufficient qty to split',              'us_english', 838, 0, '273652 Insufficient qty to split'
execute rdt.rdtAddMsg 273653, 10, '273653^PackInfo not found',                     'us_english', 838, 0, '273653 PackInfo not found'
execute rdt.rdtAddMsg 273654, 10, '273654^Insert PackDetail failed',               'us_english', 838, 0, '273654 Insert PackDetail failed'
execute rdt.rdtAddMsg 273655, 10, '273655^Insert PackDetail failed',               'us_english', 838, 0, '273655 Insert PackDetail failed'
execute rdt.rdtAddMsg 273656, 10, '273656^Update original PackDetail failed',      'us_english', 838, 0, '273656 Update original PackDetail failed'
execute rdt.rdtAddMsg 273657, 10, '273657^Insert PackInfo failed',                 'us_english', 838, 0, '273657 Insert PackInfo failed'
execute rdt.rdtAddMsg 273658, 10, '273658^Insert PickDetail failed',               'us_english', 838, 0, '273658 Insert PickDetail failed'
execute rdt.rdtAddMsg 273659, 10, '273659^Update original PickDetail failed',      'us_english', 838, 0, '273659 Update original PickDetail failed'
execute rdt.rdtAddMsg 273660, 10, '273660^Error Executing isp_GenUCCLabelNo_Std',  'us_english', 838, 0, '273660 Error Executing isp_GenUCCLabelNo_Std'
execute rdt.rdtAddMsg 273661, 10, '273661^Update PackDetail failed',               'us_english', 838, 0, '273661 Update PackDetail failed'
execute rdt.rdtAddMsg 273662, 10, '273662^Update PickDetail failed',               'us_english', 838, 0, '273662 Update PickDetail failed'
execute rdt.rdtAddMsg 273663, 10, '273663^Update PackInfo failed',                 'us_english', 838, 0, '273663 Update PackInfo failed'
execute rdt.rdtAddMsg 273664, 10, '273664^Update TaskDetail Status failed',        'us_english', 838, 0, '273664 Update TaskDetail Status failed'

select * from rdt.rdtmsg (nolock) where message_id between 273651 AND 273700
