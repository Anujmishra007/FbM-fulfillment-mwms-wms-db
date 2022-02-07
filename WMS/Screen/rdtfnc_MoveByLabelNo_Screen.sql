-- 3250 = From LabelNo screen
DELETE rdt.RDTScn WHERE Scn = 3250 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3250, 'ENG',
    @cLine01 = 'FROM LABELNO: '
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 533

-- 3251 = To LabelNo screen
DELETE rdt.RDTScn WHERE Scn = 3251 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3251, 'ENG',
    @cLine01 = 'FROM LABELNO: '
   ,@cLine02 = '%20d01' -- DropID Extend Field to 20
   ,@cLine03 = ''
   ,@cLine04 = 'TO LABELNO: '
   ,@cLine05 = '%20i02' -- DropID Extend Field to 20
   ,@cLine06 = ''
   ,@cLine07 = 'MERGE CARTON: %01i03'
   ,@cLine08 = ''
   ,@cLine09 = '1 = YES'
   ,@cLine10 = '2 = NO'
   ,@cLine14 = '%e'
   ,@nFunc = 533

-- 3252 = SKU, QTY screen
DELETE rdt.RDTScn WHERE Scn = 3252 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3252, 'ENG',
    @cLine01 = 'TO LABELNO: '
   ,@cLine02 = '%20d01' 
   ,@cLine03 = 'SKU: '
   ,@cLine04 = '%20i02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = ''
   ,@cLine08 = 'QTY    : %05i05'
   ,@cLine09 = 'QTY MV : %05d06'
   ,@cLine10 = 'QTY BAL: %05d07'
   ,@cLine14 = '%e'
   ,@nFunc = 533

-- 3253 = Message screen
DELETE rdt.RDTScn WHERE Scn = 3253 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3253, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'TO NEW LABELNO?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = 'CARTON TYPE:'
   ,@cLine11 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 533
