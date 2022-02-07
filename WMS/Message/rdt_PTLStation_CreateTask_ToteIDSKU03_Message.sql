--rdt_PTLStation_CreateTask_ToteIDSKU03
--execute rdt.rdtdropmsg 119701 - 119750
GO
DECLARE @nFunc INT

SET @nFunc = 805

execute rdt.rdtAddMsg 119701, 10, '19701^AssignmentNotFound',    'us_english',@nFunc
execute rdt.rdtAddMsg 119702, 10, '19702^NoTask',    'us_english',@nFunc
execute rdt.rdtAddMsg 119703, 10, '19703^InsertLogFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 119704, 10, '19704^AssignCartonID',    'us_english',@nFunc
execute rdt.rdtAddMsg 119705, 10, '19705^DiffWaveKey',    'us_english',@nFunc
execute rdt.rdtAddMsg 119706, 10, '19706^INSPTLTranFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 119707, 10, '19707^InvalidLoc',    'us_english',@nFunc





