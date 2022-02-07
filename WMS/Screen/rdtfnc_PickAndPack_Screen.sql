-- 2740 = OREDRKEY screen
DELETE rdt.RDTScn WHERE Scn = 2740 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2740, 'ENG',
    @cLine01 = 'LOADKEY:'  -- SOS280603
   ,@cLine02 = '%10i01'
   ,@cLine04 = 'ORDERKEY:'
   ,@cLine05 = '%10i02'
   ,@cLine14 = '%e'
 
-- 2741 = DROP ID screen
DELETE rdt.RDTScn WHERE Scn = 2741 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2741, 'ENG',
    @cLine01 = 'LOADKEY:  %10d05'   -- SOS280603
   ,@cLine02 = 'ORDERKEY: %10d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = 'CUST: %14d03'
   ,@cLine06 = 'SCAN CARTON ID'
   ,@cLine07 = 'DROP ID:'
   ,@cLine08 = '%20i04'    -- extend to 20 char (james01)
   ,@cLine14 = '%e'
 
-- 2742 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 2742 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2742, 'ENG',
    @cLine01 = 'DROP ID:'  -- extend to 20 char (james01)
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'SKU:'
   ,@cLine04 = '%32i02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = 'LOADKEY:  %10d11'
   ,@cLine08 = 'ORDERKEY: %10d05'
   ,@cLine09 = '%20d06'
   ,@cLine10 = 'TTL QTY: %11d07'
   ,@cLine11 = 'SKU QTY: %11d08'
   ,@cLine12 = 'SKU CNT: %11d09'
   ,@cLine13 = 'ID  QTY: %11d10'
   ,@cLine14 = '%e'

-- 2743 = SCAN ADCODE screen
DELETE rdt.RDTScn WHERE Scn = 2743 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2743, 'ENG',
    @cLine01 = 'SKU/UPC:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'DESC:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = 'ADCode:'
   ,@cLine08 = '%18i05'
   ,@cLine10 = 'SCAN: %11d06'
   ,@cLine14 = '%e'

-- 2744 = PICK COMPLETED screen
DELETE rdt.RDTScn WHERE Scn = 2744 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2744, 'ENG',
    @cLine01 = 'PICKING COMPLETED'
   ,@cLine03 = 'QTY PICKED: %05d01'
   ,@cLine04 = 'SKU COUNT: %05d02'
   ,@cLine14 = '%e'

-- 2745 = Cartontype screen
DELETE rdt.RDTScn WHERE Scn = 2745 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2745, 'ENG'
   ,@cLine01 = N'CARTON: %10i01'
   ,@cLine02 = N''
   ,@cLine03 = N'WEIGHT: %10i02'
   ,@cLine04 = N''
   ,@cLine05 = N'CUBE:   %10i03'
   ,@cLine06 = N''
   ,@cLine07 = N'REF NO:'
   ,@cLine08 = N'%20i04'
   ,@cLine14 = N'%e'
 
