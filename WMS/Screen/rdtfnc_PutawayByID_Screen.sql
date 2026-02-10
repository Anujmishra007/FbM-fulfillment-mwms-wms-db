-- 4110 = From ID screen
DELETE rdt.RDTScn WHERE Scn = 4110 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4110, 'ENG'
   ,@cLine01 = 'FROM ID:'
   ,@cLine02 = '%20i01' --wms23335
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"]}'
   ,@nFunc = 1819

-- 4111 = Final LOC screen
DELETE rdt.RDTScn WHERE Scn = 4111 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4111, 'ENG'
   ,@cLine01 = 'FROM ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'SUGGESTED LOC: '
   ,@cLine05 = '%10d02' 
   ,@cLine06 = ''
   ,@cLine07 = 'TO LOC: '    
   ,@cLine08 = '%10i03'
   ,@cLine09 = ''
   ,@cLine10 = '%20d15'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5"],"3":["7","8"],"4":["10"]}'
   ,@nFunc = 1819

-- 4112 = Message screen
DELETE rdt.RDTScn WHERE Scn = 4112 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4112, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Successful putaway'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = 'Press ENTER to'
   ,@cLine06 = 'putaway next ID'
   ,@cLine14 = '%e'
   ,@cAutoDisappear = '1'
   ,@nFunc = 1819

-- (WMS-7793)
-- 4113 = Putaway additional criteria
DELETE rdt.RDTScn WHERE Scn = 4113 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4113, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = '%20i02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20i04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20i06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%20i08'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%20i10'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["5","6"],"4":["7","8"],"5":["9","10"]}'
   ,@nFunc = 1819

-- (WMS-10120)
-- 4114 = Confirm overwrite suggested loc
DELETE rdt.RDTScn WHERE Scn = 4114 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4114, 'ENG', 
   @cLine01 = '',
   @cLine02 = 'LOC NOT MATCH.',
   @cLine03 = 'PROCEED?',
   @cLine04 = '',
   @cLine05 = '1 = YES',
   @cLine06 = '2 = NO',
   @cLine07 = '',
   @cLine08 = 'OPTION: %01i01',
   @cLine13 = '%20d15', --fcr-9755 EXTINFO
   @cLine14 = '%e',     
   @nFunc   = 1819


--FCR-122  Reason code
DELETE rdt.RDTScn WHERE Scn = 4115 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4115, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'REASON CODE:'
   ,@cLine03 = '%10i01'
   ,@cLine04 = ''
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1819

-- (FCR-2598)
-- 4116 = ExtScreen overwrite suggested loc
DELETE rdt.RDTScn WHERE Scn = 4116 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4116, 'ENG',
        @cLine01 = '',
        @cLine02 = 'LOC NOT MATCH.',
        @cLine03 = 'Scanned LOC: %20d02',
        @cLine04 = 'Suggested LOC: %20d03',
        @cLine05 = 'PROCEED?',
        @cLine06 = '',
        @cLine07 = '1 = YES',
        @cLine08 = '2 = NO',
        @cLine09 = '',
        @cLine10 = 'OPTION: %01i01',
        @cLine14 = '%e',
        @nFunc   = 1819
