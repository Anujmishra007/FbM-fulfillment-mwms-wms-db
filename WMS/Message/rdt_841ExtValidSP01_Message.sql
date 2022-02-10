--rdt_1765ExtValidSP01
--execute rdt.rdtdropmsg 90501 , 90550
GO
DECLARE @nFunc INT

SET @nFunc = 841

execute rdt.rdtAddMsg 90501, 10, '90501^ToteCompleted',    'us_english',@nFunc
execute rdt.rdtAddMsg 90502, 10, '90502^Invalid Tote',     'us_english',@nFunc
execute rdt.rdtAddMsg 90503, 10, '90503^Order Hold',     'us_english',@nFunc
execute rdt.rdtAddMsg 90504, 10, '90504^Waiting Cancel!',     'us_english',@nFunc
execute rdt.rdtAddMsg 90505, 10, '90505^Order Cancelled',     'us_english',@nFunc
execute rdt.rdtAddMsg 90506, 10, '90506^ToteNotPicked',     'us_english',@nFunc


