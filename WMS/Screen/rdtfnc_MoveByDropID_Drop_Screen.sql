-- 3110 = From DropID screen
DELETE rdt.RDTScn WHERE Scn = 3110 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3110, 'ENG',
    @cLine01 = 'FROM DROPID: '
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 525
   
-- 3111 = To DropID screen
DELETE rdt.RDTScn WHERE Scn = 3111 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3111, 'ENG',
    @cLine01 = 'FROM DROPID: '
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'TO DROPID: '
   ,@cLine05 = '%20i02'
   ,@cLine06 = ''
   ,@cLine07 = 'MERGE PALLET: %01i03'
   ,@cLine08 = ''
   ,@cLine09 = '1 = YES'
   ,@cLine10 = '2 = NO'
   ,@cLine14 = '%e'
   ,@nFunc = 525

-- 3112 = ChildID screen
DELETE rdt.RDTScn WHERE Scn = 3112 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3112, 'ENG',
    @cLine01 = 'TO DROPID: '
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'CHILD ID: '
   ,@cLine05 = '%20i02'
   ,@cLine06 = ''
   ,@cLine07 = 'SCANNED: %05d03'
   ,@cLine14 = '%e'
   ,@nFunc = 525

-- 3113 = Option screen
DELETE rdt.RDTScn WHERE Scn = 3113 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3113, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'TO NEW DROPID?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 525
