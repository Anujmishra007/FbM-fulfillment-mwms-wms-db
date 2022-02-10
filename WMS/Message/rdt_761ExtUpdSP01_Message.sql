
--rdt_761ExtUpdSP01
-- 96751 - 96800

exec rdt.rdtDropMsg 96751 , 96800
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 760

execute rdt.rdtAddMsg 96751 ,10, '96751^InsPTLLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96752 ,10, '96752^InsPTLLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96753 ,10, '96753^UpdPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96754 ,10, '96754^InsPackHFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96756 ,10, '96756^InsPickInfoFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96757 ,10, '96757^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96758 ,10, '96758^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96759 ,10, '96759^GetKeyFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96760 ,10, '96760^InsPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96761 ,10, '96761^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96762 ,10, '96762^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96763 ,10, '96763^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96764 ,10, '96764^UpdPackDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96765 ,10, '96765^InsPackDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96766 ,10, '96766^UpdPackHdrFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96767 ,10, '96767^UpdPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96768 ,10, '96768^UpdPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96769 ,10, '96769^InsPTLLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96770 ,10, '96770^DropIDNotExist', 'us_english',@nFunc
execute rdt.rdtAddMsg 96771 ,10, '96771^UpdPTLTranFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96772 ,10, '96772^UpdPTLockLocFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96773 ,10, '96773^QtyReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 96774 ,10, '96774^InvalidQty', 'us_english',@nFunc
execute rdt.rdtAddMsg 96775 ,10, '96775^UpdDropIDFail', 'us_english',@nFunc