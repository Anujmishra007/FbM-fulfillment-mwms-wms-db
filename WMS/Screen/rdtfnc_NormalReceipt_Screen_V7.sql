-- 4030 = ASN screen
DELETE rdt.RDTScn WHERE Scn = 4030 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4030, 'ENG' 
   ,@cLine01 = 'ASN: %10i01'
   ,@cLine02 = 'PO : %10i02'
   ,@cLine03 = ''
   ,@cLine04 = 'REF NO:'
   ,@cLine05 = '%20i03'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2"],"3":["4","5"]}'
   ,@nFunc = 600

-- 4031 = Loc screen
DELETE rdt.RDTScn WHERE Scn = 4031 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4031, 'ENG'
   ,@cLine01 = 'ASN: %10d01'
   ,@cLine02 = 'PO : %10d02'
   ,@cLine03 = 'TO LOC: %10i03'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3"]}'
   ,@nFunc = 600

-- 4032 = Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 4032 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4032, 'ENG'
   ,@cLine01 = 'TO LOC: %10d01'
   ,@cLine02 = 'TO ID:'         -- ID extend from 18 to 30
   ,@cLine03 = '%30i02'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3"]}'
   ,@nFunc = 600

-- 4033 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 4033 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4033, 'ENG'
   ,@cLine01 = 'TO ID: '
   ,@cLine02 = '%18d01'
   ,@cLine03 = ''
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%1000iV_Max' -- WMS-22369
   ,@cLine06 = ''
   ,@cLine07 = '%20d03'
   ,@cLine08 = '%20d04'
   ,@cLine13 = '%20d05'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5"]}'
   ,@nFunc = 600

-- 4034 = Lottable screen
DELETE rdt.RDTScn WHERE Scn = 4034 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4034, 'ENG'
   ,@cLine01 = '%20d01'   -- Lot label 01
   ,@cLine02 = '%60i02'   -- Lottable01      -- Extend to 60 chars
   ,@cLine03 = '%20d03'   -- Lot label 02
   ,@cLine04 = '%60i04'   -- Lottable02      -- Extend to 60 chars
   ,@cLine05 = '%20d05'   -- Lot label 03
   ,@cLine06 = '%60i06'   -- Lottable03      -- Extend to 60 chars
   ,@cLine07 = '%20d07'   -- Lot label 04
   ,@cLine08 = '%16i08'   -- Lottable04
   ,@cLine09 = '%20d09'   -- Lot label 05
   ,@cLine10 = '%16i10'   -- Lottable05
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["5","6"],"4":["7","8"],"5":["9","10"]}'
   ,@cLine14 = '%e'
   ,@nFunc = 600

-- 4035 = QTY, COND screen
DELETE rdt.RDTScn WHERE Scn = 4035 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4035, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = 'IVAS:'
   ,@cLine06 = '%20d04'
   ,@cLine07 = ''
   ,@cLine08 = '%07d05 %05d06   %05d07'
   ,@cLine09 = 'QTY: %10i08^DT:INT %10i09^DT:INT'
   ,@cLine10 = ''
   ,@cLine11 = 'COND CODE%10l10'
   ,@cLine12 = ''
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3","4"],"2":["5","6"],"3":["8","9"],"4":["11"],"5":["13"]}'
   ,@nFunc = 600   

-- 4036 = Message screen
DELETE rdt.RDTScn WHERE Scn = 4036 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4036, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Successful received'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = 'Press ENTER or ESC'
   ,@cLine06 = 'to continue'
   ,@cLine14 = '%e'
   ,@cAutoDisappear = '1'
   ,@nFunc = 600

-- 4037. Add SKU not in ASN?
DELETE rdt.RDTScn WHERE Scn = 4037 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4037, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'ADD SKU NOT IN ASN?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 600

-- 4038. Print pallet label
DELETE rdt.RDTScn WHERE Scn = 4038 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4038, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'PRINT PALLET LABEL?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 600

-- 4040. Lookup
DELETE rdt.RDTScn WHERE Scn = 4040 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4040, 'ENG'
   ,@cLine01 = 'SELECT ASN:'
   ,@cLine02 = ''
   ,@cLine03 = '%20d01'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%20d08'
   ,@cLine11 = '%20d09'
   ,@cLine12 = ''
   ,@cLine13 = 'OPTION: %01i10'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["3","4","5","6","7","8","9","10","11"],"2":["13"]}'
   ,@nFunc = 600
   
-- 4041. Putaway
DELETE rdt.RDTScn WHERE Scn = 4041 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4041, 'ENG'
   ,@cLine01 = 'PUTAWAY'
   ,@cLine02 = ''
   ,@cLine03 = 'SUGGESTED LOC:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = ''
   ,@cLine06 = 'FINAL LOC:'
   ,@cLine07 = '%10i02'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["3","4"],"2":["6","7"]}'
   ,@nFunc = 600

-- 4042 Close Pallet
DELETE rdt.RDTScn WHERE Scn = 4042 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4042, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Close Pallet?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 600
