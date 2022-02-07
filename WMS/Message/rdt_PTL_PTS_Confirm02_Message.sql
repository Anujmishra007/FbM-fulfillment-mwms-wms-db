
--isp_PTL_PTS_Confirm02
-- 84051 , 84100

exec rdt.rdtDropMsg 91501 , 91550
-- **********************************************
GO
DECLARE @nFunc INT



execute rdt.rdtAddMsg 91501 ,10, '91501^TerminalModule Fail', 'us_english'
execute rdt.rdtAddMsg 91502 ,10, '91502^UpdPTLTran Fail', 'us_english'
execute rdt.rdtAddMsg 91503 ,10, '91503^UpdPTLTran Fail', 'us_english'
execute rdt.rdtAddMsg 91504 ,10, '91504^UpdPackDetFail', 'us_english'
execute rdt.rdtAddMsg 91505 ,10, '91505^OverPacked', 'us_english'
execute rdt.rdtAddMsg 91506 ,10, '91506^UpdPackDetFail', 'us_english'
execute rdt.rdtAddMsg 91507 ,10, '91507^InsPackDetFail', 'us_english'
execute rdt.rdtAddMsg 91508 ,10, '91508^UpdPackDetFail', 'us_english'
execute rdt.rdtAddMsg 91509 ,10, '91509^InsPackDetFail', 'us_english'
execute rdt.rdtAddMsg 91510 ,10, '91510^UpdPickDetFail', 'us_english'
execute rdt.rdtAddMsg 91511 ,10, '91511^UpdPickDetFail', 'us_english'
execute rdt.rdtAddMsg 91512 ,10, '91512^GetKeyFail', 'us_english'
execute rdt.rdtAddMsg 91513 ,10, '91513^InsPickDetFail', 'us_english'
execute rdt.rdtAddMsg 91514 ,10, '91514^UpdPickDetFail', 'us_english'
execute rdt.rdtAddMsg 91515 ,10, '91515^UpdPickDetFail', 'us_english'
execute rdt.rdtAddMsg 91516 ,10, '91516^UpdPickDetFail', 'us_english'
execute rdt.rdtAddMsg 91516 ,10, '91516^UpdPickDetFail', 'us_english'
execute rdt.rdtAddMsg 91517 ,10, '91517^UpdPTLTran Fail', 'us_english'
execute rdt.rdtAddMsg 91517 ,10, '91517^InsPackInfoFail', 'us_english'
execute rdt.rdtAddMsg 91518 ,10, '91518^UpdDeviceProfileFail', 'us_english'
execute rdt.rdtAddMsg 91519 ,10, '91519^UpdDeviceProfileFail', 'us_english'
execute rdt.rdtAddMsg 91520 ,10, '91520^UpdDropIDFail', 'us_english'
execute rdt.rdtAddMsg 91521 ,10, '91521^InsDropIDDetFail', 'us_english'
execute rdt.rdtAddMsg 91522 ,10, '91522^UpdPackHdrFail', 'us_english'
execute rdt.rdtAddMsg 91523 ,10, '91523^UpdPackDetFail', 'us_english'
execute rdt.rdtAddMsg 91524 ,10, '91524^InsPackDetFail', 'us_english'
execute rdt.rdtAddMsg 91525 ,10, '91525^InsPackHFail', 'us_english'
execute rdt.rdtAddMsg 91526 ,10, '91526^UpdDeviceProfileFail', 'us_english'
execute rdt.rdtAddMsg 91527 ,10, '91527^UpdDeviceProfileLogFail', 'us_english'
execute rdt.rdtAddMsg 91528 ,10, '91528^UpdDeviceProfileFail', 'us_english'
execute rdt.rdtAddMsg 91529 ,10, '91529^UpdDeviceProfileLogFail', 'us_english'
execute rdt.rdtAddMsg 91530 ,10, '91530^InsPickingInfoFail', 'us_english'
execute rdt.rdtAddMsg 91531 ,10, '91531^UpdPTLTran Fail', 'us_english'
execute rdt.rdtAddMsg 91532 ,10, '91532^Terminate Light Fail', 'us_english'
execute rdt.rdtAddMsg 91533 ,10, '91533^Light Up Fail', 'us_english'
execute rdt.rdtAddMsg 91534 ,10, '91534^Terminate Light Fail', 'us_english'
execute rdt.rdtAddMsg 91535 ,10, '91535^Light Up Fail', 'us_english'
execute rdt.rdtAddMsg 91536 ,10, '91536^Light Up Fail', 'us_english'
execute rdt.rdtAddMsg 91537 ,10, '91537^UpdPTLTran Fail', 'us_english'
execute rdt.rdtAddMsg 91538 ,10, '91538^Light Up Fail', 'us_english'
execute rdt.rdtAddMsg 91539 ,10, '91539^Light Up Fail', 'us_english'
execute rdt.rdtAddMsg 91540 ,10, '91540^Terminate Light Fail', 'us_english'
execute rdt.rdtAddMsg 91541 ,10, '91541^Light Up Fail', 'us_english'
execute rdt.rdtAddMsg 91542 ,10, '91542^Terminate Light Fail', 'us_english'
execute rdt.rdtAddMsg 91543 ,10, '91543^Light Up Fail', 'us_english'
execute rdt.rdtAddMsg 91544 ,10, '91544^PTLKeyNotFound', 'us_english'