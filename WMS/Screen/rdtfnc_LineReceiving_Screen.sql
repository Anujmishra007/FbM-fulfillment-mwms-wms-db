-- 3980 = ASN, PO screen
DELETE rdt.RDTScn WHERE Scn = 3980 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3980, 'ENG'
   ,@cLine01 = 'ASN: %10i01'
   ,@cLine02 = 'PO:  %10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 537

-- 3981 = TO LOC screen
DELETE rdt.RDTScn WHERE Scn = 3981 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3981, 'ENG' 
   ,@cLine01 = 'ASN: %10d01'
   ,@cLine02 = 'PO:  %10d02'
   ,@cLine03 = 'TO LOC: %10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 537

-- 3982 = TO ID screen
DELETE rdt.RDTScn WHERE Scn = 3982 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3982, 'ENG'
   ,@cLine01 = 'TO LOC: %10d01'
   ,@cLine02 = 'TO ID:'
   ,@cLine03 = '%30i02'
   ,@cLine14 = '%e'
   ,@nFunc = 537

-- 3983 = LineNo screen
DELETE rdt.RDTScn WHERE Scn = 3983 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3983, 'ENG'
   ,@cLine01 = 'TO ID:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = ''
   ,@cLine04 = 'LINE NO: %05i02'
   ,@cLine14 = '%e'
   ,@nFunc = 537

-- 3984 = Lottable screen
DELETE rdt.RDTScn WHERE Scn = 3984 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3984, 'ENG'
   ,@cLine01 = '%20d01' 
   ,@cLine02 = '%20i02' -- Lottable01
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20i04' -- Lottable02
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20i06' -- Lottable03
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%20i08' -- Lottable04
   ,@cLine14 = '%e'
   ,@nFunc = 537   

-- 3985 = QTY screen
DELETE rdt.RDTScn WHERE Scn = 3985 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3985, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = ''
   ,@cLine06 = 'IVAS:'
   ,@cLine07 = '%20d04'
   ,@cLine08 = ''
   ,@cLine09 = '%08d05    %05d06 %05d07'
   ,@cLine10 = 'RCV QTY:  %05i08 %05i09'
   ,@cLine11 = ''
   ,@cLine12 = 'COND. CODE: %10i10'
   ,@cLine14 = '%e'
   ,@nFunc = 537   

-- 3986 = Message screen
DELETE rdt.RDTScn WHERE Scn = 3986 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3986, 'ENG'
   ,@cLine02 = 'Line received'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = 'Press ENTER to'
   ,@cLine06 = 'receive next line'
   ,@cLine14 = '%e'
   ,@nFunc = 537
