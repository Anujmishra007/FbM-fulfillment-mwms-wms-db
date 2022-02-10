--rdtfnc_CycleCount_SKU_V7
--5430-5439
--5440-5449

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 635)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (635, 'ENG', 'FNC', 'CYCLE COUNT (SKU)', 'rdtfnc_CycleCount_SKU_V7', '8')
END

-- Scn = 5430. CCREF
DELETE rdt.RDTScn WHERE Scn = 5430 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5430, 'ENG', 
   @cLine01 = 'CCREF : %10i01',
   @cLine14 = '%e',
   @nFunc = 635

-- Scn = 5431. SHEET NO OR SELECTION CRITERIA
DELETE rdt.RDTScn WHERE Scn = 5431 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5431, 'ENG', 
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
   @nFunc = 635

-- Scn = 5432. COUNT NO
DELETE rdt.RDTScn WHERE Scn = 5432 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5432, 'ENG', 
   @cLine01 = 'CCREF : %10d01',
   @cLine02 = 'SHEET : %10d02',
   @cLine03 = 'CNT NO: %01i03',
   @cLine14 = '%e',
   @nFunc = 635
   
-- Scn = 5433. LOC
DELETE rdt.RDTScn WHERE Scn = 5433 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5433, 'ENG', 
   @cLine01 = 'CCREF : %10d01',
   @cLine02 = 'SHEET : %10d02',
   @cLine03 = 'CNT NO: %01d03',
   @cLine05 = 'LOC: %10d04',
   @cLine06 = 'LOC: %10i05',
   @cLine08 = 'TOTAL RECORDS: %05d06',   
   @cLine14 = '%e',
   @nFunc = 635
   
-- Scn = 5434. LOC - Option
DELETE rdt.RDTScn WHERE Scn = 5434 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5434, 'ENG', 
   @cLine01 = 'LOC not same as',
   @cLine02 = 'Suggestted LOC',
   @cLine04 = 'Continue CycleCount?',
   @cLine06 = 'OPT: %01i01',
   @cLine08 = '1=YES',
   @cLine09 = '2=NO',   
   @cLine14 = '%e',
   @nFunc = 635
   
-- Scn = 5435. Last LOC - Option
DELETE rdt.RDTScn WHERE Scn = 5435 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5435, 'ENG', 
   @cLine01 = 'Last LOC',
   @cLine03 = 'Add New LOC?',
   @cLine05 = 'OPT: %01i01',
   @cLine07 = '1=Yes',
   @cLine08 = '2=No',   
   @cLine14 = '%e',
   @nFunc = 635
   
-- Scn = 5436. Re-Count LOC - Option
DELETE rdt.RDTScn WHERE Scn = 5436 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5436, 'ENG', 
   @cLine01 = 'LOC has been counted',
   @cLine02 = 'Re-count?',
   @cLine04 = 'OPT: %01i01',
   @cLine06 = '1=Yes',
   @cLine07 = '2=No',   
   @cLine14 = '%e',
   @nFunc = 635

-- 5437 = ID screen
DELETE rdt.RDTScn WHERE Scn = 5437 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5437, 'ENG'
   ,@cLine01 = 'CCREF: %10d01'
   ,@cLine02 = 'SHEET: %10d02'
   ,@cLine03 = 'CNT NO: %01d03'
   ,@cLine04 = 'LOC: %10d04'
   ,@cLine05 = 'LOC: %10d05'
   ,@cLine06 = 'ID:'
   ,@cLine07 = '%18i06'
   ,@cLine14 = '%e',
   @nFunc = 635

-- 5438. SKU
DELETE rdt.RDTScn WHERE Scn = 5438 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5438, 'ENG', 
   @cLine01 = 'SKU: OPT:%01i14 %09d15',	-- OPTION: 1=ADD, 2=EDIT, ENTER=NEXT
   @cLine02 = '%20d01',                   -- Field 15: Current Counted QTY / Total Records from Screen 4. LOC Screen
   @cLine03 = '%20d02',
   @cLine04 = '%20d03',
   @cLine05 = '%10d04 %10d05',  -- For CS, QTY:99999 UOM    [C] -- (ChewKP01)
   @cLine06 = '%10d06 %10d07',  -- For EA, QTY:99999 UOM PPK:99 -- (ChewKP01)
   @cLine07 = 'ID%18d08',
   @cLine08 = '%20d09',    -- Lottablenn 
   @cLine09 = '%20d10',    -- Lottablenn 
   @cLine10 = '%20d11',    -- Lottablenn 
   @cLine11 = '%20d12',    -- Lottablenn 
   @cLine12 = '%20d13',    -- Lottablenn 
   @cLine13 = '1=ADD 2=EDT ENTR=NXT',
   @cLine14 = '%e',
   @nFunc = 635

-- 5439. SKU - Add SKU/UPC
DELETE rdt.RDTScn WHERE Scn = 5439 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5439, 'ENG', 
   @cLine01 = 'LOC: %10d01',
   @cLine02 = 'ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU/UPC:',
   @cLine05 = '%30i03',
   @cLine14 = '%e',
   @nFunc = 635

-- 5440. SKU - Add QTY
DELETE rdt.RDTScn WHERE Scn = 5440 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5440, 'ENG', 
   @cLine01 = 'LOC: %10d01',
   @cLine02 = 'ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU/UPC:',
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = '%20d05',
   @cLine08 = 'Qty', -- (ChewKP01)
   @cLine09 = '%10i06 %03d07',    -- For CS, QTY:99999 UOM -- (ChewKP01)
   @cLine10 = '%10i08 %10d09',    -- For EA, QTY:99999 UOM PPK:99 -- (ChewKP01)
   @cLine14 = '%e',
   @nFunc = 635

-- 5441. SKU - Add LOTTABLE01..05
DELETE rdt.RDTScn WHERE Scn = 5441 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5441, 'ENG', 
   @cLine01 = '%20d01',   -- Lot label 01
   @cLine02 = '%60i02',   -- Lottable01      -- Extend to 60 chars
   @cLine03 = '%20d03',   -- Lot label 02
   @cLine04 = '%60i04',   -- Lottable02      -- Extend to 60 chars
   @cLine05 = '%20d05',   -- Lot label 03
   @cLine06 = '%60i06',   -- Lottable03      -- Extend to 60 chars
   @cLine07 = '%20d07',   -- Lot label 04
   @cLine08 = '%16i08',   -- Lottable04
   @cLine09 = '%20d09',   -- Lot label 05
   @cLine10 = '%16i10',   -- Lottable05
   @cLine14 = '%e',
   @nFunc = 635

-- 5442. SKU - Edit QTY
DELETE rdt.RDTScn WHERE Scn = 5442 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5442, 'ENG', 
   @cLine01 = 'SKU:',
   @cLine02 = '%20d01',
   @cLine03 = '%20d02',
   @cLine04 = '%20d03',
   @cLine05 = '%10i04 %10d05',    -- For CS, QTY:99999 UOM    [ ]  -- (ChewKP01)
   @cLine06 = '%10i06 %10d07',    -- For EA, QTY:99999 UOM PPK:99  -- (ChewKP01)
   @cLine07 = '',
   @cLine08 = '%20d09',    -- Lottablenn 
   @cLine09 = '%20d10',    -- Lottablenn 
   @cLine10 = '%20d11',    -- Lottablenn 
   @cLine11 = '%20d12',    -- Lottablenn 
   @cLine12 = '%20d13',    -- Lottablenn 
   @cLine14 = '%e',
   @nFunc = 635