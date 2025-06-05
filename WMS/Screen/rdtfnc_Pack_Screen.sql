-- 4650 = PickSlipNo, DropID screen
DELETE rdt.RDTScn WHERE Scn = 4650 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4650, 'ENG'
   ,@cLine01 = 'PSNO: %10i01'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM DROPID:'
   ,@cLine04 = '%20i02'
   ,@cLine05 = ''
   ,@cLine06 = 'TO DROPID: '
   ,@cLine07 = '%20i03'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["3","4"],"3":["6","7"]}'
   ,@nFunc = 838

-- 4651 = Statistic screen
DELETE rdt.RDTScn WHERE Scn = 4651 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4651, 'ENG'
   ,@cLine01 = 'PSNO: %10d01'
   ,@cLine02 = 'TOTAL PICK: %05d02'
   ,@cLine03 = 'TOTAL PACK: %05d03'
   ,@cLine04 = 'SHORT PICK: %03d04'
   ,@cLine05 = ''
   ,@cLine06 = 'CARTON NO:  %08d05'
   ,@cLine07 = 'CARTON ID:'
   ,@cLine08 = '%20d06'
   ,@cLine09 = 'SKU: %04d07 QTY: %05d08'
   ,@cLine10 = ''
   ,@cLine11 = 'OPTION: %02i09      4=UCC'
   ,@cLine12 = '1=NEW 2=EDT 3=REPACK'
   ,@cLine13 = '%20d15'    -- WMS-10890 ExtInfo
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3","4"],"3":["6","7","8","9"],"4":["11","12"],"5":["11"]}'
   ,@nFunc = 838

-- 4652 = SKU QTY screen
DELETE rdt.RDTScn WHERE Scn = 4652 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4652, 'ENG'
   ,@cLine01 = 'CARTON NO: %03d01'
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
   ,@nFunc = 838

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


-- FCR-778  for rdt_838ExtScn04
-- 6440 = TO DROP ID Screen
DELETE rdt.RDTScn WHERE Scn = 6440 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6440, 'ENG'
   ,@cLine01 = 'DROP ID:       %20d01'
   ,@cLine02 = 'Pallet Type:   %10d02'
   ,@cLine03 = 'Pallet Height: %10d03'
   ,@cLine04 = 'Pallet Cube:   %10d04'
   ,@cLine05 = 'WARNING:'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = '%20d08'
   ,@cLine10 = '%20d09'
   ,@cLine11 = '%20d10'
   ,@cLine12 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3","4"],"3":["5","6","7","8","9","10","11"]}'
   ,@nFunc = 838

-- Step9 Extend Screen 6449 SerialNo Confirm
DELETE rdt.RDTScn WHERE Scn = 6449 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6449, 'ENG'
   ,@cLine01 = 'SERIAL NO:'
   ,@cLine02 = '%30d01'
   ,@cLine03 = ''
   ,@cLine04 = 'INVALID SERIAL NO'
   ,@cLine05 = 'CONFIRM?'
   ,@cLine06 = ''
   ,@cLine07 = '1 = YES'
   ,@cLine08 = '9 = NO'
   ,@cLine10 = 'OPTION: %01i03'
   ,@cLine14 = '%e'
   ,@nFunc = 838


-- 6521 = FCR-2495, Add 5=PTL
DELETE rdt.RDTScn WHERE Scn = 6521 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6521, 'ENG'
   ,@cLine01 = 'PSNO: %10d01'
   ,@cLine02 = 'TOTAL PICK: %05d02'
   ,@cLine03 = 'TOTAL PACK: %05d03'
   ,@cLine04 = 'SHORT PICK: %03d04'
   ,@cLine05 = ''
   ,@cLine06 = 'CARTON NO:  %08d05'
   ,@cLine07 = 'CARTON ID:'
   ,@cLine08 = '%20d06'
   ,@cLine09 = 'SKU: %04d07 QTY: %05d08'
   ,@cLine10 = 'OPTION: %02i09 '
   ,@cLine11 = '1=NEW 2=EDT 3=REPACK'
   ,@cLine12 = '4=UCC 5=PLT'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3","4"],"3":["6","7","8","9"],"4":["11","12"],"5":["11"]}'
   ,@nFunc = 838

-- 6522 = FCR-2495, Add 5=PTL
DELETE rdt.RDTScn WHERE Scn = 6522 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6522, 'ENG'
   ,@cLine01 = '%20d11'
   ,@cLine02 = ''
   ,@cLine03 = '%20d01'
   ,@cLine04 = '%60i02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%60i04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%60i06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%60i08'
   ,@cLine11 = '%20d09'
   ,@cLine12 = '%60i10'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["3","4"],"2":["5","6"],"3":["7","8"],"4":["9","10"],"5":["11","12"]}'
   ,@nFunc = 838

--6525 FCR-2495 Confirm Scn
DELETE rdt.RDTScn WHERE Scn = 6525 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6525, 'ENG',
     @cLine01 = 'Packing complete',
     @cLine02 = '',
     @cLine04 = 'Press ENTER or ESC',
     @cLine05 = 'to continue',
     @cLine14 = '%e'
