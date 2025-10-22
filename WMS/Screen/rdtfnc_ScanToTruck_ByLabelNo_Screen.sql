-- 3430 = Document screen
DELETE rdt.RDTScn WHERE Scn = 3430 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3430, 'ENG'
   ,@cLine01 = 'MBOLKEY:  %10i01'
   ,@cLine02 = ''
   ,@cLine03 = 'LOADKEY:  %10i02'
   ,@cLine04 = ''
   ,@cLine05 = 'ORDERKEY: %10i03'
   ,@cLine06 = ''
   ,@cLine07 = 'REF NO:'      -- WMS-15718
   ,@cLine08 = '%20i04'       -- WMS-15718
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["3"],"3":["5"],"4":["7","8"]}'
   ,@nFunc = 922

-- 3431 = Carton ID screen
DELETE rdt.RDTScn WHERE Scn = 3431 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3431, 'ENG'
   ,@cLine01 = 'MBOLKEY:  %10d01'
   ,@cLine02 = 'LOADKEY:  %10d02'
   ,@cLine03 = 'ORDERKEY: %10d03'
   ,@cLine04 = 'REF NO:'      -- WMS-15718
   ,@cLine05 = '%20d08'       -- WMS-15718
   ,@cLine06 = 'LABELNO/DROPID:'
   ,@cLine07 = '%60i04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = ''
   ,@cLine10 = 'SCANNED: %10d06'
   ,@cLine11 = 'TOTAL:   %10d07'
   ,@cLine13 = '%20d09' --wms-24119
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3","4","5"],"2":["6","7","8"],"3":["10","11","13"]}' --wms
   ,@nFunc = 922

-- 3432 = Pack info screen
DELETE rdt.RDTScn WHERE Scn = 3432 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3432, 'ENG'
   ,@cLine01 = 'LABELNO/DROPID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'WEIGHT: %10i02^DT:INT'
   ,@cLine05 = ''
   ,@cLine06 = 'CUBE:   %10i03^DT:INT'
   ,@cLine07 = ''
   ,@cLine08 = 'CARTON: %10i04'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4"],"3":["6"],"4":["8"]}'
   ,@nFunc = 922

-- 3433 = Capture Ref Info screen
DELETE rdt.RDTScn WHERE Scn = 3433 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3433, 'ENG'
   ,@cLine01 = 'REFNO1: %10i01'
   ,@cLine02 = ''
   ,@cLine03 = 'REFNO2:'
   ,@cLine04 = '%40i02'
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = '%20d15'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["3","4"],"3":["7"]}'
   ,@nFunc = 922
   
-- 3434. Print manifest label
DELETE rdt.RDTScn WHERE Scn = 3434 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3434, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'PRINT MANIFEST?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '9 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %02i01'
   ,@cLine14 = '%e'
   ,@nFunc = 922

   
-- 3435. Print manifest label
DELETE rdt.RDTScn WHERE Scn = 3435 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3435, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'All Label/DropID'
   ,@cLine03 = 'Çompleted For MBOL'
   ,@cLine04 = ''
   ,@cLine05 = 'Mark MBOL AS'
   ,@cLine06 = 'Shipped?'
   ,@cLine07 = ''
   ,@cLine08 = '1 = YES'
   ,@cLine09 = '9 = NO'
   ,@cLine10 = ''
   ,@cLine11 = 'OPTION: %02i01'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["2","3""],"2":["5","6"],"3":["8","9"],"4":["11"]}'
   ,@nFunc = 922