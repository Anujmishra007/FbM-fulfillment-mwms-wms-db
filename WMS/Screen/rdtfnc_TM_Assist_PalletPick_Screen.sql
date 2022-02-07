-- 5060 = Final LOC (1 pallet) screen
DELETE rdt.RDTScn WHERE Scn = 5060 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5060, 'ENG'
   ,@cLine01 = 'TM PICK       ASTFPK'
   ,@cLine02 = ''
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%20d01'
   ,@cLine05 = ''
   ,@cLine06 = 'SUGGESTED LOC: '
   ,@cLine07 = '%10d02' 
   ,@cLine08 = ''
   ,@cLine09 = 'FINAL LOC: '    
   ,@cLine10 = '%10i03'
   ,@cLine11 = ''
   ,@cLine12 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 1830

-- 5061 = Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 5061 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5061, 'ENG'
   ,@cLine01 = 'TM PICK       ASTFPK'
   ,@cLine02 = ''
   ,@cLine03 = 'PALLET ID:       %03d02'
   ,@cLine04 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1830

-- 5062 = Final LOC (multi pallet) screen
DELETE rdt.RDTScn WHERE Scn = 5062 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5062, 'ENG'
   ,@cLine01 = 'TM PICK       ASTFPK'
   ,@cLine02 = ''
   ,@cLine03 = 'PALLET ID:       %03d04'
   ,@cLine04 = '%20d01'
   ,@cLine05 = ''
   ,@cLine06 = 'SUGGESTED LOC: '
   ,@cLine07 = '%10d02' 
   ,@cLine08 = ''
   ,@cLine09 = 'FINAL LOC: '    
   ,@cLine10 = '%10i03'
   ,@cLine11 = ''
   ,@cLine12 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 1830
   
-- 5063 = next task screen
DELETE rdt.RDTScn WHERE Scn = 5063 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5063, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CURRENT TASK COMPLETE' 
   ,@cLine03 = ''
   ,@cLine04 = 'NEXT TASK TYPE:' 
   ,@cLine05 = '%10d01'    
   ,@cLine06 = ''
   ,@cLine07 = '' 
   ,@cLine08 = 'ENTER = NEXT TASK'
   ,@cLine09 = 'ESC   = EXIT' 
   ,@cLine14 = '%e'
   ,@nFunc = 1830
   