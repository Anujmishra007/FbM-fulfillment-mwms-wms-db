-- 3240 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3240 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3240, 'ENG',
    @cLine01 = 'STORERKEY:'
   ,@cLine02 = '%15i01'
   ,@cLine03 = 'SHOP NO  : %05i02'
   ,@cLine04 = 'SECTION  : %05i03'
   ,@cLine05 = 'SEPARATE : %05i04'
   ,@cLine06 = 'PRINT QTY: %05i05'
   ,@cLine07 = 'LABEL TYPE:'
   ,@cLine08 = '%20d06'
   ,@cLine14 = '%e'

-- 3241 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3241 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3241, 'ENG',
    @cLine01 = 'STORERKEY:'
   ,@cLine02 = '%15d01'
   ,@cLine03 = 'SHOP NO  : %05d02'
   ,@cLine04 = 'SECTION  : %05d03'
   ,@cLine05 = 'SEPARATE : %05d04'
   ,@cLine06 = 'PRINT QTY: %05d05'
   ,@cLine07 = 'LBL TYPE : %10d08'
   ,@cLine08 = 'THIS WILL PRINT FROM'
   ,@cLine09 = 'CURRENT BARCODE'
   ,@cLine10 = '%20d06'
   ,@cLine11 = 'TO'
   ,@cLine12 = '%20d07'
   ,@cLine13 = 'PRESS ENTER TO PRINT'
   ,@cLine14 = '%e'


update rdt.rdtscndetail set coltype = 'ddlb', colvalue = 'PLS SELECT', collookupview = 'isp_GetShopLabelType01' where scn = 3240 and fieldno = '06'

