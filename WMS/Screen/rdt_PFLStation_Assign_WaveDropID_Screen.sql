
-- Wave, ToteID
DELETE rdt.RDTScn WHERE Scn = 5510 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5510, 'ENG'
   ,@cLine01 = 'WAVEKEY:'
   ,@cLine02 = '%10i01'
   ,@cLine03 = ''
   ,@cLine04 = 'DROP ID:'
   ,@cLine05 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 801
