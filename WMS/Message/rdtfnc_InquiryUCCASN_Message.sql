
--rdtfnc_InquiryUCCASN
-- 92351 - 92400

exec rdt.rdtDropMsg 92351 , 92400
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 595

execute rdt.rdtAddMsg 92351 ,10, '92351^UCCReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 92352 ,10, '92352^InvalidUCC', 'us_english',@nFunc