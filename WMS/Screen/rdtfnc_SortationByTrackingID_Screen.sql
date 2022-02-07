--rdtfnc_SortByPallet_SerialNo
--5690-5699

IF NOT EXISTS ( SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 641)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (641, 'ENG', 'FNC', 'Sort By TrackingID', 'rdtfnc_SortationByTrackingID', '9')
END

-- 5690 = EMPTY CART screen
DELETE rdt.RDTScn WHERE Scn = 5690 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5690, 'ENG'
   ,@cLine01 = 'PARENT TRACKING ID:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 641
 
-- 5691 = CART ID screen
DELETE rdt.RDTScn WHERE Scn = 5691 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5691, 'ENG'
   ,@cLine01 = 'PARENT TRACKING ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'SKU/UPC:'
   ,@cLine04 = '%60i02'
   ,@cLine05 = 'CHILD TRACKING ID:'
   --,@cLine06 = '%1000iV_MAX'
   ,@cLine06 = '%60iV_MAX'
   ,@cLine07 = 'SCANNED: %03d04'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 641

-- 5692 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 5692 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5692, 'ENG'
   ,@cLine01 = 'CLOSE PALLET ?'
   ,@cLine02 = '1 = YES'
   ,@cLine03 = '2 = NO'
   ,@cLine04 = ''
   ,@cLine05 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 641

