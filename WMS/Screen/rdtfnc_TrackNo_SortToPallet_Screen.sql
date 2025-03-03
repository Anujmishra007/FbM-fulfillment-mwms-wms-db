--rdtfnc_TrackNo_SortToPallet
--5800-5809

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID = 1653 AND Message_Type = 'FNC')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1653, 'ENG', 'FNC', 'TrackNo SortToPallet', 'rdtfnc_TrackNo_SortToPallet', '9')

-- 5800 = Scan Track No screen
DELETE rdt.RDTScn WHERE Scn = 5800 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5800, 'ENG',
   @cLine03 = 'TRACK NO:'
   ,@cLine04 = '%100i01'
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
   @cLine03 = 'TRACK NO:'
   ,@cLine04 = '%40d01'
   ,@cLine05 = 'ORDERKEY: %10d02'
   ,@cLine06 = 'SCAN PALLET:'
   ,@cLine07 = '%20i03'
   ,@cLine08 = 'LANE:'  -- WMS-20667
   ,@cLine09 = '%20i04' -- WMS-20667
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 1653

-- 5802 = Confirm Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 5802 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5802, 'ENG',
   @cLine03 = 'TRACK NO:'
   ,@cLine04 = '%40d01'
   ,@cLine05 = 'ORDERKEY: %10d02'
   ,@cLine06 = 'PLEASE PUT INTO'
   ,@cLine07 = 'PALLET:'
   ,@cLine08 = '%20d03'
   ,@cLine09 = 'PALLETKEY:'
   ,@cLine10 = '%20i04'
   ,@cLine11 = 'LANE:'  -- WMS-20667
   ,@cLine12 = '%20d05' -- WMS-20667
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 1653

-- 5803 = Close Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 5803 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5803, 'ENG',
   @cLine03 = 'PALLETKEY:'
   ,@cLine04 = '%20i01'
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = '%20d15' -- WMS-20667
   ,@cLine14 = '%e'
   ,@nFunc = 1653

-- WMS-19218
-- 5804 = Confirm Scan To Different Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 5804 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5804, 'ENG',
   @cLine03 = 'SUGGESTED PALLETKEY:'
   ,@cLine04 = '%20d01'
   ,@cLine05 = ''
   ,@cLine06 = 'SCANNED PALLETKEY'
   ,@cLine07 = '%20d02'
   ,@cLine08 = ''
   ,@cLine09 = '1 = YES; 2 = NO'
   ,@cLine10 = 'Option: %01i03'
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1653

-- 5805 = Pack info screen
DELETE rdt.RDTScn WHERE Scn = 5805 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5805, 'ENG'
   ,@cLine01 = 'PALLETKEY:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'WEIGHT: %10i02'
   ,@cLine06 = 'LENGTH: %10i03'
   ,@cLine07 = 'WIDTH:  %10i04'
   ,@cLine08 = 'HEIGHT: %10i05'
   ,@cLine13 = '%20d15' -- WMS-20667 Add ExtendedInfoSP
   ,@cLine14 = '%e'
   ,@nFunc = 1653

-- WMS-20667
-- 5806 = Confirm Scan new Lane screen
DELETE rdt.RDTScn WHERE Scn = 5806 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5806, 'ENG',
   @cLine01 = 'PALLETKEY:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'NEW LANE:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = ''
   ,@cLine07 = 'SCAN LANE TO CONFIRM'
   ,@cLine08 = '%20i03'
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1653

-- FCR-539
-- 5807 = SCAN TO LOC/LANE
DELETE rdt.RDTScn WHERE Scn = 5807 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5807, 'ENG',
   @cLine01 = 'TRACK NO:'
   ,@cLine02 = '%40d01'
   ,@cLine03 = 'ORDERKEY: %10d02'
   ,@cLine04 = 'SCAN PALLET: %20d03'
   ,@cLine05 = ''
   ,@cLine06 = 'SCAN TO PALLET:'
   ,@cLine07 = '%20i04'
   ,@cLine08 = '%20d14'
   ,@cLine09 = 'LOC/LANE:'  -- WMS-20667
   ,@cLine10 = '%20i05' -- WMS-20667
   ,@cLine11 = '%20d15'
   ,@cLine12 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["6","7"],"3":["9","10"],"4":["11","12"]}'
   ,@nFunc = 1653

-- FCR-950
-- 6447 = Remove Carton from Pallet?
DELETE rdt.RDTScn WHERE Scn = 6447 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6447, 'ENG',
    @cLine01 = 'Carton already'
   ,@cLine02 = 'scanned to pallet.'
   ,@cLine03 = 'Confirm to remove'
   ,@cLine04 = 'carton from pallet?'
   ,@cLine05 = 'Pallet Key:'
   ,@cLine06 = '%20d02'
   ,@cLine07 = '1 = Yes'
   ,@cLine08 = '2 = No'
   ,@cLine09 = 'Option: '
   ,@cLine10 = '%1i01' 
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3","4"],"2":["5","6"],"3":["7","8","9","10"]}'
   ,@nFunc = 1653

