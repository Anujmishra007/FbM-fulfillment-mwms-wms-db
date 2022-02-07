-- 2090  = Scan-in the Pickslipno screen
DELETE rdt.RDTScn WHERE Scn = 2090 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2090, 'ENG',
    @cLine01 = 'PICKSLIP:'
   ,@cLine02 = '%10i01'
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'
 
-- 2091 = Scan-in the STOR screen
DELETE rdt.RDTScn WHERE Scn = 2091 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2091, 'ENG',
    @cLine01 = 'PICKSLIP:' 
   ,@cLine02 = '%10d01'
   ,@cLine03 = 'STOR:'
   ,@cLine04 = '%15i02'
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'

-- 2092 = Scan-in the SKU screen
DELETE rdt.RDTScn WHERE Scn = 2092 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2092, 'ENG',
    @cLine01 = 'PICKSLIP:' 
   ,@cLine02 = '%10d01'
   ,@cLine03 = 'STOR:'
   ,@cLine04 = '%15d02'
   ,@cLine05 = 'SKU:'
   ,@cLine06 = '%20i03'
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'

-- 2093 = Key-in the ACT QTY picked in its corresponding UOM column screen
DELETE rdt.RDTScn WHERE Scn = 2093 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2093, 'ENG',
    @cLine01 = 'STOR: %15d01' 
   ,@cLine02 = 'SKU:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '1 %18d05'
   ,@cLine07 = '2 %18d06'
   ,@cLine08 = '3 %18d07'
   ,@cLine09 = '4 %16d08'
   ,@cLine10 = '1:%05d09  %05d10 %05d11'
   ,@cLine11 = 'BAL QTY: %05d12 %05d13'
   ,@cLine12 = 'ACT QTY: %05i14 %05i15'
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'

-- 2094 = Scan-in the Drop ID screen
DELETE rdt.RDTScn WHERE Scn = 2094 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2094, 'ENG',
    @cLine01 = 'STOR: %15d01' 
   ,@cLine02 = 'SKU:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = ''
   ,@cLine07 = '1:%05d05  %05d06 %05d07'
   ,@cLine08 = 'BAL QTY: %05d08 %05d09'
   ,@cLine09 = 'ACT QTY: %05d10 %05d11'
   ,@cLine10 = 'DROPID:'
   ,@cLine11 = '%18i12'
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'

-- 2095 = Enter Option screen
DELETE rdt.RDTScn WHERE Scn = 2095 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2095, 'ENG',
    @cLine01 = 'FINISH BUILD DROPID?' 
   ,@cLine02 = ''
   ,@cLine03 = 'BAL QTY: %05d01'
   ,@cLine04 = 'ACT QTY: %05d02'
   ,@cLine05 = ''
   ,@cLine06 = '1=YES'
   ,@cLine07 = '2=NO'
   ,@cLine08 = ''
   ,@cLine09 = 'OPTION: %01i03'
   ,@cLine14 = '%e'

