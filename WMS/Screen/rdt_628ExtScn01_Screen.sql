-- 6677 = LOC, ID screen
DELETE rdt.RDTScn WHERE Scn = 6677 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6677, 'ENG',
    @cLine01 = 'LOC:'
   ,@cLine02 = '%30i01' --WMS23936
   ,@cLine03 = 'OR'
   ,@cLine04 = ''
   ,@cLine05 = 'ID:'
   ,@cLine06 = '%60i02'
   ,@cLine07 = 'OR'
   ,@cLine08 = ''
   ,@cLine09 = 'SKU:'
   ,@cLine10 = '%30i03'
   ,@cLine11 = 'AND/OR'
   ,@cLine12 = 'LOCTYPE'
   ,@cLine13 = '%30i04'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["5","6"],"3":["9","10"],"4":["12","13"]}'
   ,@nFunc = 628
 
-- 6679 = Result screen
DELETE rdt.RDTScn WHERE Scn = 6679 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6679, 'ENG',
    @cLine01 = 'SKU:        %20d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = 'LOC: %10d05'
   ,@cLine06 = 'ID: %18d06'
   ,@cLine07 = '         %11d07'
   ,@cLine08 = '%20d08'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%20d10'
   ,@cLine11 = '%20d11'
   ,@cLine12 = '%20d12' --WMS10415 Remove qty hold, add pending move in
   ,@cLine13 = '%20d13'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3","4"],"2":["5","6"],"3":["7","8","9","10","11","12","13"]}'
   ,@nFunc = 628

-- 6682 = location type screen
DELETE rdt.RDTScn WHERE Scn = 6682 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6682, 'ENG',
    @cLine01 = 'Location Type'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20d06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%20d08'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%20d10'
   ,@cLine11 = '%20d11'
   ,@cLine12 = '%20d12'
   ,@cLine13 = 'Option: %05i01^DT:INT'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3","4","5","6","7","8","9","10","11","12","13"]}'
   ,@nFunc = 628