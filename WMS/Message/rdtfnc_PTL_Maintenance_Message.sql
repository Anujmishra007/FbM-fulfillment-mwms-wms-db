
--rdtfnc_PTL_Maintenance
-- 81801 - 81850

exec rdt.rdtDropMsg 81801 , 81850
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 814

execute rdt.rdtAddMsg 81801 ,10, '81801^DeviceID req',        'us_english',@nFunc
execute rdt.rdtAddMsg 81802 ,10, '81802^Invalid DeviceID',    'us_english',@nFunc
execute rdt.rdtAddMsg 81803 ,10, '81803^InvalidIPAddress',    'us_english',@nFunc
execute rdt.rdtAddMsg 81804 ,10, '81804^InvalidLightModule',  'us_english',@nFunc
execute rdt.rdtAddMsg 81805 ,10, '81805^InvalidIPAddress',    'us_english',@nFunc
execute rdt.rdtAddMsg 81806 ,10, '81806^InvalidLightModule',  'us_english',@nFunc
execute rdt.rdtAddMsg 81807 ,10, '81807^InvalidOption',       'us_english',@nFunc
execute rdt.rdtAddMsg 81808 ,10, '81808^MaintenanceComplete', 'us_english',@nFunc
execute rdt.rdtAddMsg 81809 ,10, '81809^MaintenanceComplete', 'us_english',@nFunc
execute rdt.rdtAddMsg 81810 ,10, '81810^MaintenanceComplete', 'us_english',@nFunc
execute rdt.rdtAddMsg 81811 ,10, '81811^LightAddNotFound',    'us_english',@nFunc
execute rdt.rdtAddMsg 81812 ,10, '81812^LightModuleReq',      'us_english',@nFunc
execute rdt.rdtAddMsg 81813 ,10, '81813^MaintenanceComplete', 'us_english',@nFunc
execute rdt.rdtAddMsg 81814 ,10, '81814^LightModuleReq',      'us_english',@nFunc
execute rdt.rdtAddMsg 81815 ,10, '81815^MaintenanceComplete', 'us_english',@nFunc
execute rdt.rdtAddMsg 81816 ,10, '81816^LightAddNotFound',    'us_english',@nFunc
execute rdt.rdtAddMsg 81817 ,10, '81817^LightModuleReq',      'us_english',@nFunc
execute rdt.rdtAddMsg 81818 ,10, '81818^MaintenanceComplete', 'us_english',@nFunc
execute rdt.rdtAddMsg 81819 ,10, '81819^UpdDropIDFail',       'us_english',@nFunc
execute rdt.rdtAddMsg 81820 ,10, '81820^UpdPTLTranFail',      'us_english',@nFunc
execute rdt.rdtAddMsg 81821 ,10, '81821^UpdDProfileLogFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 81822 ,10, '81822^UpdDProfileFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 81823 ,10, '81823^UpdDropIDFail',       'us_english',@nFunc
execute rdt.rdtAddMsg 81824 ,10, '81824^UpdPTLTranFail',      'us_english',@nFunc
execute rdt.rdtAddMsg 81825 ,10, '81825^UpdDProfileLogFail',  'us_english',@nFunc
execute rdt.rdtAddMsg 81826 ,10, '81826^UpdDProfileFail',     'us_english',@nFunc
execute rdt.rdtAddMsg 81827 ,10, '81827^DelRdtAssignLocFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 81828 ,10, '81828^Reset Complete',      'us_english',@nFunc







