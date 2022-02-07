-- 3050 = Wave/Load/Order Screen
DELETE rdt.RDTScn WHERE Scn = 3050 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3050, 'ENG',
    @cLine01 = 'WAVEKEY:  %10i01'
   ,@cLine02 = 'OR'
   ,@cLine04 = 'LOADKEY:  %10i02'
   ,@cLine05 = 'OR'
   ,@cLine07 = 'ORDERKEY: %10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 869

-- 3051 = Info screen
DELETE rdt.RDTScn WHERE Scn = 3051 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3051, 'ENG',
    @cLine01 = 'WAVEKEY: %10d01'
   ,@cLine02 = 'LOADKEY: %10d02'
   ,@cLine03 = 'ORDERKEY: %10d03'
   ,@cLine04 = ''
   ,@cLine05 = 'ORDER COUNT: %05d04'
   ,@cLine06 = 'QTY PICK : %05d05'
   ,@cLine07 = 'QTY SHORT: %05d06'
   ,@cLine08 = ''
   ,@cLine09 = 'PRESS ENTER GO TO'
   ,@cLine10 = 'SHORT PICK CONFIRM'
   ,@cLine14 = '%e'
   ,@nFunc = 869

-- 3052 = Option screen
DELETE rdt.RDTScn WHERE Scn = 3052 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3052, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'Confirm short pick?'
   ,@cLine03 = ''
   ,@cLine04 = '1=YES'
   ,@cLine05 = '2=NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 869

-- 3053 = Option screen
DELETE rdt.RDTScn WHERE Scn = 3053 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3053, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'All short pick QTY'
   ,@cLine03 = 'unallocated'
   ,@cLine04 = ''
   ,@cLine05 = 'All orders have been'
   ,@cLine06 = 'pack confirmed and'
   ,@cLine07 = 'scanned out'
   ,@cLine14 = '%e'
   ,@nFunc = 869