-- FCR-9200
-- 6720 = PickSlipNo, DropID screen
DELETE rdt.RDTScn WHERE Scn = 6720 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6720, 'ENG'
   ,@cLine01 = 'Order Key:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"]}'
   ,@nFunc = 777

-- 6721 = Statistic screen
DELETE rdt.RDTScn WHERE Scn = 6721 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6721, 'ENG'
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
   ,@nFunc = 777

-- 6722 = SKU QTY screen
DELETE rdt.RDTScn WHERE Scn = 6722 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6722, 'ENG'
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
   ,@nFunc = 777

-- 6723 = Pack info screen
DELETE rdt.RDTScn WHERE Scn = 6723 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6723, 'ENG'
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
   ,@nFunc = 777

-- 6724 = Print label screen
DELETE rdt.RDTScn WHERE Scn = 6724 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6724, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'PRINT LABEL?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 777

-- 6725 = Print packing list screen
DELETE rdt.RDTScn WHERE Scn = 6725 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6725, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'PRINT PACKING LIST?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 777

-- 6726 = Confirm repack screen
DELETE rdt.RDTScn WHERE Scn = 6726 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6726, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CONFIRM REPACK?'
   ,@cLine03 = 'CARTON NO: %01d01'
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 777

-- 6727 = UCC
DELETE rdt.RDTScn WHERE Scn = 6727 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6727, 'ENG'
   ,@cLine01 = 'UCCNO:'
   ,@cLine02 = '%60i01' --FCR-7545
   ,@cLine03 = ''
   ,@cLine04 = 'SCAN:  %05d02'
   ,@cLine05 = ''
   ,@cLine06 = 'TOTAL: %05d03'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4"],"3":["6"]}'
   ,@nFunc = 777

-- 6729 = Data capture screen
DELETE rdt.RDTScn WHERE Scn = 6729 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6729, 'ENG'
   ,@cLine01 = N'%20d01'
   ,@cLine02 = N'%20i02'
   ,@cLine03 = N'%20d03'
   ,@cLine04 = N'%20i04'
   ,@cLine05 = N'%20d05'
   ,@cLine06 = N'%20i06'
   ,@cLine14 = N'%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["5","6"]}'
   ,@nFunc = 777