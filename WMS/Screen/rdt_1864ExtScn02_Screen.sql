-- 6701 Short Option Screen
   DELETE rdt.RDTScn WHERE Scn = 6701 AND Lang_Code = 'ENG'
   EXECUTE rdt.rdtAddScn 6701, 'ENG'
      ,@cLine02 = 'CONFIRM OPTION?'
      ,@cLine04 = '1 = Alternate Pick Loc'
      ,@cLine05 = '2 = Skip Task'
      ,@cLine06 = 'ESC = Back'
      ,@cLine08 = 'OPTION: %01i01'
      ,@cLine14 = '%e'
      ,@nFunc = 1864

--6702 Reason code
DELETE rdt.RDTScn WHERE Scn = 6702 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6702, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'REASON CODE:'
   ,@cLine03 = '%30i01'
   ,@cLine04 = ''
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1864