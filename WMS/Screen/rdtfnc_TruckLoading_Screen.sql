-- 2920 = Door screen
DELETE rdt.RDTScn WHERE Scn = 2920 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2920, 'ENG'
   ,@cLine01 = 'TRUCK LOADING'
   ,@cLine03 = 'DOOR NO:'
   ,@cLine04 = '%10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1648
 
-- 2921 = MBOLKey screen
DELETE rdt.RDTScn WHERE Scn = 2921 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2921, 'ENG'
   ,@cLine01 = 'TRUCK LOADING'
   ,@cLine03 = 'DOOR NO:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'MBOLKEY:'
   ,@cLine06 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1648
 
-- 2922 = Carton screen
DELETE rdt.RDTScn WHERE Scn = 2922 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2922, 'ENG'
   ,@cLine01 = 'TRUCK LOADING'
   ,@cLine03 = 'DOOR NO:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'MBOLKEY:'
   ,@cLine06 = '%10d02'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20i03'
   ,@cLine10 = 'FIRST CARTON:'
   ,@cLine11 = '%20d04'
   ,@cLine14 = '%e'
   ,@nFunc = 1648
 
-- 2923 = Message screen
DELETE rdt.RDTScn WHERE Scn = 2923 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2923, 'ENG'
   ,@cLine01 = 'TRUCK LOADING'
   ,@cLine03 = 'LOADING COMPLETED'
   ,@cLine04 = 'DOOR NO:'
   ,@cLine05 = '%10d01'
   ,@cLine06 = 'MBOLKEY:'
   ,@cLine07 = '%10d02'
   ,@cLine09 = 'FIRST CARTON:'
   ,@cLine10 = '%20d03'
   ,@cLine11 = 'LAST CARTON'
   ,@cLine12 = '%20d04'
   ,@cLine14 = '%e'
   ,@nFunc = 1648
 
-- 2924 = Confirm screen
DELETE rdt.RDTScn WHERE Scn = 2924 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2924, 'ENG'
   ,@cLine01 = 'TRUCK LOADING'
   ,@cLine02 = 'DOOR NO:'
   ,@cLine03 = '%10d01'
   ,@cLine04 = 'MBOLKEY:'
   ,@cLine05 = '%10d02'
   ,@cLine06 = 'FIRST CARTON:'
   ,@cLine07 = '%20d03'
   ,@cLine09 = 'Last Carton Same As'
   ,@cLine10 = 'First Carton ?'
   ,@cLine11 = '1 = YES | 2 = NO'
   ,@cLine12 = 'Options: %01i04'
   ,@cLine14 = '%e'
   ,@nFunc = 1648
 
-- 2925 = Confirm screen
DELETE rdt.RDTScn WHERE Scn = 2925 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2925, 'ENG'
   ,@cLine01 = 'TRUCK LOADING'
   ,@cLine03 = 'MBOLKEY:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'DOOR NO:'
   ,@cLine06 = '%10d02'
   ,@cLine07 = 'FIRST CARTON NO:'
   ,@cLine08 = '%20d03'
   ,@cLine09 = 'FIRST CARTON SCANNED'
   ,@cLine10 = 'CONFIRM EXIT ?'
   ,@cLine11 = '1 = YES | 2 = NO'
   ,@cLine12 = 'OPTION: %01i04'
   ,@cLine14 = '%e'
 
