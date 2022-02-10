
--rdt_PTL_OrderPicking_InsertPTLTran
-- 79751 - 79800

exec rdt.rdtDropMsg 79751 - 79800
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 811

execute rdt.rdtAddMsg 79751 ,10, '79751^UpdPTLTranFail', 'us_english',@nFunc









