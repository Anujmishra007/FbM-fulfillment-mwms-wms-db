
--rdtfnc_TMS_OrderInquiry
-- 100001 - 100050


exec rdt.rdtDropMsg 100001 , 100050
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1186

execute rdt.rdtAddMsg 100001 ,10, '00001^RecNotFound', 'us_english',@nFunc
execute rdt.rdtAddMsg 100002 ,10, '00002^RecNotFound', 'us_english',@nFunc