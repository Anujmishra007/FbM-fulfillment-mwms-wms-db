--rdtfnc_InboundSKUPutaway
-- 4670 - 4679

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 743)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType)
   VALUES ('743', 'ENG', 'FNC', 'INBOUND PUTAWAY', 'rdtfnc_InboundSKUPutaway', 7)
END

-- 4670 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4670 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4670, 'ENG',
    @cLine01 = 'PUTAWAY'
   ,@cLine03 = 'ID:'
   ,@cLine04 = '%18i01'
   ,@cLine14 = '%e'
   ,@nFunc = 743

-- 4671 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4671 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4671, 'ENG',
    @cLine01 = 'PUTAWAY'
   ,@cLine03 = 'ID:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'SUGGESTED LOC:'
   ,@cLine06 = '%10d02'
   ,@cLine07 = 'LOC:'
   ,@cLine08 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 743

-- 4672 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4672 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4672, 'ENG',
    @cLine01 = 'PUTAWAY'
   ,@cLine03 = 'ID:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'LOC:'
   ,@cLine06 = '%10d02'
   ,@cLine07 = 'SKU/UPC:'
   ,@cLine08 = '%30d03'
   ,@cLine09 = '%30i04'
   ,@cLine14 = '%e'
   ,@nFunc = 743

-- 4673 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4673 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4673, 'ENG',
    @cLine01 = 'PUTAWAY'
   ,@cLine03 = 'LOC:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'SKU:'
   ,@cLine06 = '%20d02'
   ,@cLine07 = '%20d03'
   ,@cLine08 = '%20d04'
   ,@cLine09 = '%07d05  %05d06 %05d07'
   ,@cLine10 = 'EXP QTY: %05d08 %05d09'
   ,@cLine11 = 'CFM QTY: %05i10 %05i11'
   ,@cLine14 = '%e'
   ,@nFunc = 743

-- 4674 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4674 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4674, 'ENG',
    @cLine01 = 'PUTAWAY SUCCESSFULL.'
   ,@cLine02 = ''
   ,@cLine03 = 'PRESS ENTER'
   ,@cLine04 = 'TO CONTINUE.'
   ,@cLine14 = '%e'
   ,@nFunc = 743