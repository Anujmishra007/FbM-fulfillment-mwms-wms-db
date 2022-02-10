--rdtfnc_Scan_Pallet_To_Door
execute rdt.rdtdropmsg 54501 , 54550

execute rdt.rdtAddMsg 54501, 10, '54501^Pallet ID Req',  'us_english', 1650
execute rdt.rdtAddMsg 54502, 10, '54502^Invalid PLT ID', 'us_english', 1650
execute rdt.rdtAddMsg 54503, 10, '54503^PLT >1 MBOL',    'us_english', 1650
execute rdt.rdtAddMsg 54504, 10, '54504^ID No Loadkey ', 'us_english', 1650
execute rdt.rdtAddMsg 54505, 10, '54505^No MBOL       ', 'us_english', 1650
execute rdt.rdtAddMsg 54506, 10, '54506^MBOL Shipped  ', 'us_english', 1650
execute rdt.rdtAddMsg 54507, 10, '54507^DoorNotAssign ', 'us_english', 1650
execute rdt.rdtAddMsg 54508, 10, '54508^Door req      ', 'us_english', 1650
execute rdt.rdtAddMsg 54509, 10, '54509^Invalid Door  ', 'us_english', 1650
execute rdt.rdtAddMsg 54510, 10, '54510^Option Req    ', 'us_english', 1650
execute rdt.rdtAddMsg 54511, 10, '54511^Inv Option    ', 'us_english', 1650
execute rdt.rdtAddMsg 54512, 10, '54512^ID mix storer ', 'us_english', 1650
execute rdt.rdtAddMsg 54513, 10, '54513^NotInStorerGrp', 'us_english', 1650

--(james01)
execute rdt.rdtAddMsg 54514, 10, '54514^PltMultiMbol  ', 'us_english', 1650

