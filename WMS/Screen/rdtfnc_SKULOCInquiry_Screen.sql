--rdtfnc_SKULOCInquiry
--4780-4789

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID = 728 AND Message_Type = 'FNC')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (728, 'ENG', 'FNC', 'SKU/LOC INQUIRY', 'rdtfnc_SKULOCInquiry', '0')

-- 4780 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4780 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4780, 'ENG',
    @cLine01 = 'SKU/LOC INQUIRY:'
   ,@cLine02 = ''
   ,@cLine03 = 'LOC:'
   ,@cLine04 = '%10i01'
   ,@cLine05 = 'OR'
   ,@cLine06 = ''
   ,@cLine07 = 'SKU:'
   ,@cLine08 = '%60i02'
   ,@cLine14 = '%e'

-- 4781 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4781 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4781, 'ENG',
    @cLine01 = 'LOC:    PAGE: %05d01'
   ,@cLine02 = '%10d02'
   ,@cLine03 = 'NO. OF SKUs: %05d03'
   ,@cLine04 = 'SKU   QTY  ALC  AVL'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = '%20d08'
   ,@cLine10 = '%20d09'
   ,@cLine11 = '%20d10'
   ,@cLine12 = '%20d11'
   ,@cLine13 = 'ENTER=NEXT; ESC=BACK'
   ,@cLine14 = '%e'

-- 4782 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4782 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4782, 'ENG',
    @cLine01 = 'SKU:    PAGE: %05d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20d04'
   ,@cLine06 = 'LOC TYPE: %10d05'
   ,@cLine07 = 'NO. OF LOCs: %05d06'
   ,@cLine08 = '%20d11' --WMS-17918 Add new display line
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%20d08'
   ,@cLine11 = '%20d09'
   ,@cLine12 = '%20d10'
   ,@cLine13 = 'ENTER=NEXT; ESC=BACK'
   ,@cLine14 = '%e'   