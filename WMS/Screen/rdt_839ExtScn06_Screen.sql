-- FCR-9040
-- Reason Code Screen
DELETE rdt.RDTScn WHERE Scn = 6773 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6773, 'ENG', 
   @cLine01 = 'SHORT PICK!',
   @cLine02 = 'REASON CODE:',
   @cLine03 = '%10i01',
   @cLine14 = '%e'

-- 6774 = SKU QTY screen
DELETE rdt.RDTScn WHERE Scn = 6774 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6774, 'ENG'
   ,@cLine01 = 'LOC: %10d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = 'SKU/UPC:'
   ,@cLine06 = '%2000iV_Barcode'
   ,@cLine07 = '%20d08'    -- Lottable
   ,@cLine08 = '%20d09'    -- Lottable
   ,@cLine09 = '%20d10'    -- Lottable
   ,@cLine10 = '%20d11'    -- Lottable
   ,@cLine11 = 'PICK: %05i07 ACT: %06d06'
   ,@cLine12 = 'BAL QTY: %12d13'
   ,@cLine13 = '%20d12'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3","4"],"3":["5","6"],"4":["7","8","9","10"],"5":["11","12"],"6":["13"]}'
   ,@nFunc = 839


-- 6775 = To ID screen
DELETE rdt.RDTScn WHERE Scn = 6775 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6775, 'ENG'
   ,@cLine01 = 'To ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20i02'
   ,@cLine04 = ''
   ,@cLine05 = 'Close DropID?'
   ,@cLine06 = '1 = Yes'
   ,@cLine07 = 'OPTION: %1i05'
   ,@cLine08 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3"],"2":["5","6","7"]}'
   ,@nFunc = 839

-- 6828 = No More Task screen
DELETE rdt.RDTScn WHERE Scn = 6828 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6828, 'ENG'
   ,@cLine01 = 'No More Task'
   ,@cLine02 = 'Close all Drop ID'
   ,@cLine03 = ''
   ,@cLine04 = 'Press Enter'
   ,@cLine05 = 'to continue'
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3"],"2":["5","6","7"]}'
   ,@nFunc = 839

-- 6777 = Short pick screen
DELETE rdt.RDTScn WHERE Scn = 6777 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6777, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CONFIRM OPTION?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = SHORT'
   ,@cLine05 = '2 = BAL PICK LATER'
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 839


-- 6840 = Abort LOC screen
DELETE rdt.RDTScn WHERE Scn = 6840 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6840, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'ABORT PICKING?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = '9 = Close ALL Pallet'
   ,@cLine08 = ''
   ,@cLine09 = 'OPTION: %01i01'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 839