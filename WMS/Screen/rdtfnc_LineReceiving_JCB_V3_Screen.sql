
--rdtfnc_LineReceiving_JCB_V3

DELETE rdt.RDTScn WHERE Scn = 6630 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6630, 'ENG' 
   ,@cLine03 = 'TO LOC:'
   ,@cLine14 = '%e'
   ,@nFunc = 684
 
DELETE rdt.RDTScn WHERE Scn = 6631 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6631, 'ENG' 
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine06 = 'TO LOC: %20i04'
   ,@cLine07 = '%20i04'
   ,@cLine12 = 'COND. CODE: %10i10'
   ,@cLine14 = '%e'
   ,@nFunc = 684
   
DELETE rdt.RDTScn WHERE Scn = 6650 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6650, 'ENG' 
   ,@cLine01 = 'ASN: %10i01'
   ,@cLine02 = 'PO:  %10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 685

DELETE rdt.RDTScn WHERE Scn = 6651 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6651, 'ENG' 
   ,@cLine01 = 'TO LOC: %10d01'
   ,@cLine02 = 'TO ID:'
   ,@cLine03 = '%30i02'
   ,@cLine14 = '%e'
   ,@nFunc = 685

DELETE rdt.RDTScn WHERE Scn = 6652 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6652, 'ENG' 
   ,@cLine01 = 'TO ID:'
   ,@cLine02 = '%18d01'
   ,@cLine04 = 'LINE NO: %05i02'
   ,@cLine14 = '%e'
   ,@nFunc = 685

DELETE rdt.RDTScn WHERE Scn = 6654 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6654, 'ENG' 
   ,@cLine02 = 'Line received'
   ,@cLine05 = 'Press ENTER to'
   ,@cLine06 = 'receive next line'
   ,@cLine14 = '%e'
   ,@nFunc = 685

DELETE rdt.RDTScn WHERE Scn = 6655 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6655, 'ENG' 
   ,@cLine01 = '%20d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20d06'
   ,@cLine07 = '%20i07'
   ,@cLine08 = '%20d08'
   ,@cLine09 = '%20i09'
   ,@cLine10 = '%20d10'
   ,@cLine11 = '%20d11'
   ,@cLine12 = '%20d12'
   ,@cLine13 = '%20d13'
   ,@cLine14 = '%e'
   ,@nFunc = 685

DELETE rdt.RDTScn WHERE Scn = 6656 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6656, 'ENG' 
   ,@cLine01 = ''
   ,@cLine02 = 'PRINT LABEL COPY?'
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '9 = NO'
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 685

 
