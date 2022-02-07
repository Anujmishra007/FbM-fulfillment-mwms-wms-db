--rdt_608ExtVal02
execute rdt.rdtdropmsg 120101 - 120150
GO
DECLARE @nFunc INT

SET @nFunc = 608


execute rdt.rdtAddMsg 120101, 10, '120101^NoMixSKUinID',    'us_english',@nFunc
execute rdt.rdtAddMsg 120102, 10, '20102^NoMixSKUinID',    'us_english',@nFunc
execute rdt.rdtAddMsg 120103, 10, '20103^NoMixSKUinID',    'us_english',@nFunc




