
--rdt_760ExtUpdSP02
-- 98501 - 98550

exec rdt.rdtDropMsg 98501 - 98550
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 760

execute rdt.rdtAddMsg 98501 ,10, '98501^InsPTLLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 98502 ,10, '98502^UpdPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 98503 ,10, '98503^InsPackHFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 98504 ,10, '98504^InsPickInfoFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 98505 ,10, '98505^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 98506 ,10, '98506^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 98507 ,10, '98507^GetKeyFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 98508 ,10, '98508^InsPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 98509 ,10, '98509^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 98510 ,10, '98510^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 98511 ,10, '98511^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 98512 ,10, '98512^UpdPackDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 98513 ,10, '98513^InsPackDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 98514 ,10, '98514^UpdPackHdrFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 98515 ,10, '98515^UpdPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 98516 ,10, '98516^UpdPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 98517 ,10, '98517^UpdPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 98518 ,10, '98518^InsPTLLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 98519 ,10, '98519^InvalidToLabel', 'us_english',@nFunc
execute rdt.rdtAddMsg 98520 ,10, '98520^DropIDSorted', 'us_english',@nFunc
execute rdt.rdtAddMsg 98521 ,10, '98521^InvalidQty', 'us_english',@nFunc
execute rdt.rdtAddMsg 98522 ,10, '98522^InvalidDropID', 'us_english',@nFunc