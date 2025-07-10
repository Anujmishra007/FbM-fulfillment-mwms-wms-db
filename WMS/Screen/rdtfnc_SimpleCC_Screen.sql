--rdtfnc_SimpleCC
-- 2770 - 2779

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('731', 'ENG', 'FNC', 'Apparel CC', 'rdtfnc_SimpleCC', '1')

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('732', 'ENG', 'FNC', 'Simple CC (Assisted)', 'rdtfnc_SimpleCC', '1')

-- 2770 = CCREF screen
DELETE rdt.RDTScn WHERE Scn = 2770 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2770, 'ENG',
    @cLine01 = 'CCREF: %10i01'
   ,@cLine02 = ''
   ,@cLine03 = 'SHEET: %10i02'       
   ,@cLine14 = '%e'
   
-- 2771 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 2771 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2771, 'ENG'
   ,@cLine01 = 'CCREF: %10d01'
   ,@cLine02 = 'SHEET: %10d06'   
   ,@cLine03 = 'COUNT NO: %01d03'   
   ,@cLine04 = ''
   ,@cLine05 = 'LOC: %10d04'    -- Loc -- (ChewKP02)
   ,@cLine06 = 'LOC: %10i02 %03d05'   -- (james02)
   ,@cLine14 = '%e'
   
-- 2772 = Statistic screen
DELETE rdt.RDTScn WHERE Scn = 2772 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2772, 'ENG'
   ,@cLine01 = 'CCREF: %10d01'
   ,@cLine02 = 'SHEET: %10d06'      
   ,@cLine03 = 'COUNT NO: %01d03'      
   ,@cLine04 = ''
   ,@cLine05 = 'LOC: %10d02'   
   ,@cLine06 = ''
   ,@cLine07 = 'SKU: %15d04'   
   ,@cLine08 = 'QTY: %15d05'   
   ,@cLine13 = '%20d07'   -- (james05)
   ,@cLine14 = '%e'   

-- 2773 = SKU QTY screen
DELETE rdt.RDTScn WHERE Scn = 2773 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2773, 'ENG'
   ,@cLine01 = 'SHEET: %10d12'      
   ,@cLine02 = 'COUNT NO: %01d06'   
   ,@cLine03 = 'LOC: %10d02'   
   ,@cLine04 = 'SKU:'
   ,@cLine05 = '%20d11' -- SKU -- (ChewKP02)
   ,@cLine06 = '%40i03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = '%20d07' 
   ,@cLine10 = '         %05d13 %05d14'
   ,@cLine11 = 'QTY:     %05i08 %05i09'
   ,@cLine12 = 'TTL QTY: %10d10'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'
   
-- 2774 = Add count LOC screen
DELETE rdt.RDTScn WHERE Scn = 2774 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2774, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'LOC NOT FOUND. ADD?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'   
   ,@cLine05 = '2 = NO'   
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   
-- 2775 = Reset LOC screen
DELETE rdt.RDTScn WHERE Scn = 2775 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2775, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'LOC COUNTED. RESET?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'   
   ,@cLine05 = '2 = NO, CONTINUE'   -- WMS-9996
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'   
   
-- 2776 = Confirm SKIP screen
DELETE rdt.RDTScn WHERE Scn = 2776 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2776, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'SKIP LOC?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'   
   ,@cLine05 = '2 = NO'   
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'  
   
-- 2777 = Confirm SKIP screen
DELETE rdt.RDTScn WHERE Scn = 2777 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2777, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'LOC COUNTED?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'   
   ,@cLine05 = '2 = NO'   
   ,@cLine06 = '3 = RESET LOC'   
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'       

-- 2778 = ID screen
DELETE rdt.RDTScn WHERE Scn = 2778 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2778, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'ID:'
   ,@cLine03 = '%20i01'    -- FCR-2054 Extend to 20 chars
   ,@cLine13 = '%20d15'    -- FCR-2054 ExtendedInfoSP
   ,@cLine14 = '%e'    

--WMS996. Add Reset by counted ID
-- 2779 = Reset LOC screen
DELETE rdt.RDTScn WHERE Scn = 2779 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2779, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'ID COUNTED. RESET?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'   
   ,@cLine05 = '2 = NO'   
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e' 
      
-- update rdt.rdtscn with function id   
UPDATE RDT.RDTSCN SET FUNC = 731 WHERE SCN BETWEEN 2770 AND 2779
   
-- Note: This module no need set function no as it is shared across multi function