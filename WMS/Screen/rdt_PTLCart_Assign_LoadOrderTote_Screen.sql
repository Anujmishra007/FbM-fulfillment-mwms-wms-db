
-- LoadKey (orders), tote
DELETE rdt.RDTScn WHERE Scn = 4186 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4186, 'ENG'
   ,@cLine01 = 'CART ID:  %10d01'
   ,@cLine02 = 'PICKZONE: %10d02' 
   ,@cLine03 = ''
   ,@cLine04 = 'LOADKEY:  %10i03'
   ,@cLine05 = 'TASKS:    %02i04'
   ,@cLine06 = ''
   ,@cLine07 = 'ORDERKEY:      %05d08'
   ,@cLine08 = '%10i05'
   ,@cLine09 = 'POSITION:'
   ,@cLine10 = '%10d06'
   ,@cLine11 = 'TOTE ID:       %05d09'
   ,@cLine12 = '%20i07'
   ,@cLine14 = '%e'
   ,@nFunc = 808
