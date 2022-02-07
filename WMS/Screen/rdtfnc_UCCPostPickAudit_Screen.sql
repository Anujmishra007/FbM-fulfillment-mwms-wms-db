-- 3370 = LabelNo screen
DELETE rdt.RDTScn WHERE Scn = 3370 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3370, 'ENG',
    @cLine01 = 'UCC: '
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = 'LAST SCANNED ID:'
   ,@cLine05 = '%20d02'
   ,@cLine14 = '%e'
   ,@nFunc = 580
