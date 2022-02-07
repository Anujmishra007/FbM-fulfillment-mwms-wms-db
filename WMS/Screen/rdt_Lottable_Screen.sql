
-- 3990 = Dynamic lottable screen
DELETE rdt.RDTScn WHERE Scn = 3990 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3990, 'ENG'
   ,@cLine01 = '%20d01' 
   ,@cLine02 = '%60i02' -- Lottable no 1
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%60i04' -- Lottable no 2
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%60i06' -- Lottable no 3
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%60i08' -- Lottable no 4
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%60i10' -- Lottable no 5
   ,@cLine14 = '%e'

