-- FCR-9003
EXECUTE rdt.rdtDropMsg 252851, 252900

EXECUTE rdt.rdtAddMsg 252851, 10, '252851^InvalidCartID', 'us_english', 803, 0, '252851 Invalid CartID'
EXECUTE rdt.rdtAddMsg 252852, 10, '252852^CartNotEmpty', 'us_english', 803, 0, '252852 Cart is not empty'
EXECUTE rdt.rdtAddMsg 252853, 10, '252853^AssignedToDiffCart', 'us_english', 803, 0, '252853 Station assigned with different cart'
EXECUTE rdt.rdtAddMsg 252854, 10, '252854^AssignedToDiffStation', 'us_english', 803, 0, '252854 Cart assigned to another station'
EXECUTE rdt.rdtAddMsg 252855, 10, '252855^UPD Failed', 'us_english', 803, 0, '252855 UPD RDTPTLPIECELOG fail'
EXECUTE rdt.rdtAddMsg 252856, 10, '^252856Tote belongs to station {}', 'us_english', 803, 0, '252856 Tote belongs to station {}'
EXECUTE rdt.rdtAddMsg 252857, 10, '252857Cannot find station', 'us_english', 803, 0, '252857Can not find station/position'
EXECUTE rdt.rdtAddMsg 252858, 10, '252858Cannot find Order', 'us_english', 803, 0, '252858Can not find SKU in DropID'
EXECUTE rdt.rdtAddMsg 252859, 10, '252859DeviceIDEmpty', 'us_english', 803, 0, '252859DeviceID Can not be empty'
EXECUTE rdt.rdtAddMsg 252860, 10, '252860CartIsNotEpty', 'us_english', 803, 0, '252860Cart is not empty'
EXECUTE rdt.rdtAddMsg 252861, 10, '252861WaveNotComplete', 'us_english', 803, 0, '252861Wave Not Complete'

