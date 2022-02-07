IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 882)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (882, 'ENG', 'FNC', 'MODIFY UCC DATA', 'rdtfnc_ModifyUCCData', '8')
END

-- 1480 = lottable02 screen
DELETE rdt.RDTScn WHERE Scn = 1480 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1480, 'ENG',
    @cLine01 = 'ID:'
   ,@cLine02 = '%20i01' -- WMS13049
   ,@cLine04 = 'UCC:'
   ,@cLine05 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 882

-- 1481 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 1481 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1481, 'ENG',
    @cLine01 = 'UCC:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'SKU/UPC:'
   ,@cLine04 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 882
   
-- 1482 = loc screen
DELETE rdt.RDTScn WHERE Scn = 1482 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1482, 'ENG',
    @cLine01 = 'UCC:'
   ,@cLine02 = '%20d01'
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%20d07'
   ,@cLine07 = 'LOT: %10i02'
   ,@cLine08 = 'LOC: %10i03'
   ,@cLine09 = 'ID:'
   ,@cLine10 = '%18i04'
   ,@cLine11 = 'STATUS: %01i05'
   ,@cLine12 = 'QTY: %05i06'
   ,@cLine14 = '%e'
   ,@nFunc = 882

-- 1483 = Lottable screen
DELETE rdt.RDTScn WHERE Scn = 1483 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1483, 'ENG',
    @cLine01 = 'Lottable:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = '%20d08'
   ,@cLine10 = '%20d09'
   ,@cLine11 = '%20d10'
   ,@cLine14 = '%e'
   ,@nFunc = 882