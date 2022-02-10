
-- Batch (PickDetail.PickslipNo), tote
DELETE rdt.RDTScn WHERE Scn = 5142 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5142, 'ENG'
   ,@cLine01 = 'CART ID:  %10d01'
   ,@cLine02 = 'PICKZONE: %10d02' 
   ,@cLine03 = ''
   ,@cLine04 = 'BATCHKEY:'
   ,@cLine05 = '%20i03'
   ,@cLine06 = 'POSITION:      %05d06'
   ,@cLine07 = '%10d04'
   ,@cLine08 = 'TOTE ID:       %05d07'
   ,@cLine09 = '%20i05'
   ,@cLine14 = '%e'
   ,@nFunc = 808
