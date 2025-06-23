--Screen Range 2680 - 2699

-- Drop ID
DELETE rdt.RDTScn WHERE Scn = 2680 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2680, 'ENG',
    @cLine01 = 'REPLEN FROM      RPF'
   ,@cLine02 = 'PLEASE TAKE AN EMPTY'
   ,@cLine03 = 'PALLET'
   ,@cLine04 = ''
   ,@cLine05 = 'DROPID:'
   ,@cLine06 = '%20i01'
   ,@cLine07 = ''
   ,@cLine08 = '%20d10'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["5","6"],"2":["8"]}'
   ,@nFunc = 1764

-- From LOC
DELETE rdt.RDTScn WHERE Scn = 2681 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2681, 'ENG',
    @cLine01 = 'REPLEN FROM      RPF'
   ,@cLine02 = 'PICKTYPE: %10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'DROPID:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = ''
   ,@cLine07 = 'FROM LOC:'
   ,@cLine08 = '%10d03'
   ,@cLine09 = '%10i04'
   ,@cLine10 = ''
   ,@cLine11 = '%20d10'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["4","5"],"2":["7","8"],"3":["11"]}'
   ,@nFunc = 1764

-- From ID
DELETE rdt.RDTScn WHERE Scn = 2682 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2682, 'ENG',
    @cLine01 = 'REPLEN FROM      RPF'
   ,@cLine02 = 'PICKTYPE: %10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'DROPID:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = ''
   ,@cLine07 = 'FROM LOC:'
   ,@cLine08 = '%10d03'
   ,@cLine09 = ''
   ,@cLine10 = 'FROM ID:'
   ,@cLine11 = '%18d04'
   ,@cLine12 = '%40i05'    --WMS6145 Extend to 40 chars
   ,@cLine13 = '%20d10'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["4","5"],"2":["7","8"],"3":["10","11","12"],"4":["13"]}'
   ,@nFunc = 1764

-- SKU, QTY
DELETE rdt.RDTScn WHERE Scn = 2683 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2683, 'ENG',
    @cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '1 %18d04'
   ,@cLine06 = '2 %18d05'
   ,@cLine07 = '3 %18d06'
   ,@cLine08 = '4 %10d07'
   ,@cLine09 = '%20d10'
   ,@cLine10 = '%32i08'
   ,@cLine11 = '%20d11'
   ,@cLine12 = 'RPL QTY: %05d12 %05d13'
   ,@cLine13 = 'ACT QTY: %05i14^DT:INT %05i15^DT:INT'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["4","5"],"2":["7","8"],"3":["10","11","12"],"4":["13"]}'
   ,@nFunc = 1764

-- Next task
DELETE rdt.RDTScn WHERE Scn = 2684 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2684, 'ENG',
    @cLine01 = 'REPLEN FROM      RPF'
   ,@cLine02 = ''
   ,@cLine03 = '1 = CONT NEXT TASK'
   ,@cLine04 = '9 = CLOSE PALLET'
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = '%20d10'
   ,@cLine11 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1764

-- To LOC
DELETE rdt.RDTScn WHERE Scn = 2685 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2685, 'ENG',
    @cLine01 = 'REPLEN FROM      RPF'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM LOC:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = ''
   ,@cLine06 = 'TO LOC:'
   ,@cLine07 = '%10d02'
   ,@cLine08 = '%10i03'
   ,@cLine09 = ''
   ,@cLine10 = '%20d10'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["3","4"],"2":["6","7","8"],"4":["10"]}'
   ,@nFunc = 1764

-- Exit
DELETE rdt.RDTScn WHERE Scn = 2686 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2686, 'ENG',
    @cLine01 = 'REPLEN FROM      RPF'
   ,@cLine02 = ''
   ,@cLine03 = 'Pallet is closed and'
   ,@cLine04 = 'moved'
   ,@cLine05 = ''
   ,@cLine06 = 'ENTER = Next Task'
   ,@cLine07 = 'ESC   = Exit to TM'
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = 'LAST LOC: %10d01'
   ,@cLine11 = '%20d10'
   ,@cLine14 = '%e'
   ,@nFunc = 1764

-- Short pick
DELETE rdt.RDTScn WHERE Scn = 2687 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2687, 'ENG',
    @cLine01 = 'REPLEN FROM      RPF'
   ,@cLine02 = ''
   ,@cLine03 = '1 = SHORT PICK'
   ,@cLine04 = '9 = CLOSE PALLET'
   ,@cLine05 = ''
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1764


-- Exit
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
