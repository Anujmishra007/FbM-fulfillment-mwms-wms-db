--rdt_1796SwapTaskSP01
execute rdt.rdtdropmsg 106551 , 106600
GO
DECLARE @nFunc INT

SET @nFunc = 1796

execute rdt.rdtAddMsg 106551, 10, '06551^UpdTaskdetFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 106552, 10, '06552^UpdTaskdetFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 106553, 10, '06553^UpdRFPAFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 106554, 10, '06554^UpdRFPAFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 106555, 10, '06555^UpdLLIFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 106556, 10, '06556^UpdLLIFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 106557, 10, '06557^InvalidUCC',    'us_english',@nFunc
execute rdt.rdtAddMsg 106558, 10, '06558^InvalidUCC',    'us_english',@nFunc



