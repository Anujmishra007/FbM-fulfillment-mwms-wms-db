
-- 6718 = short pick screen (reallocation)
DELETE rdt.RDTScn WHERE Scn = 6718 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6718, 'ENG',
        @cLine01 = '',
        @cLine02 = 'Confirm short pick?',
        @cLine03 = '',
        @cLine04 = '1 = YES',
        @cLine05 = '2 = NO',
        @cLine06 = '9 = Suggest Alternate Location',
        @cLine07 = '',
        @cLine08 = 'OPTION: %01i01',
        @cLine14 = '%e'

--6719 Reason code
DELETE rdt.RDTScn WHERE Scn = 6719 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6719, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'REASON CODE:'
   ,@cLine03 = '%30i01'
   ,@cLine04 = ''
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine14 = '%e'
