-- 2370 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2370 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2370, 'ENG',
    @cLine01 = 'STORE TO LOC ASSIGN'
   ,@cLine03 = 'STORERKEY:'
   ,@cLine04 = '%15d01'
   ,@cLine05 = 'STORE:'
   ,@cLine06 = '%15i02'
   ,@cLine14 = '%e'
 
-- 2371 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2371 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2371, 'ENG',
    @cLine01 = 'STORE:'
   ,@cLine02 = '%15d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = 'ADDRESS:'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%20d08'
   ,@cLine11 = '%20d09'
   ,@cLine12 = '%20d10'
   ,@cLine13 = '%20d11'
   ,@cLine14 = '%e'
 
-- 2372 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2372 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2372, 'ENG',
    @cLine01 = 'STORE TO LOC ASSIGN'
   ,@cLine03 = 'STORE:'
   ,@cLine04 = '%15d01'
   ,@cLine05 = 'TO LOC:'
   ,@cLine06 = '%10i02'
   ,@cLine14 = '%e'
 
-- 2373 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2373 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2373, 'ENG',
    @cLine01 = 'STORE TO LOC ASSIGN'
   ,@cLine03 = 'DELETE EXISTING'
   ,@cLine04 = 'STORE & LOC SETUP'
   ,@cLine05 = 'AND CREATE NEW LINK?'
   ,@cLine07 = '1 = YES'
   ,@cLine08 = '9 = NO'
   ,@cLine10 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
 
-- 2374 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2374 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2374, 'ENG',
    @cLine01 = 'STORE TO LOC ASSIGN'
   ,@cLine03 = 'STORERKEY:'
   ,@cLine04 = '%15d01'
   ,@cLine05 = 'STORE:'
   ,@cLine06 = '%15d02'
   ,@cLine07 = 'LOC:'
   ,@cLine08 = '%10d03'
   ,@cLine09 = 'STORE GROUP:'
   ,@cLine10 = '%10i04'
   ,@cLine14 = '%e'
 
