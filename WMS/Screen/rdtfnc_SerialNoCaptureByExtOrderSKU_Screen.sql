--rdtfnc_SerialNoCaptureByExtOrderSKU
-- 4530 - 4539

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 878)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName)
   VALUES ('878', 'ENG', 'FNC', 'Serial No Capture', 'rdtfnc_SerialNoCaptureByExtOrderSKU')
END

-- 4530 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4530 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4530, 'ENG',
    @cLine01 = 'EXT ORDER KEY:'
   ,@cLine02 = '%20i01'
   ,@cLine04 = 'SKU:'
   ,@cLine05 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 878

-- 4531 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4531 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4531, 'ENG',
    @cLine01 = 'EXT ORDER KEY:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'SKU:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = 'SERIAL NO:'
   ,@cLine08 = '%20i05'
   ,@cLine10 = 'CASE: %05d06'
   ,@cLine12 = 'EXP SCAN QTY: %05d07'
   ,@cLine13 = 'ACT SCAN QTY: %05d08'
   ,@cLine14 = '%e'
   ,@nFunc = 878