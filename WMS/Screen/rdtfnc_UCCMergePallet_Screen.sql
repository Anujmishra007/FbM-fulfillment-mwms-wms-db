-- 3180 = From DropID screen
DELETE rdt.RDTScn WHERE Scn = 3180 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3180, 'ENG',
    @cLine01 = 'FROM ID: '
   ,@cLine02 = '%18i01'
   ,@cLine14 = '%e'
   ,@nFunc = 528
   
-- 3181 = To ID screen
DELETE rdt.RDTScn WHERE Scn = 3181 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3181, 'ENG',
    @cLine01 = 'FROM ID: '
   ,@cLine02 = '%18d01'
   ,@cLine03 = ''
   ,@cLine04 = 'TO ID: '
   ,@cLine05 = '%18i02'
   ,@cLine06 = ''
   ,@cLine07 = 'MERGE PALLET: %01i03'
   ,@cLine08 = ''
   ,@cLine09 = '1 = YES'
   ,@cLine10 = '2 = NO'
   ,@cLine14 = '%e'
   ,@nFunc = 528

-- 3182 = ChildID screen
DELETE rdt.RDTScn WHERE Scn = 3182 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3182, 'ENG',
    @cLine01 = 'TO ID: '
   ,@cLine02 = '%18d01'
   ,@cLine03 = ''
   ,@cLine04 = 'UCC: '
   ,@cLine05 = '%20i02'
   ,@cLine06 = ''
   ,@cLine07 = 'SCANNED: %05d03'
   ,@cLine14 = '%e'
   ,@nFunc = 528

-- 3183 = Putaway pallet screen
DELETE rdt.RDTScn WHERE Scn = 3183 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3183, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'PUTAWAY PALLET?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine08 = ''
   ,@cLine09 = 'UCC ON ID: %02i02'
   ,@cLine14 = '%e'
   ,@nFunc = 528
