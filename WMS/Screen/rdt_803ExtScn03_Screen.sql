--FCR-9003
DELETE rdt.RDTScn WHERE Scn = 6706 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6706, 'ENG',
    @cLine01 = 'CART ID'
   ,@cLine02 = '%10i01'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 803

-- FCR-14204
-- Unassign station
DELETE rdt.RDTScn WHERE Scn = 6925 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6925, 'ENG'
   ,@cLine01 = 'UNASSIGN STATION?'
   ,@cLine02 = ''
   ,@cLine03 = '1 = YES' 
   ,@cLine04 = '9 = NO' 
   ,@cLine05 = '' 
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 803

-- FCR-14204
--ReasonKey
DELETE rdt.RDTScn WHERE Scn = 6926 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6926, 'ENG'
   ,@cLine01 = 'UNASSIGN STATION?'
   ,@cLine02 = 'WAVE NOT COMPLETE'
   ,@cLine03 = 'REASON CODE' 
   ,@cLine04 = '%20i01'
   ,@cLine05 = '' 
   ,@cLine06 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 803