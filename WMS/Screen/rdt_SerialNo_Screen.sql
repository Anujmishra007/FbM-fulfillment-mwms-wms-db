
-- 4830 = Serial no screen
DELETE rdt.RDTScn WHERE Scn = 4830 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4830, 'ENG', 
    @cLine01 = 'SKU:'
   ,@cLine02 = '%20d01' 	
   ,@cLine03 = '%20d02' 	
   ,@cLine04 = '%20d03' 	
   ,@cLine05 = '' 	
   ,@cLine06 = 'SERIAL NO:' 	
   ,@cLine07 = '%30i04'
   ,@cLine08 = '' 	
   ,@cLine09 = 'SCAN/TOTAL: %08d05'
   ,@cLine14 = '%e'

-- 4831 = Serial no screen (2D barcode)
DELETE rdt.RDTScn WHERE Scn = 4831 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4831, 'ENG', 
    @cLine01 = 'SKU:'
   ,@cLine02 = '%20d01' 	
   ,@cLine03 = '%20d02' 	
   ,@cLine04 = '%20d03' 	
   ,@cLine05 = '' 	
   ,@cLine06 = 'SERIAL NO:' 	
   ,@cLine07 = '%1000iV_MAX'
   ,@cLine08 = '' 	
   ,@cLine09 = 'SCAN/TOTAL: %08d05'
   ,@cLine14 = '%e'
