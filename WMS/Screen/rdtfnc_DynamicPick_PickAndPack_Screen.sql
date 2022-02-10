-- 1640 = WAVEKEY screen
DELETE rdt.RDTScn WHERE Scn = 1640 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1640, 'ENG',
    @cLine01 = 'WAVEKEY:  %10i01'
   ,@cLine02 = 'LOADKEY:  %10i07'
   ,@cLine03 = 'PICKZONE: %10i02'
   ,@cLine04 = 'PICKSLIP: %01i03 (1-9)'
   ,@cLine05 = 'COUNTRY:'
   ,@cLine06 = '%20i04'
   ,@cLine07 = ''
   ,@cLine08 = 'FROM LOC: %10i05'
   ,@cLine09 = 'TO LOC:   %10i06'
   ,@cLine14 = '%e'

-- 1641 = PKSLIPNO screen
DELETE rdt.RDTScn WHERE Scn = 1641 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1641, 'ENG',
    @cLine01 = 'PICKSLIP NO'
   ,@cLine02 = '1. %10i01'
   ,@cLine03 = '2. %10i02'
   ,@cLine04 = '3. %10i03'
   ,@cLine05 = '4. %10i04'
   ,@cLine06 = '5. %10i05'
   ,@cLine07 = '6. %10i06'
   ,@cLine08 = '7. %10i07'
   ,@cLine09 = '8. %10i08'
   ,@cLine10 = '9. %10i09'
   ,@cLine14 = '%e'
    
-- 1642 = WAVEKEY screen
DELETE rdt.RDTScn WHERE Scn = 1642 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1642, 'ENG',
    @cLine01 = 'WAVEKEY:  %10d01'
   ,@cLine02 = 'LOADKEY:  %10d09'
   ,@cLine03 = 'PICKZONE: %10d02'
   ,@cLine04 = 'PICKSLIP: %01d03'
   ,@cLine05 = 'COUNTRY:'
   ,@cLine06 = '%20d04'
   ,@cLine07 = ''
   ,@cLine08 = 'FROM LOC: %10d05'
   ,@cLine09 = 'TO LOC:   %10d06'
   ,@cLine10 = ''
   ,@cLine11 = 'TOTAL QTY: %09d07'
   ,@cLine12 = 'TOTAL CBM: %09d08'
   ,@cLine14 = '%e'
 
-- 1643 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 1643 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1643, 'ENG',
    @cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'LOC: %10i02'
   ,@cLine14 = '%e'
 
-- 1644 = QTY screen
DELETE rdt.RDTScn WHERE Scn = 1644 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1644, 'ENG',
    @cLine01 = 'PKSLIPNO: %10d01'
   ,@cLine02 = 'SKU:         PPK:%03d13'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '1 %18d05'
   ,@cLine07 = '2 %18d06'
   ,@cLine08 = '3 %18d07'
   ,@cLine09 = '4 %10d08'
   ,@cLine10 = 'PICK:%05d09 ACT:%05i10'
   ,@cLine11 = 'SKU/UPC:'
   ,@cLine12 = '%20i11'
   ,@cLine13 = 'BAL QTY: %11d12'
   ,@cLine14 = '%e'
 
-- 1645 = LABEL NO screen
DELETE rdt.RDTScn WHERE Scn = 1645 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1645, 'ENG',
    @cLine01 = 'PKSLIPNO: %10d01'
   ,@cLine02 = 'CARTONNO: %05d02'
   ,@cLine03 = 'LABEL NO:'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20i04'
   ,@cLine12 = 'OPT:%01i05 (1=NEW CARTON)'
   ,@cLine14 = '%e'

-- 1646 = OPTION screen
DELETE rdt.RDTScn WHERE Scn = 1646 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1646, 'ENG',
    @cLine01 = 'NEXT OPTION '
   ,@cLine03 = '1 = CONFIRM'
   ,@cLine04 = '2 = CLOSE CASE'
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'

-- 1647 = OPTION screen
DELETE rdt.RDTScn WHERE Scn = 1647 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1647, 'ENG',
    @cLine01 = 'CONFIRM SHORT PICK? '
   ,@cLine03 = '1 = YES'
   ,@cLine04 = '2 = NO'
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
