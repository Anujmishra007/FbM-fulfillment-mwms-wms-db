
/*
   rdtfnc_Mbol_ChildReverse
*/
IF NOT EXISTS( SELECT 1 FROM rdt.rdtMsg WITH (NOLOCK) WHERE Message_ID = '1862' AND Message_Type = 'FNC' AND Lang_Code = 'ENG')
   INSERT INTO rdt.rdtMsg (Message_ID, Message_Type, Lang_Code, Message_Text, StoredProcName, EventType)
   VALUES (1862, 'FNC', 'ENG', 'Mbol ChildReverse', 'rdtfnc_Mbol_ChildReverse', 3)
GO

-- 6190 = MBOLKEY
DELETE rdt.RDTScn WHERE Scn = 6190 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6190, 'ENG',
   @cLine01 = 'MBOLkey: %20i01',
   @cLine14 = '%e',
   @nFunc = 1862

-- 6191 = palletkey
DELETE rdt.RDTScn WHERE Scn = 6191 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6191, 'ENG',
   @cLine01 = 'Facility: %20d01',
   @cLine02 = 'MBOLKEY:',
   @cLine03 = '%20d02',
   @cLine04 = 'Orderkey:',
   @cLine05 = '%20i03',
   @cLine06 = 'UDF02:',
   @cLine07 = '%20i04',
   @cLine08 = 'PalletID:',
   @cLine09 = '%20i05',
   @cLine10 = 'CaseID:',
   @cLine11 = '%20i06',
   @cLine12 = 'DropID:',
   @cLine13 = '%20i07',
   @cLine14 = '%e',
   @nFunc = 1862

-- 6192 = reverse sucess
DELETE rdt.RDTScn WHERE Scn = 6192 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6192, 'ENG',
   @cLine01 = 'Reverse order',
   @cLine02 = 'MBOLKEY:',
   @cLine03 = '%20d01',
   @cLine04 = '', 
   @cLine05 = 'Child Order ',
   @cLine06 = 'Reverse Success',
   @cLine14 = '%e',
   @nFunc = 1862

-- 6193 = option
DELETE rdt.RDTScn WHERE Scn = 6193 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6193 , 'ENG',
   @cLine01 = 'Reverse order',
   @cLine02 = 'MBOLKEY:',
   @cLine03 = '%20d01',
   @cLine04 = '', 
   @cLine05 = 'Reverse BY MBOL',
   @cLine06 = '1-YES',   
   @cLine07 = '9-NO',
   @cLine08 = 'Option: %01i02',
   @cLine14 = '%e',
   @nFunc = 1862
   

