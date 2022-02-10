--rdt_1664ExtValidSP01
execute rdt.rdtdropmsg 91101 , 91150
GO
DECLARE @nFunc INT

SET @nFunc = 1664

execute rdt.rdtAddMsg 91101, 10, '91101^CarrierKeyDifferent',    'us_english',@nFunc
execute rdt.rdtAddMsg 91102, 10, '91102^UserDefine02Different',     'us_english',@nFunc
execute rdt.rdtAddMsg 91103, 10, '91103^CCountryDifferent',     'us_english',@nFunc
execute rdt.rdtAddMsg 91104, 10, '91104^OrderTypeDifferent',     'us_english',@nFunc



