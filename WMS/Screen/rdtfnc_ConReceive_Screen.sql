-- 4230 = ASN screen
DELETE rdt.RDTScn WHERE Scn = 4230 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4230, 'ENG' 
   ,@cLine01 = 'REF NO:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 598

-- 4231 = Loc screen
DELETE rdt.RDTScn WHERE Scn = 4231 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4231, 'ENG'
   ,@cLine01 = 'REF NO:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'TO LOC: %10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 598

-- 4232 = Pallet ID screen
DELETE rdt.RDTScn WHERE Scn = 4232 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4232, 'ENG'
   ,@cLine01 = 'TO LOC: %10d01'
   ,@cLine02 = 'TO ID:'         -- ID extend from 18 to 30
   ,@cLine03 = '%30i02'
   ,@cLine14 = '%e'
   ,@nFunc = 598

-- 4233 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 4233 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4233, 'ENG'
   ,@cLine01 = 'TO ID: '
   ,@cLine02 = '%18d01'
   ,@cLine03 = ''
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%30i02' -- SKU extend to 30 chars
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine13 = '%20d15' --WMS9426-Add ext info
   ,@cLine14 = '%e'
   ,@nFunc = 598

--WMS-17244 
--4234. UCCID screen [lottbale screen using 3490]
DELETE rdt.RDTScn WHERE Scn = 4234 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4234, 'ENG'
   ,@cLine01 = 'REF NO:'
   ,@cLine02 = '%20d01' 
   ,@cLine03 = 'UCC:' 
   ,@cLine04 = '%20d02' 
   ,@cLine05 = 'TO ID:'         
   ,@cLine06 = '%30i03'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 598
---- 4234 = Lottable screen
--DELETE rdt.RDTScn WHERE Scn = 4234 AND Lang_Code = 'ENG'
--EXECUTE rdt.rdtAddScn 4234, 'ENG'
--   ,@cLine01 = '%20d01'   -- Lot label 01
--   ,@cLine02 = '%60i02'   -- Lottable01      -- Extend to 60 chars
--   ,@cLine03 = '%20d03'   -- Lot label 02
--   ,@cLine04 = '%60i04'   -- Lottable02      -- Extend to 60 chars
--   ,@cLine05 = '%20d05'   -- Lot label 03
--   ,@cLine06 = '%60i06'   -- Lottable03      -- Extend to 60 chars
--   ,@cLine07 = '%20d07'   -- Lot label 04
--   ,@cLine08 = '%16i08'   -- Lottable04
--   ,@cLine09 = '%20d09'   -- Lot label 05
--   ,@cLine10 = '%16i10'   -- Lottable05
--   ,@cLine14 = '%e'
--   ,@nFunc = 598

-- 4235 = QTY, COND screen
DELETE rdt.RDTScn WHERE Scn = 4235 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4235, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = 'IVAS:'
   ,@cLine06 = '%20d04'
   ,@cLine07 = ''
   ,@cLine08 = '%07d05 %05d06  %05d07'
   ,@cLine09 = 'QTY: %07i08 %07i09'
   ,@cLine10 = ''
   ,@cLine11 = 'COND CODE:%10i10'
   ,@cLine12 = 'SUBREASON:%10i11'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 598   

-- 4236 = Message screen
DELETE rdt.RDTScn WHERE Scn = 4236 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4236, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Successful received'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = 'Press ENTER or ESC'
   ,@cLine06 = 'to continue'
   ,@cLine14 = '%e'
   ,@nFunc = 598

-- 4237. Add SKU not in ASN?
DELETE rdt.RDTScn WHERE Scn = 4237 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4237, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'ADD SKU NOT IN ASN?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 598

-- 4238. Print pallet label
DELETE rdt.RDTScn WHERE Scn = 4238 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4238, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'PRINT PALLET LABEL?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 598

-- 4239. Putaway
DELETE rdt.RDTScn WHERE Scn = 4239 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4239, 'ENG'
   ,@cLine01 = 'PUTAWAY'
   ,@cLine02 = ''
   ,@cLine03 = 'SUGGESTED LOC:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = ''
   ,@cLine06 = 'FINAL LOC:'
   ,@cLine07 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 598
   

