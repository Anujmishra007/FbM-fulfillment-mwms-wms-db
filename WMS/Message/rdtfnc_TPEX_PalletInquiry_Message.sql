-- rdtfnc_TPEX_PalletInquiry
-- 94401 - 94450

exec rdt.rdtDropMsg 94401, 94450
-- ************************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1181

execute rdt.rdtAddMsg 94401, 10, '94401^IDNotExist', 'us_english', @nFunc
execute rdt.rdtAddMsg 94402, 10, '94402^PalletID req', 'us_english', @nFunc






execute rdt.rdtAddMsg 94403, 10, '94403^Last Record', 'us_english', @nFunc