
-- Batch (orders), tote
DELETE rdt.RDTScn WHERE Scn = 4189 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4189, 'ENG'
   ,@cLine01 = 'CART ID:  %10d01'
   ,@cLine02 = 'PICKZONE: %10d02' 
   ,@cLine03 = ''
   ,@cLine04 = 'BATCHKEY:      %05d05'
   ,@cLine05 = '%20i03'
   ,@cLine06 = ''
   ,@cLine07 = 'TOTE ID:'
   ,@cLine08 = '%20i04'
   ,@cLine14 = '%e'
   ,@nFunc = 808
