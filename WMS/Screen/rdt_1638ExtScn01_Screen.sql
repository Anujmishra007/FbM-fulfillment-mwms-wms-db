-- FCR-8110
DELETE rdt.RDTScn WHERE Scn = 6678 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6678, 'ENG',
    @cLine01 = 'PalletKey: '
   ,@cLine02 = '%30d01'
   ,@cLine04 = 'Order Tracking No:'
   ,@cLine05 = '%40i02'
   ,@cLine06 = 'OR'
   ,@cLine07 = 'Extern Order Key:'
   ,@cLine08 = '%50i03'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5","6","7","8"]}'
   ,@nFunc = 1638