-- 2230  = FromLOC screen
DELETE rdt.RDTScn WHERE Scn = 2230 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2230, 'ENG',
    @cLine01 = 'PICKING          VPK'
   ,@cLine03 = 'FROM LOC: '
   ,@cLine04 = '%10d01'
   ,@cLine05 = '%10i02'
   ,@cLine14 = '%e'

-- 2231  = ID screen
DELETE rdt.RDTScn WHERE Scn = 2231 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2231, 'ENG',
    @cLine01 = 'PICKING          VPK'
   ,@cLine03 = 'FROM LOC: '
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'PALLET ID: '
   ,@cLine06 = '%18d02'
   ,@cLine07 = '%18i03'
   ,@cLine14 = '%e'

-- 2232  = QTY screen
DELETE rdt.RDTScn WHERE Scn = 2232 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2232, 'ENG',
    @cLine01 = 'PICKING          VPK'
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'SKU:'
   ,@cLine06 = '%20d02'
   ,@cLine07 = '%20d03'
   ,@cLine08 = '%20d04'
   ,@cLine09 = '%04d11 %05d05 %05d12'  -- SOS219045
   ,@cLine10 = 'QTY: %05d07 %05d08'
   ,@cLine11 = 'QTY: %05i09 %05i10'
   ,@cLine14 = '%e'

-- 2233  = DROP ID screen
DELETE rdt.RDTScn WHERE Scn = 2233 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2233, 'ENG',
    @cLine01 = 'PICKING          VPK'
   ,@cLine03 = 'FROM LOC '
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'PALLET ID:'
   ,@cLine06 = '%18d02'
   ,@cLine07 = 'DROP ID'
   ,@cLine08 = '%18i03'
--   ,@cLine10 = '%20d04'  -- for phase 2
--   ,@cLine11 = '%20d05'
--   ,@cLine12 = 'OPTION: %01i06'
   ,@cLine14 = '%e'

-- 2234  = TO LOC screen
DELETE rdt.RDTScn WHERE Scn = 2234 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2234, 'ENG',
    @cLine01 = 'PICKING          VPK'
   ,@cLine03 = 'FROM LOC:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'PALLET ID:'
   ,@cLine06 = '%18d02'
   ,@cLine07 = 'DROP ID'
   ,@cLine08 = '%18d03'
   ,@cLine09 = '%04d10 %05d04 %05d05'
   ,@cLine10 = 'QTY: %05d06 %05d07'
   ,@cLine11 = 'TO LOC'
   ,@cLine12 = '%10d08'
   ,@cLine13 = '%10i09'
   ,@cLine14 = '%e'

-- 2235  = MSG screen
DELETE rdt.RDTScn WHERE Scn = 2235 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2235, 'ENG',
    @cLine01 = 'PICKING          VPK'
   ,@cLine03 = 'PICKING is'
   ,@cLine04 = 'SUCCESSFUL'
   ,@cLine06 = 'ENTER = Next Task'
   ,@cLine07 = 'ESC = Exit TM'
   ,@cLine14 = '%e'
   
-- For task manager, need to update rdt.rdtscn with function id   
UPDATE RDT.RDTSCN SET FUNC = 1758 WHERE SCN BETWEEN 2230 AND 2235