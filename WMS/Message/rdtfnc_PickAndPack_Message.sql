-- rdtfnc_PickAndPack 
execute rdt.rdtdropmsg 72591, 72640
execute rdt.rdtdropmsg 155451 , 155500

execute rdt.rdtAddMsg 72591, 10, '72591^OrderKey req',   'us_english'
execute rdt.rdtAddMsg 72592, 10, '72592^Bad OrderKey',   'us_english'
execute rdt.rdtAddMsg 72593, 10, '72593^Bad ORD Status', 'us_english'
execute rdt.rdtAddMsg 72594, 10, '72594^PKSLIPNotPrint', 'us_english'
execute rdt.rdtAddMsg 72595, 10, '72595^PS Scanned Out', 'us_english'
execute rdt.rdtAddMsg 72596, 10, '72596^InsPHdrFail',    'us_english'
execute rdt.rdtAddMsg 72597, 10, '72597^InsPHdrFail',    'us_english'
execute rdt.rdtAddMsg 72598, 10, '72598^LockOrdersFail', 'us_english'
execute rdt.rdtAddMsg 72599, 10, '72599^Order Locked',   'us_english'
execute rdt.rdtAddMsg 72600, 10, '72600^ReleaseMobFail', 'us_english'
execute rdt.rdtAddMsg 72601, 10, '72601^DropID needed',  'us_english'
execute rdt.rdtAddMsg 72602, 10, '72602^Bad DropID',     'us_english'
execute rdt.rdtAddMsg 72603, 10, '72603^Bad DropID',     'us_english'
execute rdt.rdtAddMsg 72604, 10, '72604^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 72605, 10, '72605^INSPKLockFail',  'us_english'
execute rdt.rdtAddMsg 72606, 10, '72606^SKU req',        'us_english'
execute rdt.rdtAddMsg 72607, 10, '72607^Invalid SKU',    'us_english'
execute rdt.rdtAddMsg 72608, 10, '72608^SameBarCodeSKU', 'us_english'
execute rdt.rdtAddMsg 72609, 10, '72609^Qty Needed',     'us_english'
execute rdt.rdtAddMsg 72610, 10, '72610^SKUNotInORD',    'us_english'
execute rdt.rdtAddMsg 72611, 10, '72611^Over Pick',      'us_english'
execute rdt.rdtAddMsg 72612, 10, '72612^INSPKLockFail',  'us_english'
execute rdt.rdtAddMsg 72613, 10, '72613^UPDPKLockFail',  'us_english'
execute rdt.rdtAddMsg 72614, 10, '72614^AD UOM X SETUP', 'us_english'
execute rdt.rdtAddMsg 72615, 10, '72615^ConfPackFail',   'us_english'
execute rdt.rdtAddMsg 72616, 10, '72616^ADCode req',     'us_english'
execute rdt.rdtAddMsg 72617, 10, '72617^ADCode exists',  'us_english'
execute rdt.rdtAddMsg 72618, 10, '72618^Upd Fail',       'us_english'
execute rdt.rdtAddMsg 72619, 10, '72619^Upd Fail',       'us_english'
execute rdt.rdtAddMsg 72620, 10, '72620^ConfPackFail',   'us_english'
execute rdt.rdtAddMsg 72621, 10, '72621^Bad Reason',     'us_english'

--SOS270278
execute rdt.rdtAddMsg 72622, 10, '72622^Bad SKU Field',  'us_english'

--SOS280603
execute rdt.rdtAddMsg 72623, 10, '72623^ORD/LOAD req',   'us_english'
execute rdt.rdtAddMsg 72624, 10, '72624^ONLY ORD/LOAD',  'us_english'
execute rdt.rdtAddMsg 72625, 10, '72625^Bad LOADKEY',    'us_english'
execute rdt.rdtAddMsg 72626, 10, '72626^Bad ORD Status', 'us_english'
execute rdt.rdtAddMsg 72627, 10, '72627^PKSLIPNotPrint', 'us_english'
execute rdt.rdtAddMsg 72628, 10, '72628^PS Scanned Out', 'us_english'
execute rdt.rdtAddMsg 72629, 10, '72629^Scan In Fail',   'us_english'
execute rdt.rdtAddMsg 72630, 10, '72630^InsPHdrFail',    'us_english'
execute rdt.rdtAddMsg 72631, 10, '72631^InsPHdrFail',    'us_english'

--SOS305925
execute rdt.rdtAddMsg 72632, 10, '72632^Scan In Fail',    'us_english'
execute rdt.rdtAddMsg 72633, 10, '72633^INSPKLockFail',   'us_english'
execute rdt.rdtAddMsg 72634, 10, '72634^Order CANCEL',    'us_english'

--WMS6939
execute rdt.rdtAddMsg 72635, 10, '72635^Invalid Format',  'us_english'

--WMS13277
execute rdt.rdtAddMsg 72636, 10, '72636^BadCTNType',  'us_english'
execute rdt.rdtAddMsg 72637, 10, '72637^NeedWeight',  'us_english'
execute rdt.rdtAddMsg 72638, 10, '72638^InvalidWeight',  'us_english'
execute rdt.rdtAddMsg 72639, 10, '72639^NeedCube',  'us_english'
execute rdt.rdtAddMsg 72640, 10, '72640^InvalidCube',  'us_english'
execute rdt.rdtAddMsg 155451, 10, '155451InsPackInfoFail',  'us_english'
execute rdt.rdtAddMsg 155452, 10, '155452UpdPackInfoFail',  'us_english'
