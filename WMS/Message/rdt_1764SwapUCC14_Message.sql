--rdt_1764SwapUCC14
--FCR-12990

EXECUTE rdt.rdtdropmsg 270451, 270500

EXECUTE rdt.rdtAddMsg 270451, 10, '270451^UCCScanned',               'us_english', 1764, 0, '270451 UCC scanned'
EXECUTE rdt.rdtAddMsg 270452, 10, '270452^CannotSwapUCC',            'us_english', 1764, 0, '270452 UCC status is not valid for swap'
EXECUTE rdt.rdtAddMsg 270453, 10, '270453^LocDoNotMatch',            'us_english', 1764, 0, '270453 Loc does not match'
EXECUTE rdt.rdtAddMsg 270454, 10, '270454^SKUDoNotMatch',            'us_english', 1764, 0, '270454 SKU does not match'
EXECUTE rdt.rdtAddMsg 270455, 10, '270455^LOTDoNotMatch',            'us_english', 1764, 0, '270455 LOT does not match'
EXECUTE rdt.rdtAddMsg 270456, 10, '270456^QtyDoNotMatch',            'us_english', 1764, 0, '270456 Qty does not match'
EXECUTE rdt.rdtAddMsg 270457, 10, '270457^InvUCC',                   'us_english', 1764, 0, '270457 UCC is locked by other task'
EXECUTE rdt.rdtAddMsg 270458, 10, '270458^UpdTaskFail',              'us_english', 1764, 0, '270458 Unlock UCC from RPF task failed'
EXECUTE rdt.rdtAddMsg 270459, 10, '270459^UpdPkDtlFail',             'us_english', 1764, 0, '270459 Unlock UCC from FCP PickDetail failed'
EXECUTE rdt.rdtAddMsg 270460, 10, '270460^UpdPkDtlFail',             'us_english', 1764, 0, '270460 Unlock UCC from FCP task failed'
EXECUTE rdt.rdtAddMsg 270461, 10, '270461^UpdTaskFail',              'us_english', 1764, 0, '270461 Allocate task UCC to other RPF task failed'
EXECUTE rdt.rdtAddMsg 270462, 10, '270462^UpdPkDtlFail',             'us_english', 1764, 0, '270462 Unallocate scanned UCC from PickDetail failed'
EXECUTE rdt.rdtAddMsg 270463, 10, '270463^UpdPkDtlFail',             'us_english', 1764, 0, '270463 Allocate task UCC to other PickDetail failed'
EXECUTE rdt.rdtAddMsg 270464, 10, '270464^UpdTaskFail',              'us_english', 1764, 0, '270464 Allocate scanned UCC to RPF task failed'
EXECUTE rdt.rdtAddMsg 270465, 10, '270465^UpdPkDtlFail',             'us_english', 1764, 0, '270465 Allocate scanned UCC to PickDetail failed'
EXECUTE rdt.rdtAddMsg 270466, 10, '270466^UpdTaskFail',              'us_english', 1764, 0, '270466 Allocate scanned UCC to TaskDetail failed'
EXECUTE rdt.rdtAddMsg 270467, 10, '270467^ExecSPFail',               'us_english', 1764, 0, '270467 Exec rdt_Putaway_PendingMoveIn failed'
EXECUTE rdt.rdtAddMsg 270468, 10, '270468^UpdUCCFail',               'us_english', 1764, 0, '270468 Update scanned UCC to 3 failed'
EXECUTE rdt.rdtAddMsg 270469, 10, '270469^UpdUCCFail',               'us_english', 1764, 0, '270469 Update original task UCC to 1 failed'
EXECUTE rdt.rdtAddMsg 270470, 10, '270470^UpdUCCFail',               'us_english', 1764, 0, '270470 Update original task UCC to 3 failed'
EXECUTE rdt.rdtAddMsg 270471, 10, '270471^UpdTaskFail',              'us_english', 1764, 0, '270471 Allocate task UCC to other FCP TaskDetail failed'
EXECUTE rdt.rdtAddMsg 270472, 10, '270472^ExecSPFail',               'us_english', 1764, 0, '270472 Exec rdt_Putaway_PendingMoveIn failed'
EXECUTE rdt.rdtAddMsg 270473, 10, '270473^ExecSPFail',               'us_english', 1764, 0, '270473 Exec rdt_Putaway_PendingMoveIn failed'
EXECUTE rdt.rdtAddMsg 270474, 10, '270474^UpdUCCFail',               'us_english', 1764, 0, '270474 Update scanned UCC to 1 failed'
EXECUTE rdt.rdtAddMsg 270475, 10, '270475^InvUCC',                   'us_english', 1764, 0, '270475 Scanned UCC does not exist'
EXECUTE rdt.rdtAddMsg 270476, 10, '270476^MultipleSKU',              'us_english', 1764, 0, '270476 Scanned UCC contains multiple SKUs'

SELECT * FROM rdt.rdtmsg WITH (NOLOCK) WHERE Message_ID BETWEEN 270451 AND 270500