-- 6750 = Trolley ID Screen
-- FCR-9734
DELETE rdt.RDTScn WHERE Scn = 6750 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6750, 'ENG',
    @cLine01 = 'Trolley ID:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"]}'
   ,@nFunc = 1875

-- 6751 = Option Screen
DELETE rdt.RDTScn WHERE Scn = 6751 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6751, 'ENG',
    @cLine01 = 'Trolley ID'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'Trolley ID in use.'
   ,@cLine05 = 'Proceed?'
   ,@cLine06 = 'ESC - No'
   ,@cLine07 = 'Enter - Yes'
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5","6","7"]}'
   ,@nFunc = 1875

-- 6752 = UCC Screen
DELETE rdt.RDTScn WHERE Scn = 6752 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6752, 'ENG',
    @cLine01 = 'Trolley ID'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'Position:%10d02'
   ,@cLine05 = ''
   ,@cLine06 = 'Carton/UCC:'
   ,@cLine07 = '%20i03'
   ,@cLine08 = ''
   ,@cLine09 = 'Option: %10i04'
   ,@cLine10 = '1 - Empty Trolley'
   ,@cLine11 = '9 - Close Trolley'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4"],"3":["6","7"],"4":["9","10","11"]}'
   ,@nFunc = 1875


-- 6753 = Empty Trolley Screen
DELETE rdt.RDTScn WHERE Scn = 6753 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6753, 'ENG',
    @cLine01 = 'Trolley ID'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'Confirm empty '
   ,@cLine05 = 'trolley?'
   ,@cLine06 = 'ESC - No'
   ,@cLine07 = 'Enter - Yes'
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5","6","7"]}'
   ,@nFunc = 1875

-- 6754 = Close Trolley Screen
DELETE rdt.RDTScn WHERE Scn = 6754 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6754, 'ENG',
    @cLine01 = 'Trolley ID'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'Confirm close '
   ,@cLine05 = 'trolley?'
   ,@cLine06 = 'ESC - No'
   ,@cLine07 = 'Enter - Yes'
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5","6","7"]}'
   ,@nFunc = 1875