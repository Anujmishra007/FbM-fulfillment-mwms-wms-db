--rdtfnc_UCCInquire
--4810 - 4819

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID = 729 AND Message_Type = 'FNC')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (729, 'ENG', 'FNC', 'UCC INQUIRY', 'rdtfnc_UCCInquire', '9')

-- 4810 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4810 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4810, 'ENG',
    @cLine01 = 'UCC:'
   ,@cLine02 = '%200iV_Barcode' --FCR-9907
   ,@cLine03 = '%20d02:'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = 'QTY: %05d05 PPK: %04d06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%20d08'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%20d10'
   ,@cLine11 = '%20d11'
   ,@cLine12 = '%20d12'
   ,@cLine13 = '%20d13'
   ,@cLine14 = '%e'
   ,@nFunc = 729
