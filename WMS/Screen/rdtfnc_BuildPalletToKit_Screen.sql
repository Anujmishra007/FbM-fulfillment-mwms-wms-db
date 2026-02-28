--BuildPalletToKit 663
-- 6570 = Kit Key screen
DELETE rdt.RDTScn WHERE Scn = 6570 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6570, 'ENG' 
   ,@cLine01 = 'KIT Ticket #:'
   ,@cLine02 = '%10i01'
   ,@cLine03 = 'Extern Ticket #:'
   ,@cLine04 = '%20i02'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2"],"3":["4"]}'
   ,@nFunc = 663

-- 6571 = toLoc screen
DELETE rdt.RDTScn WHERE Scn = 6571 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6571, 'ENG'
   ,@cLine01 = 'KIT Ticket #:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = 'Extern Ticket #:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = 'TO LOC: %10i03'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3","4"],"2":["5"]}'
   ,@nFunc = 663

-- 6572 = Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 6572 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6572, 'ENG'
   ,@cLine01 = 'TO LOC: %10d01'
   ,@cLine02 = 'TO ID:'
   ,@cLine03 = '%18i02'
   --,@cLine04 = '%12d03'
   ,@cLine05 = 'Pallet Type:%10l04'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3"],"3":["5"]}'
   ,@nFunc = 663
------------------------------------------------------------------------------
-- 6573 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 6573 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6573, 'ENG'
   ,@cLine01 = 'TO ID: '
   ,@cLine02 = '%18d01'
   ,@cLine03 = 'PALLET TYPE:'
   ,@cLine04 = '%10d02'
   ,@cLine05 = ''
   ,@cLine06 = 'SKU/UPC:'
   ,@cLine07 = '%1000iV_Max'
   ,@cLine08 = '%20d03'
   ,@cLine09 = '%20d04'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["6","7"]}'
   ,@nFunc = 663

-- 6574 = Lottable screen
DELETE rdt.RDTScn WHERE Scn = 6574 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6574, 'ENG'
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
   ,@nFunc = 663

-- 6575 = QTY
DELETE rdt.RDTScn WHERE Scn = 6575 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6575, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   --,@cLine05 = 'IVAS:'
   --,@cLine06 = '%20d04'
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = '%07d05 %05d06   %05d07'
   ,@cLine09 = 'QTY: %10i08^DT:INT %10i09^DT:INT'
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3","4"],"2":["5","6"],"3":["8","9"],"4":["13"]}'
   ,@nFunc = 663   

-- 6576 = Message screen
DELETE rdt.RDTScn WHERE Scn = 6576 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6576, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Successful built'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = 'Press ENTER or ESC'
   ,@cLine06 = 'to continue'
   ,@cLine14 = '%e'
   ,@cAutoDisappear = '1'
   ,@nFunc = 663
