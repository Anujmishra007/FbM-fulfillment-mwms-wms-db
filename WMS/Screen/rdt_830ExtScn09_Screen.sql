-- 6846 = short pick screen (reallocation)
DELETE rdt.RDTScn WHERE Scn = 6846 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6846, 'ENG',
   @cLine01 = '',
   @cLine02 = 'Confirm short pick?',
   @cLine03 = '',
   @cLine04 = '1 = YES',
   @cLine05 = '2 = NO',
   @cLine06 = '9 = Suggest Alternate',
   @cLine07 = '    Location',
   @cLine09 = 'OPTION: %01i01',
   @cLine14 = '%e'

-- 6847  = Reason Code screen
DELETE rdt.RDTScn WHERE Scn = 6847 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6847, 'ENG',
   @cLine02 = 'REASON CODE: '
   ,@cLine03 = '%10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 830