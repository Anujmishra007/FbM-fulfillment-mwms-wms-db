
-- nspPendingMoveInUpdate Messages
-- **********************************************

--execute rdt.rdtDropMsg 67779, 67786

execute rdt.rdtAddMsg 67779, 10, '67779 ID is blank therefore LOT/LOC/ID/QTY/STORERKEY/SKU must be filled in. (nspPendingMoveInUpdate)', 'us_english'
execute rdt.rdtAddMsg 67780, 10, '67780 ID has been filled in therefore LOT should be blank. (nspPendingMoveInUpdate)', 'us_english'
execute rdt.rdtAddMsg 67781, 10, '67781 ID has been filled in therefore LOC must be filled in. (nspPendingMoveInUpdate)', 'us_english'
execute rdt.rdtAddMsg 67782, 10, '67782 ID has been filled in and QTY has been provided but there is MORE than one LOTxLOCxID record for this ID. (nspPendingMoveInUpdate)', 'us_english'
execute rdt.rdtAddMsg 67783, 10, '67783 Update Failed To LOTxLOCxID. (nspPendingMoveInUpdate)', 'us_english'
execute rdt.rdtAddMsg 67784, 10, '67784 Update Failed To LOTxLOCxID. (nspPendingMoveInUpdate)', 'us_english'
execute rdt.rdtAddMsg 67785, 10, '67785 Update Failed To LOTxLOCxID. (nspPendingMoveInUpdate)', 'us_english'
execute rdt.rdtAddMsg 67786, 10, '67786 Update Failed To LOTxLOCxID. (nspPendingMoveInUpdate)', 'us_english'


