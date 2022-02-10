--SOS301473 - rebuit screen 

-- 926 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 926 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 926, 'ENG',
    @cLine01 = 'UCC:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'

-- 927 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 927 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 927, 'ENG',
    @cLine01 = 'UCC:'
   ,@cLine02 = '%20d01'
   ,@cLine04 = 'FROM LOC:'
   ,@cLine05 = '%10d02'
   ,@cLine07 = 'SUGGESTED LOC:'
   ,@cLine08 = '%10d03'
   ,@cLine10 = 'FINAL LOC:'
   ,@cLine11 = '%20i04'
   ,@cLine12 = '%20d05' -- SOS373949 (james03)/WMS-17795
   ,@cLine13 = '%20d06' -- SOS373949 (james03)
   ,@cLine14 = '%e'

-- 928 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 928 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 928, 'ENG',
    @cLine02 = 'Successful putaway'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = 'Press ENTER to'
   ,@cLine06 = 'putaway next item'
   ,@cLine14 = '%e'

-- 929 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 929 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 929, 'ENG',
    @cLine02 = 'MIXED CARTON.'
   ,@cLine03 = 'CONTINUE !?'
   ,@cLine04 = ''
   ,@cLine05 = 'Option: %01i01'
   ,@cLine06 = '1 = YES; 2 = NO'
   ,@cLine14 = '%e'

-- 930 = ?? screen -- WMS-16559 (cc02)
DELETE rdt.RDTScn WHERE Scn = 930 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 930, 'ENG', 
   @cLine01 = '',
   @cLine02 = 'LOC NOT MATCH.',
   @cLine03 = 'PROCEED?',
   @cLine04 = '',
   @cLine05 = '1 = YES',
   @cLine06 = '2 = NO',
   @cLine07 = '',
   @cLine08 = 'OPTION: %01i01',
   @cLine14 = '%e'