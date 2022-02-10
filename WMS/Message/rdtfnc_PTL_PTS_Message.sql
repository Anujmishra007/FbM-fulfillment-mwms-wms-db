
--rdtfnc_PTL_PTS
-- 83801 - 83850
-- 86051 - 86100

exec rdt.rdtDropMsg 83801, 83850
exec rdt.rdtDropMsg 86051, 86100
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 816

execute rdt.rdtAddMsg 83801 ,10, '83801^BAD PTSZONE', 'us_english',@nFunc
execute rdt.rdtAddMsg 83802 ,10, '83802^BAD PTSZONE', 'us_english',@nFunc
execute rdt.rdtAddMsg 83803 ,10, '83803^INV PAPER PRT', 'us_english',@nFunc
execute rdt.rdtAddMsg 83804 ,10, '83804^UPD PRT FA', 'us_english',@nFunc
execute rdt.rdtAddMsg 83805 ,10, '83805^INV LABEL PRT', 'us_english',@nFunc
execute rdt.rdtAddMsg 83806 ,10, '83806^UPD PRT FA', 'us_english',@nFunc
execute rdt.rdtAddMsg 83807 ,10, '83807^NoPaperPrinter', 'us_english',@nFunc
execute rdt.rdtAddMsg 83808 ,10, '83808^NoLabelPrinter', 'us_english',@nFunc
execute rdt.rdtAddMsg 83809 ,10, '83809^ToteIDOrUCCReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 83810 ,10, '83810^InvalidTote', 'us_english',@nFunc

execute rdt.rdtAddMsg 83811 ,10, '83811^ToteNotPciked', 'us_english',@nFunc
execute rdt.rdtAddMsg 83812 ,10, '83812^UCCNotExists', 'us_english',@nFunc
execute rdt.rdtAddMsg 83813 ,10, '83813^InvalidUCC', 'us_english',@nFunc
execute rdt.rdtAddMsg 83814 ,10, '83814^InvalidUCC', 'us_english',@nFunc
execute rdt.rdtAddMsg 83815 ,10, '83815^UCCNotPick', 'us_english',@nFunc
execute rdt.rdtAddMsg 83816 ,10, '83816^ToteNotPick', 'us_english',@nFunc
execute rdt.rdtAddMsg 83817 ,10, '83817^InvalidOption', 'us_english',@nFunc
execute rdt.rdtAddMsg 83818 ,10, '83818^CartonIDReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 83819 ,10, '83819^InvalidCarton', 'us_english',@nFunc

execute rdt.rdtAddMsg 83820 ,10, '83820^PickNotComplete', 'us_english',@nFunc

execute rdt.rdtAddMsg 83821 ,10, '83821^InvalidOption', 'us_english',@nFunc

execute rdt.rdtAddMsg 83822 ,10, '83822^CartonIDReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 83823 ,10, '83823^CartonExistInPTS', 'us_english',@nFunc
execute rdt.rdtAddMsg 83824 ,10, '83824^PTSLocReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 83825 ,10, '83825^LightLocDiffZone', 'us_english',@nFunc
execute rdt.rdtAddMsg 83826 ,10, '83826^InvalidPosition', 'us_english',@nFunc
execute rdt.rdtAddMsg 83827 ,10, '83827^InsDProfileLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83828 ,10, '83828^InsDropIDFail', 'us_english',@nFunc

execute rdt.rdtAddMsg 83829 ,10, '83829^UpdDeviceProfileLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83830 ,10, '83830^UpdDropIDFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83831 ,10, '83831^UpdDropIDFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83832 ,10, '83832^UpdPTLTranFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83833 ,10, '83833^PickNotComplete', 'us_english',@nFunc
execute rdt.rdtAddMsg 83834 ,10, '83834^PickNotComplete', 'us_english',@nFunc
execute rdt.rdtAddMsg 83835 ,10, '83835^UpdDropIDDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83836 ,10, '83836^UpdPackHeaderFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83837 ,10, '83837^UCCScanned', 'us_english',@nFunc
execute rdt.rdtAddMsg 83838 ,10, '83838^ToteNotPack', 'us_english',@nFunc
execute rdt.rdtAddMsg 83839 ,10, '83839^PrevTaskNotComplete', 'us_english',@nFunc
execute rdt.rdtAddMsg 83840 ,10, '83840^UpdPTLTranFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83841 ,10, '83841^ObjNotSameWaveKey', 'us_english',@nFunc

execute rdt.rdtAddMsg 83842 ,10, '83842^PTSZoneNotAssigned', 'us_english',@nFunc
execute rdt.rdtAddMsg 83843 ,10, '83843^UpdPickInfoFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83844 ,10, '83844^UpdDeviceProFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83845 ,10, '83845^NoMoreTask', 'us_english',@nFunc
execute rdt.rdtAddMsg 83846 ,10, '83846^ScanOnly1Field', 'us_english',@nFunc

execute rdt.rdtAddMsg 83847 ,10, '83847^InvalidCarton', 'us_english',@nFunc
execute rdt.rdtAddMsg 83848 ,10, '83848^ToteNotPack', 'us_english',@nFunc
execute rdt.rdtAddMsg 83849 ,10, '83849^UpdDeviceProfileLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83850 ,10, '83850^UpdDropIDFail', 'us_english',@nFunc

--86051, 86100
execute rdt.rdtAddMsg 86051 ,10, '86051^UpdPackHeaderFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 86052 ,10, '86052^UpdPickInfoFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 86053 ,10, '86053^UpdDeviceProFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 86054 ,10, '86054^NoMoreTAsk', 'us_english',@nFunc
execute rdt.rdtAddMsg 86055 ,10, '86055^CartonClosed', 'us_english',@nFunc
execute rdt.rdtAddMsg 86056 ,10, '86056^CartonClosed', 'us_english',@nFunc
execute rdt.rdtAddMsg 86057 ,10, '86057^WrongPTSZone', 'us_english',@nFunc
execute rdt.rdtAddMsg 86058 ,10, '86058^WrongPTSZone', 'us_english',@nFunc
execute rdt.rdtAddMsg 86059 ,10, '86059^UpdDropIDDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 86060 ,10, '86060^DelPTLTranFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 86061 ,10, '86061^PackNotComplete', 'us_english',@nFunc
execute rdt.rdtAddMsg 86062 ,10, '86062^PackNotComplete', 'us_english',@nFunc
execute rdt.rdtAddMsg 86063 ,10, '86063^Option Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 86064 ,10, '86064^InvalidOption', 'us_english',@nFunc
execute rdt.rdtAddMsg 86065 ,10, '86065^InvalidCartonID', 'us_english',@nFunc

execute rdt.rdtAddMsg 86066 ,10, '86066^PickPackQtyNotMatch', 'us_english',@nFunc
execute rdt.rdtAddMsg 86067 ,10, '86067^SHORT PICK UCC', 'us_english',@nFunc

execute rdt.rdtAddMsg 86068 ,10, '86068^RESIDUAL PA', 'us_english',@nFunc
execute rdt.rdtAddMsg 86069 ,10, '86069^UpdWCSRODetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 86070 ,10, '86070^UpdWCSROFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 86071 ,10, '86071^LightInProcess', 'us_english',@nFunc
execute rdt.rdtAddMsg 86072 ,10, '86072^DropIDExist', 'us_english',@nFunc

execute rdt.rdtAddMsg 86073 ,10, '86073^DelPTLTranFail', 'us_english',@nFunc
