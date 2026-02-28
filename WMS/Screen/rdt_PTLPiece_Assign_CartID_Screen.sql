
--FCR-9003
DELETE rdt.RDTScn WHERE Scn = 6706 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6706, 'ENG',
      @cLine01 = 'CART ID'
   ,@cLine02 = '%10i01'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 803

