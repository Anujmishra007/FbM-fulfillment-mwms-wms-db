-- rdt_1812SwapUCC05
exec rdt.rdtDropMsg 269951, 270000

execute rdt.rdtAddMsg 269951, 10, '269951^BadTaskDtlKey',    'us_english', 1812, 0, '269951: Task detail key not found'
execute rdt.rdtAddMsg 269952, 10, '269952^UCCScanned',       'us_english', 1812, 0, '269952: UCC already scanned'
execute rdt.rdtAddMsg 269953, 10, '269953^InvalidUCC',       'us_english', 1812, 0, '269953: Not a valid UCC label'
execute rdt.rdtAddMsg 269954, 10, '269954^MultiSKUUCC',      'us_english', 1812, 0, '269954: Multiple SKUs UCC'
execute rdt.rdtAddMsg 269955, 10, '269955^InvUCCStatus',     'us_english', 1812, 0, '269955: Invalid UCC status'
execute rdt.rdtAddMsg 269956, 10, '269956^SKUMismatch',      'us_english', 1812, 0, '269956: UCC SKU mismatch'
execute rdt.rdtAddMsg 269957, 10, '269957^LOCMismatch',      'us_english', 1812, 0, '269957: UCC LOC mismatch'
execute rdt.rdtAddMsg 269958, 10, '269958^QTYMismatch',      'us_english', 1812, 0, '269958: UCC QTY mismatch'
execute rdt.rdtAddMsg 269959, 10, '269959^LOTMismatch',      'us_english', 1812, 0, '269959: UCC LOT mismatch'
execute rdt.rdtAddMsg 269960, 10, '269960^UCCTaken',         'us_english', 1812, 0, '269960: UCC is taken by other task'
execute rdt.rdtAddMsg 269961, 10, '269961^UCCPicked',        'us_english', 1812, 0, '269961: UCC is picked'
execute rdt.rdtAddMsg 269962, 10, '269962^InvalidTaskType',  'us_english', 1812, 0, '269962: Invalid task type for UCC swap'
execute rdt.rdtAddMsg 269963, 10, '269963^TaskNotFound',     'us_english', 1812, 0, '269963: Task not found for the UCC'
execute rdt.rdtAddMsg 269964, 10, '269964^UpdTskDtlFail',   'us_english', 1812, 0, '269964: Update task detail fail'
execute rdt.rdtAddMsg 269965, 10, '269965^UpdPKDtlFail',    'us_english', 1812, 0, '269965: Update pick detail fail'
execute rdt.rdtAddMsg 269966, 10, '269966^UpdUCCFail',      'us_english', 1812, 0, '269966: Update UCC fail'
execute rdt.rdtAddMsg 269967, 10, '269967^UpdUCCFail',      'us_english', 1812, 0, '269967: Update UCC fail'
execute rdt.rdtAddMsg 269968, 10, '269968^UpdTskDtlFail',   'us_english', 1812, 0, '269968: Update task detail fail'
execute rdt.rdtAddMsg 269969, 10, '269969^UpdPKDtlFail',    'us_english', 1812, 0, '269969: Update pick detail fail'
execute rdt.rdtAddMsg 269970, 10, '269970^UpdTskDtlFail',   'us_english', 1812, 0, '269970: Update task detail fail'
execute rdt.rdtAddMsg 269971, 10, '269971^UpdREPLENFail',   'us_english', 1812, 0, '269971: Update REPLENISHMENT fail'
execute rdt.rdtAddMsg 269972, 10, '269972^CannotSwapUCC',   'us_english', 1812, 0, '269972: Cannot swap UCC'
execute rdt.rdtAddMsg 269973, 10, '269973^InsSwapUCCFail',  'us_english', 1812, 0, '269973: Insert swap UCC fail'
execute rdt.rdtAddMsg 269974, 10, '269974^IDMismatch',      'us_english', 1812, 0, '269974: Task ID and UCC ID mismatch'

select * from rdt.rdtmsg (nolock) where message_id between 269951 and 270000
