--rdtfnc_PackByCartonID
--5380-5389

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 833)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (833, 'ENG', 'FNC', 'CARTON PACK', 'rdtfnc_PackByCartonID', '3')
END

-- 5380 = WAVEKEY screen
DELETE rdt.RDTScn WHERE Scn = 5380 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5380, 'ENG'
   ,@cLine01 = 'WAVEKEY: %10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 833
 
-- 5381 = SKU/CASE ID/SERIAL NO screen
DELETE rdt.RDTScn WHERE Scn = 5381 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5381, 'ENG'
   ,@cLine01 = 'WAVEKEY:'
   ,@cLine02 = '%20d01'  
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%20i02'
   ,@cLine07 = 'CASE ID:'
   ,@cLine08 = '%20i03'
   ,@cLine10 = 'SERIAL NO:'
   ,@cLine11 = '%1000iV_MAX'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 833
