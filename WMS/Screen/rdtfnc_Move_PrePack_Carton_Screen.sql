IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 651 AND Lang_Code = 'ENG' AND Message_Type = 'FNC')
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (651, 'ENG', 'FNC', 'Move PrePack Carton' ,'rdtfnc_Move_PrePack_Carton', '4')
END

-- 6080 = LOC
DELETE rdt.RDTScn WHERE Scn = 6080 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6080, 'ENG',
   @cLine01 = 'FROM LOC: %10i01',
   @cLine14 = '%e',
   @nFunc = 651
   
-- 6081 = REFNO
DELETE rdt.RDTScn WHERE Scn = 6081 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6081, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = '',
   @cLine03 = 'REFNO:',
   @cLine04 = '%20i02',
   @cLine14 = '%e',
   @nFunc = 651
   
-- 6082 = QTY
DELETE rdt.RDTScn WHERE Scn = 6082 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6082, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = '',
   @cLine03 = 'REFNO:', 
   @cLine04 = '%20d02',
   @cLine05 = 'QTY: %05i03',
   @cLine14 = '%e',
   @nFunc = 651
   
-- 6083 = To LOC
DELETE rdt.RDTScn WHERE Scn = 6083 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6083, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = '',
   @cLine03 = 'REFNO:', 
   @cLine04 = '%20d02',
   @cLine05 = 'QTY: %05d03',
   @cLine06 = '',
   @cLine07 = 'TO ID:',
   @cLine08 = '%18i04',
   @cLine09 = 'TO LOC: %10i05',
   @cLine14 = '%e',
   @nFunc = 651

-- 6084 = Message
DELETE rdt.RDTScn WHERE Scn = 6084 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6084, 'ENG',
   @cLine02 = 'SKU moved',
   @cLine03 = 'successfully',
   @cLine04 = '',
   @cLine06 = 'Press ENTER or ESC', 
   @cLine07 = 'to continue', 
   @cLine14 = '%e',
   @nFunc = 651