-- rdtfnc_PostPickAudit 
execute rdt.rdtDropMsg 60851, 60900
execute rdt.rdtDropMsg 179001, 179050

execute rdt.rdtAddMsg 60851, 10, '60851^Value required', 'us_english'
execute rdt.rdtAddMsg 60852, 10, '60852^Key-in either1', 'us_english'
execute rdt.rdtAddMsg 60853, 10, '60853^REFNO req     ', 'us_english'
execute rdt.rdtAddMsg 60854, 10, '60854^PSNO  req     ', 'us_english'
execute rdt.rdtAddMsg 60855, 10, '60855^LOADKEY req   ', 'us_english'
execute rdt.rdtAddMsg 60856, 10, '60856^ORDERKEY req  ', 'us_english'
execute rdt.rdtAddMsg 60857, 10, '60857^CARTON ID req ', 'us_english'
execute rdt.rdtAddMsg 60858, 10, '60858^Invalid Ref#  ', 'us_english'
execute rdt.rdtAddMsg 60859, 10, '60859^Not Scan-in   ', 'us_english'
execute rdt.rdtAddMsg 60860, 10, '60860^Not Scan-out  ', 'us_english'
execute rdt.rdtAddMsg 60861, 10, '60861^Invalid PS#   ', 'us_english'
execute rdt.rdtAddMsg 60862, 10, '60862^Not scan-in   ', 'us_english'
execute rdt.rdtAddMsg 60863, 10, '60863^Not scan-out  ', 'us_english'
execute rdt.rdtAddMsg 60864, 10, '60864^InvalidLoadKey', 'us_english'
execute rdt.rdtAddMsg 60865, 10, '60865^Not Scan-in   ', 'us_english'
execute rdt.rdtAddMsg 60866, 10, '60866^Not Scan-out  ', 'us_english'
execute rdt.rdtAddMsg 60867, 10, '60867^Inv OrderKey  ', 'us_english'
execute rdt.rdtAddMsg 60868, 10, '60868^Not Scan-in   ', 'us_english'
execute rdt.rdtAddMsg 60869, 10, '60869^Not Scan-out  ', 'us_english'
execute rdt.rdtAddMsg 60870, 10, '60870^Inv CARTON ID ', 'us_english'
execute rdt.rdtAddMsg 60871, 10, '60871^Inv CARTON ID ', 'us_english'
execute rdt.rdtAddMsg 60872, 10, '60872^SKU required  ', 'us_english'
execute rdt.rdtAddMsg 60873, 10, '60873^Invalid SKU   ', 'us_english'
execute rdt.rdtAddMsg 60874, 10, '60874^QTY required  ', 'us_english'
execute rdt.rdtAddMsg 60875, 10, '60875^Invalid QTY   ', 'us_english'
execute rdt.rdtAddMsg 60876, 10, '60876^SKU NotInList ', 'us_english'
execute rdt.rdtAddMsg 60877, 10, '60877^Over Tolerance', 'us_english'
execute rdt.rdtAddMsg 60878, 10, '60878^Fail INS PPA  ', 'us_english'
execute rdt.rdtAddMsg 60879, 10, '60879^Fail UPD PPA  ', 'us_english'
execute rdt.rdtAddMsg 60880, 10, '60880^Inv Carton ID ', 'us_english'
execute rdt.rdtAddMsg 60881, 10, '60881^OptionRequired', 'us_english'
execute rdt.rdtAddMsg 60882, 10, '60882^Invalid Option', 'us_english'
execute rdt.rdtAddMsg 60883, 10, '60883^OptionRequired', 'us_english'
execute rdt.rdtAddMsg 60884, 10, '60884^Invalid Option', 'us_english'
execute rdt.rdtAddMsg 60885, 10, '60885^MultiSKUBarcod', 'us_english'
execute rdt.rdtAddMsg 60886, 10, '60886^Invalid SKU   ', 'us_english'

-- WMS1256
execute rdt.rdtAddMsg 60887, 10, '60887^Invalid CaseID', 'us_english'

--WMS8002
execute rdt.rdtAddMsg 60888, 10, '60888^Pallet ID req ', 'us_english'
execute rdt.rdtAddMsg 60889, 10, '60889^TaskKey req   ', 'us_english'
execute rdt.rdtAddMsg 60890, 10, '60890^Inv TaskKey',    'us_english'

execute rdt.rdtAddMsg 60891, 10, '60891^NoSkuFound',    'us_english'
execute rdt.rdtAddMsg 60892, 10, '60892^NoSkuFound',    'us_english'

--WMS17279
execute rdt.rdtAddMsg 60893, 10, '60893^InvReasonCode',    'us_english'

--WMS17439
execute rdt.rdtAddMsg 60894, 10, '60894^NeedCartonType', 'us_english'
execute rdt.rdtAddMsg 60895, 10, '60895^Bad CTN TYPE  ', 'us_english'
execute rdt.rdtAddMsg 60896, 10, '60896^Need Weight   ', 'us_english'
execute rdt.rdtAddMsg 60897, 10, '60897^Invalid Format', 'us_english'
execute rdt.rdtAddMsg 60898, 10, '60898^Invalid weight', 'us_english'
execute rdt.rdtAddMsg 60899, 10, '60899^Need Cube     ', 'us_english'
execute rdt.rdtAddMsg 60900, 10, '60900^Invalid cube  ', 'us_english'

execute rdt.rdtAddMsg 179001, 10, '179001INSPackInfFail', 'us_english'
execute rdt.rdtAddMsg 179002, 10, '179002UPDPackInfFail', 'us_english'
execute rdt.rdtAddMsg 179002, 10, '179002UPDPackInfFail', 'us_english'




SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE message_id BETWEEN 60851 and 60900
SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE message_id BETWEEN 179001 AND 179050
