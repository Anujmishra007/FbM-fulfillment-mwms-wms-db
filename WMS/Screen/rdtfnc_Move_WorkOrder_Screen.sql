-- 2280 = WORKORDER NO
DELETE rdt.RDTScn WHERE Scn = 2280 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2280, 'ENG',
   @cLine01 = 'WORKORDER NO:',
   @cLine02 = '%10i01',
   @cLine14 = '%e'

-- 2281 = LOC
DELETE rdt.RDTScn WHERE Scn = 2281 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2281, 'ENG',
   @cLine01 = 'FROM LOC: %10i01',
   @cLine14 = '%e'

-- 2282 = ID
DELETE rdt.RDTScn WHERE Scn = 2282 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2282, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18i02',
   @cLine14 = '%e'

-- 2283 = SKU
DELETE rdt.RDTScn WHERE Scn = 2283 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2283, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU/UPC:',
   @cLine05 = '%20i03',
   @cLine14 = '%e'

-- 2284 = Lottables
DELETE rdt.RDTScn WHERE Scn = 2284 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2284, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU/UPC:',
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = '%20d05',
   @cLine08 = '%20d06', -- LottableLabel02
   @cLine09 = '%18i07', -- Lottable02
   @cLine10 = '%20d08', -- LottableLabel03
   @cLine11 = '%18i09', -- Lottable03
   @cLine12 = '%20d10', -- LottableLabel04
   @cLine13 = '%16i11', -- Lottable04
   @cLine14 = '%e'

-- 2285 = Lottables QTY
DELETE rdt.RDTScn WHERE Scn = 2285 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2285, 'ENG',
   @cLine01 = 'ID:',
   @cLine02 = '%18d01', -- ID
   @cLine03 = '%20d02', -- LottableLabel02
   @cLine04 = '%18d03', -- Lottable02
   @cLine05 = '%20d04', -- LottableLabel03
   @cLine06 = '%18d05', -- Lottable03
   @cLine07 = '%20d06', -- LottableLabel04
   @cLine08 = '%16d07', -- Lottable04
   @cLine09 = 'UOM:%05i08',
   @cLine10 = 'QTY AVL:%10d09',
   @cLine11 = 'QTY MV: %10i10',
   @cLine14 = '%e'

-- 2286 = To ID
DELETE rdt.RDTScn WHERE Scn = 2286 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2286, 'ENG',
   @cLine01 = '%10d01',
   @cLine02 = 'FROM LOC: %10d02',
   @cLine03 = 'FROM ID:',
   @cLine04 = '%18d03',
   @cLine05 = 'SKU:',
   @cLine06 = '%20d04',
   @cLine07 = '%20d05',
   @cLine08 = '%20d06',
   @cLine09 = 'UOM:%05d07',
   @cLine10 = 'QTY MV:  %10d08',
   @cLine11 = 'TO ID:',
   @cLine12 = '%18i09',
   @cLine14 = '%e'

-- 2287 = To LOC
DELETE rdt.RDTScn WHERE Scn = 2287 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2287, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU:',
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = '%20d05',
   @cLine08 = 'UOM:%05d06',
   @cLine09 = 'QTY MV:  %10d07',
   @cLine10 = 'TO ID:',
   @cLine11 = '%18d08',
   @cLine12 = 'TO LOC: %10i09',
   @cLine14 = '%e'

-- 2288 = Message screen
DELETE rdt.RDTScn WHERE Scn = 2288 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2288, 'ENG',
   @cLine02 = 'SKU moved',
   @cLine03 = 'successfully',
   @cLine04 = '',
   @cLine05 = 'Press ENTER or ESC',
   @cLine06 = 'to continue',
   @cLine14 = '%e'
