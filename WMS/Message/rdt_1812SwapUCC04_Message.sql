-- rdt_1812SwapUCC04
exec rdt.rdtDropMsg 262151, 262200

execute rdt.rdtAddMsg 262151, 10, '262151UCC scanned   ',   'us_english', 1812
execute rdt.rdtAddMsg 262152, 10, '262152BadTaskDtlKey ',   'us_english', 1812, 0, '262152: Task Not Found'
execute rdt.rdtAddMsg 262153, 10, '262153Not an UCC    ',   'us_english', 1812, 0, '262153: Not an UCC'
execute rdt.rdtAddMsg 262154, 10, '262154Multi SKU UCC ',   'us_english', 1812, 0, '262154: Multiple SKU UCC'
execute rdt.rdtAddMsg 262155, 10, '262155SKU mismatch  ',   'us_english', 1812, 0, '262155: SKU mismatch'
execute rdt.rdtAddMsg 262156, 10, '262156LOC mismatch  ',   'us_english', 1812, 0, '262156: Loc mismatch'
execute rdt.rdtAddMsg 262157, 10, '262157QTY mismatch  ',   'us_english', 1812, 0, '262157: Qty mismatch'
execute rdt.rdtAddMsg 262158, 10, '262158LOT mismatch  ',   'us_english', 1812, 0, '262158: Lot mismatch'
execute rdt.rdtAddMsg 262159, 10, '262159UCC cant pick ',   'us_english', 1812, 0, '262159: UCC cannot be picked'
execute rdt.rdtAddMsg 262160, 10, '262160UCCWasTaken',      'us_english', 1812, 0, '262160: UCC was taken'
execute rdt.rdtAddMsg 262161, 10, '262161UCCPicked',        'us_english', 1812, 0, '262161: UCC was picked'
execute rdt.rdtAddMsg 262162, 10, '262162TaskNotFound',     'us_english', 1812, 0, '262162: Get UCC task fail'
execute rdt.rdtAddMsg 262163, 10, '262163UpdTaskFail',      'us_english', 1812, 0, '262163: Update original UCC task fail'
execute rdt.rdtAddMsg 262164, 10, '262164UpdPKDFail',       'us_english', 1812, 0, '262164: Update task UCC pickdetail fail'
execute rdt.rdtAddMsg 262165, 10, '262165UpdUCCFail',       'us_english', 1812, 0, '262165: Update task UCC fail'
execute rdt.rdtAddMsg 262166, 10, '262166UpdUCCFail',       'us_english', 1812, 0, '262166: Update act UCC fail'
execute rdt.rdtAddMsg 262167, 10, '2621637UpdTaskFail',     'us_english', 1812, 0, '262167: Update act UCC task fail'
execute rdt.rdtAddMsg 262168, 10, '262168UpdPKDFail',       'us_english', 1812, 0, '262168: Update act UCC pickdetail fail'
execute rdt.rdtAddMsg 262169, 10, '262169UpdTaskFail',      'us_english', 1812, 0, '262169: Update act UCC task fail'
execute rdt.rdtAddMsg 262170, 10, '262170UpdReplnFail',     'us_english', 1812, 0, '262170: Update act UCC repln fail'
execute rdt.rdtAddMsg 262171, 10, '262171UpdUCCFail',       'us_english', 1812, 0, '262171: Update task UCC fail'
execute rdt.rdtAddMsg 262172, 10, '262172UpdUCCFail',       'us_english', 1812, 0, '262172: Update act UCC fail'
execute rdt.rdtAddMsg 262173, 10, '262173CantSwapUCC',      'us_english', 1812, 0, '262173: Cannot swap this UCC'
execute rdt.rdtAddMsg 262174, 10, '262174InsSwapUCCFail',   'us_english', 1812, 0, '262174: Insert SwapUCC fail'
execute rdt.rdtAddMsg 262175, 10, '262175UpdUCCFail',       'us_english', 1812, 0, '262175: Update act UCC fail'
execute rdt.rdtAddMsg 262176, 10, '262176UpdUCCFail',       'us_english', 1812, 0, '262176: Update task UCC fail'

select * from rdt.rdtmsg (nolock) where message_id between 262151 and 262200
