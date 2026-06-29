--rdtfnc_CycleCount_UCC_V7
--5410-5419
--5420-5429

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 634)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (634, 'ENG', 'FNC', 'CYCLE COUNT (UCC)', 'rdtfnc_CycleCount_UCC_V7', '8')
END

-- Scn = 5410. CCREF
DELETE rdt.RDTScn WHERE Scn = 5410 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5410, 'ENG', 
   @cLine01 = 'CCREF : %10i01',
   @cLine14 = '%e',
   @nFunc = 634

-- Scn = 5411. SHEET NO OR SELECTION CRITERIA
DELETE rdt.RDTScn WHERE Scn = 5411 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5411, 'ENG', 
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
   @nFunc = 634

-- Scn = 5412. COUNT NO
DELETE rdt.RDTScn WHERE Scn = 5412 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5412, 'ENG', 
   @cLine01 = 'CCREF : %10d01',
   @cLine02 = 'SHEET : %10d02',
   @cLine03 = 'CNT NO: %01i03',
   @cLine14 = '%e',
   @nFunc = 634
   
-- Scn = 5413. LOC
DELETE rdt.RDTScn WHERE Scn = 5413 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5413, 'ENG', 
   @cLine01 = 'CCREF : %10d01',
   @cLine02 = 'SHEET : %10d02',
   @cLine03 = 'CNT NO: %01d03',
   @cLine05 = 'LOC: %10d04',
   @cLine06 = 'LOC: %10i05',
   @cLine08 = 'TOTAL RECORDS: %05d06',   
   @cLine14 = '%e',
   @nFunc = 634
   
-- Scn = 5414. LOC - Option
DELETE rdt.RDTScn WHERE Scn = 5414 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5414, 'ENG', 
   @cLine01 = 'LOC not same as',
   @cLine02 = 'Suggestted LOC',
   @cLine04 = 'Continue CycleCount?',
   @cLine06 = 'OPT: %01i01',
   @cLine08 = '1=YES',
   @cLine09 = '2=NO',   
   @cLine14 = '%e',
   @nFunc = 634
   
-- Scn = 5415. Last LOC - Option
DELETE rdt.RDTScn WHERE Scn = 5415 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5415, 'ENG', 
   @cLine01 = 'Last LOC',
   @cLine03 = 'Add New LOC?',
   @cLine05 = 'OPT: %01i01',
   @cLine07 = '1=Yes',
   @cLine08 = '2=No',   
   @cLine14 = '%e',
   @nFunc = 634
   
-- Scn = 5416. Re-Count LOC - Option
DELETE rdt.RDTScn WHERE Scn = 5416 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5416, 'ENG', 
   @cLine01 = 'LOC has been counted',
   @cLine02 = 'Re-count?',
   @cLine04 = 'OPT: %01i01',
   @cLine06 = '1=Yes',
   @cLine07 = '2=No',   
   @cLine14 = '%e',
   @nFunc = 634

-- 5417 = ID screen
DELETE rdt.RDTScn WHERE Scn = 5417 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5417, 'ENG'
   ,@cLine01 = 'CCREF: %10d01'
   ,@cLine02 = 'SHEET: %10d02'
   ,@cLine03 = 'CNT NO: %01d03'
   ,@cLine04 = 'LOC: %10d04'
   ,@cLine05 = 'LOC: %10d05'
   ,@cLine06 = 'ID:'
   ,@cLine07 = '%18i06'
   ,@cLine14 = '%e',
    @nFunc = 634

-- 5418. UCC
DELETE rdt.RDTScn WHERE Scn = 5418 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5418, 'ENG', 
   @cLine01 = 'UCC:           %05d11',			-- No. of Ctn scanned / Total Ctn per LOC
   @cLine02 = '%20i01',
   @cLine03 = 'SKU:      QTY: %05d05',
   @cLine04 = '%20d02',
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = '',
   @cLine08 = '%20d06',    -- Lottablenn 
   @cLine09 = '%20d07',    -- Lottablenn 
   @cLine10 = '%20d08',    -- Lottablenn 
   @cLine11 = '%20d09',    -- Lottablenn 
   @cLine12 = '%20d10',    -- Lottablenn 
   @cLine13 = 'OPT: %01i12        1=ADD',
   @cLine14 = '%e',
   @nFunc = 634  

-- 5419. UCC - Add UCC
DELETE rdt.RDTScn WHERE Scn = 5419 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5419, 'ENG', 
   @cLine01 = 'LOC: %10d01',
   @cLine02 = 'ID:',
   @cLine03 = '%18d02',
   @cLine05 = 'UCC:',
   @cLine06 = '%20i03',      
   @cLine14 = '%e',
   @nFunc = 634       

-- 5420. UCC - Add SKU & QTY
DELETE rdt.RDTScn WHERE Scn = 5420 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5420, 'ENG', 
   @cLine01 = 'LOC: %10d01',
   @cLine02 = 'ID:',
   @cLine03 = '%18d02',
   @cLine05 = 'UCC:',
   @cLine06 = '%20d03',
   @cLine07 = 'SKU:      QTY: %05d07',
   @cLine08 = '%20d04',
   @cLine09 = '%20d05',
   @cLine10 = '%20d06', 
   @cLine14 = '%e',
   @nFunc = 634
    
-- 5421. UCC - Add LOTTABLES
DELETE rdt.RDTScn WHERE Scn = 5421 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5421, 'ENG', 
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
   @nFunc = 634

-- 5422. UCC
DELETE rdt.RDTScn WHERE Scn = 5422 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5422, 'ENG', 
   @cLine01 = 'Qty: %05i01',	
   @cLine14 = '%e',
   @nFunc = 634