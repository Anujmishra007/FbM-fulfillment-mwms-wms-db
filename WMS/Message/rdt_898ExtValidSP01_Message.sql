
--rdt_898ExtValidSP01
-- 93251 , 93300

exec rdt.rdtDropMsg 93251 , 93300
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 898

execute rdt.rdtAddMsg 93251 ,10, '93251^InvalidUCCNo', 'us_english',@nFunc

-- WMS-15353
execute rdt.rdtAddMsg 93252 ,10, '93252^UCC Status = 6', 'us_english',@nFunc

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 93251 AND 93300

