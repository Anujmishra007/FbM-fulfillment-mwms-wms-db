--FCR-13167 Levis US PPA Packing - No Pre-Sort Flow
--New 5-screen process with VAS codes display

-- 814 = SC1: Scan Carton ID screen (reuse from rdtfnc_PostPickAudit_Screen.sql)

-- 6911 = SC2: SKU Scan with VAS display (main packing screen)
-- Layout per FCR-13167 requirement:
--   SKU info, then counters, then 4 VAS lines at bottom
DELETE rdt.RDTScn WHERE Scn = 6911 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6911, 'ENG',
    @cLine01 = 'SKU/UPC:%20i01 QTY:%03i02'  -- SKU/UPC input + QTY input (can be disabled via config)
   ,@cLine02 = '%20d03'              -- Scanned SKU
   ,@cLine03 = '%20d04'              -- STYLE / COLOR / SIZE
   ,@cLine04 = '%20d05'              -- SKU DESCRIPTION
   ,@cLine05 = ''                    -- separator
   ,@cLine06 = 'SKU CTD:%03d06  CTN/SKU:%05d07' -- SKU Counted + CTN SKU CKD/Total (concatenated)
   ,@cLine07 = 'TOTAL:%03d08  QTY CKD:%11d09'  -- SKU Total + QTY CKD/Total (concatenated)
   ,@cLine08 = '%20d10'              -- VAS1: Code + Description
   ,@cLine09 = '%20d11'              -- VAS2: Code + Description
   ,@cLine10 = '%20d12'              -- VAS3: Code + Description
   ,@cLine11 = '%20d13'              -- VAS4: Code + Description
   ,@cLine12 = '%20d14'              -- VAS5: Code + Description
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3","4"],"3":["6","7"],"4":["8","9","10","11","12"]}'
   ,@nFunc = 855

-- 6914 = SC5: Discrepancy screen (FCR-13167)
-- Display up to 5 SKUs per page, sorted by highest discrepancy first
-- Enter = next page (if more), ESC = options screen (6915)
-- d01=CARTON, d02=SKU1, d03=Cnt1/Exp1, d04=SKU2, d05=Cnt2/Exp2, ...
DELETE rdt.RDTScn WHERE Scn = 6914 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6914, 'ENG',
    @cLine01 = 'Error: Pack Incomplete'
   ,@cLine02 = 'CARTON: %20d01'
   ,@cLine03 = '%20d02  %11d03' -- SKU1 + Counted/Expected (combined in SQL)
   ,@cLine04 = '%20d04  %11d05' -- SKU2 + Counted/Expected (combined in SQL)
   ,@cLine05 = '%20d06  %11d07' -- SKU3 + Counted/Expected (combined in SQL)
   ,@cLine06 = '%20d08  %11d09' -- SKU4 + Counted/Expected (combined in SQL)
   ,@cLine07 = '%20d10  %11d11' -- SKU5 + Counted/Expected (combined in SQL)
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = '%12d12  ESC=OPTIONS' -- d12 = 'ENTER=MORE' if more pages, 'ENTER=BACK' if last page
   ,@cLine12 = ''
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4","5","6","7"]}'
   ,@nFunc = 855

-- 6915 = SC6: Discrepancy Options screen (FCR-13167)
-- Options: 1 = SEND TO QC PRINT LBL, 3 = CONTINUE PACKING
DELETE rdt.RDTScn WHERE Scn = 6915 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6915, 'ENG',
    @cLine01 = 'DISCREPANCY OPTIONS'
   ,@cLine02 = ''
   ,@cLine03 = 'CARTON: %20d01'
   ,@cLine04 = ''
   ,@cLine05 = '1 = SEND TO QC PRINT LBL'
   ,@cLine06 = '3 = CONTINUE PACKING'
   ,@cLine07 = ''
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = 'OPTION: %01i02'
   ,@cLine12 = ''
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["3"],"3":["5","6"],"4":["11"]}'
   ,@nFunc = 855

-- 6464 = Print Options with Automation label (reuse from rdtfnc_PostPickAudit_Screen.sql)
