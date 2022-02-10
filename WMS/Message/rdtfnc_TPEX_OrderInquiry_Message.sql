-- rdtfnc_TPEX_OrderInquiry
-- 94701 - 94750

exec rdt.rdtDropMsg 94701 , 94750
-- ************************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1184

execute rdt.rdtAddMsg 94701, 10, '94701^OrderNotExist', 'us_english', @nFunc
execute rdt.rdtAddMsg 94702, 10, '94702^Order Num req', 'us_english', @nFunc
execute rdt.rdtAddMsg 94703, 10, '94703^Last Record', 'us_english', @nFunc