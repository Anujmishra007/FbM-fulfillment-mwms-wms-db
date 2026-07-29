--rdt_1764SwapUCCON
--RITM8891302

EXECUTE rdt.rdtdropmsg 270700, 270750

EXECUTE rdt.rdtAddMsg 270700, 10, '270700^UCCScanned',               'us_english', 1764, 0, '270700 UCC scanned'
EXECUTE rdt.rdtAddMsg 270701, 10, '270701^CannotSwapUCC',            'us_english', 1764, 0, '270701 UCC status is not valid for swap'
EXECUTE rdt.rdtAddMsg 270702, 10, '270702^LocDoNotMatch',            'us_english', 1764, 0, '270702 Loc does not match'
EXECUTE rdt.rdtAddMsg 270703, 10, '270703^SKUDoNotMatch',            'us_english', 1764, 0, '270703 SKU does not match'
EXECUTE rdt.rdtAddMsg 270704, 10, '270704^LOTDoNotMatch',            'us_english', 1764, 0, '270704 LOT does not match'
EXECUTE rdt.rdtAddMsg 270705, 10, '270705^QtyDoNotMatch',            'us_english', 1764, 0, '270705 Qty does not match'
EXECUTE rdt.rdtAddMsg 270706, 10, '270706^InvUCC',                   'us_english', 1764, 0, '270706 UCC is locked by other task'
EXECUTE rdt.rdtAddMsg 270707, 10, '270707^UpdTaskFail',              'us_english', 1764, 0, '270707 Unlock UCC from RPF task failed'
EXECUTE rdt.rdtAddMsg 270708, 10, '270708^UpdPkDtlFail',             'us_english', 1764, 0, '270708 Unlock UCC from FCP PickDetail failed'
EXECUTE rdt.rdtAddMsg 270709, 10, '270709^UpdPkDtlFail',             'us_english', 1764, 0, '270709 Unlock UCC from FCP task failed'
EXECUTE rdt.rdtAddMsg 270710, 10, '270710^UpdTaskFail',              'us_english', 1764, 0, '270710 Allocate task UCC to other RPF task failed'
EXECUTE rdt.rdtAddMsg 270711, 10, '270711^UpdPkDtlFail',             'us_english', 1764, 0, '270711 Unallocate scanned UCC from PickDetail failed'
EXECUTE rdt.rdtAddMsg 270712, 10, '270712^UpdPkDtlFail',             'us_english', 1764, 0, '270712 Allocate task UCC to other PickDetail failed'
EXECUTE rdt.rdtAddMsg 270713, 10, '270713^UpdTaskFail',              'us_english', 1764, 0, '270713 Allocate scanned UCC to RPF task failed'
EXECUTE rdt.rdtAddMsg 270714, 10, '270714^UpdPkDtlFail',             'us_english', 1764, 0, '270714 Allocate scanned UCC to PickDetail failed'
EXECUTE rdt.rdtAddMsg 270715, 10, '270715^UpdTaskFail',              'us_english', 1764, 0, '270715 Allocate scanned UCC to TaskDetail failed'
EXECUTE rdt.rdtAddMsg 270716, 10, '270716^ExecSPFail',               'us_english', 1764, 0, '270716 Exec rdt_Putaway_PendingMoveIn failed'
EXECUTE rdt.rdtAddMsg 270717, 10, '270717^UpdUCCFail',               'us_english', 1764, 0, '270717 Update scanned UCC to 3 failed'
EXECUTE rdt.rdtAddMsg 270718, 10, '270718^UpdUCCFail',               'us_english', 1764, 0, '270718 Update original task UCC to 1 failed'
EXECUTE rdt.rdtAddMsg 270719, 10, '270719^UpdUCCFail',               'us_english', 1764, 0, '270719 Update original task UCC to 3 failed'
EXECUTE rdt.rdtAddMsg 270720, 10, '270720^UpdTaskFail',              'us_english', 1764, 0, '270720 Allocate task UCC to other FCP TaskDetail failed'
EXECUTE rdt.rdtAddMsg 270721, 10, '270721^ExecSPFail',               'us_english', 1764, 0, '270721 Exec rdt_Putaway_PendingMoveIn failed'
EXECUTE rdt.rdtAddMsg 270722, 10, '270722^ExecSPFail',               'us_english', 1764, 0, '270722 Exec rdt_Putaway_PendingMoveIn failed'
EXECUTE rdt.rdtAddMsg 270723, 10, '270723^UpdUCCFail',               'us_english', 1764, 0, '270723 Update scanned UCC to 1 failed'
EXECUTE rdt.rdtAddMsg 270724, 10, '270724^InvUCC',                   'us_english', 1764, 0, '270724 Scanned UCC does not exist'
EXECUTE rdt.rdtAddMsg 270725, 10, '270725^MultipleSKU',              'us_english', 1764, 0, '270725 Scanned UCC contains multiple SKUs'
EXECUTE rdt.rdtAddMsg 270726, 10, '270726^CannotSwapUCC',            'us_english', 1764, 0, '270726 UCC status is not valid for swap'
EXECUTE rdt.rdtAddMsg 270727, 10, '270727^UpdPackFail',              'us_english', 1764, 0, '270727 Allocate UCC to PackDetail failed'



SELECT * FROM rdt.rdtmsg WITH (NOLOCK) WHERE Message_ID BETWEEN 270700 AND 270750