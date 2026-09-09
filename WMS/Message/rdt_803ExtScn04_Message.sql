--rdt_803ExtScn04
--FCR-13139: PTW/PTL Extended Screen SP for AEOMX
execute rdt.rdtdropmsg 274501, 274550

execute rdt.rdtAddMsg 274501, 10, '274501 Need ToteID  ', 'us_english', 803, 0, '274501 Please scan SortTote ID'
execute rdt.rdtAddMsg 274502, 10, '274502 Tote In Use  ', 'us_english', 803, 0, '274502 SortTote already assigned to another slot'
execute rdt.rdtAddMsg 274503, 10, '274503 Tote en uso  ', 'us_english', 803, 0, '274503 Tote en uso (Tote in progress)'
execute rdt.rdtAddMsg 274504, 10, '274504 Need Cfm LOC ', 'us_english', 803, 0, '274504 Please scan LOC to confirm'
execute rdt.rdtAddMsg 274505, 10, '274505 LOC Not Match', 'us_english', 803, 0, '274505 Scanned LOC does not match destination'
execute rdt.rdtAddMsg 274506, 10, '274506 Upd Slot Fail', 'us_english', 803, 0, '274506 Failed to update slot status'
execute rdt.rdtAddMsg 274507, 10, '274507 No DropID    ', 'us_english', 803, 0, '274507 No DropID found for this user'

--FCR-13139: NODROPID error codes (unique per code path for debugging)
execute rdt.rdtAddMsg 274508, 10, '274508 DropID Sorted', 'us_english', 803, 0, '274508 DropID/UCC sorting complete'
execute rdt.rdtAddMsg 274509, 10, '274509 DropID Sorted', 'us_english', 803, 0, '274509 DropID/UCC sorting complete'
execute rdt.rdtAddMsg 274510, 10, '274510 DropID Sorted', 'us_english', 803, 0, '274510 DropID/UCC sorting complete'

--FCR-13139: SLOTCOMPLETE error codes (SC - slot complete, prioritize showing slot complete message)
execute rdt.rdtAddMsg 274511, 10, '274511 Slot Complete', 'us_english', 803, 0, '274511 Listo para packing (Slot Complete)'
execute rdt.rdtAddMsg 274512, 10, '274512 Slot Complete', 'us_english', 803, 0, '274512 Listo para packing (Slot Complete)'
execute rdt.rdtAddMsg 274513, 10, '274513 Slot Complete', 'us_english', 803, 0, '274513 Listo para packing (Slot Complete)'

--FCR-13139: PARTIAL COMPLETE error codes (PC - DropID has more VCs without slot, continue scan)
execute rdt.rdtAddMsg 274514, 10, '274514 Partial Done ', 'us_english', 803, 0, '274514 Partial complete, continue scan DropID'
execute rdt.rdtAddMsg 274515, 10, '274515 Partial Done ', 'us_english', 803, 0, '274515 Partial complete, continue scan DropID'

--FCR-13139: Update SortTote failed
execute rdt.rdtAddMsg 274516, 10, '274516 Upd Tote Fail', 'us_english', 803, 0, '274516 Failed to update SortTote assignment'

--FCR-13139: Update PTLPieceLog CartonID failed
execute rdt.rdtAddMsg 274517, 10, '274517 Upd Log Ctn  ', 'us_english', 803, 0, '274517 Failed to update PTLPieceLog CartonID'

--UWP-66208: Confirm SP exception
execute rdt.rdtAddMsg 274518, 10, '274518 Confirm Fail ', 'us_english', 803, 0, '274518 Confirm SP failed with exception'
