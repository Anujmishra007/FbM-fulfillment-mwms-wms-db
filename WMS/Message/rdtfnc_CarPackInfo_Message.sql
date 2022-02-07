--Message Range 157701 - 157750 (rdtfnc_CarPackInfo)
execute rdt.rdtDropMsg 157701,157750

execute rdt.rdtAddMsg 157701, 10, '57701DestinationReq ', 'us_english',1847
execute rdt.rdtAddMsg 157702, 10, '157702NeedVehicleNo ', 'us_english',1847
execute rdt.rdtAddMsg 157703, 10, '157703Key Either One', 'us_english',1847
execute rdt.rdtAddMsg 157704, 10, '157704InvalidTrackNo', 'us_english',1847
execute rdt.rdtAddMsg 157705, 10, '157705^INS Fail     ', 'us_english',1847
execute rdt.rdtAddMsg 157706, 10, '157706^Option Req   ', 'us_english',1847
execute rdt.rdtAddMsg 157707, 10, '157707^InvalidOption', 'us_english',1847
execute rdt.rdtAddMsg 157708, 10, '157708Key Either One', 'us_english',1847
execute rdt.rdtAddMsg 157709, 10, '157709IvalidMbolKey ', 'us_english',1847
execute rdt.rdtAddMsg 157710, 10, '157710^INS Fail     ', 'us_english',1847

--WMS-16798
execute rdt.rdtAddMsg 157711, 10, '157711^Option Req   ', 'us_english',1847
execute rdt.rdtAddMsg 157712, 10, '157712^InvalidOption', 'us_english',1847
execute rdt.rdtAddMsg 157713, 10, '157713TrackingNo Req', 'us_english',1847
execute rdt.rdtAddMsg 157714, 10, '157714CartonType Reg', 'us_english',1847
execute rdt.rdtAddMsg 157715, 10, '157715InvalidTrackNo', 'us_english',1847
execute rdt.rdtAddMsg 157716, 10, '157716No SF_PreSales', 'us_english',1847
execute rdt.rdtAddMsg 157717, 10, '157717InvalidCtnType', 'us_english',1847
execute rdt.rdtAddMsg 157718, 10, '157718^INS Fail     ', 'us_english',1847
execute rdt.rdtAddMsg 157719, 10, '157719^Ins TL2 Err  ', 'us_english',1847
execute rdt.rdtAddMsg 157720, 10, '157720TrackNo Exists', 'us_english',1847
execute rdt.rdtAddMsg 157721, 10, '157721TrackNo Exists', 'us_english',1847
execute rdt.rdtAddMsg 157722, 10, '157722TrackNo Exists', 'us_english',1847

--WMS-17147
execute rdt.rdtAddMsg 157723, 10, '157723^PelletID Req ', 'us_english',1847
execute rdt.rdtAddMsg 157724, 10, '157724^UPD Fail     ', 'us_english',1847
execute rdt.rdtAddMsg 157725, 10, '157725^PelletID Req ', 'us_english',1847
execute rdt.rdtAddMsg 157726, 10, '157726TrackingNo Req', 'us_english',1847
execute rdt.rdtAddMsg 157727, 10, '157727Not Pre Del   ', 'us_english',1847
execute rdt.rdtAddMsg 157728, 10, '157728^UPD Fail     ', 'us_english',1847
execute rdt.rdtAddMsg 157729, 10, '157729TrackNo Exists', 'us_english',1847

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 157701 AND 157750

--INSERT INTO rdt.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text,StoredProcName, EventType, Func, URL)
--VALUES (1847, 'ENG','FNC', 'Car Pack Info','rdtfnc_CarPackInfo',2 ,0,'')

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID ='1847'



