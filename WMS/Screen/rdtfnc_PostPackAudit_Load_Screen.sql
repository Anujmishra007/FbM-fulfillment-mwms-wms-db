/*
   Post pick audit load
*/

-- 640 = Vehicle
DELETE rdt.RDTScn WHERE Scn = 640 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 640, 'ENG', 
   @cLine01 = 'LOAD', 
   @cLine02 = '', 
   @cLine03 = 'VEHICLE NO:', 
   @cLine04 = '%20i01', 
   @cLine05 = '', 
   @cLine06 = 'REF NO:', 
   @cLine07 = '1. %17i02', 
   @cLine08 = '2. %17i03', 
   @cLine09 = '3. %17i04', 
   @cLine10 = '4. %17i05', 
   @cLine11 = '5. %17i06', 
   @cLine12 = '', 
   @cLine14 = '%e'

-- 641 = Case
DELETE rdt.RDTScn WHERE Scn = 641 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 641, 'ENG', 
   @cLine01 = 'LOAD', 
   @cLine02 = '', 
   @cLine03 = 'VEHICLE NO:', 
   @cLine04 = '%20d01', 
   @cLine05 = '', 
   @cLine06 = 'STOR:', 
   @cLine07 = '%15i02', 
   @cLine08 = '', 
   @cLine09 = 'SEAL:', 
   @cLine10 = '%20i03', 
   @cLine11 = '', 
   @cLine14 = '%e'

-- 642 = Case
DELETE rdt.RDTScn WHERE Scn = 642 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 642, 'ENG', 
   @cLine01 = 'LOAD', 
   @cLine02 = '', 
   @cLine03 = 'VEHICLE NO:', 
   @cLine04 = '%20d01', 
   @cLine05 = '', 
   @cLine06 = 'STOR:', 
   @cLine07 = '%10d02', 
   @cLine08 = '', 
   @cLine09 = 'CASE/TOTE:', 
   @cLine10 = '%18i03', 
   @cLine11 = '', 
   @cLine12 = 'SCAN: %05d04', 
   @cLine14 = '%e'