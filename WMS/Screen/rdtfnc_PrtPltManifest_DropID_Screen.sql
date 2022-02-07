-- 1720 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2020 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2020, 'ENG',
      @cLine01 = 'PRINTER: %10i01'
     ,@cLine02 = ''
     ,@cLine03 = 'DROP ID:'
     ,@cLine04 = '%20i02'
     ,@cLine14 = '%e'
    
-- 1721 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2021 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2021, 'ENG',
     @cLine01 = 'DROP ID:'
    ,@cLine02 = '%20d01'
    ,@cLine03 = 'Print Pallet'
    ,@cLine04 = 'Manifest'
    ,@cLine05 = 'Report/Label'
    ,@cLine07 = '1 = Pallet Man Rpt'
    ,@cLine08 = '2 = Pallet Man Lbl'
    ,@cLine09 = '3 = Dispatch Label'
    ,@cLine10 = '4 = Carton Man Lbl'	--GOH01
    ,@cLine12 = 'Option: %01i02'
    ,@cLine14 = '%e'