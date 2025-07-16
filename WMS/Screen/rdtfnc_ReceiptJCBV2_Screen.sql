
--rdtfnc_ReceiptJCBV2_Screens

DELETE rdt.RDTScn WHERE Scn = 6633 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6633, 'ENG'
   ,@cLine01 = 'Enter/Scan Pallet Type'
   ,@cLine02 = '%10l01'
   ,@cLine03 = 'Pallet Types'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%20d08'
   ,@cLine11 = '%20d09'
   ,@cLine12 = '%20d10'
   ,@cLine13 = '%20d11'
   ,@cLine14 = '%e'
   ,@nFunc = 684
   ,@cWebGroup = '{"1":["1"],"2":["2"],"3":["3","4","5","6","7","8","9","10","11","12","13"]}'

INSERT INTO rdt.RDTSCNHeader (scn, scndescr, lang_code, adddate, addwho, editddate, editwho)
VALUES (6633, 'JCB receipt', 'ENG', GETDATE(), 'PPA374', GETDATE(), 'PPA374')

--
DELETE rdt.RDTScn WHERE Scn = 6632 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6632, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'PRINT LABEL COPY?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '9 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 684

INSERT INTO rdt.RDTSCNHeader (scn, scndescr, lang_code, adddate, addwho, editddate, editwho)
VALUES (6632, 'JCB receipt', 'ENG', GETDATE(), 'PPA374', GETDATE(), 'PPA374')

--
DELETE rdt.RDTScn WHERE Scn = 6634 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6634, 'ENG'
   ,@cLine01 = 'ASN: %10i01'
   ,@cLine02 = 'PO : %10i02'
   ,@cLine03 = ''
   ,@cLine04 = 'REF NO:'
   ,@cLine05 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 684
   ,@cWebGroup = '{"1":["1"],"2":["2"],"3":["4","5"]}'

   INSERT INTO rdt.RDTSCNHeader (scn, scndescr, lang_code, adddate, addwho, editddate, editwho)
   VALUES (6634, 'JCB receipt', 'ENG', GETDATE(), 'PPA374', GETDATE(), 'PPA374')

--
DELETE rdt.RDTScn WHERE Scn = 6635 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6635, 'ENG'
   ,@cLine01 = 'ASN: %10d01'
   ,@cLine02 = 'PO : %10d02'
   ,@cLine03 = 'TO LOC: %10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 684
   ,@cWebGroup = '{"1":["1","2"],"2":["3"]}'

   INSERT INTO rdt.RDTSCNHeader (scn, scndescr, lang_code, adddate, addwho, editddate, editwho)
   VALUES (6635, 'JCB receipt', 'ENG', GETDATE(), 'PPA374', GETDATE(), 'PPA374')
   
 --
 DELETE rdt.RDTScn WHERE Scn = 6638 AND Lang_Code = 'ENG'
 EXECUTE rdt.rdtAddScn 6638, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = '%60i02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%60i04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%60i06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%60i08'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%60i10'
   ,@cLine14 = '%e'
   ,@nFunc = 684
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["5","6"],"4":["7","8"],"5":["9","10"]}'

   INSERT INTO rdt.RDTSCNHeader (scn, scndescr, lang_code, adddate, addwho, editddate, editwho)
   VALUES (6638, 'JCB receipt', 'ENG', GETDATE(), 'PPA374', GETDATE(), 'PPA374')
 
 --
 DELETE rdt.RDTScn WHERE Scn = 6637 AND Lang_Code = 'ENG'
 EXECUTE rdt.rdtAddScn 6637, 'ENG'
   ,@cLine01 = 'TO ID: '
   ,@cLine02 = '%18d01'
   ,@cLine03 = ''
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%1000iV_Max'
   ,@cLine06 = ''
   ,@cLine07 = '%20d03'
   ,@cLine08 = '%20d04'
   ,@cLine13 = '%20d05'
   ,@cLine14 = '%e'
   ,@nFunc = 684
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5"]}'

   INSERT INTO rdt.RDTSCNHeader (scn, scndescr, lang_code, adddate, addwho, editddate, editwho)
   VALUES (6637, 'JCB receipt', 'ENG', GETDATE(), 'PPA374', GETDATE(), 'PPA374')
   
 --
 DELETE rdt.RDTScn WHERE Scn = 6636 AND Lang_Code = 'ENG'
 EXECUTE rdt.rdtAddScn 6636, 'ENG'
   ,@cLine01 = 'TO LOC: %10d01'
   ,@cLine02 = 'TO ID:'
   ,@cLine03 = '%30i02'
   ,@cLine14 = '%e'
   ,@nFunc = 684
   ,@cWebGroup = '{"1":["1"],"2":["2","3"]}'

   INSERT INTO rdt.RDTSCNHeader (scn, scndescr, lang_code, adddate, addwho, editddate, editwho)
   VALUES (6636, 'JCB receipt', 'ENG', GETDATE(), 'PPA374', GETDATE(), 'PPA374')
   
--
DELETE rdt.RDTScn WHERE Scn = 6639 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6639, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = 'IVAS:'
   ,@cLine06 = '%20d04'
   ,@cLine07 = ''
   ,@cLine08 = '%07d05 %05d06   %05d07'
   ,@cLine09 = 'QTY: %10i08^DT:INT %10i09^DT:INT'
   ,@cLine10 = ''
   ,@cLine11 = 'COND CODE%10l10'
   ,@cLine12 = ''
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 684
   ,@cWebGroup = '{"1":["1","2","3","4"],"2":["5","6"],"3":["8","9"],"4":["11"],"5":["13"]}'

   INSERT INTO rdt.RDTSCNHeader (scn, scndescr, lang_code, adddate, addwho, editddate, editwho)
   VALUES (6639, 'JCB receipt', 'ENG', GETDATE(), 'PPA374', GETDATE(), 'PPA374')
   
--
DELETE rdt.RDTScn WHERE Scn = 6640 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6640, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Successful received'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = 'Press ENTER or ESC'
   ,@cLine06 = 'to continue'
   ,@cLine14 = '%e'
   ,@nFunc = 684

   INSERT INTO rdt.RDTSCNHeader (scn, scndescr, lang_code, adddate, addwho, editddate, editwho)
   VALUES (6640, 'JCB receipt', 'ENG', GETDATE(), 'PPA374', GETDATE(), 'PPA374')
   
--
DELETE rdt.RDTScn WHERE Scn = 6642 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6642, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20i12'
   ,@cLine06 = 'WEIGHT: %10i04'
   ,@cLine07 = 'CUBE  : %10i05'
   ,@cLine08 = 'L     : %10i06'
   ,@cLine09 = 'W     : %10i07'
   ,@cLine10 = 'H     : %10i08'
   ,@cLine11 = 'INNER : %10i09'
   ,@cLine12 = 'CASE  : %10i10'
   ,@cLine13 = 'PALLET: %10i11'
   ,@cLine14 = '%e'
   ,@nFunc = 684

   INSERT INTO rdt.RDTSCNHeader (scn, scndescr, lang_code, adddate, addwho, editddate, editwho)
   VALUES (6642, 'JCB receipt', 'ENG', GETDATE(), 'PPA374', GETDATE(), 'PPA374')
   
--
DELETE rdt.RDTScn WHERE Scn = 6641 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6641, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'ADD SKU NOT IN ASN?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 684

   INSERT INTO rdt.RDTSCNHeader (scn, scndescr, lang_code, adddate, addwho, editddate, editwho)
   VALUES (6641, 'JCB receipt', 'ENG', GETDATE(), 'PPA374', GETDATE(), 'PPA374')
   
--
DELETE rdt.RDTScn WHERE Scn = 6643 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6643, 'ENG'
   ,@cLine01 = 'SELECT ASN:'
   ,@cLine02 = ''
   ,@cLine03 = '%20d01'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%20d08'
   ,@cLine11 = '%20d09'
   ,@cLine12 = ''
   ,@cLine13 = 'OPTION: %01i10'
   ,@cLine14 = '%e'
   ,@nFunc = 684
   ,@cWebGroup = '{"1":["3","4","5","6","7","8","9","10","11"],"2":["13"]}'

   INSERT INTO rdt.RDTSCNHeader (scn, scndescr, lang_code, adddate, addwho, editddate, editwho)
   VALUES (6643, 'JCB receipt', 'ENG', GETDATE(), 'PPA374', GETDATE(), 'PPA374')
   
--
DELETE rdt.RDTScn WHERE Scn = 6644 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6644, 'ENG'
   ,@cLine01 = 'PUTAWAY'
   ,@cLine02 = ''
   ,@cLine03 = 'SUGGESTED LOC:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = ''
   ,@cLine06 = 'FINAL LOC:'
   ,@cLine07 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 684
   ,@cWebGroup = '{"1":["3","4"],"2":["6","7"]}'

   INSERT INTO rdt.RDTSCNHeader (scn, scndescr, lang_code, adddate, addwho, editddate, editwho)
   VALUES (6644, 'JCB receipt', 'ENG', GETDATE(), 'PPA374', GETDATE(), 'PPA374')

--
DELETE rdt.RDTScn WHERE Scn = 6645 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6645, 'ENG'
   ,@cLine01 = 'SKU 1/2/3:     OPT:%01i13'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = ''
   ,@cLine06 = '%20d06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%20d08'
   ,@cLine09 = ''
   ,@cLine10 = '%20d10'
   ,@cLine11 = '%20d11'
   ,@cLine12 = '%20d12'
   ,@cLine13 = '(1-3=SKU ENTER=NEXT)'
   ,@cLine14 = '%e'
   ,@nFunc = 684
   ,@cWebGroup = '{"1":["3","4"],"2":["6","7"]}'

   INSERT INTO rdt.RDTSCNHeader (scn, scndescr, lang_code, adddate, addwho, editddate, editwho)
   VALUES (6645, 'JCB receipt', 'ENG', GETDATE(), 'PPA374', GETDATE(), 'PPA374')

--
DELETE rdt.RDTScn WHERE Scn = 6646 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6646, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = ''
   ,@cLine06 = 'SERIAL NO:'
   ,@cLine07 = '%1000iV_Max'
   ,@cLine08 = ''
   ,@cLine09 = 'SCAN/TOTAL: %08d05'
   ,@cLine14 = '%e'
   ,@nFunc = 684
   ,@cWebGroup = '{{"1":["1","2","3","4"],"2":["6","7"],"3":["9"]}'

   INSERT INTO rdt.RDTSCNHeader (scn, scndescr, lang_code, adddate, addwho, editddate, editwho)
   VALUES (6646, 'JCB receipt', 'ENG', GETDATE(), 'PPA374', GETDATE(), 'PPA374')
   
--
DELETE rdt.RDTScn WHERE Scn = 6647 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6647, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Close Pallet?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 684


   INSERT INTO rdt.RDTSCNHeader (scn, scndescr, lang_code, adddate, addwho, editddate, editwho)
   VALUES (6647, 'JCB receipt', 'ENG', GETDATE(), 'PPA374', GETDATE(), 'PPA374')
