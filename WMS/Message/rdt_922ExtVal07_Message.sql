
-- rdt_922ExtVal07
exec rdt.rdtDropMsg 94851 , 94900

execute rdt.rdtAddMsg 94851, 10, '94851^DIFF MBOLKEY',   'us_english'
execute rdt.rdtAddMsg 94852, 10, '94852^ORD NO REGION',  'us_english'
execute rdt.rdtAddMsg 94853, 10, '94853^MBOL>1 REGION',  'us_english'

-- error msg to be shown in MsgQueue
execute rdt.rdtAddMsg 94854, 10, '94854^INVALID REGION', 'us_english'
execute rdt.rdtAddMsg 94855, 10, '94855^PLS TRY A',      'us_english'
execute rdt.rdtAddMsg 94856, 10, '94856^NEW MBOL.',      'us_english'

--WMS-17659
execute rdt.rdtAddMsg 94857, 10, '94857^MBOL>100Parcel', 'us_english'
execute rdt.rdtAddMsg 94858, 10, '94858^MBOL>100Parcel', 'us_english'
execute rdt.rdtAddMsg 94859, 10, '94859^MBOLMixCourier', 'us_english'