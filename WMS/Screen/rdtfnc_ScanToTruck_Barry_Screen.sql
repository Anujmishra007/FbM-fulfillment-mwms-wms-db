--rdtfnc_ScanToTruck_Barry
-- 6400 - 6409

IF NOT EXISTS (SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID = '925')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('925', 'ENG', 'FNC', 'Truck Loading(Barry)', 'rdtfnc_ScanToTruck_Barry', '0')

-- Screen 1
-- Scn = 6400 
DELETE rdt.RDTScn WHERE Scn = 6400 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6400, 'ENG', 
   @cLine01 = 'TRUCK LOADING',
   @cLine03 = 'MBOLKEY:',
   @cLine04 = '%10i01',
   @cLine14 = '%e'

-- Screen 2
-- Scn = 6401 
DELETE rdt.RDTScn WHERE Scn = 6401 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6401, 'ENG', 
   @cLine01 = 'TRUCK LOADING',
   @cLine03 = 'Truck No:',
   @cLine04 = '%20i01',
   @cLine14 = '%e'

-- Screen 3
-- Scn = 6402
DELETE rdt.RDTScn WHERE Scn = 6402 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6402, 'ENG', 
   @cLine01 = 'TRUCK LOADING',
   @cLine03 = 'Truck ID:',
   @cLine04 = '%20d01',
   @cLine06 = '1 = CLOSE TRUCK',
   @cLine07 = '9 = ADD PALLET',
   @cLine08 = 'Options:%01i02',
   @cLine14 = '%e'

-- Screen 4
-- Scn = 6403
DELETE rdt.RDTScn WHERE Scn = 6403 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6403, 'ENG', 
   @cLine01 = 'TRUCK LOADING',
   @cLine03 = 'MBOLKEY:',
   @cLine04 = '%20d01',
   @cLine06 = 'Truck ID:',
   @cLine07 = '%20d02',
   @cLine09 = 'PALLET ID:',
   @cLine10 = '%20i03',
   @cLine11 = 'Scanned:  %20d04',
   @cLine13 = 'Last SO:%20d05',
   @cLine14 = '%e'

-- Screen 5
-- Scn = 6404
DELETE rdt.RDTScn WHERE Scn = 6404 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6404, 'ENG', 
   @cLine01 = 'TRUCK LOADING',
   @cLine02 = 'Truck ID:',
   @cLine03 = '%20d01',
   @cLine04 = 'SEAL NO 1:',
   @cLine05 = '%20i02',
   @cLine06 = 'SEAL NO 2:',
   @cLine07 = '%20i03',
   @cLine08 = 'SEAL NO 3:',
   @cLine09 = '%20i04',
   @cLine10 = 'Confirm Seal Number',
   @cLine11 = 'Completion 1 = Yes%01i05',
   @cLine14 = '%e',
   @cWebGroup = '{"1":["10","11"],"2":["4","5"],"3":["6","7"],"4":["8","9"]}'

-- Screen 6
-- Scn = 6405
DELETE rdt.RDTScn WHERE Scn = 6405 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6405, 'ENG', 
   @cLine01 = 'TRUCK LOADING',
   @cLine02 = 'Truck ID:',
   @cLine03 = '%20d01',
   @cLine04 = 'SEAL NO 4:',
   @cLine05 = '%20i02',
   @cLine06 = 'SEAL NO 5:',
   @cLine07 = '%20i03',
   @cLine08 = 'SEAL NO 6:',
   @cLine09 = '%20i04',
   @cLine14 = '%e',
   @cWebGroup = '{"1":["4","5"],"2":["6","7"],"3":["8","9"]}'

-- Screen 7
-- Scn = 6406
DELETE rdt.RDTScn WHERE Scn = 6406 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6406, 'ENG', 
   @cLine01 = 'TRUCK LOADING',
   @cLine03 = 'Truck Loaded.',
   @cLine04 = 'Please press Enter',
   @cLine05 = 'Or ESC to continue',
   @cLine14 = '%e'

         