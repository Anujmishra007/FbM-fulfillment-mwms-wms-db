
--rdtfnc_UNI_PTS
-- 104701 , 104750

exec rdt.rdtDropMsg 104701 , 104750
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 761

execute rdt.rdtAddMsg 104701 ,10, '04701^DropIDReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 104702 ,10, '04702^InvalidDropID', 'us_english',@nFunc
execute rdt.rdtAddMsg 104703 ,10, '04703^InsPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 104704 ,10, '04704^PTSPosReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 104705 ,10, '04705^PTSPosNotSame', 'us_english',@nFunc
execute rdt.rdtAddMsg 104706 ,10, '04706^SKUReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 104707 ,10, '04707^InvalidSKU', 'us_english',@nFunc
execute rdt.rdtAddMsg 104708 ,10, '04708^MultiSKUBarCod', 'us_english',@nFunc
execute rdt.rdtAddMsg 104709 ,10, '04709^DiffSKU', 'us_english',@nFunc
execute rdt.rdtAddMsg 104710 ,10, '04710^Invalid QTY', 'us_english',@nFunc
execute rdt.rdtAddMsg 104711 ,10, '04711^Invalid QTY', 'us_english',@nFunc
execute rdt.rdtAddMsg 104712 ,10, '04712^QTY needed', 'us_english',@nFunc
execute rdt.rdtAddMsg 104713 ,10, '04713^ToLabelNoReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 104714 ,10, '04714^OptionReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 104715 ,10, '04715^InvalidOption', 'us_english',@nFunc
execute rdt.rdtAddMsg 104716 ,10, '04716^UpdPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 104717 ,10, '04717^UpdPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 104718 ,10, '04718^NoTask', 'us_english',@nFunc
execute rdt.rdtAddMsg 104719 ,10, '04719^DropIDExist', 'us_english',@nFunc
execute rdt.rdtAddMsg 104720 ,10, '04720^UpdPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 104721 ,10, '04721^InsPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 104722 ,10, '04722^NoTask', 'us_english',@nFunc
execute rdt.rdtAddMsg 104723 ,10, '04723^NoTask', 'us_english',@nFunc
execute rdt.rdtAddMsg 104724 ,10, '04724^NoTask', 'us_english',@nFunc
execute rdt.rdtAddMsg 104725 ,10, '04725^NoTask', 'us_english',@nFunc
execute rdt.rdtAddMsg 104726 ,10, '04726^InvalidFormat', 'us_english',@nFunc