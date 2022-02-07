-- rdtfnc_Scan_To_Pallet

IF NOT EXISTS( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1638 AND Lang_Code = 'ENG' AND Message_Type = 'FNC')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1638, 'ENG', 'FNC', 'Scan To Pallet', 'rdtfnc_Scan_To_Pallet', '0')
GO

-- 2250 = PalletKey screen
DELETE rdt.RDTScn WHERE Scn = 2250 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2250, 'ENG',
    @cLine01 = 'PalletKey: '
   ,@cLine02 = '%30i01'
   ,@cLine03 = ''
   ,@cLine04 = 'LOC: %10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1638

-- 2251 = CartonType screen
DELETE rdt.RDTScn WHERE Scn = 2251 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2251, 'ENG',
    @cLine01 = 'PalletKey: '
   ,@cLine02 = '%30d01'
   ,@cLine04 = 'Carton type:'
   ,@cLine05 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1638

-- 2252 = CaseID screen
DELETE rdt.RDTScn WHERE Scn = 2252 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2252, 'ENG',
    @cLine01 = 'PalletKey: '
   ,@cLine02 = '%30d01'
   ,@cLine04 = 'Carton type:'
   ,@cLine05 = '%10d02'
   ,@cLine07 = 'CASE ID:'
   ,@cLine08 = '%20i03'
   ,@cLine10 = '# OF CASES: %05d04'
   ,@cLine13 = '%20d15'    -- WMS-15913
   ,@cLine14 = '%e'
   ,@nFunc = 1638

-- 2253 = Print packing list screen
DELETE rdt.RDTScn WHERE Scn = 2253 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2253, 'ENG',
    @cLine01 = 'Print pallet packing'
   ,@cLine02 = 'list report?'
   ,@cLine04 = '1 = Yes     2 = No'
   ,@cLine06 = 'Option: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1638
   
-- 2254 = Pallet Info screen
DELETE rdt.RDTScn WHERE Scn = 2254 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2254, 'ENG',
    @cLine01 = 'PalletKey: '
   ,@cLine02 = '%30d01'
   ,@cLine04 = 'Length      : %05i02'
   ,@cLine05 = 'Width       : %05i03'
   ,@cLine06 = 'Height      : %05i04'
   ,@cLine07 = 'Gross Weight: %05i05'
   ,@cLine14 = '%e'
   ,@nFunc = 1638   

-- 2255 = Pack info screen
DELETE rdt.RDTScn WHERE Scn = 2255 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2255, 'ENG'
   ,@cLine01 = 'CARTON: %10i01'
   ,@cLine02 = ''
   ,@cLine03 = 'WEIGHT: %10i02'
   ,@cLine04 = ''
   ,@cLine05 = 'CUBE:   %10i03'
   ,@cLine06 = ''
   ,@cLine07 = 'REF NO:'
   ,@cLine08 = '%20i04'
   ,@cLine14 = '%e'
   ,@nFunc = 1638

-- WMS-15913
-- 2256 = Close pallet screen
DELETE rdt.RDTScn WHERE Scn = 2256 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2256, 'ENG'
   ,@cLine01 = 'CLOSE PALLET ?'
   ,@cLine02 = ''
   ,@cLine03 = '1 = YES'
   ,@cLine04 = '2 = NO'
   ,@cLine05 = ''
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1638
