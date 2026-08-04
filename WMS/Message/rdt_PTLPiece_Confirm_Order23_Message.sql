--rdt_PTLPiece_Confirm_Order23
--FCR-13139: PTW/PTL Sorting Confirmation SP for AEOMX
execute rdt.rdtdropmsg 272801, 272830

-- Screen 6920 Unit-Level errors
execute rdt.rdtAddMsg 272801, 10, '272801 No Slot SKU  ', 'us_english', 803, 0, '272801 No slot found for this SKU'

-- Screen 6922 errors
execute rdt.rdtAddMsg 272802, 10, '272802 No Slot SKU  ', 'us_english', 803, 0, '272802 No slot found for this SKU'

-- Full UCC errors
execute rdt.rdtAddMsg 272803, 10, '272803 Upd Log Fail ', 'us_english', 803, 0, '272803 Failed to update PTLPieceLog'

-- Unit-Level AfterToteAssign errors
execute rdt.rdtAddMsg 272804, 10, '272804 No Slot SKU  ', 'us_english', 803, 0, '272804 No slot found for this SKU'
execute rdt.rdtAddMsg 272805, 10, '272805 Move Ref Fail', 'us_english', 803, 0, '272805 Failed to move PickDetail RefKey'
execute rdt.rdtAddMsg 272806, 10, '272806 Upd PDtl Fail', 'us_english', 803, 0, '272806 Failed to update PickDetail'
execute rdt.rdtAddMsg 272807, 10, '272807 Merge Qty Err', 'us_english', 803, 0, '272807 Failed to merge PickDetail qty'
execute rdt.rdtAddMsg 272808, 10, '272808 Merge Del Err', 'us_english', 803, 0, '272808 Failed to delete merged PickDetail'
execute rdt.rdtAddMsg 272809, 10, '272809 Get Key Fail ', 'us_english', 803, 0, '272809 Failed to get new PickDetailKey'
execute rdt.rdtAddMsg 272810, 10, '272810 Ins PDtl Fail', 'us_english', 803, 0, '272810 Failed to insert new PickDetail'
execute rdt.rdtAddMsg 272811, 10, '272811 Ins Ref Fail ', 'us_english', 803, 0, '272811 Failed to insert RefKey record'
execute rdt.rdtAddMsg 272812, 10, '272812 Upd PDtl Fail', 'us_english', 803, 0, '272812 Failed to update source PickDetail'
execute rdt.rdtAddMsg 272813, 10, '272813 Inv Move Fail', 'us_english', 803, 0, '272813 Failed to move inventory'

-- Slot completion errors
execute rdt.rdtAddMsg 272814, 10, '272814 Upd Log Fail ', 'us_english', 803, 0, '272814 Failed to update PTLPieceLog status'
execute rdt.rdtAddMsg 272815, 10, '272815 Upd Log Fail ', 'us_english', 803, 0, '272815 Failed to update PTLPieceLog status'

-- DropID completion
execute rdt.rdtAddMsg 272816, 10, '272816 DropID Done  ', 'us_english', 803, 0, '272816 DropID sorting completed'

-- Full UCC errors (FCR-13139)
execute rdt.rdtAddMsg 272817, 10, '272817 Upd Drop Fail', 'us_english', 803, 0, '272817 Failed to update DropID (Full UCC)'
execute rdt.rdtAddMsg 272818, 10, '272818 Upd Prof Fail', 'us_english', 803, 0, '272818 Failed to update DeviceProfile (Full UCC)'

-- Double-depth errors (FCR-13139)
execute rdt.rdtAddMsg 272819, 10, '272819 Upd Prof Fail', 'us_english', 803, 0, '272819 Failed to update DeviceProfile (Double-depth)'