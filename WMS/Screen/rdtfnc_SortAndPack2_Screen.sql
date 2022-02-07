IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID = 1829 AND Message_Type = 'FNC')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1831, 'ENG', 'FNC', 'SORT AND PACK 2', 'rdtfnc_SortAndPack2', '9')

-- 5170 = LoadKey screen
DELETE rdt.RDTScn WHERE Scn = 5170 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5170, 'ENG'
   ,@cLine01 = 'SORT AND PACK'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20i02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20i04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20i06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = '%20i08'
   ,@cLine10 = '%20d09'
   ,@cLine11 = '%20i10'
   ,@cLine12 = '%20d11'
   ,@cLine13 = '%20d12'
   ,@cLine14 = '%e'
   ,@nFunc = 1831
   
-- 5171 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 5171 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5171, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1831

-- 5172 = QTY screen
DELETE rdt.RDTScn WHERE Scn = 5172 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5172, 'ENG' 
   ,@cLine01 = 'SKU/UPC:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20i02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = 'EXP QTY: %05d05'
   ,@cLine07 = 'PCK QTY: %05i06'
   ,@cLine12 = '%20d07'             
   ,@cLine13 = '%20d08'             
   ,@cLine14 = '%e'
   ,@nFunc = 1831

-- 5173 = Label No screen
DELETE rdt.RDTScn WHERE Scn = 5173 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5173, 'ENG' 
   ,@cLine01 = 'LABEL NO:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1831


   