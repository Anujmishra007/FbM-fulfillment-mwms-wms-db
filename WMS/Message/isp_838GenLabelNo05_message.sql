--isp_838GenLabelNo05_Message
EXEC rdt.rdtdropmsg 266701, 266750

EXECUTE rdt.rdtAddMsg 266701, 10, '266701^Order Not Found',        'us_english', 838, 0, '266701 Order Not Found'
EXECUTE rdt.rdtAddMsg 266702, 10, '266702^Setup CodeLKUP',         'us_english', 838, 0, '266702 Setup CodeLKUP'
EXECUTE rdt.rdtAddMsg 266703, 10, '266703^Invalid Code2 Value',    'us_english', 838, 0, '266703 Invalid Code2 Value'
EXECUTE rdt.rdtAddMsg 266704, 10, '266704^Invalid Code Value',     'us_english', 838, 0, '266704 Invalid Code Value'
EXECUTE rdt.rdtAddMsg 266705, 10, '266705^UDF01/UDF02 Error',      'us_english', 838, 0, '266705 UDF01/UDF02 Error'
EXECUTE rdt.rdtAddMsg 266706, 10, '266706^Reset nCounter failed',  'us_english', 838, 0, '266706 Reset nCounter failed'
EXECUTE rdt.rdtAddMsg 266707, 10, '266707^Getkey Error',           'us_english', 838, 0, '266707 Getkey Error'
EXECUTE rdt.rdtAddMsg 266708, 10, '266708^Gen LabelNo Fail',       'us_english', 838, 0, '266708 Gen LabelNo Fail'

SELECT * FROM rdt.rdtmsg WITH (NOLOCK) WHERE message_id BETWEEN 266701 AND 266750
