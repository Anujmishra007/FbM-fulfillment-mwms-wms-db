-- rdt_Pack_LVSUSA_Confirm
execute rdt.rdtDropMsg 227601, 227650

execute rdt.rdtAddMsg 227601, 10, '227601InvalidType', 'us_english', 993, 0 , '227601 Invalid Type'
execute rdt.rdtAddMsg 227602, 10, '227602SKUNotInOriCart', 'us_english', 993, 0 , '227602 SKU Not In Orignal Carton'
execute rdt.rdtAddMsg 227603, 10, '227603GenLabelNoFail', 'us_english', 993, 0 , '227603 Generate Label No Failure'
execute rdt.rdtAddMsg 227604, 10, '227604UpdPackDetailFail', 'us_english', 993, 0 , '227604 PackDetail Update Failure'
execute rdt.rdtAddMsg 227605, 10, '227605DelPackDetailFail', 'us_english', 993, 0 , '227605 Delete PackDetail Fail'
execute rdt.rdtAddMsg 227606, 10, '227606InsPackDetailFail', 'us_english', 993, 0 , '227606 Insert PackDetail Fail'
execute rdt.rdtAddMsg 227607, 10, '227607InsPackDetailFail', 'us_english', 993, 0 , '227607 Insert PackInfo Fail'
execute rdt.rdtAddMsg 227608, 10, '227608UpdPackDetailFail', 'us_english', 993, 0 , '227608 PackDetail Update Failure'
execute rdt.rdtAddMsg 227609, 10, '227609InsPackDetailFail', 'us_english', 993, 0 , '227609 Insert PackDetail Fail'
execute rdt.rdtAddMsg 227610, 10, '227610InsMoveLogFail', 'us_english', 993, 0 , '227610 Fail to Insert MoveLog'
execute rdt.rdtAddMsg 227611, 10, '227611QtyTooGreat', 'us_english', 993, 0 , '227611 Qty is too great'
execute rdt.rdtAddMsg 227612, 10, '227612FailtoHandlePickDetail', 'us_english', 993, 0 , '227612 Fail to Handle PickDetail'


select * from rdt.rdtmsg (nolock) where message_id between 227601 AND 227650
