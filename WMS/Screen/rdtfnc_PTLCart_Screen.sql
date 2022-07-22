
-- CartID, pickzone, method
DELETE rdt.RDTScn WHERE Scn = 4130 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4130, 'ENG'
   ,@cLine01 = 'CART ID:  %10i01'
   ,@cLine02 = ''
   ,@cLine03 = 'PICKZONE: %10i02'
   ,@cLine04 = ''
   ,@cLine05 = 'METHOD:   %01i03'
   ,@cLine06 = ''
   ,@cLine07 = 'PICK SEQ: %01i04'
   ,@cLine08 = ''
   ,@cLine09 = 'COL: %02i05'
   ,@cLine10 = ''
   ,@cLine11 = 'ROW: %02i06'
   ,@cLine12 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 808

-- Dynamic assign screens (4180 to 4189)

-- SKU
DELETE rdt.RDTScn WHERE Scn = 4132 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4132, 'ENG'
   ,@cLine01 = 'LOC: %15d01'
   ,@cLine02 = 'SKU:        QTY: %03d12'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%40i03' -- SKU barcode expanded to 40 char
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d08'
   ,@cLine08 = '%20d09'
   ,@cLine09 = '%20d10'
   ,@cLine10 = '%20d11'
   ,@cLine11 = 'TOTAL POS: %05d06'
   ,@cLine12 = 'TOTAL QTY: %05d07'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 808

-- Matrix
DELETE rdt.RDTScn WHERE Scn = 4133 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4133, 'ENG'
   ,@cLine01 = '%20d01' -- Result01
   ,@cLine02 = '%20d02' 
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20d06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%20d08'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%20d10' -- Result10
   ,@cLine11 = '' 
   ,@cLine12 = 'OPTION: %01i11' 
   ,@cLine13 = '1-CLOSE 9-SHORT' 
   ,@cLine14 = '%e'
   ,@nFunc = 808

-- Old tote
DELETE rdt.RDTScn WHERE Scn = 4134 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4134, 'ENG'
   ,@cLine01 = 'TOTE ID:'
   ,@cLine02 = '%20i01' 
   ,@cLine03 = ''
   ,@cLine04 = 'QTY: %05i02'
   ,@cLine14 = '%e'
   ,@nFunc = 808
   
-- New tote
DELETE rdt.RDTScn WHERE Scn = 4135 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4135, 'ENG'
   ,@cLine01 = 'NEW TOTE ID:'
   ,@cLine02 = '%20i01' 
   ,@cLine14 = '%e'
   ,@nFunc = 808
   
-- Unassign cart
DELETE rdt.RDTScn WHERE Scn = 4136 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4136, 'ENG'
   ,@cLine01 = 'UNASSIGN CART?'
   ,@cLine02 = ''
   ,@cLine03 = '1 = YES' 
   ,@cLine04 = '9 = NO' 
   ,@cLine05 = '' 
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 808
   