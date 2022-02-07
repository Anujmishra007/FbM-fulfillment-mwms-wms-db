--rdt_841ExtValidSP02
--execute rdt.rdtdropmsg 94301 - 94350
GO
DECLARE @nFunc INT

SET @nFunc = 841

execute rdt.rdtAddMsg 94301, 10, '94301^ToteCompleted',    'us_english',@nFunc
execute rdt.rdtAddMsg 94302, 10, '94302^Invalid Tote',     'us_english',@nFunc
execute rdt.rdtAddMsg 94303, 10, '94303^Order Hold',     'us_english',@nFunc
execute rdt.rdtAddMsg 94304, 10, '94304^Waiting Cancel!',     'us_english',@nFunc
execute rdt.rdtAddMsg 94305, 10, '94305^Order Cancelled',     'us_english',@nFunc
execute rdt.rdtAddMsg 94306, 10, '94306^ToteNotPicked',     'us_english',@nFunc


