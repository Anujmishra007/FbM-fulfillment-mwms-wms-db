-- FCR-12622 - 6894
DELETE rdt.RDTScn WHERE Scn = 6894 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6894, 'ENG',
    @cLine01 = 'TOLOC:'
   ,@cLine02 = '%15d01'
   ,@cLine04 = '%15i02'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4"]}'
   ,@nFunc = 1628
