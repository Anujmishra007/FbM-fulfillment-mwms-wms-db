--Screen Range 6527

--UWP-34785
/* 2025-05-21 1.1    NLT013   UWP-34785 Add new Exit Screen                 */
DELETE rdt.RDTScn WHERE Scn = 6527 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6527, 'ENG',
    @cLine01 = 'REPLEN FROM      RPF'
   ,@cLine02 = ''
   ,@cLine03 = 'Pallet is closed and'
   ,@cLine04 = 'moved'
   ,@cLine05 = ''
   ,@cLine06 = '1 = Next Task'
   ,@cLine07 = '9 = Exit to TM'
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = 'LAST LOC: %10d01'
   ,@cLine11 = 'OPTION: %01i02'
   ,@cLine12 = '%20d10'
   ,@cLine14 = '%e'
   ,@nFunc = 1764
