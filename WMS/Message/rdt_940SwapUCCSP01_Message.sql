
--rdt_940SwapUCCSP01
-- 93451 ,  93500

exec rdt.rdtDropMsg 93451 ,  93500
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 940

execute rdt.rdtAddMsg 93451 ,10, '93451^Invalid UCC ', 'us_english',@nFunc
execute rdt.rdtAddMsg 93452 ,10, '93452^Invalid UCC', 'us_english',@nFunc
execute rdt.rdtAddMsg 93453 ,10, '93453^NoUCCToSwap', 'us_english',@nFunc
execute rdt.rdtAddMsg 93454 ,10, '93454^Upd PKDtl fail', 'us_english',@nFunc
execute rdt.rdtAddMsg 93455 ,10, '93455^UpdReplenfail', 'us_english',@nFunc
execute rdt.rdtAddMsg 93456 ,10, '93456^UpdNewUCCfail', 'us_english',@nFunc
execute rdt.rdtAddMsg 93457 ,10, '93457^UpdOldUCCfail', 'us_english',@nFunc
execute rdt.rdtAddMsg 93458 ,10, '93458^UpdPDFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 93459 ,10, '93459^InvalidUCC', 'us_english',@nFunc
execute rdt.rdtAddMsg 93460 ,10, '93460^InvalidUCC', 'us_english',@nFunc
execute rdt.rdtAddMsg 93461 ,10, '93461^InvalidUCC', 'us_english',@nFunc
execute rdt.rdtAddMsg 93462 ,10, '93462^InvalidUCC', 'us_english',@nFunc
execute rdt.rdtAddMsg 93463 ,10, '93463^InvalidUCC', 'us_english',@nFunc
execute rdt.rdtAddMsg 93464 ,10, '93464^Invalid UCC ', 'us_english',@nFunc
execute rdt.rdtAddMsg 93465 ,10, '93465^Invalid UCC', 'us_english',@nFunc
execute rdt.rdtAddMsg 93466 ,10, '93466^NoUCCToSwap', 'us_english',@nFunc
execute rdt.rdtAddMsg 93467 ,10, '93467^Invalid UCC', 'us_english',@nFunc
execute rdt.rdtAddMsg 93468 ,10, '93468^Invalid UCC', 'us_english',@nFunc