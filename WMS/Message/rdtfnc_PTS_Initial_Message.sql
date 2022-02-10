--rdtfnc_PTS_Initial
--execute rdt.rdtdropmsg 50351, 50400

execute rdt.rdtAddMsg '50351', 10, '50351^BAD PTZONE',      'us_english'
execute rdt.rdtAddMsg '50352', 10, '50352^BAD PTZONE',      'us_english'
execute rdt.rdtAddMsg '50353', 10, '50353^INV PAPER PRT',   'us_english'
execute rdt.rdtAddMsg '50354', 10, '50354^UPD PRT FAIL',    'us_english'
execute rdt.rdtAddMsg '50355', 10, '50355^INV LABEL PRT',   'us_english'
execute rdt.rdtAddMsg '50356', 10, '50356^UPD PRT FAIL',    'us_english'
execute rdt.rdtAddMsg '50357', 10, '50357^NoPaperPrinter',  'us_english'
execute rdt.rdtAddMsg '50358', 10, '50358^TOTE NO Req',     'us_english'
execute rdt.rdtAddMsg '50359', 10, '50359^INVALID TOTE',    'us_english'
execute rdt.rdtAddMsg '50360', 10, '50360^INVALID TOTE',    'us_english'
execute rdt.rdtAddMsg '50361', 10, '50361^INVALID TOTE',    'us_english'
execute rdt.rdtAddMsg '50362', 10, '50362^INV TOTENO LEN',  'us_english'
execute rdt.rdtAddMsg '50363', 10, '50363^INV TOTE NO',     'us_english'
execute rdt.rdtAddMsg '50364', 10, '50364^INVALID TOTE',    'us_english'
execute rdt.rdtAddMsg '50365', 10, '50365^MANIFEST PRINT',  'us_english'
execute rdt.rdtAddMsg '50366', 10, '50366^INVALID TOTE',    'us_english'
execute rdt.rdtAddMsg '50367', 10, '50367^TOTE CANCEL',     'us_english'
execute rdt.rdtAddMsg '50368', 10, '50368^TOTE CLOSED',     'us_english'
execute rdt.rdtAddMsg '50369', 10, '50369^TOTENOTPICKED',   'us_english'
execute rdt.rdtAddMsg '50370', 10, '50370^TOTE SHIPPED',    'us_english'
execute rdt.rdtAddMsg '50371', 10, '50371^UPD WCS FAIL',    'us_english'
execute rdt.rdtAddMsg '50372', 10, '50372^UPD WCSDT FAIL',  'us_english'
execute rdt.rdtAddMsg '50373', 10, '50373^Inv Case Qty',    'us_english'
execute rdt.rdtAddMsg '50374', 10, '50374^No Qty To Sort',  'us_english'



SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 50351 AND 50400