-- rdt_1812ExtUpd05
--253651 - 253700


execute rdt.rdtDropMsg 253651, 253700

execute rdt.rdtAddMsg 253651, 10, '253651^TaskKeyEmpty',    'us_english', 1812
execute rdt.rdtAddMsg 253652, 10, '253652^NoTaskFound',     'us_english', 1812
execute rdt.rdtAddMsg 253653, 10, '253653^FromLocEmpty',     'us_english', 1812
execute rdt.rdtAddMsg 253654, 10, '253654^SKUEmpty',         'us_english', 1812
execute rdt.rdtAddMsg 253655, 10, '253655^WaveKeyEmpty',     'us_english', 1812
execute rdt.rdtAddMsg 253656, 10, '253656^NoQcmdConfig',     'us_english', 1812
execute rdt.rdtAddMsg 253657, 10, '253657^InvalidSPName',    'us_english', 1812
execute rdt.rdtAddMsg 253658, 10, '253658^QcmdFail',         'us_english', 1812
execute rdt.rdtAddMsg 253659, 10, '253659^SubmitQcmdFail',   'us_english', 1812

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 125365172536515751 and 253700
