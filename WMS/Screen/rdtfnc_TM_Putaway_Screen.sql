-- 2110  = FromLOC screen
DELETE rdt.RDTScn WHERE Scn = 2110 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2110, 'ENG',
    @cLine01 = 'PUTAWAY          VPA'
   ,@cLine03 = 'FROM LOC: '
   ,@cLine04 = '%10d01'
   ,@cLine05 = '%10i02'
   ,@cLine14 = '%e'

-- 2111  = ID screen
DELETE rdt.RDTScn WHERE Scn = 2111 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2111, 'ENG',
    @cLine01 = 'PUTAWAY          VPA'
   ,@cLine03 = 'FROM LOC: '
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'ID: '
   ,@cLine06 = '%18d02'
   ,@cLine07 = '%18i03'
   ,@cLine14 = '%e'

-- 2112  = TO LOC screen
DELETE rdt.RDTScn WHERE Scn = 2112 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2112, 'ENG',
    @cLine01 = 'PUTAWAY          VPA'
   ,@cLine03 = 'FROM LOC: '
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'ID: '
   ,@cLine06 = '%18d02'
   ,@cLine07 = 'SUGGESTED TOLOC:'
   ,@cLine08 = '%10d03'
   ,@cLine09 = 'TO LOC:'
   ,@cLine10 = '%10i04'
   ,@cLine14 = '%e'

-- 2113  = QTY, REASON CODE screen
DELETE rdt.RDTScn WHERE Scn = 2113 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2113, 'ENG',
    @cLine01 = 'PUTAWAY          VPA'
   ,@cLine03 = 'FROM LOC: '
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'ID: '
   ,@cLine06 = '%18d02'
   ,@cLine07 = 'TO LOC:'
   ,@cLine08 = '%10d03'
   ,@cLine09 = '%04d11 %05d05 %05d06'
   ,@cLine10 = 'QTY: %05d07 %05d08'
   ,@cLine11 = 'QTY: %05i09 %05i10'
--   ,@cLine09 = 'UOM:  %05d04'     -- (james01)
--   ,@cLine10 = 'QTY:  %05d05'     -- (james01)
--   ,@cLine11 = 'QTY:  %05i06'     -- (james01)
   ,@cLine14 = '%e'

-- 2114  = Msg screen
DELETE rdt.RDTScn WHERE Scn = 2114 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2114, 'ENG',
    @cLine01 = 'PUTAWAY          VPA'
   ,@cLine03 = 'Putaway is '
   ,@cLine04 = 'successful'
   ,@cLine06 = 'ENTER = Next Task'
   ,@cLine07 = 'ESC   = Exit TM'
   ,@cLine14 = '%e'

-- For task manager, need to update rdt.rdtscn with function id   
UPDATE RDT.RDTSCN SET FUNC = 1757 WHERE SCN BETWEEN 2110 AND 2114