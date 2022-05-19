--rdtfnc_TrackNo_SortToPallet
--5800-5809

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID = 1653 AND Message_Type = 'FNC')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1653, 'ENG', 'FNC', 'TrackNo SortToPallet', 'rdtfnc_TrackNo_SortToPallet', '9')

-- 5800 = Scan Track No screen
DELETE rdt.RDTScn WHERE Scn = 5800 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5800, 'ENG',
    @cLine01 = 'TRACKNO SORTTOPALLET'
   ,@cLine02 = ''
   ,@cLine03 = 'TRACK NO:'
   ,@cLine04 = '%100i01'   -- WMS-18616 Extend to 100 chars
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = 'CLOSE PALLET(1=YES)%01i02'   -- WMS-19061
   ,@cLine13 = '%20d15'                      -- WMS-19061
   ,@cLine14 = '%e'
   ,@nFunc = 1653

-- 5801 = Scan Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 5801 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5801, 'ENG',
    @cLine01 = 'TRACKNO SORTTOPALLET'
   ,@cLine02 = ''
   ,@cLine03 = 'TRACK NO:'
   ,@cLine04 = '%40d01'
   ,@cLine05 = 'ORDERKEY: %10d02'
   ,@cLine06 = 'SCAN PALLET:'
   ,@cLine07 = '%20i03'
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1653

-- 5802 = Confirm Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 5802 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5802, 'ENG',
    @cLine01 = 'TRACKNO SORTTOPALLET'
   ,@cLine02 = ''
   ,@cLine03 = 'TRACK NO:'
   ,@cLine04 = '%40d01'
   ,@cLine05 = 'ORDERKEY: %10d02'
   ,@cLine06 = 'PLEASE PUT INTO'
   ,@cLine07 = 'PALLET:'
   ,@cLine08 = '%20d03'
   ,@cLine09 = ''
   ,@cLine10 = 'PALLETKEY:'
   ,@cLine11 = '%20i04'
   ,@cLine12 = ''
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1653   

-- 5803 = Confirm Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 5803 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5803, 'ENG',
    @cLine01 = 'TRACKNO SORTTOPALLET'
   ,@cLine02 = ''
   ,@cLine03 = 'PALLETKEY:'
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
   ,@nFunc = 1653   
