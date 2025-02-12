-- 6490 = CartonNo Screen
DELETE rdt.RDTScn WHERE Scn = 6490 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6490, 'ENG'
   ,@cLine01 = 'Carton ID:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["6","7"]}'
   ,@nFunc = 993

-- 6491 = Statistic screen
DELETE rdt.RDTScn WHERE Scn = 6491 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6491, 'ENG'
   ,@cLine01 = 'CARTON ID: %20d01'
   ,@cLine02 = 'TOTAL PICK: %05d02'
   ,@cLine03 = 'TOTAL PACK: %05d03'
   ,@cLine04 = 'SHORT PICK: %03d04'
   ,@cLine05 = 'SKU: %04d05'
   ,@cLine06 = 'QTY: %05d06'
   ,@cLine07 = ''
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = 'OPTION: %02i09      '
   ,@cLine12 = '1=NEW 2=MERGE'
   ,@cLine13 = '%20d15'    -- WMS-10890 ExtInfo
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3","4"],"3":["5","6"],"4":["11","12"],"5":["11"]}'
   ,@nFunc = 993

-- 6492 = SKU QTY screen
DELETE rdt.RDTScn WHERE Scn = 6492 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6492, 'ENG'
   ,@cLine01 = 'CARTON ID: %20d01'
   ,@cLine02 = ''
   ,@cLine03 = 'SKU/UPC:       %05d02'
   ,@cLine04 = '%60i03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = ''
   ,@cLine09 = 'PACKED: %05d07 PPK:%03d10'
   --,@cLine10 = 'QTY:    %05i08 PPK:%03d10'
   ,@cLine10 = '%07d11 %05d12   %05d13'   -- WMS-10570 Change to show UOM
   ,@cLine11 = 'QTY: %07i14^DT:INT %07i08^DT:INT'
   ,@cLine12 = 'CARTON QTY: %05d09'
   ,@cLine13 = '%05d15'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["3","4","5","6","7"],"3":["9"],"4":["10","11"],"5":["12"],"6":["13"]}'
   ,@nFunc = 993

-- 6493 = From Carton screen
DELETE rdt.RDTScn WHERE Scn = 6493 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6493, 'ENG'
   ,@cLine01 = 'CURRENT CARTON ID: %20d01'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM CARTON ID: '
   ,@cLine04 = '%20i02'
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"]}'
   ,@nFunc = 993

-- 6494 = New Carton Type screen
DELETE rdt.RDTScn WHERE Scn = 6494 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6494, 'ENG'
   ,@cLine01 = 'NEW CARTON ID: %20d01'
   ,@cLine02 = ''
   ,@cLine03 = 'NEW CARTON TYPE: '
   ,@cLine04 = '%10i02'
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"]}'
   ,@nFunc = 993

-- 6495 = Print label screen
DELETE rdt.RDTScn WHERE Scn = 6495 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6495, 'ENG'
   ,@cLine01 = '%40d01' -- carton id
   ,@cLine02 = ''
   ,@cLine03 = 'PRINT LABEL?'
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 993

/*
-- 4653 = Pack info screen
DELETE rdt.RDTScn WHERE Scn = 4653 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4653, 'ENG'
   ,@cLine01 = 'CARTON: %10i01'
   ,@cLine02 = 'WEIGHT: %10i02^DT:INT'
   ,@cLine03 = 'CUBE:   %10i03^DT:INT'
   ,@cLine04 = 'REF NO:'
   ,@cLine05 = '%20i04'
   ,@cLine06 = 'LENGTH: %10i05^DT:INT'  -- WMS-15989
   ,@cLine07 = 'WIDTH:  %10i06^DT:INT'  -- WMS-15989
   ,@cLine08 = 'HEIGHT: %10i07^DT:INT'  -- WMS-15989
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3"],"3":["4","5"],"4":["6","7","8"]}'
   ,@nFunc = 838

-- 4654 = Print label screen
DELETE rdt.RDTScn WHERE Scn = 4654 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4654, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'PRINT LABEL?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 838

-- 4655 = Print packing list screen
DELETE rdt.RDTScn WHERE Scn = 4655 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4655, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'PRINT PACKING LIST?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 838

-- 4656 = Confirm repack screen
DELETE rdt.RDTScn WHERE Scn = 4656 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4656, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CONFIRM REPACK?'
   ,@cLine03 = 'CARTON NO: %01d01'
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 838

-- 4657 = UCC
DELETE rdt.RDTScn WHERE Scn = 4657 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4657, 'ENG'
   ,@cLine01 = 'UCCNO:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = 'SCAN:  %05d02'
   ,@cLine05 = ''
   ,@cLine06 = 'TOTAL: %05d03'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4"],"3":["6"]}'
   ,@nFunc = 838

-- 4659 = Data capture screen
DELETE rdt.RDTScn WHERE Scn = 4659 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4659, 'ENG'
   ,@cLine01 = N'%20d01'
   ,@cLine02 = N'%20i02'
   ,@cLine03 = N'%20d03'
   ,@cLine04 = N'%20i04'
   ,@cLine05 = N'%20d05'
   ,@cLine06 = N'%20i06'
   ,@cLine14 = N'%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["5","6"]}'
   ,@nFunc = 838
*/