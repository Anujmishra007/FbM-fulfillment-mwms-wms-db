-- 5850 = Final LOC (1 pallet) screen
DELETE rdt.RDTScn WHERE Scn = 5850 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5850, 'ENG'
   ,@cLine01 = 'TM Putaway  ASTFMV'
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
   ,@nFunc = 1849

-- 5851 = Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 5851 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5851, 'ENG'
   ,@cLine01 = 'TM Putaway  ASTFMV'
   ,@cLine02 = ''
   ,@cLine03 = 'PALLET ID:       %03d02'
   ,@cLine04 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1849

-- 5852 = Final LOC (multi pallet) screen
DELETE rdt.RDTScn WHERE Scn = 5852 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5852, 'ENG'
   ,@cLine01 = 'TM Putaway  ASTFMV'
   ,@cLine02 = ''
   ,@cLine03 = 'PALLET ID:       %03d04'
   ,@cLine04 = '%20d01'
   ,@cLine05 = ''
   ,@cLine06 = 'SUGGESTED LOC: '
   ,@cLine07 = '%10d02' 
   ,@cLine08 = ''
   ,@cLine09 = 'TO LOC: '    
   ,@cLine10 = '%10i03'
   ,@cLine11 = ''
   ,@cLine12 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 1849
   
-- 5853 = next task screen 
DELETE rdt.RDTScn WHERE Scn = 5853 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5853, 'ENG'
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
   ,@nFunc = 1849
   