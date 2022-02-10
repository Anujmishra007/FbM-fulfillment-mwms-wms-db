-- 3010 = PickSlipNo screen
DELETE rdt.RDTScn WHERE Scn = 3010 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3010, 'ENG',
    @cLine01 = 'Serial No Reset'
   ,@cLine02 = ''
   ,@cLine03 = 'Pick Slip #:'
   ,@cLine05 = '%10i01'
   ,@cLine14 = '%e'

-- 3011 = SKU/UPC screen
DELETE rdt.RDTScn WHERE Scn = 3011 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3011, 'ENG',
    @cLine01 = 'Serial No Reset'
   ,@cLine02 = ''
   ,@cLine03 = 'Pick Slip #:'
   ,@cLine04 = '%10d01'
   ,@cLine06 = 'SKU/UPC:'
   ,@cLine07 = '%20i02'
   ,@cLine14 = '%e'

-- 3012 = Option screen
DELETE rdt.RDTScn WHERE Scn = 3012 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3012, 'ENG',
    @cLine01 = 'PSNO: %10d01'
   ,@cLine02 = 'SKU:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = ''
   ,@cLine07 = 'CONFIRM RESET?'
   ,@cLine08 = ''
   ,@cLine09 = '1=YES'
   ,@cLine10 = '2=NO'
   ,@cLine11 = ''
   ,@cLine12 = 'OPTION: %01i05'
   ,@cLine13 = ''
   ,@cLine14 = '%e'

UPDATE RDT.RDTSCN SET FUNC = 874 WHERE SCN BETWEEN 3010 AND 3019