-- rdtfnc_Receive_By_Pallet 
execute rdt.rdtDropMsg 97401 , 97450

execute rdt.rdtAddMsg 97401, 10, '97401^VALUE REQ',      'us_english', 1823
execute rdt.rdtAddMsg 97402, 10, '97402^ASN NOT EXISTS', 'us_english', 1823
execute rdt.rdtAddMsg 97403, 10, '97403^ASN NOT EXISTS', 'us_english', 1823
execute rdt.rdtAddMsg 97404, 10, '97404^REF NOT EXISTS', 'us_english', 1823
execute rdt.rdtAddMsg 97405, 10, '97405^ASN NOT EXISTS', 'us_english', 1823
execute rdt.rdtAddMsg 97406, 10, '97406^REF NOT EXISTS', 'us_english', 1823
execute rdt.rdtAddMsg 97407, 10, '97407^FACILITY DIFF',  'us_english', 1823
execute rdt.rdtAddMsg 97408, 10, '97408^STORER DIFF',    'us_english', 1823
execute rdt.rdtAddMsg 97409, 10, '97409^ASN IS CLOSED',  'us_english', 1823
execute rdt.rdtAddMsg 97410, 10, '97410^PALLET ID REQ',  'us_english', 1823
execute rdt.rdtAddMsg 97411, 10, '97411^INVALID PALLET', 'us_english', 1823
execute rdt.rdtAddMsg 97412, 10, '97412^ID RECEIVED B4', 'us_english', 1823
execute rdt.rdtAddMsg 97413, 10, '97413^SSCC REQUIRED',  'us_english', 1823
execute rdt.rdtAddMsg 97414, 10, '97414^WRONG SSCC',     'us_english', 1823
execute rdt.rdtAddMsg 97415, 10, '97415^NO MORE REC',    'us_english', 1823
execute rdt.rdtAddMsg 97416, 10, '97416^INVALID OPTION', 'us_english', 1823
execute rdt.rdtAddMsg 97417, 10, '97417^PALLET ID REQ',  'us_english', 1823
execute rdt.rdtAddMsg 97418, 10, '97418^INV PALLET ID',  'us_english', 1823
execute rdt.rdtAddMsg 97419, 10, '97419^RCV TO DIFF ID', 'us_english', 1823
execute rdt.rdtAddMsg 97420, 10, '97420^FINALIZE ERROR', 'us_english', 1823
execute rdt.rdtAddMsg 97421, 10, '97421^WRONG SSCC',     'us_english', 1823

--sp_grep 'SSCCDECODE '
--'rdt.rdt_600DecodeSP01' 
                                