--rdtfnc_SerialNo_Serialize
execute rdt.rdtdropmsg 109801 , 109850
execute rdt.rdtdropmsg 142151 , 142200
GO
DECLARE @nFunc INT

SET @nFunc = 1010

execute rdt.rdtAddMsg 109801, 10, '09801^WorkOrdeRNoReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 109802, 10, '09802^InvdWorkOrder',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109803, 10, '09803^OptionReq',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109804, 10, '09804^InvalidOption',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109805, 10, '09805^SKUReq',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109806, 10, '09806^InvalidSKU',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109807, 10, '09807^MultiSKUBarCod',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109808, 10, '09808^QtyReq',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109809, 10, '09809^Invalid QTY',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109810, 10, '09810^InvalidSKU',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109811, 10, '09811^GenSerialNoFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109812, 10, '09812^GenSerialNoFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109813, 10, '09813^GenSerialNoFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109814, 10, '09814^SKUReq',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109815, 10, '09815^InvalidSKU',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109816, 10, '09816^MultiSKUBarCod',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109817, 10, '09817^InvalidSKU',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109818, 10, '09818^GetKeyFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109819, 10, '09819^InsrdtSerailFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109820, 10, '09820^InvSerialType',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109821, 10, '09821^9LNotCompleted',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109822, 10, '09822^9LNotCompleted',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109823, 10, '09823^UpdrdtSerailFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109824, 10, '09824^InvSerialType',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109825, 10, '09825^InvSerialNo',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109826, 10, '09826^SerialNoScanned',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109827, 10, '09827^InvSerialNo',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109828, 10, '09828^SerialNoScanned',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109829, 10, '09829^UpdrdtSerailFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109830, 10, '09830^ParentSerialReq',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109831, 10, '09831^InvSerialNo',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109832, 10, '09832^SerialNoScanned',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109833, 10, '09833^InsMasterSerialFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109834, 10, '09834^InsMasterSerialFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109835, 10, '09835^UpdrdtSerailFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109836, 10, '09836^InvSerialType',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109837, 10, '09837^DelrdtSerailFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109838, 10, '09838^InvSerialNo',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109839, 10, '09839^InvSerialNo',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109840, 10, '09840^InvalidOption',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109841, 10, '09841^UpdrdtSerailFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109842, 10, '09842^SKUReq',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109843, 10, '09843^InvalidSKU',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109844, 10, '09844^MultiSKUBarCod',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109845, 10, '09845^WrongSKU',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109846, 10, '09846^SKUReq',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109847, 10, '09847^InvalidSKU',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109848, 10, '09848^MultiSKUBarCod',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109849, 10, '09849^WrongSKU',    'us_english',@nFunc 
execute rdt.rdtAddMsg 109850, 10, '09850^InvSerialNo',    'us_english',@nFunc 


execute rdt.rdtAddMsg 142151, 10, '42151^InvSerialNo',    'us_english',@nFunc 
execute rdt.rdtAddMsg 142152, 10, '42152^InvSerialNo',    'us_english',@nFunc 
execute rdt.rdtAddMsg 142153, 10, '42153^Invalid Qty',    'us_english',@nFunc 

-- WMS-12137
execute rdt.rdtAddMsg 142154, 10, '42154^SerialNotExist',    'us_english',@nFunc
--WMS13083
execute rdt.rdtaddmsg 142155, 10, '42155^SerialNotExist','us_english',@nFunc