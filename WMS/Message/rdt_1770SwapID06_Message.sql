--rdt_1770SwapID06
--execute rdt.rdtdropmsg 261751 - 261800
execute rdt.rdtDropMsg 261751, 261800

execute rdt.rdtAddMsg 261751 ,10, '261751^NeedID', 'us_english', 1878, 0, '261751: Need ID'
execute rdt.rdtAddMsg 261752 ,10, '261752^IDIsOnHold', 'us_english', 1878, 0, '261752: ID Is On Hold'
execute rdt.rdtAddMsg 261753 ,10, '261753^BadTaskDtlKey', 'us_english', 1878, 0, '261753: Task Not Found'
--execute rdt.rdtAddMsg 261754 ,10, '261754^SwapIDDisallow', 'us_english', 1878, 0, '261754: Swap ID Disallowed For This Location Type'
execute rdt.rdtAddMsg 261755 ,10, '261755^InvalidID', 'us_english', 1878, 0, '261755: Invalid ID'
execute rdt.rdtAddMsg 261756 ,10, '261756^IDMultiRec', 'us_english', 1878, 0, '261756: ID Has Multiple Records'
execute rdt.rdtAddMsg 261757 ,10, '261757^LOCNotMatch', 'us_english', 1878, 0, '261757: Location Not Match'
execute rdt.rdtAddMsg 261758 ,10, '261758^SKUNotMatch', 'us_english', 1878, 0, '261758: SKU Not Match'
execute rdt.rdtAddMsg 261759 ,10, '261759^QTYNotMatch', 'us_english', 1878, 0, '261759: QTY Not Match'
execute rdt.rdtAddMsg 261760 ,10, '261760^IDPicked', 'us_english', 1878, 0, '261760: ID Already Picked'
execute rdt.rdtAddMsg 261761 ,10, '261761^IDTaskExecuted', 'us_english', 1878, 0, '261761: NewID task is executed'
execute rdt.rdtAddMsg 261762 ,10, '261762^IDHasOpenTask', 'us_english', 1878, 0, '261762: There is an open task on new ID'
execute rdt.rdtAddMsg 261763 ,10, '261763^IDLocked', 'us_english', 1878, 0, '261763: ID locked'
execute rdt.rdtAddMsg 261764 ,10, '261764^UpdTaskFail', 'us_english', 1878, 0, '261764: Update ID Task Fail'
execute rdt.rdtAddMsg 261765 ,10, '261765^UpdTaskFail', 'us_english', 1878, 0, '261765: Update NewID Task Fail'
execute rdt.rdtAddMsg 261766 ,10, '261766^UnalloPKDFail', 'us_english', 1878, 0, '261766: Unallocate Task PickDetail Fail'
execute rdt.rdtAddMsg 261767 ,10, '261767^UnalloPKDFail', 'us_english', 1878, 0, '261767: Unallocate New ID PickDetail Fail'
execute rdt.rdtAddMsg 261768 ,10, '261768^RealloPKDFail', 'us_english', 1878, 0, '261768: Reallocate PickDetail Fail'
execute rdt.rdtAddMsg 261769 ,10, '261769^UpdTaskFail', 'us_english', 1878, 0, '261769: Update ID Task Fail'
execute rdt.rdtAddMsg 261770 ,10, '261770^UpdTaskFail', 'us_english', 1878, 0, '261770: Update NewID Task Fail'

select * from rdt.rdtmsg (nolock) where message_id between 261751 and 261800