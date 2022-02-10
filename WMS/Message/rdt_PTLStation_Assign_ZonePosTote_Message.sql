--rdt_PTLStation_Assign_ZonePosTote
rdt.rdtDropMsg 166051 , 166100	

execute rdt.rdtAddMsg 166051, 10, '66051^Need WaveKey',     'us_english', 805
execute rdt.rdtAddMsg 166052, 10, '66052^InvalidWaveKey',   'us_english', 805
execute rdt.rdtAddMsg 166053, 10, '66053^Wave no task',     'us_english', 805
execute rdt.rdtAddMsg 166054, 10, '66054^Need Location',    'us_english', 805
execute rdt.rdtAddMsg 166055, 10, '66055^Bad Location',     'us_english', 805
execute rdt.rdtAddMsg 166056, 10, '66056^Pos assigned',     'us_english', 805
execute rdt.rdtAddMsg 166057, 10, '66057^Need CartonID',    'us_english', 805
execute rdt.rdtAddMsg 166058, 10, '66058^Invalid Format',   'us_english', 805
execute rdt.rdtAddMsg 166059, 10, '66059^CartonAssigned',   'us_english', 805
execute rdt.rdtAddMsg 166060, 10, '66060^Carton No Task',   'us_english', 805
execute rdt.rdtAddMsg 166061, 10, '66061^INS Log Fail',     'us_english', 805
execute rdt.rdtAddMsg 166062, 10, '66062^UPD Log Fail',     'us_english', 805
execute rdt.rdtAddMsg 166063, 10, '66063^InvalidWaveKey',   'us_english', 805
execute rdt.rdtAddMsg 166064, 10, '66064^CopyLogDataErr',   'us_english', 805
execute rdt.rdtAddMsg 166065, 10, '66065^UpdLogDataFail',   'us_english', 805

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 166051 AND 166100