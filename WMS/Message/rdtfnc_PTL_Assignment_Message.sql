
--rdtfnc_PTL_Assignment
-- 83701 - 83750
-- 87801 - 87850

exec rdt.rdtDropMsg 83701 , 83750
exec rdt.rdtDropMsg 87801 , 87850
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 815

execute rdt.rdtAddMsg 83701 ,10, '83701^Either 1 field Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 83702 ,10, '83702^Invalid CartID', 'us_english',@nFunc
execute rdt.rdtAddMsg 83703 ,10, '83703^CartInUse', 'us_english',@nFunc
execute rdt.rdtAddMsg 83704 ,10, '83704^UpdLightLocFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83705 ,10, '83705^InvalidPTSZone', 'us_english',@nFunc
execute rdt.rdtAddMsg 83706 ,10, '83706^UpdLightLocFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83707 ,10, '83707^LightLoc Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 83708 ,10, '83708^LightLocAssigned', 'us_english',@nFunc
execute rdt.rdtAddMsg 83709 ,10, '83709^LightLocDiffZone', 'us_english',@nFunc
execute rdt.rdtAddMsg 83710 ,10, '83710^ToteID Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 83711 ,10, '83711^InsDProfileLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83712 ,10, '83712^OptionReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 83713 ,10, '83713^InvalidOption', 'us_english',@nFunc
execute rdt.rdtAddMsg 83714 ,10, '83714^UpdDProfileLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83715 ,10, '83715^OptionReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 83716 ,10, '83716^InvalidOption', 'us_english',@nFunc
execute rdt.rdtAddMsg 83717 ,10, '83717^UpdDProfileLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83718 ,10, '83718^NoAssignmentDone', 'us_english',@nFunc
execute rdt.rdtAddMsg 83719 ,10, '83719^InvalidPosition', 'us_english',@nFunc
execute rdt.rdtAddMsg 83720 ,10, '83720^UpdDProfileFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83721 ,10, '83721^CartAssigned', 'us_english',@nFunc
execute rdt.rdtAddMsg 83722 ,10, '83722^PTSZoneAssigned', 'us_english',@nFunc
execute rdt.rdtAddMsg 83723 ,10, '83723^InsDropIDFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83724 ,10, '83724^CartInUse', 'us_english',@nFunc
execute rdt.rdtAddMsg 83725 ,10, '83725^InvToteNo', 'us_english',@nFunc
execute rdt.rdtAddMsg 83726 ,10, '83726^ToteAssigned', 'us_english',@nFunc
execute rdt.rdtAddMsg 83727 ,10, '83727^UpdDropIDFailed', 'us_english',@nFunc
execute rdt.rdtAddMsg 83728 ,10, '83728^InsDropIDFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83729 ,10, '83729^PTSZoneInUse', 'us_english',@nFunc
execute rdt.rdtAddMsg 83730 ,10, '83730^InvalidToteID', 'us_english',@nFunc
execute rdt.rdtAddMsg 83731 ,10, '83731^InvalidToteID', 'us_english',@nFunc
execute rdt.rdtAddMsg 83732 ,10, '83732^InsDropIDFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83733 ,10, '83733^GetKeyFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83734 ,10, '83734^UpdDropIDDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83735 ,10, '83735^UpdDropIDFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83736 ,10, '83736^InvalidToteID', 'us_english',@nFunc
execute rdt.rdtAddMsg 83737 ,10, '83737^GetKeyFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83738 ,10, '83738^UpdDropIDDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83739 ,10, '83739^UpdDropIDFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83740 ,10, '83740^InsDropIDFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83741 ,10, '83741^WaveKey Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 83742 ,10, '83742^InvalidWaveKey', 'us_english',@nFunc
execute rdt.rdtAddMsg 83743 ,10, '83743^LocNotSame', 'us_english',@nFunc
execute rdt.rdtAddMsg 83744 ,10, '83744^PTSZoneAssigned', 'us_english',@nFunc
execute rdt.rdtAddMsg 83745 ,10, '83745^UpdAssignLocFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83746 ,10, '83746^UpdAssignLocFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83747 ,10, '83747^AssignNotConfirm', 'us_english',@nFunc
execute rdt.rdtAddMsg 83748 ,10, '83748^AssignNotComplete', 'us_english',@nFunc

-- (Chee01)
execute rdt.rdtAddMsg 83749 ,10, '83749^AssignNotConfirm', 'us_english',@nFunc

-- (Chee02)
execute rdt.rdtAddMsg 83750 ,10, '83750^DelDProfileLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 87801 ,10, '87801^DelDropIDFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 87802 ,10, '87802^InvalidToteID', 'us_english',@nFunc

-- (Chee03)
execute rdt.rdtAddMsg 87803 ,10, '87803^Invalid Option', 'us_english',@nFunc
execute rdt.rdtAddMsg 87804 ,10, '87804^DropIDNotClose', 'us_english',@nFunc
execute rdt.rdtAddMsg 87805 ,10, '87805^UpdPTLTranFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 87806 ,10, '87806^UpdDProfileLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 87807 ,10, '87807^UpdDProfileFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 87808 ,10, '87808^DropIDNotClose', 'us_english',@nFunc
execute rdt.rdtAddMsg 87809 ,10, '87809^UpdPTLTranFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 87810 ,10, '87810^UpdDProfileLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 87811 ,10, '87811^UpdDProfileFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 87812 ,10, '87812^GenAssignmentFail', 'us_english',@nFunc

--(yeekung01)
execute rdt.rdtAddMsg 87813 ,10, '87813^WaveAssign', 'us_english',@nFunc
execute rdt.rdtAddMsg 87814 ,10, '87814ToteNotComp', 'us_english',@nFunc