-- 814 = Criteria screen
DELETE rdt.RDTScn WHERE Scn = 814 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 814, 'ENG',
    @cLine01 = 'REFNO:    %20i01' --WMS-21562
   ,@cLine02 = 'PSNO:     %10i02'
   ,@cLine03 = 'LOADKEY:  %10i03'
   ,@cLine04 = 'ORDERKEY: %10i04'
   ,@cLine05 = 'CARTON ID:'
   ,@cLine06 = '%20i05'
   ,@cLine07 = 'PALLET ID:'
   ,@cLine08 = '%20i06'
   ,@cLine09 = 'TASKKEY:  %10i07'   -- WMS-8002
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2"],"3":["3"],"4":["4"],"5":["5","6"],"6":["7","8"],"7":["9"]}'
   ,@nFunc = 850
   
-- 815 = Statistic screen
DELETE rdt.RDTScn WHERE Scn = 815 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 815, 'ENG',
    @cLine01 = 'REFNO:    %20d01' --WMS-21562
   ,@cLine02 = 'PSNO:     %10d02'
   ,@cLine03 = 'LOADKEY:  %10d03'
   ,@cLine04 = 'ORDERKEY: %10d04'
   ,@cLine05 = 'CARTON ID:'
   ,@cLine06 = '%20d05'
   ,@cLine07 = 'PALLET ID:'
   ,@cLine08 = '%20d09'
   ,@cLine09 = 'TASKKEY:  %10d10'   -- WMS-8002
   ,@cLine10 = ''
   ,@cLine11 = 'SKU CKD: %11d06'
   ,@cLine12 = 'QTY CKD: %11d07'
   ,@cLine13 = '%20d08'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2"],"3":["3"],"4":["4"],"5":["5","6"],"6":["7","8"],"7":["9"],"8":["11","12"],"9":["13"]}'
   ,@nFunc = 850
   
-- 816 = SKU QTY screen
DELETE rdt.RDTScn WHERE Scn = 816 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 816, 'ENG',
    @cLine01 = 'SKU/UPC:     PPK:%03d16'
   ,@cLine02 = '%60i01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%10d06     %05d07'
   ,@cLine08 = '%20d08'
   ,@cLine09 = 'QTY:     %05i09^DT:INT %05i10^DT:INT'
   ,@cLine10 = ''
   ,@cLine11 = 'COUNTED:%05d11 %06d12' --(WMS-20944
   ,@cLine12 = 'TOTAL:  %05d13 %06d14' --WMS-20944
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3","4","5"],"2":["6","7"],"3":["8","9"],"4":["11","12"],"5":["13"]}'
   ,@nFunc = 850
   
 -- 817 = Discrepency screen
DELETE rdt.RDTScn WHERE Scn = 817 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 817, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'DISCREPENCY FOUND'
   ,@cLine03 = ''
   ,@cLine04 = '1 = SEND TO QC'
   ,@cLine05 = '2 = EXIT ANYWAY'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine09 = 'Reason Code' --WMS17278
   ,@cLine10 = '%20i02'      --WMS17278
   ,@cLine14 = '%e'
   ,@nFunc = 850
   
 -- 818 = Print packing list
DELETE rdt.RDTScn WHERE Scn = 818 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 818, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'PRINT PACKING LIST?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '9 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 850
   
-- WMS-8002
-- 819 Capture data
DELETE rdt.RDTScn WHERE Scn = 819 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 819, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = 'CAPTURE DATA'
   ,@cLine04 = '%60i03'
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = '%20d13'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["13"]}'
   ,@nFunc = 850
   
-- WMS-17439
-- 5980 Capture data
DELETE rdt.RDTScn WHERE Scn = 5980 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5980, 'ENG'
   ,@cLine01 = 'CARTON: %10i01'
   ,@cLine02 = 'CUBE: %10i02^DT:INT'
   ,@cLine03 = 'WEIGHT:   %10i03^DT:INT'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2"],"3":["3"]}'
   ,@nFunc = 850
   
-- FCR-386
-- 5980 Short Confirm
DELETE rdt.RDTScn WHERE Scn = 6384 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6384, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CONFIRM SHORT'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '9 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3"],"3":["4","5","6"],"4":["7"]}'
   ,@nFunc = 850

--FCR-2630
-- 6464 = Print packing list + Automation label and doc
DELETE rdt.RDTScn WHERE Scn = 6464 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6464, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'PRINT PACKING LIST?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '5 = Automation label'
   ,@cLine06 = '9 = NO'
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 850

--FCR-4159
-- 6468 = Scan SKU to get real case id in single order
DELETE rdt.RDTScn WHERE Scn = 6468 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6468, 'ENG',
    @cLine01 = 'SINGLE UNIT ORDERS'
   ,@cLine02 = 'SCAN SKU IN CARTON'
   ,@cLine03 = 'SKU:'
   ,@cLine04 = '%20i01'
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 850
