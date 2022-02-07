--rdtfnc_ClusterPick
--execute rdt.rdtdropmsg 65901, 65950
--execute rdt.rdtdropmsg 65951, 66000
--execute rdt.rdtdropmsg 69341, 69390
--execute rdt.rdtdropmsg 104001 , 104050

execute rdt.rdtAddMsg 65901, 10, '65901^Bad WAVEKEY',    'us_english'
execute rdt.rdtAddMsg 65902, 10, '65902^Bad LOADKEY',    'us_english'
execute rdt.rdtAddMsg 65903, 10, '65903^LoadNotInWave',  'us_english'
execute rdt.rdtAddMsg 65904, 10, '65904^NeedWavLoadOrd', 'us_english'
execute rdt.rdtAddMsg 65905, 10, '65905^Bad OrderKey',   'us_english'
execute rdt.rdtAddMsg 65906, 10, '65906^Bad OrderKey',   'us_english'
execute rdt.rdtAddMsg 65907, 10, '65907^BadOrderStatus', 'us_english'
execute rdt.rdtAddMsg 65908, 10, '65908^PKSLIPNotPrint', 'us_english'
execute rdt.rdtAddMsg 65909, 10, '65909^PS Scanned Out', 'us_english'
execute rdt.rdtAddMsg 65910, 10, '65910^LockOrdersFail', 'us_english'
execute rdt.rdtAddMsg 65911, 10, '65911^OrdersAlrdLock', 'us_english'
execute rdt.rdtAddMsg 65912, 10, '65912^ReleaseMobFail', 'us_english'
execute rdt.rdtAddMsg 65913, 10, '65913^No More Task',   'us_english'
execute rdt.rdtAddMsg 65914, 10, '65914^Invalid Option', 'us_english'
execute rdt.rdtAddMsg 65915, 10, '65915^No Selection',   'us_english'
execute rdt.rdtAddMsg 65916, 10, '65916^Only1ZoneAllow', 'us_english'
execute rdt.rdtAddMsg 65917, 10, '65917^UPDPWZoneFail',  'us_english'
execute rdt.rdtAddMsg 65918, 10, '65918^UPDPWZoneFail',  'us_english'
execute rdt.rdtAddMsg 65919, 10, '65919^ReleaseMobFail', 'us_english'
execute rdt.rdtAddMsg 65920, 10, '65920^ReleaseMobFail', 'us_english'
execute rdt.rdtAddMsg 65921, 10, '65921^ReleaseMobFail', 'us_english'
execute rdt.rdtAddMsg 65922, 10, '65922^No More PWZone', 'us_english'
execute rdt.rdtAddMsg 65923, 10, '65923^InvalidPKZone',  'us_english'
execute rdt.rdtAddMsg 65924, 10, '65924^NoMorePKZone',   'us_english'
execute rdt.rdtAddMsg 65925, 10, '65925^PKZoneLocked',   'us_english'
execute rdt.rdtAddMsg 65926, 10, '65926^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 65927, 10, '65927^Invalid Option', 'us_english'
execute rdt.rdtAddMsg 65928, 10, '65928^Scan In Fail',   'us_english'
execute rdt.rdtAddMsg 65929, 10, '65929^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 65930, 10, '65930^ReleaseMobFail', 'us_english'
execute rdt.rdtAddMsg 65931, 10, '65931^Invalid DropID', 'us_english'
execute rdt.rdtAddMsg 65932, 10, '65932^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 65933, 10, '65933^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 65934, 10, '65934^Invalid SKU',    'us_english'
execute rdt.rdtAddMsg 65935, 10, '65935^SameBarCodeSKU', 'us_english'
execute rdt.rdtAddMsg 65936, 10, '65936^Different SKU',  'us_english'
execute rdt.rdtAddMsg 65937, 10, '65937^QTY needed',     'us_english'
execute rdt.rdtAddMsg 65938, 10, '65938^Invalid QTY',    'us_english'
execute rdt.rdtAddMsg 65939, 10, '65939^Over Pick',      'us_english'
execute rdt.rdtAddMsg 65940, 10, '65940^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 65941, 10, '65941^GetNextTaskFail','us_english'
execute rdt.rdtAddMsg 65942, 10, '65942^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 65943, 10, '65943^LockOrdersFail', 'us_english'
execute rdt.rdtAddMsg 65944, 10, '65944^Invalid Option', 'us_english'
execute rdt.rdtAddMsg 65945, 10, '65945^GetNextTaskFail','us_english'
execute rdt.rdtAddMsg 65946, 10, '65946^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 65947, 10, '65947^LockOrdersFail', 'us_english'
execute rdt.rdtAddMsg 65948, 10, '65948^Scan Out Fail',  'us_english'
execute rdt.rdtAddMsg 65949, 10, '65949^Invalid Option', 'us_english'
execute rdt.rdtAddMsg 65950, 10, '65950^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 65951, 10, '65951^ReleaseMobFail', 'us_english'
execute rdt.rdtAddMsg 65952, 10, '65952^Invalid Option', 'us_english'
execute rdt.rdtAddMsg 65953, 10, '65953^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 65954, 10, '65954^ReleaseMobFail', 'us_english'
execute rdt.rdtAddMsg 65955, 10, '65955^ReleaseMobFail', 'us_english'

-- SOS127539
execute rdt.rdtAddMsg 65956, 10, '65956^Invalid Option', 'us_english'
execute rdt.rdtAddMsg 65957, 10, '65957^NoLoginPrinter', 'us_english'
execute rdt.rdtAddMsg 65958, 10, '65958^DWNOTSetup',     'us_english'
execute rdt.rdtAddMsg 65959, 10, '65959^TgetDB Not Set', 'us_english'
execute rdt.rdtAddMsg 65960, 10, '65960^InsertPRTFail',  'us_english'
execute rdt.rdtAddMsg 65961, 10, '65961^DropID needed',  'us_english'

-- SOS145455
execute rdt.rdtAddMsg 65962, 10, '65962^Invalid DropID', 'us_english' 

-- SOS133222
execute rdt.rdtAddMsg 65963, 10, '65963^InsPackHdrFail', 'us_english' 
execute rdt.rdtAddMsg 65964, 10, '65964^INSTPKLockFail', 'us_english' 

-- SOS149089
execute rdt.rdtAddMsg 65965, 10, '65965^Invalid Option', 'us_english'
execute rdt.rdtAddMsg 65966, 10, '65966^NoLoginPrinter', 'us_english'
execute rdt.rdtAddMsg 65967, 10, '65967^DWNOTSetup',     'us_english'
execute rdt.rdtAddMsg 65968, 10, '65968^TgetDB Not Set', 'us_english'
execute rdt.rdtAddMsg 65969, 10, '65969^InsertPRTFail',  'us_english'
execute rdt.rdtAddMsg 65970, 10, '65970^GetNextTaskFail','us_english'
execute rdt.rdtAddMsg 65971, 10, '65971^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 65972, 10, '65972^GetNextTaskFail','us_english'
execute rdt.rdtAddMsg 65973, 10, '65973^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 65974, 10, '65974^InsPackHdrFail',  'us_english'

-- SOS170848
execute rdt.rdtAddMsg 65975, 10, '65975^No Record',      'us_english'
execute rdt.rdtAddMsg 65976, 10, '65976^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 65977, 10, '65977^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 65978, 10, '65978^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 65979, 10, '65979^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 65980, 10, '65980^LockOrdersFail', 'us_english'
execute rdt.rdtAddMsg 65981, 10, '65981^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 65982, 10, '65982^BAD Reason',     'us_english'

-- SOS172041
execute rdt.rdtAddMsg 69341, 10, '69341^AD UOM X SETUP', 'us_english'
execute rdt.rdtAddMsg 69342, 10, '69342^ADCode req',     'us_english'
execute rdt.rdtAddMsg 69343, 10, '69343^ADCode exists',  'us_english'
execute rdt.rdtAddMsg 69344, 10, '69344^Upd Fail',       'us_english'
execute rdt.rdtAddMsg 69345, 10, '69345^Upd Fail',       'us_english'
execute rdt.rdtAddMsg 69346, 10, '69346^Bad Reason',     'us_english'
execute rdt.rdtAddMsg 69347, 10, '69347^InsPHdrFail',    'us_english'
execute rdt.rdtAddMsg 69348, 10, '69348^ConfPackFail',   'us_english'
execute rdt.rdtAddMsg 69349, 10, '69349^LockOrdersFail', 'us_english'

-- SOS197651
execute rdt.rdtAddMsg 69350, 10, '69350^Skip Task Fail', 'us_english'
execute rdt.rdtAddMsg 69351, 10, '69351^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 69352, 10, '69352^LockOrdersFail', 'us_english'
execute rdt.rdtAddMsg 69353, 10, '69353^Skip Task Fail', 'us_english'
execute rdt.rdtAddMsg 69354, 10, '69354^UPDPKLockFail',  'us_english'

--SOS207999
execute rdt.rdtAddMsg 69355, 10, '69355^WAVEKEY Is Req', 'us_english'

--SOS216118
execute rdt.rdtAddMsg 69356, 10, '69356^LOADKEY Is Req', 'us_english'
execute rdt.rdtAddMsg 69357, 10, '69357^LockOrdersFail', 'us_english'
execute rdt.rdtAddMsg 69358, 10, '69358^PKSLIPNotPrint', 'us_english'
execute rdt.rdtAddMsg 69359, 10, '69359^CANNOT MIX ORD', 'us_english'

--SOS216485
execute rdt.rdtAddMsg 69360, 10, '69360^Over Pick',      'us_english'

--SOS263803
execute rdt.rdtAddMsg 69361, 10, '69361^CTN NOT BUILT',  'us_english'
execute rdt.rdtAddMsg 69362, 10, '69362^BAD LOC',        'us_english'
execute rdt.rdtAddMsg 69363, 10, '69363^LOC NOT MATCH',  'us_english'
execute rdt.rdtAddMsg 69364, 10, '69364^CTN NOT BUILT',  'us_english'
execute rdt.rdtAddMsg 69365, 10, '69365^DROPID IN USE',  'us_english'
execute rdt.rdtAddMsg 69366, 10, '69366^CANNOT MIX DID', 'us_english'
execute rdt.rdtAddMsg 69367, 10, '69367^CANNOT MIX DID', 'us_english'
execute rdt.rdtAddMsg 69368, 10, '69368^NO TASK',        'us_english'
execute rdt.rdtAddMsg 69369, 10, '69369^NO TASK',        'us_english'
execute rdt.rdtAddMsg 69370, 10, '69370^NO TASK',        'us_english'
execute rdt.rdtAddMsg 69371, 10, '69371^NO TASK',        'us_english'
execute rdt.rdtAddMsg 69372, 10, '69372^UPC NOT EXIST',  'us_english'
execute rdt.rdtAddMsg 69373, 10, '69373^BOM MULTI SKU',  'us_english'
execute rdt.rdtAddMsg 69374, 10, '69374^BOM NOT SETUP',  'us_english'

--SOS276235
execute rdt.rdtAddMsg 69375, 10, '69375^INVALID ORDERS',  'us_english'
execute rdt.rdtAddMsg 69376, 10, '69376^BadOrderStatus',  'us_english'
execute rdt.rdtAddMsg 69377, 10, '69377^Bad SKU Field',   'us_english'
execute rdt.rdtAddMsg 69378, 10, '69378^Bad SKU Field',   'us_english'

--(james30)
execute rdt.rdtAddMsg 69379, 10, '69379^SCAN IN FAIL',    'us_english'
execute rdt.rdtAddMsg 69380, 10, '69380^SCAN IN FAIL',    'us_english'
execute rdt.rdtAddMsg 69381, 10, '69381^CLOSE DID FAIL',  'us_english'
execute rdt.rdtAddMsg 69382, 10, '69382^CLOSE DID FAIL',  'us_english'

-- (james31)
execute rdt.rdtAddMsg 69383, 10, '69383^NO MORE TASK',    'us_english'

-- SOS291607
execute rdt.rdtAddMsg 69384, 10, '69384^LOT02 REQ',       'us_english'
execute rdt.rdtAddMsg 69385, 10, '69385^INVALID LOT02',   'us_english'

-- SOS297732 (reserved)
-- execute rdt.rdtAddMsg 69386, 10, '69386^SP NotSetup',     'us_english'

-- SOS303010
execute rdt.rdtAddMsg 69387, 10, '69387^SHPICK X ALLOW',  'us_english'
execute rdt.rdtAddMsg 69388, 10, '69388^SHPICK X ALLOW',  'us_english'

-- SOS34207
execute rdt.rdtAddMsg 69389, 10, '69387^CTN TYPE REQ',    'us_english'
execute rdt.rdtAddMsg 69390, 10, '69388^INV CTN TYPE',  'us_english'

-- WMS319
execute rdt.rdtAddMsg 104001, 10, '104001^Invalid Format',  'us_english'

-- WMS-14783
execute rdt.rdtAddMsg 104002, 10, '04002^Invalid LOC',  'us_english'
execute rdt.rdtAddMsg 104003, 10, '04002^No PickTask',  'us_english'
