-- rdt_838ExtVal39
-- FCR-10629
EXECUTE rdt.rdtDropMsg 259201, 259250

EXECUTE rdt.rdtAddMsg 259201, 10, '259201^PickNotComplete',  'us_english', 838, 0, '259201 Picking not complete'
EXECUTE rdt.rdtAddMsg 259202, 10, '259202^InvalidPDUOM',     'us_english', 838, 0, '259202 Invalid PickDetail UOM'
EXECUTE rdt.rdtAddMsg 259203, 10, '259203^RefNo Required',   'us_english', 838, 0, '259203 RefNo Required'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 259201 AND 259250

