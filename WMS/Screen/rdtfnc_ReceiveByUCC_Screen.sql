--rdtfnc_ReceiveByUCC
-- 4580 - 4589

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 897)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName)
   VALUES ('897', 'ENG', 'FNC', 'RECEIVE BY UCC', 'rdtfnc_ReceiveByUCC')
END

-- 4580 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4580 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4580, 'ENG',
    @cLine01 = 'RECEIVING'
   ,@cLine03 = 'CARTON:'
   ,@cLine04 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 897

-- 4581 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4581 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4581, 'ENG',
    @cLine01 = 'RECEIVING'
   ,@cLine03 = 'CARTON:'
   ,@cLine04 = '%20d01'
   ,@cLine05 = 'SKU              QTY'
   ,@cLine06 = '%20d02'
   ,@cLine07 = '%20d03'
   ,@cLine08 = '%20d04'
   ,@cLine09 = '%20d05'
   ,@cLine10 = '%20d06'
   ,@cLine12 = 'ITEM HAS BEEN'
   ,@cLine13 = 'RECEIVED'
   ,@cLine14 = '%e'
   ,@nFunc = 897

