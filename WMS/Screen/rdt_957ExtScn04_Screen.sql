
-- 6714 = UCCNo FCR-7737
DELETE rdt.RDTScn WHERE Scn = 6714 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6714, 'ENG'
   ,@cLine01 = 'LOC:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'ID:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = ''
   ,@cLine06 = 'UCC:'
   ,@cLine07 = '%20i05'
   ,@cLine08 = 'Total Case: %08d06'
   ,@cLine09 = 'Total Scan: %08d07'
   ,@cLine10 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4","5"],"3":["6","7"],"4":["8","9"],"5":["10"]}'
   ,@nFunc = 957

-- 6715 = TOLOC FCR-7737
DELETE rdt.RDTScn WHERE Scn = 6715 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6715, 'ENG'
   ,@cLine01 = 'TOLOC:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"]}'
   ,@nFunc = 957

-- 6716 = Close Pallet? FCR-7737
DELETE rdt.RDTScn WHERE Scn = 6716 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6716, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Close Pallet?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '9 = NO'
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4","5"],"3":["8"]}'
   ,@nFunc = 957

--
--  = Message screen
DELETE rdt.RDTScn WHERE Scn = 6717 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6717, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'No more Carton needs to '
   ,@cLine03 = 'be picked from the Pickslip'
   ,@cLine04 = ''
   ,@cLine05 = 'Press ENTER or ESC'
   ,@cLine06 = 'to continue'
   ,@cLine14 = '%e'
   ,@cAutoDisappear = '1'
   ,@nFunc = 957
