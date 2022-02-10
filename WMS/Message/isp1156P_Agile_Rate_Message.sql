/************************************************************/
/* RDT message range for isp1156P_Agile_Rate: 75451 - 75500 */ 
/************************************************************/

-- 75451: WSConfig.ini File Path is empty. (isp1156P_Agile_Rate) 
EXECUTE rdt.rdtAddMsg 75451 ,10, '75451^INV WSCONFPATH', 'us_english'

-- 75452: Failed to obtain InterfaceLogID. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75452 ,10, '75452^GET LOGID FAIL', 'us_english'

-- 75453: Failed to obtain FileKey. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75453 ,10, '75453^GET FLKEY FAIL', 'us_english'

-- 75454: Rate Request is only required when Payment Term is PP or PC. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75454 ,10, '75454^PMTTRM<>PP/PC', 'us_english'

-- 75455: Carrier Code is empty. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75455 ,10, '75455^INV CARRCODE', 'us_english'

-- 75456: Service Type is empty. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75456 ,10, '75456^INV SERVTYPE', 'us_english'

-- 75457: Receive Street is empty. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75457 ,10, '75457^INV RCVSTREET', 'us_english'

-- 75458: Receive City is empty. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75458 ,10, '75458^INV RCVCITY', 'us_english'

-- 75459: Receive Region is empty. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75459 ,10, '75459^INV RCVREGION', 'us_english'

-- 75460: Receive Postal Code is empty. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75460 ,10, '75460^INV RCVZIP', 'us_english'

-- 75461: Receive Country is empty. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75461 ,10, '75461^INV RCVCOUNTRY', 'us_english'

-- 75462: Package Weight is empty. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75462 ,10, '75462^INV PACKWEIGHT', 'us_english'

-- 75463: Failed to obtain BatchNo. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75463 ,10, '75463^GET BATNO FAIL', 'us_english'

-- 75464: Error inserting into [DTSITF].[dbo].[WebService_Log] Table. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75464 ,10, '75464^INSRT LOG FAIL', 'us_english'

-- 75465: Error executing [master].[dbo].[isp_GenericWebServiceClient]. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75465 ,10, '75465^SEND WS FAIL', 'us_english'

-- 75466: Error updating [DTSITF].[dbo].[WebService_Log] Table. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75466 ,10, '75466^UPDT LOG FAIL', 'us_english'

-- 75467: Error inserting into [DTSITF].[dbo].[WebService_Log] Table. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75467 ,10, '75467^INSRT LOG FAIL', 'us_english'

-- 75468: Incorrect Transaction Identifier returned. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75468 ,10, '75468^WRG TRNSCTN ID', 'us_english'

-- 75469: Respond Failed (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75469 ,10, '75469^WS RESP FAIL', 'us_english'

-- 75470: Shipping Charge is empty. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75470 ,10, '75470^INV SHIPCHRGE', 'us_english'

-- 75471: Accessorial Charge is empty. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75471 ,10, '75471^INV ACSSCHRGE', 'us_english'

-- 75472: Error updating [dbo].[CartonShipmentDetail] Table. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75472 ,10, '75472^UPDT CSD FAIL', 'us_english'

-- 75473: Invalid Status Code. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75473 ,10, '75473^INV STATUSCODE', 'us_english'


-- NEW

-- 75474: nspGetRight AgileProcess Failed. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75474 ,10, '75474^GETRIGHT FAIL', 'us_english'

-- 75475: Error inserting into [dbo].[CartonShipmentDetail] Table. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75475 ,10, '75475^INSRT CSD FAIL', 'us_english'

-- 75476: Package Type is empty. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75476 ,10, '75476^INV PKGTYPE', 'us_english'

-- 75477: Agile Web Service Request URL is empty. (isp1156P_Agile_Rate) 
EXECUTE rdt.rdtAddMsg 75477 ,10, '75477^INV AGILE URL', 'us_english'