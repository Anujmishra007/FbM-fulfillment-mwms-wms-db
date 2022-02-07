-- rdtfnc_Pick_Consolidation
-- 3790 - 3799
DELETE rdt.rdtscn Where Scn = 3790 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 3790, 'ENG',
   @cLine01 = 'ORDER KEY: %10i01', 
   @cLine02 = 'PICK ZONE: %10i02', 
   @cLine14 = '%e',
   @nFunc = 544

DELETE rdt.rdtscn Where Scn = 3791 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 3791, 'ENG',
   @cLine01 = 'ORDER KEY: %10d01', 
   @cLine02 = 'PICK ZONE: %10d02', 
   @cLine03 = 'SUGGESTED LOC:',
   @cLine04 = '%10d03',
   @cLine05 = 'FINAL LOC:',
   @cLine06 = '%10i04',
   @cLine14 = '%e',
   @nFunc = 544

DELETE rdt.rdtscn Where Scn = 3792 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 3792, 'ENG',
   @cLine01 = 'ORDER KEY: %10d01', 
   @cLine02 = 'PICKING COMPLETED.', 
   @cLine03 = 'PUSH CARTON TO',
   @cLine04 = 'PACKING PLATFORM.',
   @cLine06 = 'PRESS ENTER TO PICK',
   @cLine07 = 'NEXT ORDER.',
   @cLine14 = '%e',
   @nFunc = 544