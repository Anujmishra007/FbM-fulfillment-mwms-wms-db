-- FCR-6730
-- 6673 = Wave/Load/Order, Ship Ref Screen
DELETE rdt.RDTScn WHERE Scn = 6673 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6673, 'ENG',
    @cLine01 = 'WAVEKEY:  %10i01'
   ,@cLine02 = 'OR'
   ,@cLine04 = 'LOADKEY:  %10i02'
   ,@cLine05 = 'OR'
   ,@cLine07 = 'ORDERKEY: %10i03'
   ,@cLine08 = 'Ship Ref: %10i04'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3","4","5","6","7"],"2":["8"]}'
   ,@nFunc = 869

-- 6674 = Info screen
DELETE rdt.RDTScn WHERE Scn = 6674 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6674, 'ENG',
    @cLine01 = 'WAVEKEY: %10d01'
   ,@cLine02 = 'Ship Ref: %10d07'
   ,@cLine03 = 'LOADKEY: %10d02'
   ,@cLine04 = 'ORDERKEY: %10d03'
   ,@cLine05 = ''
   ,@cLine06 = 'ORDER COUNT: %05d04'
   ,@cLine07 = 'QTY PICK : %05d05'
   ,@cLine08 = 'QTY SHORT: %05d06'
   ,@cLine09 = ''
   ,@cLine10 = 'PRESS ENTER GO TO'
   ,@cLine11 = 'SHORT PICK CONFIRM'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3","4","5"],"2":["6","7","8","9"],"3":["10","11"]}'
   ,@nFunc = 869
