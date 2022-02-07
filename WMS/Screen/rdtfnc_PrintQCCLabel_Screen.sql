-- SOS310288 - rdtfnc_PrintQCCLabel 
-- Scn 3850 - 3859

-- 3850 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3850 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3850, 'ENG',
    @cLine01 = 'SCAN UCC:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 594

-- 3851 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3851 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3851, 'ENG',
    @cLine01 = 'UCC:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'SKU:'
   ,@cLine04 = '%20d02'
   ,@cLine06 = 'MULTI COO FOUND !!!'
   ,@cLine07 = 'COO      TTL / PRINT'
   ,@cLine08 = '%15d03 %03i08'
   ,@cLine09 = '%15d04 %03i09'
   ,@cLine10 = '%15d05 %03i10'
   ,@cLine11 = '%15d06 %03i11'
   ,@cLine12 = '%15d07 %03i12'
   ,@cLine13 = 'ENTER FOR NEXT SKU'
   ,@cLine14 = '%e'
   ,@nFunc = 594