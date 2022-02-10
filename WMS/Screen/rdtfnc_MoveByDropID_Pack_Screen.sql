-- 2960 = From DropID screen
DELETE rdt.RDTScn WHERE Scn = 2960 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2960, 'ENG',
    @cLine01 = 'FROM DROPID: '
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'

-- 2961 = To DropID screen
DELETE rdt.RDTScn WHERE Scn = 2961 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2961, 'ENG',
    @cLine01 = 'FROM DROPID: '
   ,@cLine02 = '%20d01' -- DropID Extend Field to 20
   ,@cLine03 = ''
   ,@cLine04 = 'TO DROPID: '
   ,@cLine05 = '%20i02' -- DropID Extend Field to 20
   ,@cLine06 = ''
   ,@cLine07 = 'MERGE CARTON: %01i03'
   ,@cLine08 = ''
   ,@cLine09 = '1 = YES'
   ,@cLine10 = '2 = NO'
   ,@cLine14 = '%e'

-- 2962 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 2962 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2962, 'ENG',
    @cLine01 = 'TO DROPID: '
   ,@cLine02 = '%20d01' -- DropID Extend Field to 20
   ,@cLine03 = 'SKU: '
   ,@cLine04 = '%20i02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = ''
   ,@cLine08 = 'QTY MV : %05d05'
   ,@cLine09 = 'QTY BAL: %05d06'
   ,@cLine14 = '%e'

-- 2963 = New DropID screen
DELETE rdt.RDTScn WHERE Scn = 2963 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2963, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'Close carton?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i02'
   ,@cLine14 = '%e'
