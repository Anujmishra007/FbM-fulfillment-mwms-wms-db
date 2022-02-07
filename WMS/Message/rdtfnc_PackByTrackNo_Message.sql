--rdtfnc_PackByTrackNo
--execute rdt.rdtdropmsg 76451, 76500
--execute rdt.rdtdropmsg 90651, 90700

execute rdt.rdtAddMsg '76451', 10, '76451^ORDERKEY REQ',    'us_english'
execute rdt.rdtAddMsg '76452', 10, '76452^INV ORDERKEY',    'us_english'
execute rdt.rdtAddMsg '76453', 10, '76453^ORDER ON HOLD!',  'us_english' 
execute rdt.rdtAddMsg '76454', 10, '76454^ORD NOT ALLOC',   'us_english'
execute rdt.rdtAddMsg '76455', 10, '76455^GET PSLIP FAIL',  'us_english'
execute rdt.rdtAddMsg '76456', 10, '76456^INSTPKHDR FAIL',  'us_english'
execute rdt.rdtAddMsg '76457', 10, '76457^SCAN IN FAIL',    'us_english'
execute rdt.rdtAddMsg '76458', 10, '76458^TRACKNO REQ',     'us_english'
execute rdt.rdtAddMsg '76459', 10, '76459^TRACK# > 1 ORD',  'us_english'
execute rdt.rdtAddMsg '76460', 10, '76460^INV SHIPPERKEY',  'us_english'
execute rdt.rdtAddMsg '76461', 10, '76461^INV TRACKNO',     'us_english'
execute rdt.rdtAddMsg '76462', 10, '76462^UPD ORD FAILED',  'us_english'
execute rdt.rdtAddMsg '76463', 10, '76463^SKU REQ',         'us_english'
execute rdt.rdtAddMsg '76464', 10, '76464^INVALID SKU',     'us_english'
execute rdt.rdtAddMsg '76465', 10, '76465^INVALID CTN#',    'us_english'
execute rdt.rdtAddMsg '76466', 10, '76466^INVALID CTN#',    'us_english'
execute rdt.rdtAddMsg '76467', 10, '76467^CTN# IN USE',     'us_english'
execute rdt.rdtAddMsg '76468', 10, '76468^UPDLOG FAILED',   'us_english'
execute rdt.rdtAddMsg '76469', 10, '76469^INSLOG FAILED',   'us_english'
execute rdt.rdtAddMsg '76470', 10, '76470^INSPKHDR FAIL',   'us_english'
execute rdt.rdtAddMsg '76471', 10, '76471^UPDPKDET FAIL',   'us_english'
execute rdt.rdtAddMsg '76472', 10, '76472^GET LABEL FAIL',  'us_english'
execute rdt.rdtAddMsg '76473', 10, '76473^INSPKDET FAIL',   'us_english'
execute rdt.rdtAddMsg '76474', 10, '76474^CTN TYPE REQ',    'us_english'
execute rdt.rdtAddMsg '76475', 10, '76475^CTN WGT REQ',     'us_english'
execute rdt.rdtAddMsg '76476', 10, '76476^INV CTN WGT',     'us_english'
execute rdt.rdtAddMsg '76477', 10, '76477^UPD PKINF FAIL',  'us_english'
execute rdt.rdtAddMsg '76478', 10, '76478^INS PKINF FAIL',  'us_english'
execute rdt.rdtAddMsg '76479', 10, '76479^UPD BOX FAIL',    'us_english'
execute rdt.rdtAddMsg '76480', 10, '76480^CFMPACKHD FAIL',  'us_english'
execute rdt.rdtAddMsg '76481', 10, '76481^SKU OVERPACKED',  'us_english'
execute rdt.rdtAddMsg '76482', 10, '76482^NOPAPERPRINTER',  'us_english'
execute rdt.rdtAddMsg '76483', 10, '76483^DWNOTSETUP',      'us_english'
execute rdt.rdtAddMsg '76484', 10, '76484^TGETDB NOT SET',  'us_english'
execute rdt.rdtAddMsg '76485', 10, '76485^INSERTPRTFAIL',   'us_english'
execute rdt.rdtAddMsg '76486', 10, '76486^NOLABELPRINTER',  'us_english'
execute rdt.rdtAddMsg '76487', 10, '76487^DWNOTSETUP',      'us_english'
execute rdt.rdtAddMsg '76488', 10, '76488^TGETDB NOT SET',  'us_english'
execute rdt.rdtAddMsg '76489', 10, '76489^INSERTPRTFAIL',   'us_english'

execute rdt.rdtAddMsg '76490', 10, '76490^INV OPTION',      'us_english'

execute rdt.rdtAddMsg '76491', 10, '76491^INV CTN TYPE',    'us_english'
execute rdt.rdtAddMsg '76492', 10, '76492^EXCEED MAX WGT',  'us_english'

-- SOS282353
execute rdt.rdtAddMsg '76493', 10, '76493^EXT UPD FAIL',    'us_english'
execute rdt.rdtAddMsg '76494', 10, '76494^SKU NOT IN ORD',  'us_english'

-- SOS300492
execute rdt.rdtAddMsg '76495', 10, '76495^INV TRACKNO',     'us_english'
execute rdt.rdtAddMsg '76496', 10, '76496^UPDPKDET FAIL',   'us_english'
execute rdt.rdtAddMsg '76497', 10, '76497^ORDERS PICKED',   'us_english'
execute rdt.rdtAddMsg '76498', 10, '76498^ORDERS SHIPPED',  'us_english'

-- SOS309850
execute rdt.rdtAddMsg '76499', 10, '76499^INSERTPRTFAIL',   'us_english'
execute rdt.rdtAddMsg '76500', 10, '76500^INV SHIPPERKEY',  'us_english'

-- SOS300492
execute rdt.rdtAddMsg '90651', 10, '90651^EXT UPD FAIL',    'us_english'
execute rdt.rdtAddMsg '90652', 10, '90652^TRACK NO REQ',    'us_english'

-- SOS323253
execute rdt.rdtAddMsg '90653', 10, '90653^NoPaperPrinter',  'us_english'
execute rdt.rdtAddMsg '90654', 10, '90654^DWNOTSETUP',      'us_english'
execute rdt.rdtAddMsg '90655', 10, '90655^TGETDB NOT SET',  'us_english'
execute rdt.rdtAddMsg '90656', 10, '90656^INSERTPRTFAIL',   'us_english'
execute rdt.rdtAddMsg '90657', 10, '90657^NoLabelPrinter',  'us_english'
execute rdt.rdtAddMsg '90658', 10, '90658^DWNOTSETUP',      'us_english'
execute rdt.rdtAddMsg '90659', 10, '90659^TGETDB NOT SET',  'us_english'
execute rdt.rdtAddMsg '90660', 10, '90660^INSERTPRTFAIL',   'us_english'

-- SOS329922
execute rdt.rdtAddMsg '90661', 10, '90661^INVALID WEIGHT',  'us_english'

-- SOS340748
execute rdt.rdtAddMsg '90662', 10, N'90662^报告已打印',     'us_english'

-- SOS347381
execute rdt.rdtAddMsg '90663', 10, '90663^ORDER CANCEL!',   'us_english'

-- SOS362968
execute rdt.rdtAddMsg '90664', 10, '90664^INVALID TOTEID',  'us_english'

-- 11/11/16
execute rdt.rdtAddMsg '90665', 10, '90665^INV SHIPPERKEY',  'us_english'

-- WMS1446
execute rdt.rdtAddMsg '90666', 10, '90666^PACK CFM FAIL',   'us_english'

execute rdt.rdtAddMsg '90667', 10, '90667^MultiSKUBarcod',  'us_english'

-- WMS13965
execute rdt.rdtAddMsg '90668', 10, '90668^OptionRequired',  'us_english'
execute rdt.rdtAddMsg '90669', 10, '90669^Invalid Option',  'us_english'

-- WMS15906
execute rdt.rdtAddMsg '90670', 10, '90670^Invalid RefNo',   'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 76451 and 76500
select * from rdt.rdtmsg (nolock) where message_id between 90651 and 90700
