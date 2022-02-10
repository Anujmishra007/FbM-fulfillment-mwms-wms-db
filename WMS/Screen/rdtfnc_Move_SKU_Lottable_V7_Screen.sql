--rdtfnc_Move_SKU_Lottable_V7
-- 5190-5199

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 629)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('629', 'ENG', 'FNC', 'Move SKU Lottable V7', 'rdtfnc_Move_SKU_Lottable_V7', '4')
END

-- 5190 = LOC
DELETE rdt.RDTScn WHERE Scn = 5190 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5190, 'ENG'
   ,@cLine01 = 'FROM LOC: %10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 629

-- 5191 = ID
DELETE rdt.RDTScn WHERE Scn = 5191 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5191, 'ENG'
   ,@cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'FROM ID:'
   ,@cLine03 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 629

-- 5192 = SKU
DELETE rdt.RDTScn WHERE Scn = 5192 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5192, 'ENG'
   ,@cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'FROM ID:'
   ,@cLine03 = '%18d02'
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 629

-- 5193 = Lottable screen
DELETE rdt.RDTScn WHERE Scn = 5193 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5193, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = '%60i02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%60i04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%60i06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%16i08'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%16i10'
   ,@cLine14 = '%e'
   ,@nFunc = 629

-- 5194 = Lottables QTY
DELETE rdt.RDTScn WHERE Scn = 5194 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5194, 'ENG'
   ,@cLine01 = 'ID:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = 'SKU/UPC:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine08 = '         %05d08 %05d11'
   ,@cLine09 = 'QTY AVL: %05d09 %05d12'
   ,@cLine10 = 'QTY MV:  %05i10 %05i13'
   ,@cLine14 = '%e'
   ,@nFunc = 629

-- 5195 = To ID
DELETE rdt.RDTScn WHERE Scn = 5195 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5195, 'ENG'
   ,@cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'FROM ID:'
   ,@cLine03 = '%18d02'
   ,@cLine04 = 'SKU:'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '         %05d06 %05d08'
   ,@cLine09 = 'QTY MV:  %05d07 %05d09'
   ,@cLine10 = 'TO ID:'
   ,@cLine11 = '%20i10'
   ,@cLine14 = '%e'
   ,@nFunc = 629

-- 5196 = To LOC
DELETE rdt.RDTScn WHERE Scn = 5196 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5196, 'ENG'
   ,@cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'FROM ID:'
   ,@cLine03 = '%18d02'
   ,@cLine04 = 'SKU:'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '         %05d06 %05d08'
   ,@cLine09 = 'QTY MV:  %05d07 %05d09'
   ,@cLine10 = 'TO ID:'
   ,@cLine11 = '%18d10'
   ,@cLine12 = 'TO LOC: %10i11'
   ,@cLine13 = 'SUGG LOC: %10d12'   -- WMS-16449
   ,@cLine14 = '%e'
   ,@nFunc = 629

-- 5197 = Message screen
DELETE rdt.RDTScn WHERE Scn = 5197 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5197, 'ENG'
   ,@cLine02 = 'SKU moved'
   ,@cLine03 = 'successfully'
   ,@cLine04 = ''
   ,@cLine05 = 'Press ENTER or ESC'
   ,@cLine06 = 'to continue'
   ,@cLine14 = '%e'
   ,@nFunc = 629

