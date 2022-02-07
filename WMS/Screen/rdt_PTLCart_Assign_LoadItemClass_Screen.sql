
-- Load, ItemClass, position, tote
DELETE rdt.RDTScn WHERE Scn = 5041 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5041, 'ENG'
   ,@cLine01 = 'CART ID:  %10d01'
   ,@cLine02 = 'PICKZONE: %10d02' 
   ,@cLine03 = ''
   ,@cLine04 = 'LOADKEY:       %05d07'
   ,@cLine05 = '%10i03'
   ,@cLine06 = 'MATERIAL:'
   ,@cLine07 = '%10i04'
   ,@cLine08 = 'POSITION:'
   ,@cLine09 = '%10d05'
   ,@cLine10 = 'TOTE ID:       %05d08'
   ,@cLine11 = '%20i06'
   ,@cLine14 = '%e'
   ,@nFunc = 808
