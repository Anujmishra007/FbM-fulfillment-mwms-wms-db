-- 2210  = FromLOC screen
DELETE rdt.RDTScn WHERE Scn = 2210 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2210, 'ENG'
   ,@cLine01 = 'MOVE             NMV'
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%20d01'
   ,@cLine05 = 'FROM LOC:'
   ,@cLine06 = '%10d02'
   ,@cLine07 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1759

-- 2211  = To LOC screen
DELETE rdt.RDTScn WHERE Scn = 2211 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2211, 'ENG'
   ,@cLine01 = 'MOVE             NMV'
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%20d01'
   ,@cLine05 = 'FROM LOC:'
   ,@cLine06 = '%10d02'
   ,@cLine07 = 'SUGGESTED TOLOC'
   ,@cLine08 = '%10d03'
   ,@cLine09 = 'TO LOC:'
   ,@cLine10 = '%10i04'
   ,@cLine14 = '%e'
   ,@nFunc = 1759

-- 2212  = QTY screen
DELETE rdt.RDTScn WHERE Scn = 2212 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2212, 'ENG'
   ,@cLine01 = 'MOVE             NMV'
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%20d01'
   ,@cLine05 = 'FROM LOC:'
   ,@cLine06 = '%10d02'
   ,@cLine07 = 'TO LOC:'
   ,@cLine08 = '%10d03'
   ,@cLine09 = 'UOM:  %05d04 %05d07'
   ,@cLine10 = 'QTY:  %05d05 %05d08'
   ,@cLine11 = 'QTY:  %05i06 %05i09'
   ,@cLine14 = '%e'
   ,@nFunc = 1759

-- 2213  = Msg screen
DELETE rdt.RDTScn WHERE Scn = 2213 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2213, 'ENG'
   ,@cLine01 = 'MOVE             NMV'
   ,@cLine03 = 'Move is successful'
   ,@cLine05 = 'ENTER = Next Task'
   ,@cLine06 = 'ESC   = Exit TM'
   ,@cLine14 = '%e'
   ,@nFunc = 1759

-- 2214 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2214 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2214, 'ENG'
   ,@cLine01 = 'MOVE             NMV'
   ,@cLine03 = 'FROM LOC:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'PALLET ID:'
   ,@cLine06 = '%20d02'
   ,@cLine07 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1759
   