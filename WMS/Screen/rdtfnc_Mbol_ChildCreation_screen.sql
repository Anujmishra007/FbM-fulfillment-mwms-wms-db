
/*
   rdtfnc_Mbol_ChildCreation
*/
IF NOT EXISTS( SELECT 1 FROM rdt.rdtMsg WITH (NOLOCK) WHERE Message_ID = '1861' AND Message_Type = 'FNC' AND Lang_Code = 'ENG')
   INSERT INTO rdt.rdtMsg (Message_ID, Message_Type, Lang_Code, Message_Text, StoredProcName, EventType)
   VALUES (1861, 'FNC', 'ENG', 'Mbol ChildCreation', 'rdtfnc_Mbol_ChildCreation', 3)
GO

-- 6190 = facility
DELETE rdt.RDTScn WHERE Scn = 6180 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6180, 'ENG',
   @cLine01 = 'Facility: %20i01',
   @cLine02 = 'MBOLKEY: ',
   @cLine03 = '%20i02',
   @cLine14 = '%e',
   @nFunc = 1861

-- 6191 = orderkey
DELETE rdt.RDTScn WHERE Scn = 6181 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6181, 'ENG',
   @cLine01 = 'MBOLKEY: %20d01',
   @cLine02 = 'PalletID:',
   @cLine03 = '%20i02',
   @cLine04 = 'CaseID',
   @cLine05 = '%20i03',
   @cLine06 = 'DropID',
   @cLine07 = '%20i04',
   @cLine08 = 'UDF02:',
   @cLine09 = '%20i05',
   @cLine14 = '%e',
   @nFunc = 1861

-- 6193 = create order sucess
DELETE rdt.RDTScn WHERE Scn = 6182 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6182, 'ENG',
   @cLine01 = 'Create Order',
   @cLine02 = 'MBOLKEY:',
   @cLine03 = '%20d01',
   @cLine04 = 'Store code:', 
   @cLine05 = '%20d02',
   @cLine06 = 'CaseID Counter:', 
   @cLine07 = '%20d03',
   @cLine08 = 'Child orders',
   @cLine09 = 'Create Success',
   @cLine14 = '%e',
   @nFunc = 1861
