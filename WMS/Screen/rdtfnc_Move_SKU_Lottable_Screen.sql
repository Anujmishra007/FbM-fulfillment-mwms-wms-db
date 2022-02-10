/*
   Move
*/

-- 1040 = LOC
DELETE rdt.RDTScn WHERE Scn = 1040 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1040, 'ENG',
   @cLine01 = 'FROM LOC: %10i01',
   @cLine14 = '%e'

-- 1041 = ID
DELETE rdt.RDTScn WHERE Scn = 1041 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1041, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%20i02',
   @cLine14 = '%e'

-- 1042 = SKU
DELETE rdt.RDTScn WHERE Scn = 1042 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1042, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU/UPC:',
   @cLine05 = '%20i03',
   @cLine14 = '%e'

-- 1043 = Lottables
DELETE rdt.RDTScn WHERE Scn = 1043 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1043, 'ENG',
   @cLine01 = 'SKU:',
   @cLine02 = '%20d01',
   @cLine03 = '%20d02',
   @cLine04 = '%20d03',
   @cLine05 = '%20d04', -- LottableLabel01
   @cLine06 = '%18i05', -- Lottable01
   @cLine07 = '%20d06', -- LottableLabel02
   @cLine08 = '%18i07', -- Lottable02
   @cLine09 = '%20d08', -- LottableLabel03
   @cLine10 = '%18i09', -- Lottable03
   @cLine11 = '%20d10', -- LottableLabel04
   @cLine12 = '%16i11', -- Lottable04
   @cLine14 = '%e'

-- 1044 = Lottables QTY
DELETE rdt.RDTScn WHERE Scn = 1044 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1044, 'ENG',
   @cLine01 = 'ID:',
   @cLine02 = '%18d01', -- ID
   @cLine03 = 'LOTTABLES:',
   @cLine04 = '1 %18d02', -- Lottable01
   @cLine05 = '2 %18d03', -- Lottable02
   @cLine06 = '3 %18d04', -- Lottable03
   @cLine07 = '4 %16d05', -- Lottable04
   @cLine08 = '         %05d08 %05d11',
   @cLine09 = 'QTY AVL: %05d09 %05d12',
   @cLine10 = 'QTY MV:  %05i10 %05i13',
   @cLine14 = '%e'

-- 1045 = To ID
DELETE rdt.RDTScn WHERE Scn = 1045 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1045, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU:',
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = '%20d05',
   @cLine08 = '         %05d06 %05d08',
   @cLine09 = 'QTY MV:  %05d07 %05d09',
   @cLine10 = 'TO ID:',
   @cLine11 = '%20i10',
   @cLine14 = '%e'

-- 1046 = To LOC
DELETE rdt.RDTScn WHERE Scn = 1046 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1046, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU:',
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = '%20d05',
   @cLine08 = '         %05d06 %05d08',
   @cLine09 = 'QTY MV:  %05d07 %05d09',
   @cLine10 = 'TO ID:',
   @cLine11 = '%18d10',
   @cLine12 = 'TO LOC: %10i11',
   @cLine14 = '%e'

-- 1047 = Message screen
DELETE rdt.RDTScn WHERE Scn = 1047 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1047, 'ENG',
   @cLine02 = 'SKU moved',
   @cLine03 = 'successfully',
   @cLine04 = '',
   @cLine05 = 'Press ENTER or ESC',
   @cLine06 = 'to continue',
   @cLine14 = '%e'
