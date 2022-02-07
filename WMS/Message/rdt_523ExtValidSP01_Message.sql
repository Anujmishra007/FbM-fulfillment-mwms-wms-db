
--rdt_523ExtValidSP01
-- 93501 , 93550


exec rdt.rdtDropMsg 93501,  93550

-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 523

execute rdt.rdtAddMsg 93501 ,10, '93501^InvalidLoc', 'us_english',@nFunc

