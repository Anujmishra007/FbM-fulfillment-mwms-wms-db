--rdtfnc_Receive_By_Pallet
-- 4520 - 4529

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1823)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName)
   VALUES ('1823', 'ENG', 'FNC', 'MHAP ID Receive', 'rdtfnc_Receive_By_Pallet')
END

-- 4520 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4520 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4520, 'ENG',
    @cLine01 = 'ASN #:'
   ,@cLine02 = '%10i01'
   ,@cLine04 = 'REF #:'
   ,@cLine05 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1823

-- 4521 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4521 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4521, 'ENG',
    @cLine01 = 'ASN #:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = 'REF #:'
   ,@cLine04 = '%20d02'
   ,@cLine06 = 'EXT PALLET ID:'
   ,@cLine07 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1823

-- 4522 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4522 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4522, 'ENG',
    @cLine01 = 'EXT PALLET ID:'
   ,@cLine02 = '%20d01'
   ,@cLine04 = 'SSCC:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%30i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1823

-- 4523 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4523 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4523, 'ENG',
    @cLine01 = 'SKU:    REC: %05d12'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = '%20d08'
   ,@cLine10 = '%20d09'
   ,@cLine11 = 'UOM: %03d10 QTY: %05d11'
   ,@cLine12 = 'OPT (1=CONT.): %01i13'
   ,@cLine13 = 'ENT=NEXT RECORD'
   ,@cLine14 = '%e'
   ,@nFunc = 1823

-- 4524 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4524 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4524, 'ENG',
    @cLine01 = 'LF PALLET ID:'
   ,@cLine02 = '%18i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1823

-- 4525 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4525 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4525, 'ENG',
    @cLine01 = 'RECEIVED'
   ,@cLine02 = 'SUCCESSFULLY.'
   ,@cLine04 = 'PRESS ENTER/ESC'
   ,@cLine05 = 'TO CONTINUE.'
   ,@cLine14 = '%e'
   ,@nFunc = 1823