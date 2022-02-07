
--rdt_573ExtUpdSP01
-- 116201 - 116250

exec rdt.rdtDropMsg 116201 , 116250
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 573

execute rdt.rdtAddMsg 116201 ,10, '16201^UpdReceiptDetFail', 'us_english',@nFunc

