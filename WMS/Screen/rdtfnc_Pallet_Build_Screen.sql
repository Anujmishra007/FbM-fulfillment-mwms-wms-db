-- 2320 = DROP ID screen
DELETE rdt.RDTScn WHERE Scn = 2320 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2320, 'ENG',
    @cLine01 = 'PALLET BUILD'
   ,@cLine03 = 'DROP ID:'
   ,@cLine04 = '%18i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1641

-- 2321 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 2321 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2321, 'ENG',
    @cLine01 = 'PALLET BUILD'
   ,@cLine03 = 'DROP ID:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'LOC:'
   ,@cLine06 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1641
    
-- 2322 = UCC NO screen
DELETE rdt.RDTScn WHERE Scn = 2322 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2322, 'ENG',
    @cLine01 = 'PALLET BUILD'
   ,@cLine03 = 'DROP ID:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'LOC:'
   ,@cLine06 = '%10d02'
   ,@cLine07 = 'UCC NO:'
   ,@cLine08 = '%20i03'
   ,@cLine10 = 'Total UCC Scanned:' -- (ChewKP01)
   ,@cLine11 = '%05d04'             -- (ChewKP01)
   ,@cLine13 = '%20d05'             -- SOS370791
   ,@cLine14 = '%e'
   ,@nFunc = 1641
   
-- 2323 = Close Pallet Option screen
DELETE rdt.RDTScn WHERE Scn = 2323 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2323, 'ENG',
    @cLine01 = 'PALLET BUILD'
   ,@cLine03 = 'Close Pallet?'
   ,@cLine05 = '1 = Yes'
   ,@cLine06 = '2 = No'
   ,@cLine08 = 'Option: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1641

-- 2324 = Pallet criteria
DELETE rdt.RDTScn WHERE Scn = 2324 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2324, 'ENG'
   ,@cLine01 = 'PALLET CRITERIA'
   ,@cLine02 = ''
   ,@cLine03 = '%20d01'
   ,@cLine04 = '%20i02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20i04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20i06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%20i08'
   ,@cLine11 = '%20d09'
   ,@cLine12 = '%20i10'
   ,@cLine14 = '%e'
   ,@nFunc = 1641
   
-- 2325 = Close Pallet Option screen -- (ChewKP02) 
DELETE rdt.RDTScn WHERE Scn = 2325 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2325, 'ENG',
    @cLine01 = 'PALLET BUILD'
   ,@cLine03 = 'Print Label?'
   ,@cLine05 = '1 = Yes'
   ,@cLine06 = '2 = No'
   ,@cLine08 = 'Option: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1641   
   
-- 2326 = Reopen the Pallet --(yeekung01)
DELETE rdt.RDTScn WHERE Scn = 2326 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2326, 'ENG',
    @cLine01 = 'PALLET CLOSED'
   ,@cLine03 = 'REOPEN?'
   ,@cLine05 = '1 = Yes'
   ,@cLine06 = '2 = No'
   ,@cLine08 = 'Option: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1641 

-- WMS-13606
-- 2327 = Add info screen
DELETE rdt.RDTScn WHERE Scn = 2327 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2327, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = '%20i02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20i04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20i06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%20i08'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%20i10'
   ,@cLine14 = '%e'
   ,@nFunc = 1641   