
-- 5220 = user ID screen
DELETE rdt.RDTScn WHERE Scn = 5220 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5220, 'ENG'
   ,@cLine01 = 'USER ID:'
   ,@cLine02 = '%30i01'--WMS15084
   ,@cLine03 = ''
   ,@cLine04 = 'START: %11d02'
   ,@cLine05 = 'END:   %11d03'
   ,@cLine06 = ''
   ,@cLine07 = 'DURATION: %05d04'
   ,@cLine08 = ''
   ,@cLine09 = 'JOB TYPE:' -- WMS-9433
   ,@cLine10 = '%20d05'    -- WMS-9433
   ,@cLine14 = '%e'
   ,@nFunc = 705

-- 5221 = job type screen
DELETE rdt.RDTScn WHERE Scn = 5221 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5221, 'ENG'
   ,@cLine01 = 'USER ID:'
   ,@cLine02 = '%30d01' --WMS15084
   ,@cLine03 = ''
   ,@cLine04 = 'JOB TYPE:'
   ,@cLine05 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 705

-- 5222 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 5222 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5222, 'ENG'
   ,@cLine01 = 'USER ID:'
   ,@cLine02 = '%30d01' --WMS15084
   ,@cLine03 = ''
   ,@cLine04 = 'JOB TYPE:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = ''
   ,@cLine07 = 'LOC:'
   ,@cLine08 = '%30i03'--WMS15084
   ,@cLine14 = '%e'
   ,@nFunc = 705
   
-- 5223 = QTY screen
DELETE rdt.RDTScn WHERE Scn = 5223 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5223, 'ENG'
   ,@cLine01 = 'USER ID:'
   ,@cLine02 = '%30d01' --WMS15084
   ,@cLine03 = ''
   ,@cLine04 = 'JOB TYPE:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = ''
   ,@cLine07 = 'LOC:'
   ,@cLine08 = '%30d03' --WMS15084
   ,@cLine09 = ''
   ,@cLine10 = 'QTY: %05i04'
   ,@cLine14 = '%e'
   ,@nFunc = 705

-- 5224 = Confirm job end screen
DELETE rdt.RDTScn WHERE Scn = 5224 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5224, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CONFIRM JOB ENDED?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '9 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine08 = ''
   ,@cLine09 = 'JOB TYPE:' -- WMS-9433
   ,@cLine10 = '%20d02'    -- WMS-9433
   ,@cLine14 = '%e'
   ,@nFunc = 705

--WMS-7995
-- 5225 = Ref screen
DELETE rdt.RDTScn WHERE Scn = 5225 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5225, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = '%20i02'  
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20i04'  
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20i06'  
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%20i08'  
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%20i10'  
   ,@cLine11 = ''
   ,@cLine12 = ''  
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 705