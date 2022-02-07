-- 1300 = ASN PO screen
DELETE rdt.RDTScn WHERE Scn = 1300 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1300, 'ENG'
   ,@cLine01 = 'ASN: %10i01'
   ,@cLine02 = 'PO : %10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 898
 
-- 1301 = TO LOC screen
DELETE rdt.RDTScn WHERE Scn = 1301 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1301, 'ENG'
   ,@cLine01 = 'ASN: %10d01'
   ,@cLine02 = 'PO : %10d02'
   ,@cLine04 = 'TO LOC: %10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 898
 
-- 1302 = TO ID screen
DELETE rdt.RDTScn WHERE Scn = 1302 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1302, 'ENG'
   ,@cLine01 = 'ASN: %10d01'
   ,@cLine02 = 'PO : %10d02'
   ,@cLine04 = 'TO LOC: %10d03'
   ,@cLine05 = 'TO ID:'
   ,@cLine06 = '%20i04'
   ,@cLine14 = '%e'
   ,@nFunc = 898

-- 1303 = Estimate screen
DELETE rdt.RDTScn WHERE Scn = 1303 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1303, 'ENG'
   ,@cLine01 = 'ASN: %10d01'
   ,@cLine02 = 'PO : %10d02'
   ,@cLine04 = 'TO LOC: %10d03'
   ,@cLine05 = 'TO ID:'
   ,@cLine06 = '%18d04'
   ,@cLine08 = 'ESTIMATED'
   ,@cLine09 = 'UCC ON ID: %02i05'
   ,@cLine14 = '%e'
   ,@nFunc = 898

-- 1304 = Lottable screen
DELETE rdt.RDTScn WHERE Scn = 1304 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1304, 'ENG'
   ,@cLine01 = 'Lottable01:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = 'Lottable02:'
   ,@cLine04 = '%20i02'
   ,@cLine05 = 'Lottable03:'
   ,@cLine06 = '%20i03'
   ,@cLine07 = 'Lottable04:'
   ,@cLine08 = '%18i04'
   ,@cLine14 = '%e'
   ,@nFunc = 898

-- 1305 = UCC screen
DELETE rdt.RDTScn WHERE Scn = 1305 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1305, 'ENG'
   ,@cLine01 = 'UCC:            %10d11'
   ,@cLine02 = '%20i01'
   ,@cLine03 = 'SKU:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = 'PPK/DU: %12d05'
   ,@cLine08 = '1 %18d06'
   ,@cLine09 = '2 %18d07'
   ,@cLine10 = '3 %18d08'
   ,@cLine11 = '4 %18d09'
   ,@cLine12 = 'QTY: %05d10'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 898

-- 1306 = Message screen
DELETE rdt.RDTScn WHERE Scn = 1306 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1306, 'ENG'
   ,@cLine02 = 'CREATE NEW UCC?'
   ,@cLine04 = '1=YES'
   ,@cLine05 = '2=NO'
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 898

-- 1307 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 1307 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1307, 'ENG'
   ,@cLine01 = 'UCC:           %07d03' -- (ChewKP02)
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'SKU/UPC:'
   ,@cLine04 = '%20i02'
   ,@cLine05 = 'QTY: %05d04'
   ,@cLine14 = '%e'
   ,@nFunc = 898

-- 1308 = QTY screen
DELETE rdt.RDTScn WHERE Scn = 1308 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1308, 'ENG'
   ,@cLine01 = 'UCC:           %07d11' -- (ChewKP02)
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'SKU:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = 'PPK/DU: %12d05'
   ,@cLine08 = 'LOTTABLE 1/2/3/4:'
   ,@cLine09 = '1 %18d06'
   ,@cLine10 = '2 %18d07'
   ,@cLine11 = '3 %18d08'
   ,@cLine12 = '4 %16d09'
   ,@cLine13 = 'QTY: %05i10'
   ,@cLine14 = '%e'
   ,@nFunc = 898

-- 1309 = Add info screen
DELETE rdt.RDTScn WHERE Scn = 1309 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1309, 'ENG'
   ,@cLine01 = 'Extra Data 1:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = 'Extra Data 2:'
   ,@cLine04 = '%20i02'
   ,@cLine05 = 'Extra Data 3:'
   ,@cLine06 = '%20i03'
   ,@cLine07 = 'Extra Data 4:'
   ,@cLine08 = '%20i04'
   ,@cLine09 = 'Extra Data 5:'
   ,@cLine10 = '%20i05'
   ,@cLine14 = '%e'
   ,@nFunc = 898


-- 1310 = Message screen
DELETE rdt.RDTScn WHERE Scn = 1310 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1310, 'ENG'
   ,@cLine02 = 'NOT ALL UCC RECEIVED.'
   ,@cLine03 = 'ESC ANYWAY?'
   ,@cLine05 = '1=YES'
   ,@cLine06 = '2=NO'
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 898

-- 1311 = Message screen
DELETE rdt.RDTScn WHERE Scn = 1311 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1311, 'ENG'
   ,@cLine02 = 'CLOSE PALLET?'
   ,@cLine04 = '1 = NO'
   ,@cLine05 = '2 = YES'
   ,@cLine06 = '3 = YES AND PUTAWAY'
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine10 = 'UCC ON ID: %02i02'
   ,@cLine14 = '%e'
   ,@nFunc = 898
