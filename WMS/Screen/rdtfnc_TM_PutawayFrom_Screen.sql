
-- 3440  = FromLOC screen
DELETE rdt.RDTScn WHERE Scn = 3440 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3440, 'ENG'
   ,@cLine01 = 'TM PUTAWAY FROM  PAF'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM LOC: '
   ,@cLine04 = '%10d01'
   ,@cLine05 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1797

-- 3441  = ID screen
DELETE rdt.RDTScn WHERE Scn = 3441 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3441, 'ENG'
   ,@cLine01 = 'TM PUTAWAY FROM  PAF'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM LOC: %10d01'
   ,@cLine04 = ''
   ,@cLine05 = 'ID: '
   ,@cLine06 = '%18d02'
   ,@cLine07 = '%18i03'
   ,@cLine14 = '%e'   
   ,@nFunc = 1797

-- 3442  = TO LOC screen
DELETE rdt.RDTScn WHERE Scn = 3442 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3442, 'ENG',
    @cLine01 = 'TM PUTAWAY FROM  PAF'
   ,@cLine02 = ''
   ,@cLine03 = 'ID: '
   ,@cLine04 = '%18d01'
   ,@cLine05 = ''
   ,@cLine06 = '%20d04'    -- WMS-12080 ExtendedInfoSP
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = ''
   ,@cLine10 = 'TO LOC:'
   ,@cLine11 = '%10d02'
   ,@cLine12 = '%10i03'
   ,@cLine13 = '%20d15'    -- WMS-11394 ExtendedInfoSP
   ,@cLine14 = '%e'
   ,@nFunc = 1797
   
-- 3443  = Msg screen
DELETE rdt.RDTScn WHERE Scn = 3443 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3443, 'ENG'
   ,@cLine01 = 'TM PUTAWAY FROM  PAF'
   ,@cLine02 = ''
   ,@cLine03 = 'SUCCESSFUL PUTAWAY'
   ,@cLine04 = ''
   ,@cLine06 = 'ENTER = Next Task'
   ,@cLine07 = 'ESC   = Back to TM'
   ,@cLine14 = '%e'
   ,@nFunc = 1797
