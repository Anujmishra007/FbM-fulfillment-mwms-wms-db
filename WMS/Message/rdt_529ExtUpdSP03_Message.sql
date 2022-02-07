--rdt_529ExtUpdSP03
--execute rdt.rdtdropmsg 95751 - 95800
GO
DECLARE @nFunc INT

SET @nFunc = 529

execute rdt.rdtAddMsg 95751 ,10, '95751^UpdPickDtlFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 95752 ,10, '95752^UpdPickDtlFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 95753 ,10, '95753^UpdPackDtlFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 95754 ,10, '95754^UpdPackDtlFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 95755 ,10, '95755^DelPackDtlFail', 'us_english',@nFunc

--WMS-14164
execute rdt.rdtAddMsg 95756 ,10, '95756^UpdPKInfoFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 95757 ,10, '95757^InsPKInfoFail', 'us_english',@nFunc
