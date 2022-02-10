
-- Batch (orders), tote
DELETE rdt.RDTScn WHERE Scn = 4181 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4181, 'ENG'
   ,@cLine01 = 'CART ID:  %10d01'
   ,@cLine02 = 'PICKZONE: %10d02' 
   ,@cLine03 = ''
   ,@cLine04 = 'BATCHKEY:'
   ,@cLine05 = '%20i03'
   ,@cLine06 = 'ORDERKEY:      %05d07'
   ,@cLine07 = '%10d04'
   ,@cLine08 = 'POSITION:'
   ,@cLine09 = '%10d05'
   ,@cLine10 = 'TOTE ID:       %05d08'
   ,@cLine11 = '%20i06'
   ,@cLine14 = '%e'
   ,@nFunc = 808
