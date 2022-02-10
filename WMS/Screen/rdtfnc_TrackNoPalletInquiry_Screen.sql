-- 5120 = Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 5120 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5120, 'ENG',
    @cLine01 = 'PALLET KEY:' 
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'      
   ,@nFunc = 1665

-- 5121 = Statistic screen
DELETE rdt.RDTScn WHERE Scn = 5121 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5121, 'ENG',
    @cLine01 = 'PALLET KEY:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'INVALID CARTON: %04d02'
   ,@cLine05 = 'SELECT OPTION'
   ,@cLine06 = ''
   ,@cLine07 = '1 = REMOVE ALL'
   ,@cLine08 = '2 = VIEW'
   ,@cLine09 = ''
   ,@cLine10 = 'OPTION: %01i03 '
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = 'TOTAL CTN: %05d04'
   ,@cLine14 = '%e'   
   ,@nFunc = 1665
    
-- 5122 = Track no screen
DELETE rdt.RDTScn WHERE Scn = 5122 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5122, 'ENG',
    @cLine01 = '%20d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20d03' 	
   ,@cLine04 = '%20d04' 	
   ,@cLine05 = '%20d05' 	   
   ,@cLine06 = '%20d06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%20d08'
   ,@cLine09 = '%20d09'       
   ,@cLine10 = '%20d10'
   ,@cLine11 = ''
   ,@cLine12 = '%20i11'
   ,@cLine13 = 'TOTAL CTN: %05d12 %05d13' 
   ,@cLine14 = '%e'
   ,@nFunc = 1665
   
-- 5123 = Remove carton screen
DELETE rdt.RDTScn WHERE Scn = 5123 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5123, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'REMOVE CARTON?'
   ,@cLine03 = ''
   ,@cLine04 = '%20d01'
   ,@cLine05 = '%20d02'
   ,@cLine06 = ''
   ,@cLine07 = '1 = YES'
   ,@cLine08 = '2 = NO'
   ,@cLine09 = ''
   ,@cLine10 = 'OPTION: %01i03'
   ,@cLine14 = '%e'   
   ,@nFunc = 1665
   
-- 5124 = Remove all carton screen
DELETE rdt.RDTScn WHERE Scn = 5124 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5124, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'REMOVE ALL CARTON?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'   
   ,@nFunc = 1665
   