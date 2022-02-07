
-- 3420  = FromLOC screen
DELETE rdt.RDTScn WHERE Scn = 3420 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3420, 'ENG'
   ,@cLine01 = 'TM PUTAWAY TO    PAT'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM LOC: '
   ,@cLine04 = '%10d01'
   ,@cLine05 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1796

-- 3421  = ID screen
DELETE rdt.RDTScn WHERE Scn = 3421 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3421, 'ENG'
   ,@cLine01 = 'TM PUTAWAY TO    PAT'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM LOC: '
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'FROM ID: '
   ,@cLine06 = '%18d02'
   ,@cLine07 = '%18i03'
   ,@cLine14 = '%e'   
   ,@nFunc = 1796

-- 3422  = UCC screen
DELETE rdt.RDTScn WHERE Scn = 3422 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3422, 'ENG'
   ,@cLine01 = 'TM PUTAWAY TO    PAT'
   ,@cLine02 = ''
   ,@cLine03 = 'UCC:'
   ,@cLine04 = '%20i01'
   ,@cLine14 = '%e'   
   ,@nFunc = 1796

-- 3423  = TO LOC screen
DELETE rdt.RDTScn WHERE Scn = 3423 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3423, 'ENG',
    @cLine01 = 'TM PUTAWAY TO    PAT'
   ,@cLine02 = ''
   ,@cLine03 = 'UCC: '
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'SKU: '
   ,@cLine06 = '%20d02'
   ,@cLine07 = '%20d03'
   ,@cLine08 = '%20d04'
   ,@cLine09 = 'QTY: %05d05'
   ,@cLine10 = 'TO LOC:'
   ,@cLine11 = '%10d06'
   ,@cLine12 = '%10i07'
   ,@cLine14 = '%e'
   ,@nFunc = 1796
   
-- 3424  = Msg screen
DELETE rdt.RDTScn WHERE Scn = 3424 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3424, 'ENG'
   ,@cLine01 = 'TM PUTAWAY TO    PAT'
   ,@cLine02 = ''
   ,@cLine03 = 'SUCCESSFUL PUTAWAY'
   ,@cLine04 = ''
   ,@cLine06 = 'ENTER = Next Task'
   ,@cLine07 = 'ESC   = Exit TM'
   ,@cLine14 = '%e'
   ,@nFunc = 1796
   
-- 3425  = TO LOC screen
DELETE rdt.RDTScn WHERE Scn = 3425 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3425, 'ENG'
   ,@cLine01 = 'TM PUTAWAY TO    PAT'
   ,@cLine02 = ''
   ,@cLine03 = 'TO LOC:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = '%10i02'
   ,@cLine14 = '%e'   
   ,@nFunc = 1796
