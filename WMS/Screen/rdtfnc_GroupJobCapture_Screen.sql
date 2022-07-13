--SCN DETAILS

DELETE rdt.RDTScn WHERE Scn = 5480 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5480, 'ENG',
   @cLine01 = 'USER ID:'
   ,@cLine02 = '%15i01'
   ,@cLine03 = ''
   ,@cLine04 = 'START: %11d02'
   ,@cLine05 = 'END:   %11d03'
   ,@cLine06 = ''
   ,@cLine07 = 'DURATION: %05d04'  
   ,@cLine14 = '%e'
   ,@nfunc   =707

-- 5481 = Capture UserID
DELETE rdt.RDTScn WHERE Scn = 5481 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5481, 'ENG'
   ,@cLine01 = 'USER ID 1-9'
   ,@cLine02 = '%15i01'
   ,@cLine03 = '%15i02'
   ,@cLine04 = '%15i03'
   ,@cLine05 = '%15i04'
   ,@cLine06 = '%15i05'
   ,@cLine07 = '%15i06'
   ,@cLine08 = '%15i07'
   ,@cLine09 = '%15i08'
   ,@cLine10 = '%15i09'
   ,@cLine14 = '%e'
   ,@nFunc = 707

-- 5482 = Capture the process
DELETE rdt.RDTScn WHERE Scn = 5482 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5482, 'ENG'
   ,@cLine01 = 'Process:'
   ,@cLine02 = '%30d01'
   ,@cLine03 = '%30d02'
   ,@cLine04 = '%30d03'
   ,@cLine05 = '%30d04'
   ,@cLine06 = '%30d05'
   ,@cLine07 = '%30d06'
   ,@cLine08 = '%30d07'
   ,@cLine09 = '%30d08'
   ,@cLine10 = '%30d09'
   ,@cLine12 = 'Option: %02i10'
   ,@cLine14 = '%e'
   ,@nFunc = 707

-- 5483 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5483 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5483, 'ENG'
   ,@cLine01 = N''
   ,@cLine02 = N'CONFIRM JOB ENDED?'
   ,@cLine03 = N''
   ,@cLine04 = N'1 = YES'
   ,@cLine05 = N'9 = NO'
   ,@cLine06 = N''
   ,@cLine07 = N'OPTION: %01i01'
   ,@cLine08 = N''
   ,@cLine09 = N'JOB TYPE:'
   ,@cLine10 = N'%20d02'
   ,@cLine14 = N'%e'
   ,@nFunc = 707
 
-- 5484 = Capture the process
DELETE rdt.RDTScn WHERE Scn = 5484 AND Lang_Code = 'ENG' --wms19782
EXECUTE rdt.rdtAddScn 5484, 'ENG'
   ,@cLine01 = 'UserID:'
   ,@cLine02 = '%15d01'
   ,@cLine03 = ''
   ,@cLine04 = 'Job Type:'
   ,@cLine05 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 707