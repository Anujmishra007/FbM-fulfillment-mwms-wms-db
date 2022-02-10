
-- 3840  = FromLOC screen
DELETE rdt.RDTScn WHERE Scn = 3840 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3840, 'ENG'
   ,@cLine01 = 'TM NMV FROM      NMF'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM LOC: '
   ,@cLine04 = '%10d01'
   ,@cLine05 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1746

-- 3841  = ID screen
DELETE rdt.RDTScn WHERE Scn = 3841 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3841, 'ENG'
   ,@cLine01 = 'TM NMV FROM      NMF'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM LOC: %10d01'
   ,@cLine04 = ''
   ,@cLine05 = 'ID: '
   ,@cLine06 = '%18d02'
   ,@cLine07 = '%18i03'
   ,@cLine14 = '%e'   
   ,@nFunc = 1746

-- 3842  = TO LOC screen
DELETE rdt.RDTScn WHERE Scn = 3842 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3842, 'ENG',
    @cLine01 = 'TM NMV FROM      NMF'
   ,@cLine02 = ''
   ,@cLine03 = 'ID: '
   ,@cLine04 = '%18d01'
   ,@cLine05 = ''
   ,@cLine06 = 'TO LOC:'
   ,@cLine07 = '%10d02'
   ,@cLine08 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1746
   
-- 3843  = Msg screen
DELETE rdt.RDTScn WHERE Scn = 3843 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3843, 'ENG'
   ,@cLine01 = 'TM NMV FROM      NMF'
   ,@cLine02 = ''
   ,@cLine03 = 'SUCCESSFUL MOVE'
   ,@cLine04 = ''
   ,@cLine06 = 'ENTER = Next Task'
   ,@cLine07 = 'ESC   = Back to TM'
   ,@cLine14 = '%e'
   ,@nFunc = 1746
