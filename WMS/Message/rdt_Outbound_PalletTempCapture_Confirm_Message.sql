--rdt_Outbound_PalletTempCapture_Confirm_Message
--FCR-1398
execute rdt.rdtdropmsg 230251 ,230300

execute rdt.rdtAddMsg 230251  ,10   ,'230251^GetKeyFail'          ,'us_english'  ,1870 ,0 ,'230251 - Get TemperatureLogID Fail'
execute rdt.rdtAddMsg 230252  ,10   ,'230252^INSTempLogFail'      ,'us_english'  ,1870 ,0 ,'230252 - Insert TemperatureLog Fail'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 230251 AND 230300

