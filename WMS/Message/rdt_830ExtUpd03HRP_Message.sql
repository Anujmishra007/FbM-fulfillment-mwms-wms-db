--rdt_830ExtUpd03HRP
--UWP-57192
execute rdt.rdtDropMsg 267451, 267500

execute rdt.rdtAddMsg 267451, 10, '267451 GenUCCLabelNo Failed. (rdt_830ExtUpd03HRP)',             'us_english', 830, 0, '267451 GenUCCLabelNo Failed. (rdt_830ExtUpd03HRP)'
execute rdt.rdtAddMsg 267452, 10, '267452 Insert into TRANSMITLOG3 Failed. (rdt_830ExtUpd03HRP)',  'us_english', 830, 0, '267452 Insert into TRANSMITLOG3 Failed. (rdt_830ExtUpd03HRP)'
execute rdt.rdtAddMsg 267453, 10, '267453 Insert into TRANSMITLOG3 Failed. (rdt_830ExtUpd03HRP)',  'us_english', 830, 0, '267453 Insert into TRANSMITLOG3 Failed. (rdt_830ExtUpd03HRP)'
execute rdt.rdtAddMsg 267454, 10, '267454 UnknownError',                                           'us_english', 830, 0, '267454 Unknown Error happened'

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 267451 AND 267500