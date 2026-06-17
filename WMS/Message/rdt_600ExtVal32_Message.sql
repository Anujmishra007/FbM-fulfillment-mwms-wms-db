-- 270501 - 270550

EXECUTE rdt.rdtDropMsg 270501, 270550

EXECUTE rdt.rdtAddMsg 270501, 10, '270501^Invalid PCS DOT format',   'us_english', 600
EXECUTE rdt.rdtAddMsg 270502, 10, '270502^Invalid PCS DOT format',   'us_english', 600
EXECUTE rdt.rdtAddMsg 270503, 10, '270503^Invalid PCS DOT week',     'us_english', 600
EXECUTE rdt.rdtAddMsg 270504, 10, '270504^Long life > REXLOG',       'us_english', 600
EXECUTE rdt.rdtAddMsg 270505, 10, '270505^DOT year mismatch',        'us_english', 600
EXECUTE rdt.rdtAddMsg 270506, 10, '270506^DOT 8-week rule error',    'us_english', 600

select * from rdt.RDTMSG where MsgNo between 270501 and 270550
