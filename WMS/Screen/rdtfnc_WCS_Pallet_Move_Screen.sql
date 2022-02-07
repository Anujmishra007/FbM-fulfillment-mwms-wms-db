-- 4240 = Pallet Move screen
DELETE rdt.RDTScn WHERE Scn = 4240 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4240, 'ENG',
    @cLine01 = 'PALLET FLOOR MOVE'
   ,@cLine03 = 'ID:'
   ,@cLine04 = '%18i01'
   ,@cLine06 = 'FROM LOC: %10i02'
   ,@cLine08 = 'TO LOC:   %10i03'
   ,@cLine14 = '%e'
 
