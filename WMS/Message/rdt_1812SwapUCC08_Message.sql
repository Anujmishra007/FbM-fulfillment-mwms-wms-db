--rdt_1812SwapUCC08
execute rdt.rdtDropMsg 279951, 280000

execute rdt.rdtAddMsg 279951, 10, '279951^BadTaskDtlKey  ',     'us_english', 1812, 0, '279951: Task detail not found'
execute rdt.rdtAddMsg 279952, 10, '279952^InvalidUCC     ',     'us_english', 1812, 0, '279952: Invalid UCC'
execute rdt.rdtAddMsg 279953, 10, '279953^InvUCCStatus',        'us_english', 1812, 0, '279953: Invalid UCC status'
execute rdt.rdtAddMsg 279954, 10, '279954^SKUMismatch    ',     'us_english', 1812, 0, '279954: UCC SKU mismatch'
execute rdt.rdtAddMsg 279955, 10, '279955^QTYMismatch    ',     'us_english', 1812, 0, '279955: UCC QTY mismatch'
execute rdt.rdtAddMsg 279956, 10, '279956^LOCMismatch    ',     'us_english', 1812, 0, '279956: UCC LOC mismatch'
execute rdt.rdtAddMsg 279957, 10, '279957^IDMismatch     ',     'us_english', 1812, 0, '279957: UCC ID mismatch'
execute rdt.rdtAddMsg 279958, 10, '279958^UpdOrigUCCFail ',     'us_english', 1812, 0, '279958: Update original UCC status fail'
execute rdt.rdtAddMsg 279959, 10, '279959^UpdNewUCCFail  ',     'us_english', 1812, 0, '279959: Update new UCC status fail'
execute rdt.rdtAddMsg 279960, 10, '279960^UpdTaskDtlFail ',     'us_english', 1812, 0, '279960: Update task detail fail'
execute rdt.rdtAddMsg 279961, 10, '279961^UpdPickDtlFail ',     'us_english', 1812, 0, '279961: Update pick detail fail'
execute rdt.rdtAddMsg 279962, 10, '279962^InsSwapUCCFail ',     'us_english', 1812, 0, '279962: Insert SwapUCC audit fail'
execute rdt.rdtAddMsg 279963, 10, '279963^InsTempTaskPDFail',   'us_english', 1812, 0, '279963: Insert TempTaskPD fail'
execute rdt.rdtAddMsg 279964, 10, '279964^TaskUCCNotFound',     'us_english', 1812, 0, '279964: Task UCC not found'
execute rdt.rdtAddMsg 279965, 10, '279965^InvalidUCCStatus',    'us_english', 1812, 0, '279965: Invalid Task UCC status'

select * from rdt.rdtmsg (nolock) where message_id between 279951 and 280000
