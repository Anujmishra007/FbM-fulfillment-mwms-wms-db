-- 1730 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1730 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1730, 'ENG'
   ,@cLine01 = 'QC KEY: %10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1730
 
-- 1731 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1731 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1731, 'ENG'
   ,@cLine01 = 'QC KEY: %10d01'
   ,@cLine02 = 'FROM LOC: %10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1730
   
-- 1732 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1732 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1732, 'ENG'
   ,@cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'FROM ID:'
   ,@cLine03 = '%18i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1730
   
-- 1733 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1733 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1733, 'ENG'
   ,@cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'FROM ID:'
   ,@cLine03 = '%18d02'
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1730
   
-- 1734 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1734 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1734, 'ENG'
   ,@cLine01 = 'QC LINE NO: %05d01'
   ,@cLine02 = 'SKU:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = 'LOTTABLES 2/3/4'
   ,@cLine07 = '2 %18d05'
   ,@cLine08 = '5 %18d06'
   ,@cLine09 = '4 %18d07'
   ,@cLine10 = '1:%06d08 %05d09 %05d10'
   ,@cLine11 = 'IQC QTY: %05d11 %05d12'
   ,@cLine12 = 'ACT QTY: %05i13 %05i14'
   ,@cLine14 = '%e'
   ,@nFunc = 1730
   
-- 1735 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1735 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1735, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '1:%06d04 %05d05 %05d06'
   ,@cLine06 = 'IQC QTY: %05d07 %05d08'
   ,@cLine07 = 'ACT QTY: %05d09 %05d10'
   ,@cLine08 = 'REASON: %10i11'
   ,@cLine14 = '%e'
   ,@nFunc = 1730
   
-- 1736 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1736 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1736, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '1:%06d04 %05d05 %05d06'
   ,@cLine06 = 'IQC QTY: %05d07 %05d08'
   ,@cLine07 = 'ACT QTY: %05d09 %05d10'
   ,@cLine08 = 'REASON: %10d11'
   ,@cLine09 = 'TO ID:'
   ,@cLine10 = '%18d12'
   ,@cLine11 = 'TO ID:'
   ,@cLine12 = '%18i13'
   ,@cLine14 = '%e'
   ,@nFunc = 1730
   
-- 1737 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1737 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1737, 'ENG'
   ,@cLine02 = 'IQC to different ID'
   ,@cLine04 = 'Proceed?'
   ,@cLine06 = '1=YES'
   ,@cLine07 = '2=NO'
   ,@cLine09 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1730
   
-- 1738 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1738 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1738, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '1:%06d04 %05d05 %05d06'
   ,@cLine06 = 'IQC QTY: %05d07 %05d08'
   ,@cLine07 = 'ACT QTY: %05d09 %05d10'
   ,@cLine08 = 'REASON: %10d11'
   ,@cLine09 = 'TO ID:'
   ,@cLine10 = '%18d12'
   ,@cLine11 = 'TO LOC: %10d13'
   ,@cLine12 = 'TO LOC: %10i14'
   ,@cLine14 = '%e'
   ,@nFunc = 1730
   
-- 1739 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1739 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1739, 'ENG'
   ,@cLine02 = 'IQC to different'
   ,@cLine03 = 'location'
   ,@cLine05 = 'Proceed?'
   ,@cLine07 = '1=YES'
   ,@cLine08 = '2=NO'
   ,@cLine10 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1730
   
-- 1740 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1740 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1740, 'ENG'
   ,@cLine02 = 'IQC successfully'
   ,@cLine04 = 'Press ENTER or ESC'
   ,@cLine05 = 'to continue'
   ,@cLine14 = '%e'
   ,@nFunc = 1730