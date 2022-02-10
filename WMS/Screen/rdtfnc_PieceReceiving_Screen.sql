-- 1750 = ASN/PO screen
DELETE rdt.RDTScn WHERE Scn = 1750 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1750, 'ENG',
    @cLine01 = 'ASN: %10i01'
   ,@cLine02 = 'PO : %10i02'
   ,@cLine03 = ''
   ,@cLine04 = 'REF NO:'
   ,@cLine05 = '%20i03'
   ,@cLine14 = '%e'
 
-- 1751 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 1751 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1751, 'ENG',
    @cLine01 = 'ASN: %10d01'
   ,@cLine02 = 'PO : %10d02'
   ,@cLine03 = 'REF NO:'
   ,@cLine04 = '%20d03'
   ,@cLine05 = ''
   ,@cLine06 = 'TO LOC: %10i04'
   ,@cLine14 = '%e'
 
-- 1752 = ID screen
DELETE rdt.RDTScn WHERE Scn = 1752 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1752, 'ENG',
    @cLine01 = 'ASN: %10d01'
   ,@cLine02 = 'PO : %10d02'
   ,@cLine04 = 'TO LOC: %10d03'
   ,@cLine05 = 'TO ID:'
   ,@cLine06 = '%60i04'       -- WMS5313 extend to 60 chars
   ,@cLine14 = '%e'

 
-- 1753 = Lottable screen
DELETE rdt.RDTScn WHERE Scn = 1753 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1753, 'ENG',
    @cLine01 = 'LotLabel01:'
   ,@cLine02 = '%20i01'       -- WMS5313 extend to 20 chars
   ,@cLine03 = 'LotLabel02:'
   ,@cLine04 = '%20i02'       -- WMS5313 extend to 20 chars
   ,@cLine05 = 'LotLabel03:'
   ,@cLine06 = '%20i03'       -- WMS5313 extend to 20 chars
   ,@cLine07 = 'LotLabel04:'
   ,@cLine08 = '%10i04'
   ,@cLine14 = '%e'
 
-- 1754 = SKU, QTY screen
DELETE rdt.RDTScn WHERE Scn = 1754 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1754, 'ENG',
    @cLine01 = 'TO ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'SKU/UPC:'
   ,@cLine04 = '%60i02' -- WMS-16653
   ,@cLine05 = '%20d11' 	
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = ''
   ,@cLine10 = 'REC: %15d06' 
   ,@cLine11 = 'QTY: %10i05 %05d12' 
   ,@cLine12 = 'TOID QTY: %10d10'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
 
-- 1755 = Print pallet label screen
DELETE rdt.RDTScn WHERE Scn = 1755 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1755, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'Print pallet label?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'

-- 1756 = Verif SKU screen
DELETE rdt.RDTScn WHERE Scn = 1756 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1756, 'ENG', 
    @cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02' 	
   ,@cLine04 = '%20d03' 	
   ,@cLine05 = 'QTY: %05d12'  -- SOS315958
   ,@cLine06 = 'WEIGHT: %10i04'
   ,@cLine07 = 'CUBE  : %10i05'
   ,@cLine08 = 'L     : %10i06'
   ,@cLine09 = 'W     : %10i07'
   ,@cLine10 = 'H     : %10i08'
   ,@cLine11 = 'INNER : %10i09'
   ,@cLine12 = 'CASE  : %10i10'
   ,@cLine13 = 'PALLET: %10i11'
   ,@cLine14 = '%e'

-- 1759 = Close pallet screen
DELETE rdt.RDTScn WHERE Scn = 1759 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1759, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'Close pallet?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'