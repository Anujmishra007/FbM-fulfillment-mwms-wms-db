--rdtfnc_OrderTrackNoPicking
-- 2710 - 2719

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('867', 'ENG', 'FNC', 'Pick By TrackNo', 'rdtfnc_PickByTrackNo', '3')


-- 2710 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2710 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2710, 'ENG',
    @cLine01 = 'Pick By TrackNo'
   ,@cLine03 = 'ORDERKEY:'
   ,@cLine04 = '%10i01'
   ,@cLine14 = '%e'
   
 
-- 2711 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2711 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2711, 'ENG',
    @cLine01 = 'Pick By TrackNo'
   ,@cLine03 = 'ORDERKEY:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'TRACK NO:'
   ,@cLine06 = '%18i02'
   ,@cLine14 = '%e'

-- 2712 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2712 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2712, 'ENG',
    @cLine01 = 'Pick By TrackNo'
   ,@cLine03 = 'ORDERKEY:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'TRACK NO:'
   ,@cLine06 = '%18d02'
   ,@cLine08 = 'TTL PICK: %05d04'
   ,@cLine09 = 'TTL EXP : %05d05'
   ,@cLine10 = 'SKU:'
   ,@cLine11 = '%40i03'
   ,@cLine14 = '%e'

-- 2713 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2713 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2713, 'ENG',
    @cLine01 = 'Pick By TrackNo'
   ,@cLine03 = 'Picking Completed'
   ,@cLine05 = 'PRESS ENTER for next'
   ,@cLine06 = 'Picking'
   ,@cLine14 = '%e'
   
-- 2714 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2714 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2714, 'ENG',
    @cLine01 = 'Pick By TrackNo'
   ,@cLine03 = 'Orders Exist !'
   ,@cLine05 = '1 = RESCAN '
   ,@cLine06 = '9 = CONTINUE'
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'   


-- (ChewKP04)
-- 2715 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2715 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2715, 'ENG',
    @cLine01 = 'Pick By TrackNo'
   ,@cLine03 = 'SKU:         %11d01'
   ,@cLine04 = '%20d02'
   ,@cLine06 = 'DESCR:'
   ,@cLine07 = '%20d03'
   ,@cLine08 = '%20d04'
   ,@cLine09 = '1 = SELECT SKU'
   ,@cLine10 = 'OPTION: %01i05'
   ,@cLine14 = '%e'     
   
   
      
-- update rdt.rdtscn with function id   
UPDATE RDT.RDTSCN SET FUNC = 867 WHERE SCN BETWEEN 2710 AND 2719
   
-- Note: This module no need set function no as it is shared across multi function