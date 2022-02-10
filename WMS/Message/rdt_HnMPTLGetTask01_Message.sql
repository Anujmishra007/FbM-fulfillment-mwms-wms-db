--rdt_HnMPTLGetTask01
-- 79801 - 79850

exec rdt.rdtDropMsg 51001 , 51050
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 811

execute rdt.rdtAddMsg 51001 ,10, '51001^NoTask!',        'us_english', @nFunc
execute rdt.rdtAddMsg 51002 ,10, '51002^UpdDPFail',      'us_english', @nFunc
execute rdt.rdtAddMsg 51003 ,10, '51003^UpdDPLogFail',   'us_english', @nFunc



