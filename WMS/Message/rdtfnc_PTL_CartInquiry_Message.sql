
--rdtfnc_PTL_CartInquiry
-- 79701 - 79750

--exec rdt.rdtDropMsg 79701, 79750
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 813

execute rdt.rdtAddMsg 79701 ,10, '79701^CartID/ToteID req', 'us_english',@nFunc
execute rdt.rdtAddMsg 79702 ,10, '79702^Invalid CartID', 'us_english',@nFunc
execute rdt.rdtAddMsg 79703 ,10, '79703^Invalid ToteID', 'us_english',@nFunc
execute rdt.rdtAddMsg 79704 ,10, '79704^Invalid DeviceProfileLogKey', 'us_english',@nFunc
execute rdt.rdtAddMsg 79705 ,10, '79705^CartID/ToteID only', 'us_english',@nFunc
execute rdt.rdtAddMsg 79706 ,10, '79706^Invalid ToteID In New Batch', 'us_english',@nFunc









