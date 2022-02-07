
--rdtfnc_Replenishment
--93651 , 93700

--exec rdt.rdtDropMsg 93651,  93700
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 895


execute rdt.rdtAddMsg 93651 ,10, '93651^WaveKeyReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 93652 ,10, '93652^InvalidWaveKey', 'us_english',@nFunc
execute rdt.rdtAddMsg 93653 ,10, '93653^No more task', 'us_english',@nFunc
execute rdt.rdtAddMsg 93654 ,10, '93654^Invalid Option', 'us_english',@nFunc
execute rdt.rdtAddMsg 93655 ,10, '93655^No Selection', 'us_english',@nFunc
execute rdt.rdtAddMsg 93656 ,10, '93656^Only1ZoneAllow', 'us_english',@nFunc
execute rdt.rdtAddMsg 93657 ,10, '93657^No more PAZone', 'us_english',@nFunc
execute rdt.rdtAddMsg 93658 ,10, '93658^FromLocReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 93659 ,10, '93659^InvalidLoc', 'us_english',@nFunc
execute rdt.rdtAddMsg 93660 ,10, '93660^InvalidID', 'us_english',@nFunc
execute rdt.rdtAddMsg 93661 ,10, '93661^SKUReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 93662 ,10, '93662^InvalidSKU', 'us_english',@nFunc
execute rdt.rdtAddMsg 93663 ,10, '93663^MultiSKUBarCod', 'us_english',@nFunc
execute rdt.rdtAddMsg 93664 ,10, '93664^DifferentSKU', 'us_english',@nFunc
execute rdt.rdtAddMsg 93665 ,10, '93665^Invalid QTY', 'us_english',@nFunc
execute rdt.rdtAddMsg 93666 ,10, '93666^Invalid QTY', 'us_english',@nFunc
execute rdt.rdtAddMsg 93667 ,10, '93667^QTY needed', 'us_english',@nFunc
execute rdt.rdtAddMsg 93668 ,10, '93668^QTYAvalNotEnuf', 'us_english',@nFunc
execute rdt.rdtAddMsg 93669 ,10, '93669^TO LOC needed', 'us_english',@nFunc
execute rdt.rdtAddMsg 93670 ,10, '93670^Invalid LOC', 'us_english',@nFunc
execute rdt.rdtAddMsg 93671 ,10, '93671^Diff facility', 'us_english',@nFunc
execute rdt.rdtAddMsg 93672 ,10, '93672^Diff Loc', 'us_english',@nFunc
execute rdt.rdtAddMsg 93673 ,10, '93673^Upd RPL Fail', 'us_english',@nFunc
execute rdt.rdtAddMsg 93674 ,10, '93674^InvalidLoc', 'us_english',@nFunc
execute rdt.rdtAddMsg 93675 ,10, '93675^InvalidID', 'us_english',@nFunc
execute rdt.rdtAddMsg 93676 ,10, '93676^UpdRPLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 93677 ,10, '93677^OptionReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 93678 ,10, '93678^OptionReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 93679, 10, '93679^UpdReplenLogFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93680, 10, '93680^NoReplenRecord',    'us_english',@nFunc
execute rdt.rdtAddMsg 93681 ,10, '93681^OptionReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 93682 ,10, '93682^Invalid Option', 'us_english',@nFunc
execute rdt.rdtAddMsg 93683 ,10, '93683^DELReplenLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 93684 ,10, '93684^ReplenNotFound', 'us_english',@nFunc
execute rdt.rdtAddMsg 93685 ,10, '93685^ZoneInUse', 'us_english',@nFunc
execute rdt.rdtAddMsg 93686 ,10, '93686^ZoneInUse', 'us_english',@nFunc
execute rdt.rdtAddMsg 93687 ,10, '93687^NoMoreTaskInZone', 'us_english',@nFunc
execute rdt.rdtAddMsg 93688 ,10, '93688^InvalidLoc', 'us_english',@nFunc
execute rdt.rdtAddMsg 93689 ,10, '93689^OptionReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 93690 ,10, '93690^InvalidOption', 'us_english',@nFunc
execute rdt.rdtAddMsg 93691 ,10, '93691^NoReplenRecord', 'us_english',@nFunc

--(ChewKP03) 
execute rdt.rdtAddMsg 93692 ,10, '93692^InvalidValue', 'us_english',@nFunc

--WMS-10875
execute rdt.rdtAddMsg 93693 ,10, '93693^CancBookingErr', 'us_english',@nFunc
execute rdt.rdtAddMsg 93694 ,10, '93694^BookingToLocEr', 'us_english',@nFunc
execute rdt.rdtAddMsg 93695 ,10, '93695^BookingToLocEr', 'us_english',@nFunc
execute rdt.rdtAddMsg 93696 ,10, '93696^Upd PickLOC Er', 'us_english',@nFunc
execute rdt.rdtAddMsg 93697 ,10, '93697^Upd RPLLog Err', 'us_english',@nFunc
execute rdt.rdtAddMsg 93698 ,10, '93698^Upd RPL LOC Er', 'us_english',@nFunc

