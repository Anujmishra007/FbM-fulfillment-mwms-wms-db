--rdtfnc_Capture_SKUInfo
-- 5300 - 5309

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 826)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (826, 'ENG', 'FNC', 'SKU INFO CAPTURE', 'rdtfnc_Capture_SKUInfo', '9')
END

-- 5300 = UCC/SKU screen
DELETE rdt.RDTScn WHERE Scn = 5300 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5300, 'ENG'
   ,@cLine01 = 'SKU INFO CAPTURE'
   ,@cLine02 = ''
   ,@cLine03 = 'UCC:'
   ,@cLine04 = '%20i01'
   ,@cLine05 = ''
   ,@cLine06 = 'OR'
   ,@cLine07 = ''
   ,@cLine08 = 'SKU/UPC:'
   ,@cLine09 = '%60i02'
   ,@cLine10 = 'QTY:'
   ,@cLine11 = '%05i03'
   ,@cLine12 = ''
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 826
 
-- 5301 = Param screen
DELETE rdt.RDTScn WHERE Scn = 5301 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5301, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = '%20i05'
   ,@cLine06 = '%20d06'
   ,@cLine07 = '%20i07'
   ,@cLine08 = '%20d08'
   ,@cLine09 = '%20i09'
   ,@cLine10 = '%20d10'
   ,@cLine11 = '%20i11'
   ,@cLine12 = '%20d12'
   ,@cLine13 = '%20i13'
   ,@cLine14 = '%e'
   ,@nFunc = 826

-- 5302 = Success screen
DELETE rdt.RDTScn WHERE Scn = 5302 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5302, 'ENG'
   ,@cLine01 = 'UPDATE SUCCESSFUL !!'
   ,@cLine02 = ''
   ,@cLine03 = 'PRESS ENTER TO'
   ,@cLine04 = 'CONTINUE.'
   ,@cLine14 = '%e'
   ,@nFunc = 826

--wms-16159
-- 5303 = Printting screen
DELETE rdt.RDTScn WHERE Scn = 5303 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5303, 'ENG'
   ,@cLine01 = 'PRINT PALLET LABEL?'
   ,@cLine03 = '1 = YES 2 = NO'
   ,@cLine05 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 826
  
