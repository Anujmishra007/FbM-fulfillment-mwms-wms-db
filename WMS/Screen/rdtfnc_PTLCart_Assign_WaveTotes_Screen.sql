-- 5043 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5043 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5043, 'ENG'
   ,@cLine01 = N'CART ID:  %10d01'
   ,@cLine02 = N'PICKZONE: %10d02'
   ,@cLine03 = N''
   ,@cLine04 = N'WavePK:'
   ,@cLine05 = N'%20i03'
   ,@cLine10 = N'TOTE ID:       %05d04'
   ,@cLine11 = N'%20i05'
   ,@cLine14 = N'%e'
 