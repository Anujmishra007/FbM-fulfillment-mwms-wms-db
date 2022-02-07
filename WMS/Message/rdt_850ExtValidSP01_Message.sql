
--rdt_850ExtValidSP01
-- 86251 - 86300

exec rdt.rdtDropMsg 86251 , 86300
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 850

execute rdt.rdtAddMsg 86251, 10, '86251^InvalidPickSlipNo', 'us_english', @nFunc
execute rdt.rdtAddMsg 86252, 10, '86252^InvalidPickSlipNo', 'us_english', @nFunc
execute rdt.rdtAddMsg 86253, 10, '86253^InsPickInfoFail', 'us_english', @nFunc
execute rdt.rdtAddMsg 86254, 10, '86254^UpdPickInfoFail', 'us_english', @nFunc
execute rdt.rdtAddMsg 86255, 10, '86255^InsPickInfoFail', 'us_english', @nFunc
execute rdt.rdtAddMsg 86256, 10, '86256^UpdPickInfoFail', 'us_english', @nFunc



