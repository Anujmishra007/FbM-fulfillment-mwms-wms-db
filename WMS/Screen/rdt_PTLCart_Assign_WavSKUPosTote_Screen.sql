
-- Order, position, tote
DELETE rdt.RDTScn WHERE Scn = 4184 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4184, 'ENG'
   ,@cLine01 = 'CART ID:  %10d01'
   ,@cLine02 = 'PICKZONE: %10d02' 
   ,@cLine03 = ''
   ,@cLine04 = 'WAVEKEY:'
   ,@cLine05 = '%10i03'
   ,@cLine06 = 'SKU:'
   ,@cLine07 = '%20i04'
   ,@cLine08 = 'POSITION:'
   ,@cLine09 = '%10i05'
   ,@cLine10 = 'TOTE ID:       %05d07'
   ,@cLine11 = '%20i06'
   ,@cLine14 = '%e'
   ,@nFunc = 808
