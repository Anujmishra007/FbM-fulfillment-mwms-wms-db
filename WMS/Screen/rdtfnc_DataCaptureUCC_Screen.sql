-- rdtfnc_DataCaptureUCC

IF NOT EXISTS( SELECT 1 FROM RDT.RDTMsg WITH (NOLOCK) WHERE Message_ID = '821' AND Lang_Code = 'ENG' AND Message_Type = 'FNC')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('821', 'ENG', 'FNC', 'Data Capture UCC', 'rdtfnc_DataCaptureUCC', '0')
GO

-- UCC, ID, carton type
DELETE rdt.RDTScn WHERE Scn = 4000 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4000, 'ENG', 
   @cLine01 = 'DATA CAPTURE UCC',
   @cLine02 = '', 
   @cLine03 = 'UCC:',
   @cLine04 = '%20i01',
   @cLine05 = '', 
   @cLine06 = 'ID:',
   @cLine07 = '%60i02',
   @cLine08 = '', 
   @cLine09 = 'CARTON TYPE:',
   @cLine10 = '%10i03',
   @cLine14 = '%e', 
   @nFunc = 821

-- SKU, QTY
DELETE rdt.RDTScn WHERE Scn = 4001 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4001, 'ENG', 
   @cLine01 = 'DATA CAPTURE UCC',
   @cLine02 = '', 
   @cLine03 = 'UCC:',
   @cLine04 = '%20d01',
   @cLine05 = 'ID:',
   @cLine06 = '%18d02',
   @cLine07 = 'SKU:',
   @cLine08 = '%30i03',
   @cLine09 = '%20d04',
   @cLine10 = '', 
   @cLine11 = 'EXPECTED QTY: %05d05',
   @cLine12 = 'ACTUAL QTY  : %05i06',
   @cLine14 = '%e', 
   @nFunc = 821

 -- Item, QTY
DELETE rdt.RDTScn WHERE Scn = 4002 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4002, 'ENG', 
   @cLine01 = 'DATA CAPTURE UCC',
   @cLine02 = '', 
   @cLine03 = 'ITEM         QTY',
   @cLine04 = '%12d01 %05i02',
   @cLine05 = '%12d03 %05i04',
   @cLine06 = '%12d05 %05i06',
   @cLine07 = '%12d07 %05i08',
   @cLine08 = '%12d09 %05i10',
   @cLine09 = '%12d11 %05i12',
   @cLine10 = '%12d13 %05i14',
   @cLine14 = '%e', 
   @nFunc = 821
