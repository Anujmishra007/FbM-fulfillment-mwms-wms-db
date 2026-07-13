-- Screen 1
-- Scn = 660. CCREF
DELETE rdt.RDTScn WHERE Scn = 660 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 660, 'ENG', 
   @cLine01 = 'CCREF : %10i01',
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1"]}',
   @nFunc = 610

-- Screen 2
-- Scn = 661. SHEET NO OR SELECTION CRITERIA
DELETE rdt.RDTScn WHERE Scn = 661 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 661, 'ENG', 
   @cLine01 = 'CCREF : %10d01',
   @cLine02 = 'SHEET : %10i02',
   @cLine03 = '     OR',
   @cLine04 = 'ZONE  : %10i03',
   @cLine05 = '      : %10i04',
   @cLine06 = '      : %10i05',
   @cLine07 = '      : %10i06',
   @cLine08 = '      : %10i07',
   @cLine10 = 'AISLE : %10i08',
   @cLine11 = 'LEVEL : %10i09',
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1","2"],"2":["4","5","6","7","8"],"3":["10"],"4":["11"]}', 
   @nFunc = 610

-- Screen 3   
-- Scn = 662. COUNT NO
DELETE rdt.RDTScn WHERE Scn = 662 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 662, 'ENG', 
   @cLine01 = 'CCREF : %10d01',
   @cLine02 = 'SHEET : %10d02',
   @cLine03 = 'CNT NO: %01i03',
   @cLine13 = '%20d15',    -- WMS-11865 Extendedinfosp
   @cLine14 = '%e', 
   @cWebGroup = '{"1":["1","2"],"2":["3"],"3":["13"]}',
   @nFunc = 610

-- Screen 4   
-- Scn = 663. LOC
DELETE rdt.RDTScn WHERE Scn = 663 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 663, 'ENG', 
   @cLine01 = 'CCREF : %10d01',
   @cLine02 = 'SHEET : %10d02',
   @cLine03 = 'CNT NO: %01d03',
   @cLine05 = 'LOC: %10d04',
   @cLine06 = 'LOC: %10i05',
   @cLine08 = 'TOTAL RECORDS: %05d06',   
   @cLine14 = '%e', 
   @cWebGroup = '{"1":["1","2","3"],"2":["5","6"],"3":["8"]}', 
   @nFunc = 610

-- Screen 4a
-- Scn = 664. LOC - Option
DELETE rdt.RDTScn WHERE Scn = 664 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 664, 'ENG', 
   @cLine01 = 'LOC not same as',
   @cLine02 = 'Suggestted LOC',
   @cLine04 = 'Continue CycleCount?',
   @cLine06 = 'OPT: %01i01',
   @cLine08 = '1=YES',
   @cLine09 = '2=NO',   
   @cLine14 = '%e'
   
-- Screen 4b
-- Scn = 665. Last LOC - Option
DELETE rdt.RDTScn WHERE Scn = 665 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 665, 'ENG', 
   @cLine01 = 'Last LOC',
   @cLine03 = 'Add New LOC?',
   @cLine05 = 'OPT: %01i01',
   @cLine07 = '1=Yes',
   @cLine08 = '2=No',   
   @cLine14 = '%e'
   
-- Screen 4c
-- Scn = 666. Re-Count LOC - Option
DELETE rdt.RDTScn WHERE Scn = 666 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 666, 'ENG', 
   @cLine01 = 'LOC has been counted',
   @cLine02 = 'Re-count?',
   @cLine04 = 'OPT: %01i01',
   @cLine06 = '1=Yes',
   @cLine07 = '2=No',   
   @cLine14 = '%e'

-- Screen 5
-- 667 = ID screen
DELETE rdt.RDTScn WHERE Scn = 667 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 667, 'ENG'
   ,@cLine01 = 'CCREF: %10d01'
   ,@cLine02 = 'SHEET: %10d02'
   ,@cLine03 = 'CNT NO: %01d03'
   ,@cLine04 = 'LOC: %10d04'
   ,@cLine05 = 'LOC: %10d05'
   ,@cLine07 = 'OPT: %01i06'
   ,@cLine08 = 'ID:'
   ,@cLine09 = '%20i07' -- Extend to 20 chars (WMS-9681)
   ,@cLine10 = '1=UCC'
   ,@cLine11 = '2=SKU/UPC'
   ,@cLine12 = '3=SINGLE SCAN'
   ,@cLine13 = '4=ID/CARTON'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3"],"2":["5","6"],"3":["7"],"4":["8","9"],"5":["10","11","12","13"]}'
   ,@nFunc = 610
   
-- Screen 6
-- 668. UCC
DELETE rdt.RDTScn WHERE Scn = 668 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 668, 'ENG', 
   @cLine01 = 'UCC:           %05d11',			-- No. of Ctn scanned / Total Ctn per LOC
   @cLine02 = '%200iV_Barcode',  -- WMS-23451 Change to use V_Barcode
   @cLine03 = 'SKU:      QTY: %05d05',
   @cLine04 = '%20d02',
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = 'LOTTABLE 1/2/3/4/5:',
   @cLine08 = '1 %18d06',
   @cLine09 = '2 %18d07',
   @cLine10 = '3 %18d08',
   @cLine11 = '4 %18d09',
   @cLine12 = '5 %18d10',   
   @cLine13 = 'OPT: %01i12        1=ADD',
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1","2"],"2":["3","4","5","6"],"3":["7","8","9","10","11","12"],"4":["13"]}', 
   @nFunc = 610

-- Screen 7
-- 669. UCC - Add UCC
DELETE rdt.RDTScn WHERE Scn = 669 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 669, 'ENG', 
   @cLine01 = 'LOC: %10d01',
   @cLine02 = 'ID:',
   @cLine03 = '%18d02',
   @cLine05 = 'UCC:',
   @cLine06 = '%20i03',      
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1"],"2":["2","3"],"3":["5","6"]}', 
   @nFunc = 610

-- Screen 8
-- 670. UCC - Add SKU & QTY
DELETE rdt.RDTScn WHERE Scn = 670 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 670, 'ENG', 
   @cLine01 = 'LOC: %10d01',
   @cLine02 = 'ID:',
   @cLine03 = '%18d02',
   @cLine05 = 'UCC:',
   @cLine06 = '%20d03',
   @cLine07 = 'SKU:      QTY: %05d07',
   @cLine08 = '%20d04',
   @cLine09 = '%20d05',
   @cLine10 = '%20d06', 
--   ,@cLine11 = '%20i08' REMARK HERE BECAUSE DUMMY FIELD
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1"],"2":["2","3"],"3":["5","6"],"4":["7","8","9","10"]}', 
   @nFunc = 610
   
-- Screen 9    
-- 671. UCC - Add LOTTABLE01..05
DELETE rdt.RDTScn WHERE Scn = 671 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 671, 'ENG', 
    @cLine01 = '%20d01'
   ,@cLine02 = '%18i02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%18i04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%18i06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%16i08'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%16i10'
   ,@cLine14 = '%e'   
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["5","6"],"4":["7","8"],"5":["9","10"]}'
   ,@nFunc = 610
   
-- Screen 10  
-- 672. SKU
DELETE rdt.RDTScn WHERE Scn = 672 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 672, 'ENG', 
   @cLine01 = 'SKU: OPT:%01i14 %09d15',	-- OPTION: 1=ADD, 2=EDIT, ENTER=NEXT
   @cLine02 = '%20d01',                   -- Field 15: Current Counted QTY / Total Records from Screen 4. LOC Screen
   @cLine03 = '%20d02',
   @cLine04 = '%20d03',
   @cLine05 = '%10d04 %10d05',  -- For CS, QTY:99999 UOM    [C] -- (ChewKP01)
   @cLine06 = '%10d06 %10d07',  -- For EA, QTY:99999 UOM PPK:99 -- (ChewKP01)
   @cLine07 = 'ID%18d08',
   @cLine08 = '1 %18d09',
   @cLine09 = '2 %18d10',
   @cLine10 = '3 %18d11',
   @cLine11 = '4 %18d12',
   @cLine12 = '5 %18d13',
   @cLine13 = '1=ADD 2=EDT ENTR=NXT',
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1","2","3","4"],"2":["5","6"],"3":["7"],"4":["8","9","10","11","12"],"5":["13"]}',
   @nFunc = 610

-- Screen 11
-- 673. SKU - Add SKU/UPC
DELETE rdt.RDTScn WHERE Scn = 673 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 673, 'ENG', 
   @cLine01 = 'LOC: %10d01',
   @cLine02 = 'ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU/UPC:',
   @cLine05 = '%30i03',
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1"],"2":["2","3"],"3":["4","5"]}',
   @nFunc = 610

-- Screen 12   
-- 674. SKU - Add QTY
DELETE rdt.RDTScn WHERE Scn = 674 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 674, 'ENG', 
   @cLine01 = 'LOC: %10d01',
   @cLine02 = 'ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU/UPC:',
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = '%20d05',
   @cLine08 = 'Qty', -- (ChewKP01)
   @cLine09 = '%10i06^DT:INT %03d07',    -- For CS, QTY:99999 UOM -- (ChewKP01)
   @cLine10 = '%10i08^DT:INT %10d09',    -- For EA, QTY:99999 UOM PPK:99 -- (ChewKP01)
   @cLine13 = '%20d15', -- ExtendedInfo (WMS-11865)
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1"],"2":["2","3"],"3":["4","5","6","7"],"4":["8","9","10"],"5":["13"]}', 
   @nFunc = 610
   
-- Screen 13   
-- 675. SKU - Add LOTTABLE01..05
DELETE rdt.RDTScn WHERE Scn = 675 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 675, 'ENG', 
    @cLine01 = '%20d01'
   ,@cLine02 = '%18i02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%18i04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%18i06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%16i08'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%16i10'
   ,@cLine14 = '%e'   
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["5","6"],"4":["7","8"],"5":["9","10"]}'
   ,@nFunc = 610
   
-- Screen 14  
-- 676. SKU - Edit QTY
DELETE rdt.RDTScn WHERE Scn = 676 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 676, 'ENG', 
   @cLine01 = 'SKU:',
   @cLine02 = '%20d01',
   @cLine03 = '%20d02',
   @cLine04 = '%20d03',
   @cLine05 = '%10i04^DT:INT %10d05',    -- For CS, QTY:99999 UOM    [ ]  -- (ChewKP01)
   @cLine06 = '%10i06^DT:INT %10d07',    -- For EA, QTY:99999 UOM PPK:99  -- (ChewKP01)
   @cLine07 = 'LOTTABLE 1/2/3/4/5:',
   @cLine08 = '1 %18d08',
   @cLine09 = '2 %18d09',
   @cLine10 = '3 %18d10',
   @cLine11 = '4 %18d11',
   @cLine12 = '5 %18d12',
   @cLine14 = '%e', 
   @cWebGroup = '{"1":["1","2","3","4"],"2":["5","6"],"3":["7","8","9","10","11","12"]}', 
   @nFunc = 610
   
-- Screen 15
-- 677. SINGLE SKU - Sku Scan
DELETE rdt.RDTScn WHERE Scn = 677 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 677, 'ENG', 
   @cLine01 = 'LOC: %10d01',
   @cLine02 = 'ID:',
   @cLine03 = '%18d02',
   @cLine05 = 'SKU/UPC:',
   @cLine06 = '%200iV_Barcode',
   @cLine14 = '%e', 
   @cWebGroup = '{"1":["1"],"2":["2","3"],"3":["5","6"]}', 
   @nFunc = 610
   
-- Screen 16
-- 678. SINGLE SKU - Add LOTTABLE01..05
DELETE rdt.RDTScn WHERE Scn = 678 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 678, 'ENG', 
    @cLine01 = '%20d01'
   ,@cLine02 = '%18i02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%18i04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%18i06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%16i08'
--   ,@cLine09 = '%20d09'  -- no need lootable05 when do cycle count
--   ,@cLine10 = '%16i10'  -- no need lootable05 when do cycle count
   ,@cLine14 = '%e'  
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["5","6"],"4":["7","8"]}'
   ,@nFunc = 610
   
-- Screen 17
-- 679. SINGLE SKU - Increase QTY
DELETE rdt.RDTScn WHERE Scn = 679 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 679, 'ENG', 
   @cLine01 = 'LOC: %10d01',
   @cLine02 = 'ID:',
   @cLine03 = '%18d02',
   @cLine05 = 'SKU/UPC:',
   @cLine06 = '%200iV_Barcode',
   @cLine07 = 'SKU:',
   @cLine08 = '%20d04',
   @cLine09 = '%20d05',
   @cLine10 = '%20d06',
   @cLine12 = 'SKU QTY: %05d07 %03d08',  -- QTY:99999 UOM
   @cLine13 = 'ID  QTY: %05d09 %03d10',
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1"],"2":["2","3"],"3":["5","6"],"4":["7","8","9","10"],"5":["12","13"]}', 
   @nFunc = 610
   
-- Change screen no from 680 to 700
-- because 680 crashed with UCC outbound verify (james01)
-- Screen 18
-- 700. SINGLE SKU - Option
DELETE rdt.RDTScn WHERE Scn = 700 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 700, 'ENG', 
   @cLine01 = 'SKU Changed',
   @cLine03 = '1=New Lottables',
   @cLine04 = '2=Keep Lottables',
   @cLine06 = 'OPT: %01i01',
   @cLine14 = '%e'     

-- Screen 19
-- 700. SINGLE SKU - Lottables Option
DELETE rdt.RDTScn WHERE Scn = 701 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 701, 'ENG', 
   @cLine01 = '1=New Lottables',
   @cLine02 = '2=Keep Lottables',
   @cLine03 = '3=End Count',
   @cLine05 = 'OPT: %01i01',
   @cLine14 = '%e'     

-- Screen 20
-- 701. SINGLE SKU - Back to SKU Option
DELETE rdt.RDTScn WHERE Scn = 702 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 702, 'ENG', 
   @cLine01 = '1=Back to SKU',
   @cLine02 = '2=End Count',
   @cLine04 = 'OPT: %01i01',
   @cLine14 = '%e'     

-- 3260. Carton Count 
DELETE rdt.RDTScn WHERE Scn = 3260 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3260, 'ENG', 
   @cLine01 = 'ID'
  ,@cLine02 = '%18d01'
  ,@cLine03 = 'Carton Count %05i02'
  ,@cLine05 = 'PUT 0 FOR EMPTY LOC'
  ,@cLine14 = '%e'     

-- 3261 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3261 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3261, 'ENG'
   ,@cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'ID:'
   ,@cLine03 = '%18d02'
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%30i03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = '%20d06'
   ,@cLine10 = '%10d07 %10d08'
   ,@cLine11 = '%10d09 %10d10'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3"],"3":["4","5","7","8","9"],"5":["10","11"]}'
   ,@nFunc = 610
   
-- 3262 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3262 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3262, 'ENG'
   ,@cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'ID:'
   ,@cLine03 = '%18d02'
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = 'Qty'
   ,@cLine09 = '%10i06^DT:INT %03d07'
   ,@cLine10 = '%10i08^DT:INT %10d09'
   ,@cLine13 = '%20d15' -- ExtendedInfo (WMS-11865)
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3"],"3":["4","5","6","7"],"4":["8","9"],"5":["13"]}'
   ,@nFunc = 610

-- 3263 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3263 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3263, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = '%18i02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%18i04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%18i06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%16i08'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%16i10'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["5","6"],"4":["7","8"],"5":["9","10"]}'
   ,@nFunc = 610
   
-- 3264 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3264 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3264, 'ENG'
   ,@cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'SKU:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20i03'
   ,@cLine05 = 'L1/L2/L3/L4'
   ,@cLine06 = '1:%18d04'
   ,@cLine07 = '%18i05'
   ,@cLine08 = '2:%18d06'
   ,@cLine09 = '%18i07'
   ,@cLine10 = '3:%18d08'
   ,@cLine11 = '%18i09'
   ,@cLine12 = '4:%18d10'
   ,@cLine13 = '%20i11'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3","4"],"3":["6","7"],"4":["8","9"],"5":["10","11"],"6":["12","13"]}'
   ,@nFunc = 610

-- WMS-22616
-- 703 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 703 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 703, 'ENG'
   ,@cLine01 = 'UCC:'
   ,@cLine02 = '%20d01'   
   ,@cLine03 = 'SKU:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = 'Qty: %05i05'
   ,@cLine14 = '%e'   