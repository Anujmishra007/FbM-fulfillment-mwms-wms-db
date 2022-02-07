
-- totes (order = tote)
DELETE rdt.RDTScn WHERE Scn = 4183 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4183, 'ENG'
   ,@cLine01 = 'CART ID:  %10d01'
   ,@cLine02 = 'PICKZONE: %10d02' 
   ,@cLine03 = ''
   ,@cLine04 = 'ORDERKEY:'
   ,@cLine05 = '%10d03'
   ,@cLine06 = 'POSITION:'
   ,@cLine07 = '%10d04'
   ,@cLine08 = 'TOTE ID:       %05d06'
   ,@cLine09 = '%20i05'
   ,@cLine14 = '%e'
   ,@nFunc = 808
