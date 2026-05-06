DELETE rdt.RDTScn WHERE Scn = 6771 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6771, 'ENG',
    @cLine01 = 'PICK CASE        FCP'
   ,@cLine02 = ''
   ,@cLine03 = 'DROPID:'
   ,@cLine04 = '%20i01'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["3","4"]}'
   ,@nFunc = 1812

-- Close pallet
DELETE rdt.RDTScn WHERE Scn = 6810 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6810, 'ENG',
    @cLine01 = 'PICK CASE        FCP'
   ,@cLine02 = ''
   ,@cLine03 = '1 = CONT NEXT TASK'
   ,@cLine04 = '9 = CLOSE CARTON'
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1812

-- Short pick
DELETE rdt.RDTScn WHERE Scn = 6811 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6811, 'ENG',
    @cLine01 = 'PICK CASE        FCP'
   ,@cLine02 = ''
   ,@cLine03 = '1 = SHORT PICK'
   ,@cLine04 = '9 = CLOSE CARTON'
   ,@cLine05 = ''
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1812

DELETE rdt.RDTScn WHERE Scn = 6812 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6812, 'ENG',
    @cLine01 = 'PICK CASE        FCP'
   ,@cLine02 = ''
   ,@cLine03 = 'Carton is closed and'
   ,@cLine04 = 'moved'
   ,@cLine05 = ''
   ,@cLine06 = 'ENTER = Next Task'
   ,@cLine07 = 'ESC   = Exit to TM'
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = 'LAST LOC: %10d01'
   ,@cLine11 = ''
   ,@cLine12 = '%20d10'
   ,@cLine14 = '%e'
   ,@nFunc = 1812

DELETE rdt.RDTScn WHERE Scn = 6813 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6813, 'ENG',
    @cLine01 = 'PICK CASE        FCP'
   ,@cLine02 = ''
   ,@cLine03 = '1 = PICK NEXT CARTON'
   ,@cLine04 = '9 = DROP TO STAGING'
   ,@cLine05 = ''
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1812
