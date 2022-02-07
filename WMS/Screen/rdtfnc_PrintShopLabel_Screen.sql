-- rdtfnc_PrintShopLabel
-- 3550 - 3559

-- 3550 = LoadKey
DELETE rdt.RDTScn WHERE Scn = 3550 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3550, 'ENG',
   @cLine01 = 'LOADKEY: %10i01',
   @cLine03 = 'LABEL TYPE:',
   @cLine04 = '%20d02',
   @cLine14 = '%e',
   @nFunc = 592

update rdt.rdtscndetail set coltype = 'ddlb', colvalue = 'PLS SELECT', collookupview = 'isp_GetShopLabelType02' where scn = 3550 and fieldno = '02'