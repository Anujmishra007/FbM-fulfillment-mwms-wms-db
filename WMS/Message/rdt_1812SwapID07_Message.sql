--rdt_1812SwapID07
--276101 - 276150


exec rdt.rdtDropMsg 276101, 276150

execute rdt.rdtAddMsg 276101, 10, '276101^NewIDIsEmpty',         'us_english', 1812, 0, '276101: New ID is empty'
execute rdt.rdtAddMsg 276102, 10, '276102^TaskNotFound',         'us_english', 1812, 0, '276102: Task not found'
execute rdt.rdtAddMsg 276103, 10, '276103^PickMethodNotFP',      'us_english', 1812, 0, '276103: PickMethod is not FP'
execute rdt.rdtAddMsg 276104, 10, '276104^InvalidPalletID',      'us_english', 1812, 0, '276104: Invalid pallet ID'
execute rdt.rdtAddMsg 276105, 10, '276105^IDMultiRec',           'us_english', 1812, 0, '276105: New ID must have one lot'
execute rdt.rdtAddMsg 276106, 10, '276106^IDOnHold',             'us_english', 1812, 0, '276106: New ID is on hold'
execute rdt.rdtAddMsg 276107, 10, '276107^LocNotMatch',          'us_english', 1812, 0, '276107: Loc Not Match'
execute rdt.rdtAddMsg 276108, 10, '276108^SKUNotMatch',          'us_english', 1812, 0, '276108: SKU Not Match'
execute rdt.rdtAddMsg 276109, 10, '276109^QtyNotMatch',          'us_english', 1812, 0, '276109: QTY Not Match'
execute rdt.rdtAddMsg 276110, 10, '276110^TaskIsTaken',          'us_english', 1812, 0, '276110: Executed task exists on new ID'
execute rdt.rdtAddMsg 276111, 10, '276111^IDHasOpenTask',        'us_english', 1812, 0, '276111: NewID has open tasks'
execute rdt.rdtAddMsg 276112, 10, '276112^DiffWave',             'us_english', 1812, 0, '276112: New ID allocated to different wave'
execute rdt.rdtAddMsg 276113, 10, '276113^UpdTaskFail',          'us_english', 1812, 0, '276113: Update task fail'
execute rdt.rdtAddMsg 276114, 10, '276114^UpdTaskFail',          'us_english', 1812, 0, '276114: Update task fail'
execute rdt.rdtAddMsg 276115, 10, '276115^UpdNewIDTaskFail',     'us_english', 1812, 0, '276115: Update NewID task fail'
execute rdt.rdtAddMsg 276116, 10, '276116^UpdNewIDTaskFail',     'us_english', 1812, 0, '276116: Update NewID task fail'
execute rdt.rdtAddMsg 276117, 10, '276117^GetKeyFail',           'us_english', 1812, 0, '276117: GetKey fail (task re-alloc)'
execute rdt.rdtAddMsg 276118, 10, '276118^GetKeyFail',           'us_english', 1812, 0, '276118: GetKey fail (bilateral re-alloc)'
execute rdt.rdtAddMsg 276119, 10, '276119^NoLotOnNewID',         'us_english', 1812, 0, '276119: No lot available on new ID'
execute rdt.rdtAddMsg 276120, 10, '276120^UnalloTaskPKDFail',   'us_english', 1812, 0, '276120: Unallocate task pickdetail fail'
execute rdt.rdtAddMsg 276121, 10, '276121^DelTaskPKDFail',      'us_english', 1812, 0, '276121: Delete task pickdetail fail'
execute rdt.rdtAddMsg 276122, 10, '276122^CreateTaskPKDFail',   'us_english', 1812, 0, '276122: Create task pickdetail fail'
execute rdt.rdtAddMsg 276123, 10, '276123^NoLotOnOrigID',       'us_english', 1812, 0, '276123: No lot available on original ID'
execute rdt.rdtAddMsg 276124, 10, '276124^UnalloNewIDPKDFail',  'us_english', 1812, 0, '276124: Unallocate NewID pickdetail fail'
execute rdt.rdtAddMsg 276125, 10, '276125^DelNewIDPKDFail',     'us_english', 1812, 0, '276125: Delete NewID pickdetail fail'
execute rdt.rdtAddMsg 276126, 10, '276126^CreateNewIDPKDFail',  'us_english', 1812, 0, '276126: Create NewID pickdetail fail'
execute rdt.rdtAddMsg 276127, 10, '276127^QtyNotMatch',          'us_english', 1812, 0, '276127: QTY Not Match'
execute rdt.rdtAddMsg 276128, 10, '276128^OrdListEmptyTaskID',   'us_english', 1812, 0, '276128: Order list empty for task ID re-alloc'
execute rdt.rdtAddMsg 276129, 10, '276129^OrdListEmptyNewID',    'us_english', 1812, 0, '276129: Order list empty for new ID re-alloc'
execute rdt.rdtAddMsg 276130, 10, '276130^ResetTaskFail',        'us_english', 1812, 0, '276130: Reset current task fail'
execute rdt.rdtAddMsg 276131, 10, '276131^TakeNewTaskFail',      'us_english', 1812, 0, '276131: Take new ID task fail'


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 276101 AND 276150
