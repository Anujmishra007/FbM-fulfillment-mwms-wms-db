-- 6419 Short Option Screen
   DELETE rdt.RDTScn WHERE Scn = 6419 AND Lang_Code = 'ENG'
   EXECUTE rdt.rdtAddScn 6419, 'ENG'
      ,@cLine02 = 'CONFIRM OPTION?'
      ,@cLine04 = '1 = SHORT'
      ,@cLine05 = '2 = PICK LATER'
      ,@cLine08 = 'OPTION: %01i01'
      ,@cLine14 = '%e'
      ,@nFunc = 1864