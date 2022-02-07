-- 2010 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2010 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2010, 'ENG',
    @cLine01 = 'SHORT PICK'
   ,@cLine02 = 'BAL QTY: %05d01 %05d02'
   ,@cLine03 = '         %05d03 %05d04'
   ,@cLine05 = 'RSN: %10i05'
   ,@cLine14 = '%e'   