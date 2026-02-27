-- 4640 = PickSlipNo screen
DELETE rdt.RDTScn WHERE Scn = 4640 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4640, 'ENG'
   ,@cLine01 = 'PSNO: %10i01'
   ,@cLine13 = '%20d12'    -- WMS-22439
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["13"]}'
   ,@nFunc = 839

-- 4641 = Pick zone screen
DELETE rdt.RDTScn WHERE Scn = 4641 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4641, 'ENG'
   ,@cLine01 = 'PSNO:   %10d01'
   ,@cLine02 = ''
   ,@cLine03 = 'PKZONE: %10i02'
   ,@cLine04 = ''
   ,@cLine05 = 'DROPID:'
   ,@cLine06 = '%20i03'
   ,@cLine13 = '%20d15' --WMS-18004 ExtendedInfo
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["3"],"3":["5","6"],"3":["13"]}'
   ,@nFunc = 839

-- 4642 = SKU QTY screen
DELETE rdt.RDTScn WHERE Scn = 4642 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4642, 'ENG'
   ,@cLine01 = 'LOC: %10d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = 'SKU/UPC:'
   ,@cLine06 = '%120iV_Barcode'  -- WMS-22147
   ,@cLine07 = '%20d08'    -- Lottablenn (WMS5057)
   ,@cLine08 = '%20d09'    -- Lottablenn (WMS5057)
   ,@cLine09 = '%20d10'    -- Lottablenn (WMS5057)
   ,@cLine10 = '%20d11'    -- Lottablenn (WMS5057)
   ,@cLine11 = 'PICK: %05i07 ACT: %06d06'
   ,@cLine12 = 'BAL QTY: %12d13'    -- WMS10357(yeekung01)
   ,@cLine13 = '%20d12'    -- WMS10357
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3","4"],"3":["5","6"],"4":["7","8","9","10"],"5":["11","12"],"6":["13"]}'
   ,@nFunc = 839

-- 4643 = Message screen
DELETE rdt.RDTScn WHERE Scn = 4643 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4643, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'No more task in LOC'
   ,@cLine03 = '%10d01'              -- FCR-10366
   ,@cLine04 = ''
   ,@cLine05 = 'Press ENTER or ESC'
   ,@cLine06 = 'to continue'
   ,@cLine14 = '%e'
   ,@nFunc = 839

-- 4644 = Short pick screen
DELETE rdt.RDTScn WHERE Scn = 4644 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4644, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CONFIRM OPTION?' -- WMS-11654
   ,@cLine03 = ''
   ,@cLine04 = '1 = SHORT'       -- WMS-11654
   ,@cLine05 = '2 = BAL PICK LATER' -- WMS-11654
   ,@cLine06 = '3 = CLOSE DROPID' -- (ChewKP01) 
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 839

-- 4645 = Skip LOC screen
DELETE rdt.RDTScn WHERE Scn = 4645 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4645, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'SKIP LOC?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 839
   
-- 4646 = Confirm LOC screen
DELETE rdt.RDTScn WHERE Scn = 4646 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4646, 'ENG'
   ,@cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'LOC: %10i02'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2"]}'
   ,@nFunc = 839

-- 4647 = Abort LOC screen
DELETE rdt.RDTScn WHERE Scn = 4647 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4647, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'ABORT PICKING?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine13 = '%20d15'    -- WMS-10241
   ,@cLine14 = '%e'
   ,@nFunc = 839

-- 4648 Carton ID screen
DELETE rdt.RDTScn WHERE Scn = 4648 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4648, 'ENG'
   ,@cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'Carton ID'
   ,@cLine03 = '%20d04'
   ,@cLine04 = '%20i05'
   ,@cLine13 = '%20d12' 
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3","4"],"3":["13"]}'
   ,@nFunc = 839

-- 4649 Data Capture screen
DELETE rdt.RDTScn WHERE Scn = 4649 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4649, 'ENG'
   ,@cLine01 = N'%20d01'
   ,@cLine02 = N'%20i02'
   ,@cLine03 = N'%20d03'
   ,@cLine04 = N'%20i04'
   ,@cLine05 = N'%20d05'
   ,@cLine06 = N'%20i06'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["5","6"]}'
   ,@nFunc = 839

-- 6417 = TO LOC screen
--FCR-540
DELETE rdt.RDTScn WHERE Scn = 6417 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6417, 'ENG'
   ,@cLine01 = 'TO LOC: '
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'TO LOC:'
   ,@cLine05 = '%20i02'
   ,@cLine06 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5"]}'
   ,@nFunc = 839

-- 6445 = SKU QTY screen
DELETE rdt.RDTScn WHERE Scn = 6445 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6445, 'ENG'
   ,@cLine01 = 'LOC: %10d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = '%20m14'
--    ,@cLine06 = 'SKU/UPC:'
   ,@cLine06 = 'SKU/UPC: %120iV_Barcode'  -- WMS-22147
   ,@cLine07 = '%20d08'    -- Lottablenn (WMS5057)
   ,@cLine08 = '%20d09'    -- Lottablenn (WMS5057)
   ,@cLine09 = '%20d10'    -- Lottablenn (WMS5057)
   ,@cLine10 = '%20d11'    -- Lottablenn (WMS5057)
   ,@cLine11 = 'PICK: %05i07 ACT: %06d06'
   ,@cLine12 = 'BAL QTY: %12d13'    -- WMS10357(yeekung01)
   ,@cLine13 = '%20d12'    -- WMS10357
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3","4"],"3":["5","6"],"4":["7","8","9","10"],"5":["11","12"],"6":["13"]}'
   ,@nFunc = 839

   -- 6524 = Short pick screen
   DELETE rdt.RDTScn WHERE Scn = 6524 AND Lang_Code = 'ENG'
   EXECUTE rdt.rdtAddScn 6524, 'ENG'
      ,@cLine01 = ''
      ,@cLine02 = 'CONFIRM OPTION?' -- WMS-11654
      ,@cLine03 = ''
      ,@cLine04 = '1 = SHORT'       -- WMS-11654
      ,@cLine05 = '2 = BAL PICK LATER' -- WMS-11654
      ,@cLine06 = '3 = CLOSE DROPID' -- (ChewKP01) 
      ,@cLine07 = '9 = Alternate PICK LOC' -- (ChewKP01)
      ,@cLine08 = 'OPTION: %01i01'
      ,@cLine14 = '%e'
      ,@nFunc = 839
