
DELETE rdt.rdtscn Where Scn = 1710 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 1710, 'ENG',
@cLine01 = 'WAVEKEY: %10i01',
@cLine02 = 'LOADKEY: %10i02', -- SOS279025
@cLine14 = '%e',
@nFunc = 1710

DELETE rdt.rdtscn Where Scn = 1711 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 1711, 'ENG',
@cLine01 = 'WAVEKEY: %10d01',
@cLine02 = 'LOADKEY: %10d08', -- SOS279025
@cLine03 = 'SKU/UPC:',
@cLine04 = '%20i02',
@cLine05 = '%20d03',
@cLine06 = '%20d04',
@cLine08 = 'QTY: %05i05',     -- SOS279025
@cLine10 = 'SKU QTY: %10d06', -- SOS279025
@cLine11 = 'TTL QTY: %10d07', -- SOS279025
@cLine14 = '%e',
@nFunc = 1710


DELETE rdt.rdtscn Where Scn = 1712 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 1712, 'ENG',
@cLine01 = 'Start distribute?',
@cLine03 = '1=YES',
@cLine04 = '2=NO',
@cLine06 = 'OPTION: %01i01',
@cLine14 = '%e',
@nFunc = 1710


DELETE rdt.rdtscn Where Scn = 1713 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 1713, 'ENG',
@cLine01 = 'DISTRIBUTE:   %02d01 /%02d02',
@cLine02 = 'ORDERKEY: %10d03',
--@cLine03 = 'PKSLIPNO: %10d04',
--@cLine04 = 'CONSIGNEE/COMPANY:',
@cLine03 = '%20d04', -- SOS279025
@cLine04 = '%20d15', -- SOS279025
@cLine05 = '%15d05',
@cLine06 = '%20d06',
@cLine07 = 'SKU:          %02d07 /%02d08',
@cLine08 = '%20d09',
@cLine09 = 'QTY1: %05d10',
@cLine10 = '%20d11',
@cLine11 = 'QTY2: %05d12',
@cLine12 = '%20d13',
@cLine13 = 'QTY3: %05d14',
@cLine14 = '%e',
@nFunc = 1710


DELETE rdt.rdtscn Where Scn = 1714 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 1714, 'ENG',
@cLine01 = 'Finish distribute? ',
@cLine03 = '1=YES',
@cLine04 = '2=NO',
@cLine06 = 'OPTION: %01i01',
@cLine14 = '%e',
@nFunc = 1710

DELETE rdt.rdtscn Where Scn = 1715 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 1715, 'ENG',
@cLine01 = 'Everything scanned',
@cLine02 = 'will be deleted.',
@cLine04 = 'Are you sure ?',
@cLine05 = '1=YES',
@cLine06 = '2=NO',
@cLine08 = 'OPTION: %01i01',
@cLine14 = '%e',
@nFunc = 1710
