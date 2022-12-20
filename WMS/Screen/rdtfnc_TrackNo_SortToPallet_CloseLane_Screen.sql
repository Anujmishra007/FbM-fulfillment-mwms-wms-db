--rdtfnc_TrackNo_SortToPallet_CloseLane
--6130-6139

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID = 1654 AND Message_Type = 'FNC')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1654, 'ENG', 'FNC', 'Close Lane', 'rdtfnc_TrackNo_SortToPallet_CloseLane', '9')

-- 6130 = Scan Lane To Close screen
DELETE rdt.RDTScn WHERE Scn = 6130 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6130, 'ENG',
    @cLine01 = 'TRACKNO SORTTOPALLET'
   ,@cLine02 = 'CLOSE LANE'
   ,@cLine03 = 'LANE:'
   ,@cLine04 = '%20i01'
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1654   

-- 6131 = Confirm Close Lane screen
DELETE rdt.RDTScn WHERE Scn = 6131 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6131, 'ENG',
    @cLine01 = 'CONFIRM CLOSE ?'
   ,@cLine02 = 'LANE:'
   ,@cLine03 = '%20d01'
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i02'
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1654   

-- 6132 = Successfully Close Lane screen
DELETE rdt.RDTScn WHERE Scn = 6132 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6132, 'ENG',
    @cLine01 = 'LANE:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'CLOSED SUCCESSFULLY'
   ,@cLine04 = ''
   ,@cLine05 = ''
   ,@cLine06 = '%20d02'
   ,@cLine07 = '%20d03'
   ,@cLine08 = '%20d04'
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1654   

-- 6133 = Confirm Split Lane screen
DELETE rdt.RDTScn WHERE Scn = 6133 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6133, 'ENG',
    @cLine01 = 'SPLIT FULLY SCANNED'
   ,@cLine02 = 'CARTONS TO NEW LANE'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1654   

-- 6134 = Close New Lane screen
DELETE rdt.RDTScn WHERE Scn = 6134 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6134, 'ENG',
    @cLine01 = 'LANE SPLIT TO'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'CLOSE LANE:'
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i02'
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1654      