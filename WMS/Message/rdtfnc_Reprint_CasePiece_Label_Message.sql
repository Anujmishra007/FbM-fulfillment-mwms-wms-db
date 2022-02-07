--rdtfnc_Reprint_CaseLabel_Label
--execute rdt.rdtdropmsg 73066 - 73090

execute rdt.rdtAddMsg '73066', 10, '73066^Option req',     'us_english'
execute rdt.rdtAddMsg '73067', 10, '73067^Invalid Option', 'us_english'
execute rdt.rdtAddMsg '73068', 10, '73068^PKSLIP req',     'us_english'
execute rdt.rdtAddMsg '73069', 10, '73069^Invalid PKSLIP', 'us_english'
execute rdt.rdtAddMsg '73070', 10, '73070^Inv FROM CTN',   'us_english'
execute rdt.rdtAddMsg '73071', 10, '73071^Inv FROM CTN',   'us_english'
execute rdt.rdtAddMsg '73072', 10, '73072^Inv TO CTN',     'us_english'
execute rdt.rdtAddMsg '73073', 10, '73073^Inv TO CTN',     'us_english'
execute rdt.rdtAddMsg '73074', 10, '73074^NoLoginPrinter', 'us_english'
execute rdt.rdtAddMsg '73075', 10, '73075^DWNOTSetup',     'us_english'
execute rdt.rdtAddMsg '73076', 10, '73076^TgetDBNotSet',   'us_english'
execute rdt.rdtAddMsg '73077', 10, '73077^InsertPRTFail',  'us_english'
execute rdt.rdtAddMsg '73078', 10, '73078^NoLoginPrinter', 'us_english'
execute rdt.rdtAddMsg '73079', 10, '73079^DWNOTSetup',     'us_english'
execute rdt.rdtAddMsg '73080', 10, '73080^TgetDBNotSet',   'us_english'
execute rdt.rdtAddMsg '73081', 10, '73081^InsertPRTFail',  'us_english'
execute rdt.rdtAddMsg '73082', 10, '73082^FROM > TO CTN',  'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 73066 and 73090
