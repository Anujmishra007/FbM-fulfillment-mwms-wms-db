--rdt_PTLStation_Assign_DropCarton
execute rdt.rdtdropmsg 213051, 213100
GO
DECLARE @nFunc INT

SET @nFunc = 805

execute rdt.rdtAddMsg 213051, 10, '213051^DropIDNeeded',                               'us_english',@nFunc
execute rdt.rdtAddMsg 213052, 10, '213052^InvalidDropID',                              'us_english',@nFunc
execute rdt.rdtAddMsg 213053, 10, '213053^DiffDropID',                                 'us_english',@nFunc
execute rdt.rdtAddMsg 213054, 10, '213054^NoPickTask',                                 'us_english',@nFunc
execute rdt.rdtAddMsg 213055, 10, '213055^InsPTLLogFail',                              'us_english',@nFunc
execute rdt.rdtAddMsg 213056, 10, '213056^PTLLocNeeded',                               'us_english',@nFunc
execute rdt.rdtAddMsg 213057, 10, '213057^InvalidPTLLoc',                              'us_english',@nFunc
execute rdt.rdtAddMsg 213058, 10, '213058^NeedCartonID',                               'us_english',@nFunc
execute rdt.rdtAddMsg 213059, 10, '213059^LocAssigned',                                'us_english',@nFunc
execute rdt.rdtAddMsg 213060, 10, '213060^CartonAssigned',                             'us_english',@nFunc
execute rdt.rdtAddMsg 213061, 10, '213061^UPDLogFail',                                 'us_english',@nFunc
execute rdt.rdtAddMsg 213062, 10, '213062^NoLocAvaiable',                              'us_english',@nFunc
execute rdt.rdtAddMsg 213063, 10, '213063^CartonDiffWave',                             'us_english',@nFunc

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 213051 AND 213100