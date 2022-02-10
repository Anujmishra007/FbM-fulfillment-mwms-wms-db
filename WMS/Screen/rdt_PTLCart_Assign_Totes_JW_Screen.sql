-- totes (order = tote)
DELETE rdt.RDTScn WHERE Scn = 4188 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4188, 'ENG'
   ,@cLine01 = 'CART ID:  %10d01'
   ,@cLine02 = 'PICKZONE: %10d02' 
   ,@cLine03 = 'METHOD:   %01d03'
   ,@cLine04 = 'PICK SEQ: %01d04'
   ,@cLine06 = 'SCAN A NEW TOTE:'
   ,@cLine07 = '%20i05'
   ,@cLine08 = 'TOTE SCANNED: %05d06'
   ,@cLine14 = '%e'
   ,@nFunc = 819
