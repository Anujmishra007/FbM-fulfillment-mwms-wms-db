-- rdt_1812ExtUpd07
--270101 - 270150

execute rdt.rdtDropMsg 270101, 270150

execute rdt.rdtAddMsg 270101, 10, '270101^TaskKeyEmpty',     'us_english', 1812, 0, '270101: Task key empty'
execute rdt.rdtAddMsg 270102, 10, '270102^NoTaskFound',      'us_english', 1812, 0, '270102: Task not found'
execute rdt.rdtAddMsg 270103, 10, '270103^FromLocEmpty',     'us_english', 1812, 0, '270103: From loc empty'
execute rdt.rdtAddMsg 270104, 10, '270104^SKUEmpty',         'us_english', 1812, 0, '270104: SKU empty'
execute rdt.rdtAddMsg 270105, 10, '270105^WaveKeyEmpty',     'us_english', 1812, 0, '270105: Wave key empty'
execute rdt.rdtAddMsg 270106, 10, '270106^NoQcmdConfig',     'us_english', 1812, 0, '270106: No QCmd config found'
execute rdt.rdtAddMsg 270107, 10, '270107^InvalidSPName',    'us_english', 1812, 0, '270107: Invalid stored proc name'
execute rdt.rdtAddMsg 270108, 10, '270108^QcmdFail',         'us_english', 1812, 0, '270108: Submit QCmd fail'
execute rdt.rdtAddMsg 270109, 10, '270109^SubmitQcmdFail',   'us_english', 1812, 0, '270109: Generate QCmd task fail'

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 270101 AND 270150