-- Scn = 1500. ParentSKU
DELETE rdt.RDTScn WHERE Scn = 1500 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1500, 'ENG', 
   @cLine01 = 'PARENTSKU:',
--    @cLine02 = '%20i01',
   @cLine02 = '%18i01',
   @cLine07 = 'Leave Blank And', 
   @cLine08 = 'Press ENTER To ',
   @cLine09 = 'Assign System',
   @cLine10 = 'Generated PARENTSKU',
   @cLine14 = '%e'

-- Scn = 1501. ParentSKU, SKU
DELETE rdt.RDTScn WHERE Scn = 1501 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1501, 'ENG', 
   @cLine01 = 'PARENTSKU:',
--    @cLine02 = '%20d01',
   @cLine02 = '%18d01',
   @cLine03 = 'SKU/UPC: ',
   @cLine04 = '%20i02',
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine14 = '%e'

-- Scn = 1502. ParentSKU, SKU, QTY
DELETE rdt.RDTScn WHERE Scn = 1502 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1502, 'ENG', 
   @cLine01 = 'PARENTSKU:',
--    @cLine02 = '%20d01',
   @cLine02 = '%18d01',
   @cLine03 = 'SKU/UPC: ',
   @cLine04 = '%20d02',
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = 'QTY:',
   @cLine08 = '%05i05',
   @cLine14 = '%e'


-- Scn = 1503. ParentSKU, SKU, QTY, Option
DELETE rdt.RDTScn WHERE Scn = 1503 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1503, 'ENG', 
   @cLine01 = 'CHOOSE OPTION BELOW:',
   @cLine03 = '1 = Create Pack',
   @cLine04 = '2 = Cancel Creation',
   @cLine06 = 'OPTION: %01i01',
   @cLine14 = '%e'


-- -- Scn = 1504. Msg (Confirmation)
-- DELETE rdt.RDTScn WHERE Scn = 1504 AND Lang_Code = 'ENG'
-- EXECUTE rdt.rdtAddScn 1504, 'ENG', 
--    @cLine01 = 'BOM CONFIRMED',
--    @cLine03 = 'PARENTSKU:',
--    @cLine04 = '%20d01',
--    @cLine14 = '%e'

-- Scn = 1504. Msg InnerPack
DELETE rdt.RDTScn WHERE Scn = 1504 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1504, 'ENG', 
   @cLine01 = 'HOW MANY PREPACK ',
   @cLine02 = 'PER INNER? ',
   @cLine05 = '%05i01',
   @cLine10 = 'Anymore Packs? %01i02',
   @cLine12 = '(1 = Yes, 2 = No)' ,
   @cLine14 = '%e'

-- Scn = 1505. Msg Case
DELETE rdt.RDTScn WHERE Scn = 1505 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1505, 'ENG', 
   @cLine01 = 'HOW MANY INNER ',
   @cLine02 = 'PER CASE? ',
   @cLine05 = '%05i01',
   @cLine10 = 'Anymore Packs? %01i02',
   @cLine12 = '(1 = Yes, 2 = No)' ,
   @cLine14 = '%e'

-- Scn = 1506. Msg Shipper
DELETE rdt.RDTScn WHERE Scn = 1506 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1506, 'ENG', 
   @cLine01 = 'HOW MANY CASE ',
   @cLine02 = 'PER SHIPPER? ',
   @cLine05 = '%05i01',
   @cLine10 = 'Anymore Packs? %01i02',
   @cLine12 = '(1 = Yes, 2 = No)' ,
   @cLine14 = '%e'

-- Scn = 1507. Msg Pallet
DELETE rdt.RDTScn WHERE Scn = 1507 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1507, 'ENG', 
   @cLine01 = 'HOW MANY SHIPPER ',
   @cLine02 = 'PER MASTER? ',
   @cLine05 = '%05i01',
   @cLine14 = '%e'
   
-- Scn = 1508. Print Label
DELETE rdt.RDTScn WHERE Scn = 1508 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1508, 'ENG', 
	 @cLine01 = 'PRINT LABEL',
    @cLine03 = 'PARENTSKU:',
--     @cLine04 = '%20d01',
    @cLine04 = '%18d01',
	 @cLine05 = 'NO OF LABEL:',
	 @cLine06 = '%06i02',
	 @cLine14 = '%e'
   
-- SOS#151310   
-- Scn = 1510. Length, Width, Height, Weight
DELETE rdt.RDTScn WHERE Scn = 1510 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1510, 'ENG', 
	 @cLine01 = 'DIMENSION & WEIGHT',
    @cLine03 = 'LEN: %05i01',
    @cLine04 = 'WDT: %05i02',
	 @cLine05 = 'HGT: %05i03',
	 @cLine07 = 'WGT: %05i04',
	 @cLine14 = '%e'

-- SOS175733
-- Scn = 1511. ParentSKU, SKU, QTY, Option
DELETE rdt.RDTScn WHERE Scn = 1511 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1511, 'ENG',
    @cLine01 = 'CHOOSE OPTION BELOW:'
   ,@cLine03 = '1 = Create Pack'
   ,@cLine04 = '9 = Cancel Creation'
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
