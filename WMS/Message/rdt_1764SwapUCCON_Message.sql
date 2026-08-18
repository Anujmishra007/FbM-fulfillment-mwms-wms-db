--rdt_1764SwapUCCON
--RITM8891302
-- 275851 - 275900

EXECUTE rdt.rdtdropmsg 275851, 275900

EXECUTE rdt.rdtAddMsg 275851, 10, '275851^UCCScanned',               'us_english', 1764, 0, '275851 UCC scanned'
EXECUTE rdt.rdtAddMsg 275852, 10, '275852^CannotSwapUCC',            'us_english', 1764, 0, '275852 UCC status is not valid for swap'
EXECUTE rdt.rdtAddMsg 275853, 10, '275853^LocDoNotMatch',            'us_english', 1764, 0, '275853 Loc does not match'
EXECUTE rdt.rdtAddMsg 275854, 10, '275854^SKUDoNotMatch',            'us_english', 1764, 0, '275854 SKU does not match'
EXECUTE rdt.rdtAddMsg 275855, 10, '275855^LOTDoNotMatch',            'us_english', 1764, 0, '275855 LOT does not match'
EXECUTE rdt.rdtAddMsg 275856, 10, '275856^QtyDoNotMatch',            'us_english', 1764, 0, '275856 Qty does not match'
EXECUTE rdt.rdtAddMsg 275857, 10, '275857^InvUCC',                   'us_english', 1764, 0, '275857 UCC is locked by other task'
EXECUTE rdt.rdtAddMsg 275858, 10, '275858^UpdTaskFail',              'us_english', 1764, 0, '275858 Unlock UCC from RPF task failed'
EXECUTE rdt.rdtAddMsg 275859, 10, '275859^UpdPkDtlFail',             'us_english', 1764, 0, '275859 Unlock UCC from FCP PickDetail failed'
EXECUTE rdt.rdtAddMsg 275860, 10, '275860^UpdPkDtlFail',             'us_english', 1764, 0, '275860 Unlock UCC from FCP task failed'
EXECUTE rdt.rdtAddMsg 275861, 10, '275861^UpdTaskFail',              'us_english', 1764, 0, '275861 Allocate task UCC to other RPF task failed'
EXECUTE rdt.rdtAddMsg 275862, 10, '275862^UpdPkDtlFail',             'us_english', 1764, 0, '275862 Unallocate scanned UCC from PickDetail failed'
EXECUTE rdt.rdtAddMsg 275863, 10, '275863^UpdPkDtlFail',             'us_english', 1764, 0, '275863 Allocate task UCC to other PickDetail failed'
EXECUTE rdt.rdtAddMsg 275864, 10, '275864^UpdTaskFail',              'us_english', 1764, 0, '275864 Allocate scanned UCC to RPF task failed'
EXECUTE rdt.rdtAddMsg 275865, 10, '275865^UpdPkDtlFail',             'us_english', 1764, 0, '275865 Allocate scanned UCC to PickDetail failed'
EXECUTE rdt.rdtAddMsg 275866, 10, '275866^UpdTaskFail',              'us_english', 1764, 0, '275866 Allocate scanned UCC to TaskDetail failed'
EXECUTE rdt.rdtAddMsg 275867, 10, '275867^ExecSPFail',               'us_english', 1764, 0, '275867 Exec rdt_Putaway_PendingMoveIn failed'
EXECUTE rdt.rdtAddMsg 275868, 10, '275868^UpdUCCFail',               'us_english', 1764, 0, '275868 Update scanned UCC to 3 failed'
EXECUTE rdt.rdtAddMsg 275869, 10, '275869^UpdUCCFail',               'us_english', 1764, 0, '275869 Update original task UCC to 1 failed'
EXECUTE rdt.rdtAddMsg 275870, 10, '275870^UpdUCCFail',               'us_english', 1764, 0, '275870 Update original task UCC to 3 failed'
EXECUTE rdt.rdtAddMsg 275871, 10, '275871^UpdTaskFail',              'us_english', 1764, 0, '275871 Allocate task UCC to other FCP TaskDetail failed'
EXECUTE rdt.rdtAddMsg 275872, 10, '275872^ExecSPFail',               'us_english', 1764, 0, '275872 Exec rdt_Putaway_PendingMoveIn failed'
EXECUTE rdt.rdtAddMsg 275873, 10, '275873^ExecSPFail',               'us_english', 1764, 0, '275873 Exec rdt_Putaway_PendingMoveIn failed'
EXECUTE rdt.rdtAddMsg 275874, 10, '275874^UpdUCCFail',               'us_english', 1764, 0, '275874 Update scanned UCC to 1 failed'
EXECUTE rdt.rdtAddMsg 275875, 10, '275875^InvUCC',                   'us_english', 1764, 0, '275875 Scanned UCC does not exist'
EXECUTE rdt.rdtAddMsg 275876, 10, '275876^MultipleSKU',              'us_english', 1764, 0, '275876 Scanned UCC contains multiple SKUs'
EXECUTE rdt.rdtAddMsg 275877, 10, '275877^CannotSwapUCC',            'us_english', 1764, 0, '275877 UCC status is not valid for swap'
EXECUTE rdt.rdtAddMsg 275878, 10, '275878^UpdPackFail',              'us_english', 1764, 0, '275878 Allocate UCC to PackDetail failed'



SELECT * FROM rdt.rdtmsg WITH (NOLOCK) WHERE Message_ID BETWEEN 275851 AND 275900