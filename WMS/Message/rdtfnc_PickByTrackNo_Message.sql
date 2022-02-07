--rdtfnc_PickByTrackNo
--execute rdt.rdtdropmsg 72441 - 72490


execute rdt.rdtAddMsg '72441', 10, '72441^OrderKey req', 'us_english'
execute rdt.rdtAddMsg '72442', 10, '72442^Order Picked', 'us_english'
execute rdt.rdtAddMsg '72443', 10, '72443^DelLog Failed', 'us_english'
execute rdt.rdtAddMsg '72444', 10, '72444^TrackNo req', 'us_english'
execute rdt.rdtAddMsg '72445', 10, '72445^Inv TrackNo', 'us_english'
execute rdt.rdtAddMsg '72446', 10, '72446^Upd Ord Failed', 'us_english'
execute rdt.rdtAddMsg '72447', 10, '72447^SKU req', 'us_english'
execute rdt.rdtAddMsg '72448', 10, '72448^Order Changed', 'us_english'
execute rdt.rdtAddMsg '72449', 10, '72449^InsLog Failed', 'us_english'
execute rdt.rdtAddMsg '72450', 10, '72450^UpdLog Failed', 'us_english'
execute rdt.rdtAddMsg '72451', 10, '72451^QtySugg > QtyPick', 'us_english'
execute rdt.rdtAddMsg '72452', 10, '72452^UpdPickDetFail', 'us_english'
execute rdt.rdtAddMsg '72453', 10, '72453^Inv OrderKey', 'us_english'
execute rdt.rdtAddMsg '72454', 10, '72454^UpdLog Failed', 'us_english'
execute rdt.rdtAddMsg '72455', 10, '72455^Inv ShipperKey', 'us_english'
execute rdt.rdtAddMsg '72456', 10, '72456^Inv TrackNo', 'us_english'
execute rdt.rdtAddMsg '72457', 10, '72457^Invalid SKU', 'us_english'
execute rdt.rdtAddMsg '72458', 10, '72458^GetDetKey Fail', 'us_english'
execute rdt.rdtAddMsg '72459', 10, '72459^InstPKHdr Fail', 'us_english'
execute rdt.rdtAddMsg '72460', 10, '72460^Scan In Fail', 'us_english'
execute rdt.rdtAddMsg '72461', 10, '72461^Inv TrackNo', 'us_english'
execute rdt.rdtAddMsg '72462', 10, '72462^Option Req', 'us_english'
execute rdt.rdtAddMsg '72463', 10, '72463^Inv Option', 'us_english'
execute rdt.rdtAddMsg '72464', 10, '72464^UpdPickInfoFail', 'us_english'
execute rdt.rdtAddMsg '72465', 10, '72465^InsLog Failed', 'us_english'

execute rdt.rdtAddMsg '72466', 10, '72466^UpdPickDetFail', 'us_english' -- (ChewKP01)
execute rdt.rdtAddMsg '72467', 10, '72467^Order Hold!', 'us_english' -- (ChewKP02)
execute rdt.rdtAddMsg '72468', 10, '72468^Order Hold!', 'us_english' -- (ChewKP02)
execute rdt.rdtAddMsg '72469', 10, '72469^TrackNoInUsed', 'us_english' -- (SOS#230128)
execute rdt.rdtAddMsg '72470', 10, '72470^Waiting Cancel!', 'us_english' -- (ChewKP03)


execute rdt.rdtAddMsg '72471', 10, '72471^Inv Option', 'us_english' -- (ChewKP04)

execute rdt.rdtAddMsg '72472', 10, '72472^TrackNoReq', 'us_english' -- (ChewKP05)
execute rdt.rdtAddMsg '72473', 10, '72473^Order Cancel', 'us_english' -- (ChewKP05)

execute rdt.rdtAddMsg '72474', 10, '72474^PaperPrinterReq', 'us_english' -- (ChewKP07)

execute rdt.rdtAddMsg '72475', 10, '72475^TrackNoCompleted', 'us_english' -- (ChewKP09)

select * from rdt.rdtmsg (nolock) where message_id between 72441 and 72490
