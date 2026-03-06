-- rdt_838ExtScn08
-- FCR-10629
EXECUTE rdt.rdtDropMsg 259251, 259300

EXECUTE rdt.rdtAddMsg 259251, 10, '259251^UpdatePackHeaderFail', 'us_english', 838, 0, '259251 Update PackHeader fail'
EXECUTE rdt.rdtAddMsg 259252, 10, '259252^PackComplete',                'us_english', 838, 0, '259252 Packing Complete'
EXECUTE rdt.rdtAddMsg 259253, 10, '259253^PickNotComplete',             'us_english', 838, 0, '259253 Picking not complete'
EXECUTE rdt.rdtAddMsg 259254, 10, '259254^InvalidUOM',                  'us_english', 838, 0, '259254 UCC require Case UOM'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 259251 AND 259300
