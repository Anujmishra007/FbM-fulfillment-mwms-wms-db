-- Scn = 1790 ASN, PO, PICKSLIP NO
DELETE rdt.RDTScn WHERE Scn = 1790 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1790, 'ENG', 
   @cLine01 = 'ASN: %10i01',
   @cLine02 = 'PO : %10i02',
   @cLine04 = 'PICKSLIP NO:',
   @cLine05 = '%10i03',
   @cLine06 = 'EXT RECEIPT KEY:',
   @cLine07 = '%20i04',
   @cLine14 = '%e'

-- Scn = 1791. ASN, PO, PICKSLIP NO, SKU, Desc 
DELETE rdt.RDTScn WHERE Scn = 1791 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1791, 'ENG', 
   @cLine01 = 'ASN: %10d01',
   @cLine02 = 'PO : %10d02',
   @cLine03 = 'PICKSLIP NO:',
   @cLine04 = '%10d06',
   @cLine05 = 'EXT RECEIPT KEY:',
   @cLine06 = '%20d07',
   @cLine07 = 'SKU: ',
   @cLine08 = '%20i03',
   @cLine09 = '%20d04',
   @cLine10 = '%20d05',
   @cLine14 = '%e'

-- Scn = 1792. SKU, IVAS, UOM, QTY RTN, TOTAL QTY
DELETE rdt.RDTScn WHERE Scn = 1792 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1792, 'ENG', 
   @cLine01 = 'SKU: ',
   @cLine02 = '%20d01',
   @cLine03 = '%20d02',
   @cLine04 = '%20d03',
--   @cLine05 = 'IVAS: ',
--   @cLine06 = '%20d04',
   @cLine06 = '%08d05 %05d06 %05d07',
   @cLine07 = 'QTY RTN: %05i08 %05i09',
   @cLine08 = 'TOTAL QTY: ',
   @cLine09 = '%08d10 %05d11 %05d12',
   @cLine10 = '         %05d13 %05d14',
   @cLine11 = 'TOTAL ASN QTY: ',
   @cLine12 = '         %05d15 %05d04',
   @cLine14 = '%e'
   
-- Scn = 1793. Lottables
DELETE rdt.RDTScn WHERE Scn = 1793 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1793, 'ENG',
    @cLine01 = '%20d01'
   ,@cLine02 = '%18i02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%18i04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%18i06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%10i08'
   ,@cLine10 = 'SERIAL NO: '
   ,@cLine11 = '%18i09'
   ,@cLine14 = '%e'

-- Scn = 1794. Verify Serial No, SubReason
DELETE rdt.RDTScn WHERE Scn = 1794 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1794, 'ENG', 
   @cLine01 = 'SUBREASON:',
   @cLine02 = '%10i01',
   @cLine14 = '%e'
 
   
-- -- Scn = 1795. SKU, LOTTABLE02/03/04, UOM, QTY RTN, SERIAL NO
-- DELETE rdt.RDTScn WHERE Scn = 1795 AND Lang_Code = 'ENG'
-- EXECUTE rdt.rdtAddScn 1795, 'ENG', 
--    @cLine01 = 'SKU: ',
--    @cLine02 = '%20d01',
--    @cLine03 = '%20d02',
--    @cLine04 = '%20d03',
--    @cLine05 = 'LOTTABLE 2/3/4',
--    @cLine06 = '2 %18d04',
--    @cLine07 = '3 %18d05',
--    @cLine08 = '4 %16d06',
--    @cLine09 = '%08d07 %05d08 %05d09',
--    @cLine10 = 'QTY RTN: %05d10 %05d11',
--    @cLine11 = 'SERIAL NO: ',
--    @cLine12 = '%18i12',
--    @cLine14 = '%e'

-- Scn = 1795. SKU, LOTTABLE02/03/04, UOM, QTY RTN, SERIAL NO, TO LOC
DELETE rdt.RDTScn WHERE Scn = 1795 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1795, 'ENG', 
   @cLine01 = 'SKU: ',
   @cLine02 = '%20d01',
   @cLine03 = '%20d02',
   @cLine04 = '%20d03',
   @cLine05 = 'LOTTABLE 2/3/4',
   @cLine06 = '2 %18d04',
   @cLine07 = '3 %18d05',
   @cLine08 = '4 %16d06',
   @cLine09 = '%08d07 %05d08 %05d09',
   @cLine10 = 'QTY RTN: %05d10 %05d11',
   @cLine11 = 'SERIAL NO: ',
   @cLine12 = '%18d12',
   @cLine13 = 'TO LOC: %10i13',
   @cLine14 = '%e'

-- Scn = 1796. Message
DELETE rdt.RDTScn WHERE Scn = 1796 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1796, 'ENG', 
   @cLine01 = 'SKU successfully',
   @cLine02 = 'received',
   @cLine04 = 'Press ENTER or ESC',
   @cLine05 = 'to continue',
   @cLine14 = '%e'

