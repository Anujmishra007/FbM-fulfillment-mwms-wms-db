--FCR-8553
/* 2025-11-03 1.0.0    NLT013   FCR-8553 Add new Unassign Screen                 */
DELETE rdt.RDTScn WHERE Scn = 6713 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6713, 'ENG',
    @cLine01 = 'Drop IDs are not'
   ,@cLine02 = 'completely sorted.'
   ,@cLine03 = 'Do you want to'
   ,@cLine04 = 'UNASSIGN?'
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = '1 = Yes'
   ,@cLine09 = '9 = No'
   ,@cLine10 = ''
   ,@cLine11 = 'OPTION: %01i01'
   ,@cLine12 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 803
