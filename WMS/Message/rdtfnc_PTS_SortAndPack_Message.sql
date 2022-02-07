
--rdtfnc_PTS_SortAndPack
-- 91201 - 91250

exec rdt.rdtDropMsg 96251 , 96300
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 760

execute rdt.rdtAddMsg 96251 ,10, '96251^DropIDReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 96252 ,10, '96252^InvalidDropID', 'us_english',@nFunc
execute rdt.rdtAddMsg 96253 ,10, '96253^InsPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96254 ,10, '96254^PTSPosReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 96255 ,10, '96255^PTSPosNotSame', 'us_english',@nFunc
execute rdt.rdtAddMsg 96256 ,10, '96256^SKUReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 96257 ,10, '96257^InvalidSKU', 'us_english',@nFunc
execute rdt.rdtAddMsg 96258 ,10, '96258^MultiSKUBarCod', 'us_english',@nFunc
execute rdt.rdtAddMsg 96259 ,10, '96259^DiffSKU', 'us_english',@nFunc
execute rdt.rdtAddMsg 96260 ,10, '96260^Invalid QTY', 'us_english',@nFunc
execute rdt.rdtAddMsg 96261 ,10, '96261^Invalid QTY', 'us_english',@nFunc
execute rdt.rdtAddMsg 96262 ,10, '96262^QTY needed', 'us_english',@nFunc
execute rdt.rdtAddMsg 96263 ,10, '96263^ToLabelNoReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 96264 ,10, '96264^OptionReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 96265 ,10, '96265^InvalidOption', 'us_english',@nFunc
execute rdt.rdtAddMsg 96266 ,10, '96266^UpdPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96267 ,10, '96267^UpdPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96268 ,10, '96268^NoTask', 'us_english',@nFunc
execute rdt.rdtAddMsg 96269 ,10, '96269^DropIDExist', 'us_english',@nFunc
execute rdt.rdtAddMsg 96270 ,10, '96270^UpdPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96271 ,10, '96271^InsPTSLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96272 ,10, '96272^NoTask', 'us_english',@nFunc
execute rdt.rdtAddMsg 96273 ,10, '96273^NoTask', 'us_english',@nFunc
execute rdt.rdtAddMsg 96274 ,10, '96274^NoTask', 'us_english',@nFunc
execute rdt.rdtAddMsg 96275 ,10, '96275^NoTask', 'us_english',@nFunc
execute rdt.rdtAddMsg 96276 ,10, '96276^InvalidFormat', 'us_english',@nFunc
execute rdt.rdtAddMsg 96277 ,10, '96277^Over pack', 'us_english',@nFunc
