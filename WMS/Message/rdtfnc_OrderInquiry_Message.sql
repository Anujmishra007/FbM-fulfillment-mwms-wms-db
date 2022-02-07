--rdtfnc_OrderInquiry
execute rdt.rdtdropmsg 93301 , 93350

GO
DECLARE @nFunc INT

SET @nFunc = 596

execute rdt.rdtAddMsg 93301, 10, '93301^OrderKeyReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 93302, 10, '93302^OrderKeyNotExist',    'us_english',@nFunc

