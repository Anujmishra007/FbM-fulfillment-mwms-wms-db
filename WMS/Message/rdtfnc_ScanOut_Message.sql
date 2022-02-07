-- rdtfnc_ScanOut (range 65701 - 65750)
-- EXEC RDT.RDTDROPMSG 65701, 65712
execute rdt.rdtAddMsg 65701, 10, '65701^Pkslip needed',  'us_english'
execute rdt.rdtAddMsg 65702, 10, '65702^Invalid PKSlip', 'us_english'
execute rdt.rdtAddMsg 65703, 10, '65703^PS NotScanIn',   'us_english'
execute rdt.rdtAddMsg 65704, 10, '65704^PS ScanedOut',   'us_english'
execute rdt.rdtAddMsg 65705, 10, '65705^OrderShipped',   'us_english'
execute rdt.rdtAddMsg 65706, 10, '65706^OrderShipped',   'us_english'
execute rdt.rdtAddMsg 65707, 10, '65707^PackNotConfirm', 'us_english'
execute rdt.rdtAddMsg 65708, 10, '65708^PackNotDone',    'us_english'
execute rdt.rdtAddMsg 65709, 10, '65709^nspGetRight',    'us_english'
execute rdt.rdtAddMsg 65710, 10, '65710^nspGetRight',    'us_english'
execute rdt.rdtAddMsg 65711, 10, '65711^LPNotFinalize',  'us_english'
execute rdt.rdtAddMsg 65712, 10, '65712^ScanOutFail',    'us_english'

--SOS132566
execute rdt.rdtAddMsg 65713, 10, '65713^w/BalToPick',    'us_english'
execute rdt.rdtAddMsg 65714, 10, '65714^PKScnOutScsful', 'us_english'

-- SOS#141306
execute rdt.rdtAddMsg 65715, 10, '65715^Diff Storer', 'us_english'
execute rdt.rdtAddMsg 65716, 10, '65716^Diff Facility', 'us_english'


