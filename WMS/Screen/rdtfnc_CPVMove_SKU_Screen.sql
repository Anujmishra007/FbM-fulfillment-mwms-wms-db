--rdtfnc_CPVMove_SKU
-- 5320 - 5329

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 633)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (633, 'ENG', 'FNC', 'CPV Move By SKU', 'rdtfnc_CPVMove_SKU', '4')
END

-- 5320 = LOC
DELETE rdt.RDTScn WHERE Scn = 5320 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5320, 'ENG',
   @cLine01 = 'FROM LOC: %10i01',
   @cLine14 = '%e',
   @nFunc = 633

-- 5321 = ID
DELETE rdt.RDTScn WHERE Scn = 5321 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5321, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%20i02',
   @cLine14 = '%e',
   @nFunc = 633

-- 5322 = SKU
DELETE rdt.RDTScn WHERE Scn = 5322 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5322, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU/UPC:',
   @cLine05 = '%60i03',
   @cLine14 = '%e',
   @nFunc = 633

-- 5323 = QTY
DELETE rdt.RDTScn WHERE Scn = 5323 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5323, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU:         PPK:%03d12', 
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = '%20d05',
   @cLine08 = '         %05d06 %05d09',
   @cLine09 = 'QTY AVL: %05d07 %05d10',
   @cLine10 = 'QTY MV:  %05i08 %05i11',
   @cLine14 = '%e',
   @nFunc = 633

-- 5324 = To ID
DELETE rdt.RDTScn WHERE Scn = 5324 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5324, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU:         PPK:%03d13', 
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = '%20d05',
   @cLine08 = '         %05d06 %05d09',
   @cLine09 = 'QTY AVL: %05d07 %05d10',
   @cLine10 = 'QTY MV:  %05d08 %05d11',
   @cLine11 = 'TO ID:',
   @cLine12 = '%20i12',
   @cLine14 = '%e',
   @nFunc = 633

-- 5325 = To LOC
DELETE rdt.RDTScn WHERE Scn = 5325 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5325, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU:         PPK:%03d14', 
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = '%20d05',
   @cLine08 = '         %05d06 %05d09',
   @cLine09 = 'QTY AVL: %05d07 %05d10',
   @cLine10 = 'QTY MV:  %05d08 %05d11',
   @cLine11 = 'TO ID:',
   @cLine12 = '%18d12',
   @cLine13 = 'TO LOC: %10i13',
   @cLine14 = '%e',
   @nFunc = 633

-- 5326 = Message screen
DELETE rdt.RDTScn WHERE Scn = 5326 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5326, 'ENG',
   @cLine02 = 'SKU moved',
   @cLine03 = 'successfully',
   @cLine04 = 'TO LOC: %10d01',     
   @cLine06 = 'Press ENTER or ESC', 
   @cLine07 = 'to continue',        
   @cLine14 = '%e',
   @nFunc = 633

-- 5327 = Suggest LOC screen
DELETE rdt.RDTScn WHERE Scn = 5327 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5327, 'ENG', 
   @cLine01 = '%20d01',
   @cLine02 = '%20d02',
   @cLine03 = '%20d03',
   @cLine04 = '%20d04',
   @cLine05 = '%20d05',
   @cLine06 = '%20d06',
   @cLine14 = '%e',
   @nFunc = 633

-- 5328 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5328 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5328, 'ENG',
   @cLine01 = N'SKU 1/2:      OPT:%02i13',
   @cLine02 = N'',
   @cLine03 = N'%20d02',
   @cLine04 = N'%20d03',
   @cLine05 = N'%20d04',
   @cLine06 = N'%20d05',
   @cLine07 = N'',
   @cLine08 = N'%20d07',
   @cLine09 = N'%20d08',
   @cLine10 = N'%20d09',
   @cLine11 = N'%20d10',
   @cLine12 = N'',
   @cLine13 = N'(1-2=SKU ENTER=NEXT)',
   @cLine14 = N'%e',
   @nFunc = 633 