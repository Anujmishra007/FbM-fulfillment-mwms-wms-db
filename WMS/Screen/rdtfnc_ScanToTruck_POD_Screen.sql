--rdtfnc_ScanToTruck_POD
-- 3660 - 3669


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('924', 'ENG', 'FNC', 'ScanToTruck POD', 'rdtfnc_ScanToTruck_POD', '0')

-- 3660 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3660 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3660, 'ENG'
   ,@cLine01 = 'MBOLKEY:  %10i01'
   ,@cLine02 = ''
   ,@cLine03 = 'LOADKEY:  %10i02'
   ,@cLine04 = ''
   ,@cLine05 = 'ORDERKEY: %10i03'
   ,@cLine14 = '%e'

-- 3661 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3661 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3661, 'ENG'
   ,@cLine01 = 'DOOR NO: %10i01'
   ,@cLine14 = '%e'
   
-- 3662 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3662 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3662, 'ENG'
   ,@cLine01 = 'DOOR NO: %10d01'
   ,@cLine02 = 'TRUCK NO:'
   ,@cLine03 = '%18i02'
   ,@cLine14 = '%e'

-- 3661 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3663 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3663, 'ENG'
   ,@cLine01 = 'DOOR NO: %10d01'
   ,@cLine02 = 'TRUCK NO: '
   ,@cLine03 = '%18d02'
   ,@cLine04 = 'TRANSPORTER:'
   ,@cLine05 = '%20i03'
   ,@cLine14 = '%e'      

 