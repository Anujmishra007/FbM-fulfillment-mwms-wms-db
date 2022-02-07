--rdtfnc_SortationByTrackingID_Reversal
--5701-5709

IF NOT EXISTS ( SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 642)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (642, 'ENG', 'FNC', 'Sort By TrackingID Reversal', 'rdtfnc_SortationByTrackingID_Reversal', '9')
END

-- 5700 = PARENT TRACKING screen
DELETE rdt.RDTScn WHERE Scn = 5700 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5700, 'ENG'
   ,@cLine01 = 'PARENT TRACKING ID:'
   ,@cLine02 = '%20i01'
   ,@cLine12 = 'REVERSE ALL (1=Y): %01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 642
 
-- 5701 = CHILD TRACKING screen
DELETE rdt.RDTScn WHERE Scn = 5701 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5701, 'ENG'
   ,@cLine01 = 'PARENT TRACKING ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'SKU/UPC:'
   ,@cLine04 = '%60i02'
   ,@cLine05 = 'CHILD TRACKING ID:'
   ,@cLine06 = '%60iV_MAX'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 642

-- 5702 = CONFIRM REVERSAL screen
DELETE rdt.RDTScn WHERE Scn = 5702 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5702, 'ENG'
   ,@cLine01 = 'PARENT TRACKING ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'CHILD TRACKING ID:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = ''
   ,@cLine07 = 'CONFIRM REVERSAL ?'
   ,@cLine08 = '1 = YES'
   ,@cLine09 = '2 = NO'
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = 'OPTION: %01i03'
   ,@cLine14 = '%e'
   ,@nFunc = 642

