-- 1720 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1720 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1720, 'ENG',
     @cLine01 = 'PSNO: %10i01'
    ,@cLine14 = '%e'
    
-- 1721 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1721 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1721, 'ENG',
     @cLine01 = 'PSNO: %10d01'
    ,@cLine03 = 'Print Pallet'
    ,@cLine04 = 'Manifest'
    ,@cLine05 = 'Report/Label'
    ,@cLine07 = '1 = Pallet Man Rpt'
    ,@cLine08 = '2 = Pallet Man Lbl'
    ,@cLine10 = 'Option: %01i02'
    ,@cLine14 = '%e'