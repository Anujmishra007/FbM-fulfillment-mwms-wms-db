--rdtfnc_PalletBuild_SerialNo
--5310 - 5319

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1644)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1644, 'ENG', 'FNC', 'PALLET BUILD (SERIALNO)', 'rdtfnc_PalletBuild_SerialNo', '9')
END

-- 5310 = PICKSLIP NO screen
DELETE rdt.RDTScn WHERE Scn = 5310 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5310, 'ENG'
   ,@cLine01 = 'PICKSLIP NO:'
   ,@cLine02 = '%10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1644
 
-- 5311 = DROP ID screen
DELETE rdt.RDTScn WHERE Scn = 5311 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5311, 'ENG'
   ,@cLine01 = 'PICKSLIP NO:'
   ,@cLine02 = '%10d01'   
   ,@cLine03 = 'DROP ID:'
   ,@cLine04 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1644

-- 5312 = SKU/CASE ID/SERIAL NO screen
DELETE rdt.RDTScn WHERE Scn = 5312 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5312, 'ENG'
   ,@cLine01 = 'DROP ID:'
   ,@cLine02 = '%20d01'  
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%20i02'
   ,@cLine07 = 'CASE ID:'
   ,@cLine08 = '%20i03'
   ,@cLine10 = 'SERIAL NO:'
   ,@cLine11 = '%1000iV_MAX'
   ,@cLine14 = '%e'
   ,@nFunc = 1644

-- 5313 = Close Pallet screen
DELETE rdt.RDTScn WHERE Scn = 5313 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5313, 'ENG'
   ,@cLine01 = 'Close Pallet?'
   ,@cLine02 = ''  
   ,@cLine04 = '1 = Yes'
   ,@cLine05 = '2 = No'
   ,@cLine06 = '%01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1644

-- 5314 = Print Manifest screen
DELETE rdt.RDTScn WHERE Scn = 5314 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5314, 'ENG'
   ,@cLine01 = 'Print Manifest?'
   ,@cLine02 = ''  
   ,@cLine04 = '1 = Yes'
   ,@cLine05 = '2 = No'
   ,@cLine06 = '%01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1644