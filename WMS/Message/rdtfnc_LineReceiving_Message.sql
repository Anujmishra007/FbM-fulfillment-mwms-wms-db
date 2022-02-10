-- rdtfnc_LineReceiving
execute rdt.rdtDropMsg 50851, 50900

execute rdt.rdtAddMsg 50851, 10, '50851 Need ASN or PO', 'us_english', 537
execute rdt.rdtAddMsg 50852, 10, '50852 ASN not exist ', 'us_english', 537
execute rdt.rdtAddMsg 50853, 10, '50853 PO not exist  ', 'us_english', 537
execute rdt.rdtAddMsg 50854, 10, '50854 ASN not exist ', 'us_english', 537
execute rdt.rdtAddMsg 50855, 10, '50855 Multi POInASN ', 'us_english', 537
execute rdt.rdtAddMsg 50856, 10, '50856 PO not exist  ', 'us_english', 537
execute rdt.rdtAddMsg 50857, 10, '50857 Multi ASNInPO ', 'us_english', 537
execute rdt.rdtAddMsg 50858, 10, '50858 Diff facility ', 'us_english', 537
execute rdt.rdtAddMsg 50859, 10, '50859 Diff storer   ', 'us_english', 537
execute rdt.rdtAddMsg 50860, 10, '50860 ASN is closed ', 'us_english', 537
execute rdt.rdtAddMsg 50861, 10, '50861 Need LOC      ', 'us_english', 537
execute rdt.rdtAddMsg 50862, 10, '50862 Invalid LOC   ', 'us_english', 537
execute rdt.rdtAddMsg 50863, 10, '50863 LOC not in FAC', 'us_english', 537
execute rdt.rdtAddMsg 50864, 10, '50864 ToID in used  ', 'us_english', 537
execute rdt.rdtAddMsg 50865, 10, '50865 Need LineNo   ', 'us_english', 537
execute rdt.rdtAddMsg 50866, 10, '50866 Invalid LineNo', 'us_english', 537
execute rdt.rdtAddMsg 50867, 10, '50867 Line not exist', 'us_english', 537
execute rdt.rdtAddMsg 50868, 10, '50868 Invalid Date  ', 'us_english', 537
execute rdt.rdtAddMsg 50869, 10, '50869 NeedLottable01', 'us_english', 537
execute rdt.rdtAddMsg 50870, 10, '50870 NeedLottable02', 'us_english', 537
execute rdt.rdtAddMsg 50871, 10, '50871 NeedLottable03', 'us_english', 537
execute rdt.rdtAddMsg 50872, 10, '50872 NeedLottable04', 'us_english', 537
execute rdt.rdtAddMsg 50873, 10, '50873 Invalid date  ', 'us_english', 537
execute rdt.rdtAddMsg 50874, 10, '50874 Invalid QTY   ', 'us_english', 537
execute rdt.rdtAddMsg 50875, 10, '50875 Invalid QTY   ', 'us_english', 537
execute rdt.rdtAddMsg 50876, 10, '50876 Invalid QTY   ', 'us_english', 537
execute rdt.rdtAddMsg 50877, 10, '50877 Bad ReasonCode', 'us_english', 537
execute rdt.rdtAddMsg 50878, 10, '50878 NotInStorerGrp', 'us_english', 537

-- SOS364967
execute rdt.rdtAddMsg 50879, 10, '50879^INVALID FORMAT', 'us_english'

