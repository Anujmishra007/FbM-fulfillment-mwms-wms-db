
--rdt_895ExtValidSP01
-- 93801 - 93850

--exec rdt.rdtDropMsg 93801 - 93850
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 895

execute rdt.rdtAddMsg 93801 ,10, '93801^InvalidLot09', 'us_english',@nFunc
execute rdt.rdtAddMsg 93802 ,10, '93802^InvalidUCCQty', 'us_english',@nFunc
execute rdt.rdtAddMsg 93803 ,10, '93803^InvalidUCC', 'us_english',@nFunc
execute rdt.rdtAddMsg 93804 ,10, '93804^UCCScanned', 'us_english',@nFunc
execute rdt.rdtAddMsg 93805 ,10, '93805^InvalidUCC', 'us_english',@nFunc
execute rdt.rdtAddMsg 93806 ,10, '93806^InvalidSKU', 'us_english',@nFunc
execute rdt.rdtAddMsg 93807 ,10, '93807^UCCScanned', 'us_english',@nFunc
execute rdt.rdtAddMsg 93808 ,10, '93808^PONotMatch', 'us_english',@nFunc
execute rdt.rdtAddMsg 93809 ,10, '93809^InvalidUCCQty', 'us_english',@nFunc
execute rdt.rdtAddMsg 93810 ,10, '93810^CountNotMatch', 'us_english',@nFunc