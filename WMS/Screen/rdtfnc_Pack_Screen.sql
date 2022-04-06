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
   ,@cLine11 = 'OPTION: %01i09      4=UCC'
   ,@cLine12 = '1=NEW 2=EDT 3=REPACK'
   ,@cLine13 = '%20d15'    -- WMS-10890 ExtInfo
   ,@cLine14 = '%e'
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
   ,@cLine11 = 'QTY: %07i14 %07i08'
   ,@cLine12 = 'CARTON QTY: %05d09'
   ,@cLine13 = '%05d15'
   ,@cLine14 = '%e'
   ,@nFunc = 838

-- 4653 = Pack info screen
DELETE rdt.RDTScn WHERE Scn = 4653 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4653, 'ENG'
   ,@cLine01 = 'CARTON: %10i01'
   ,@cLine02 = 'WEIGHT: %10i02'
   ,@cLine03 = 'CUBE:   %10i03'
   ,@cLine04 = 'REF NO:'
   ,@cLine05 = '%20i04'
   ,@cLine06 = 'LENGTH: %10i05'  -- WMS-15989
   ,@cLine07 = 'WIDTH:  %10i06'  -- WMS-15989
   ,@cLine08 = 'HEIGHT: %10i07'  -- WMS-15989
   ,@cLine14 = '%e'
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
   ,@nFunc = 838

-- 4659 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4659 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4659, 'ENG'
   ,@cLine01 = N'%20d01'
   ,@cLine02 = N'%20i02'
   ,@cLine03 = N'%20d03'
   ,@cLine04 = N'%20i04'
   ,@cLine05 = N'%20d05'
   ,@cLine06 = N'%20i06'
   ,@cLine14 = N'%e'
