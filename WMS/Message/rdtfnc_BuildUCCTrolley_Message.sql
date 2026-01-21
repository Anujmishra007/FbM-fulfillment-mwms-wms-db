--rdtfnc_BuildUCCTrolley
--FCR-9734
rdt.rdtDropMsg 254401, 254450

EXECUTE rdt.rdtAddMsg 254401, 10, '254401TrolleyIDNeeded',              'us_english', 855, 0, '254401 Trolley ID is needed'
EXECUTE rdt.rdtAddMsg 254402, 10, '254402TrolleyIDNeeded',              'us_english', 855, 0, '254402 Trolley ID must be <= 10 characters'
EXECUTE rdt.rdtAddMsg 254403, 10, '254403InvalidTrolleyID',             'us_english', 855, 0, '254403 Trolley ID not in Device Profile'
EXECUTE rdt.rdtAddMsg 254404, 10, '254404InvalidTrolleyID',             'us_english', 855, 0, '254404 Trolley ID bad status'
EXECUTE rdt.rdtAddMsg 254405, 10, '254405InvalidTrolleyID',             'us_english', 855, 0, '254405 Trolley is closed, cannot add more cartons'
EXECUTE rdt.rdtAddMsg 254406, 10, '254406InvalidTrolleyConfig',         'us_english', 855, 0, '254406 Bad trolley configuration'
EXECUTE rdt.rdtAddMsg 254407, 10, '254407BadTrolley',                   'us_english', 855, 0, '254407 Trolley is full'
EXECUTE rdt.rdtAddMsg 254408, 10, '254408UCCNeeded',                    'us_english', 855, 0, '254408 UCC is needed'
EXECUTE rdt.rdtAddMsg 254409, 10, '254409InvalidUCC',                   'us_english', 855, 0, '254409 UCC does not exist'
EXECUTE rdt.rdtAddMsg 254410, 10, '254410BadUCCStatus',                 'us_english', 855, 0, '254410 Bad UCC Status'
EXECUTE rdt.rdtAddMsg 254411, 10, '254411NoOpenTask',                   'us_english', 855, 0, '254411 UCC has no open replenishment task'
EXECUTE rdt.rdtAddMsg 254412, 10, '254412InvalidOption',                'us_english', 855, 0, '254412 Invlid option'
EXECUTE rdt.rdtAddMsg 254413, 10, '254413TrolleyIsFull',                'us_english', 855, 0, '254413 Trolley is full'
EXECUTE rdt.rdtAddMsg 254414, 10, '254414DelTrolleyLogFail',            'us_english', 855, 0, '254414 Delete trolley log failed'
EXECUTE rdt.rdtAddMsg 254415, 10, '254414UpdDeviceProfileFail',         'us_english', 855, 0, '254415 Update DeviceProfile failed'
EXECUTE rdt.rdtAddMsg 254416, 10, '254416TrolleyIsEmpty',               'us_english', 855, 0, '254416 Trolley is empty, cannot close'
EXECUTE rdt.rdtAddMsg 254417, 10, '254417InsLogFail',                   'us_english', 855, 0, '254417 Insert trolley log failed'
EXECUTE rdt.rdtAddMsg 254418, 10, '254418TrolleyIsFull',                'us_english', 855, 0, '254418 Trolley is full'
EXECUTE rdt.rdtAddMsg 254419, 10, '254419UCCScanned',                   'us_english', 855, 0, '254419 UCC already scanned'
EXECUTE rdt.rdtAddMsg 254420, 10, '254420UpdPkdFail',                   'us_english', 855, 0, '254420 Update Pickdetail failed'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 254401 AND 254450 ORDER BY Message_ID