--FCR-5413
--6628 New step1 loadkey and dropid
DELETE rdt.RDTScn WHERE Scn = 6628 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6628, 'ENG',
    @cLine01 = 'LOADKEY:'
   ,@cLine02 = '%10i01'
   ,@cLine03 = 'Drop ID:'
   ,@cLine04 = '%20i02'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2"],"3":["3"],"4":["4"],"5":["5","6"],"6":["7","8"],"7":["9"]}'
   ,@nFunc = 855

-- 6629 = Load Statistic screen
DELETE rdt.RDTScn WHERE Scn = 6629 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6629, 'ENG',
    @cLine01 = 'LOADKEY:%10d01' 
   ,@cLine02 = ''
   ,@cLine03 = 'AUDIT SUMMARY'
   ,@cLine04 = 'PALLETS PICKED: %05d02'
   ,@cLine05 = 'PALLETS AUDITED: %05d03'
   ,@cLine06 = ''
   ,@cLine07 = 'PICK TASKS'
   ,@cLine08 = 'PENDING PICK: %05d04'
   ,@cLine09 = 'SHORT PICK:  %15d05'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2"],"3":["3","4","5"],"4":["7","8","9"]}'
   ,@nFunc = 855
   
-- 6670 = Load Statistic screen with drop id
DELETE rdt.RDTScn WHERE Scn = 6670 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6670, 'ENG',
    @cLine01 = 'LOADKEY:%10d01' 
   ,@cLine02 = ''
   ,@cLine03 = 'AUDIT SUMMARY'
   ,@cLine04 = 'PALLETS PICKED: %05d02'
   ,@cLine05 = 'PALLETS AUDITED: %05d03'
   ,@cLine06 = ''
   ,@cLine07 = 'PICK TASKS'
   ,@cLine08 = 'PENDING PICK: %05d04'
   ,@cLine09 = 'SHORT PICK:  %15d05'
   ,@cLine10 = ''
   ,@cLine11 = 'DROP ID:  %20d06'
   ,@cLine12 = 'SKUs CKD: %05d07'
   ,@cLine13 = 'Total QTY CKD: %05d08'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2"],"3":["3","4","5"],"4":["7","8","9"],"5":["11","12","13"]}'
   ,@nFunc = 855
   
 -- 6671 = Discrepency screen
DELETE rdt.RDTScn WHERE Scn = 6671 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6671, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'DISCREPENCY FOUND'
   ,@cLine03 = ''
   ,@cLine04 = '2 = Exit anyway'
   ,@cLine05 = '9 = Recount'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 855
