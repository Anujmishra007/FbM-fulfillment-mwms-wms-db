
IF NOT EXISTS( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1584)
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1584, 'ENG', 'FNC', 'SSCC RECEIVE1', 'rdtfnc_SSCC_Receiving1', '3')
GO

-- 6220 = ASN screen
DELETE rdt.RDTScn WHERE Scn = 6220 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6220, 'ENG' 
   ,@cLine01 = 'ASN: %10i01'
   ,@cLine02 = ''
   ,@cLine03 = 'REF NO:'
   ,@cLine04 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1584

-- 6221 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 6221 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6221, 'ENG'
   ,@cLine01 = 'ASN: %10d01'
   ,@cLine02 = ''
   ,@cLine03 = 'TO LOC: %10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1584

-- 6222 = ID screen
DELETE rdt.RDTScn WHERE Scn = 6222 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6222, 'ENG'
   ,@cLine01 = 'TO LOC: %10d01'
   ,@cLine02 = ''
   ,@cLine03 = 'TO ID:'
   ,@cLine04 = '%18i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1584

-- 6223. SSCC screen
DELETE rdt.RDTScn WHERE Scn = 6223 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6223, 'ENG'
   ,@cLine01 = 'TO ID:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = ''
   ,@cLine04 = 'PALLET SSCC:'
   ,@cLine05 = '%30i02'
   ,@cLine06 = ''
   ,@cLine07 = 'CASE SSCC:'
   ,@cLine08 = '%30i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1584

-- 6224 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 6224 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6224, 'ENG'
   ,@cLine01 = 'SSCC: '
   ,@cLine02 = '%18d01'
   ,@cLine03 = ''
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%60i02'
   ,@cLine06 = ''
   ,@cLine07 = '%20d03'
   ,@cLine08 = '%20d04'
   ,@cLine14 = '%e'
   ,@nFunc = 1584

-- 6225 = QTY, COND screen
DELETE rdt.RDTScn WHERE Scn = 6225 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6225, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = 'IVAS:'
   ,@cLine06 = '%20d04'
   ,@cLine07 = ''
   ,@cLine08 = '%07d05  %05d06 %05d07'
   ,@cLine09 = 'QTY:     %05i08 %05i09'
   ,@cLine10 = ''
   ,@cLine11 = 'COND CODE:%10i10'
   ,@cLine12 = ''
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 1584   
