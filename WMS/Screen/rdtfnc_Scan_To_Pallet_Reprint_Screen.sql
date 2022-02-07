-- rdtfnc_Scan_To_Pallet_Reprint

-- 2270 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2270 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2270, 'ENG',
    @cLine01 = 'PalletKey: '
   ,@cLine02 = '%30i01'
   ,@cLine14 = '%e'



