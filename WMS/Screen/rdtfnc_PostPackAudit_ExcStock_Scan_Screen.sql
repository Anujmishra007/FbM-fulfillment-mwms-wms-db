
-- Excess Stocks Scanning (for TOTE only)

-- Screen 1
-- 2040 = WorkStation, Batch
DELETE rdt.RDTScn WHERE Scn = 2040 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2040, 'ENG', 
   @cLine01 = 'Excess Stocks',
   @cLine02 = '',
   @cLine03 = 'WORKSTATION:',
   @cLine04 = '%15i01*', 
   @cLine05 = '',
   @cLine06 = 'BATCH:',
   @cLine07 = '%15i02',
   @cLine14 = '%e'

-- Screen 2
-- 2041 = Batch, SKU
DELETE rdt.RDTScn WHERE Scn = 2041 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2041, 'ENG', 
   @cLine01 = 'Excess Stocks',
   @cLine02 = '',
   @cLine03 = 'BATCH:',
   @cLine04 = '%15d01',
   @cLine05 = '',
   @cLine06 = 'SKU/UPC:',
   @cLine07 = '%15i02',
   @cLine14 = '%e'

-- Screen 3
-- 2042 = Batch, SKU, SKU DESC, STORE, BAL QTY, PICK QTY
DELETE rdt.RDTScn WHERE Scn = 2042 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2042, 'ENG', 
   @cLine01 = 'BATCH:',
   @cLine02 = '%15d01',
   @cLine03 = '',
   @cLine04 = 'SKU/UPC:',
   @cLine05 = '%15d02',
   @cLine06 = 'DESCR:',
   @cLine07 = '%20d03',
   @cLine08 = '%20d04',
   @cLine09 = 'STORE:',
   @cLine10 = '%15d05',
   @cLine11 = '',
   @cLine12 = 'BAL QTY: %05d06',
   @cLine13 = 'PCK QTY: %05i07',
   @cLine14 = '%e'

-- Screen 4
-- 2043 = STORE, PICK QTY, TOTE#
DELETE rdt.RDTScn WHERE Scn = 2043 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2043, 'ENG', 
   @cLine01 = 'STORE:',
   @cLine02 = '%15d01',
   @cLine03 = '',
   @cLine04 = 'PCK QTY: %05d02',
   @cLine05 = '',
   @cLine06 = 'TOTE#:',
   @cLine07 = '%18i03',
   @cLine14 = '%e'

-- Screen 5   
-- 2044 = TOTE#, REF NO 1..5
DELETE rdt.RDTScn WHERE Scn = 2044 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2044, 'ENG', 
   @cLine01 = 'TOTE#:',
   @cLine02 = '%18d01',
   @cLine03 = '',
   @cLine04 = 'REF NO:',
   @cLine05 = '1. %17i02',
   @cLine06 = '2. %17i03',
   @cLine07 = '3. %17i04',
   @cLine08 = '4. %17i05',
   @cLine09 = '5. %17i06',
   @cLine14 = '%e'

-- Screen 6
-- 2045 = REF NO 1..5, OPTION
DELETE rdt.RDTScn WHERE Scn = 2045 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2045, 'ENG', 
   @cLine01 = 'REF NO:',
   @cLine02 = '1. %17d01',
   @cLine03 = '2. %17d02',
   @cLine04 = '3. %17d03',
   @cLine05 = '4. %17d04',
   @cLine06 = '5. %17d05',
   @cLine07 = '',
   @cLine08 = 'Please Confirm',
   @cLine09 = '1 = YES',
   @cLine10 = '2 = NO',
   @cLine11 = '',
   @cLine12 = 'OPTION: %01i06',
   @cLine14 = '%e'
   
-- Screen 7   
-- 2046 = Successful Message
DELETE rdt.RDTScn WHERE Scn = 2046 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2046, 'ENG',    
   @cLine01 = 'ITEM Successfully',
   @cLine02 = 'Saved',
   @cLine03 = '',
   @cLine04 = '',
   @cLine05 = 'Press ENTER or',
   @cLine06 = 'ESC to continue',
   @cLine14 = '%e'