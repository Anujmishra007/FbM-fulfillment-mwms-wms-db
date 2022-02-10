/*************************************************************************/
/* RDT message range for isp1155P_Agile_ShipmentToHold: 75651 - 75700    */ 
/*************************************************************************/

-- 75651: WSConfig.ini File Path is empty. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75651 ,10, '75651^INV WSCONFPATH', 'us_english'

-- 75652: Carrier Code is empty. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75652 ,10, '75652^INV CARRCODE', 'us_english'

-- 75653: Service Type is empty. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75653 ,10, '75653^INV SERVTYPE', 'us_english'

-- 75654: Receive Street is empty. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75654 ,10, '75654^INV RCVSTREET', 'us_english'

-- 75655: Receive City is empty. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75655 ,10, '75655^INV RCVCITY', 'us_english'

-- 75656: Receive Region is empty. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75656 ,10, '75656^INV RCVREGION', 'us_english'

-- 75657: Receive Postal Code is empty. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75657 ,10, '75657^INV RCVZIP', 'us_english'

-- 75658: Receive Country is empty. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75658 ,10, '75658^INV RCVCOUNTRY', 'us_english'

-- 75659: Package Receiver Name is empty. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75659 ,10, '75659^INV PKGRCVNAME', 'us_english'

-- 75660: Package Receive Phone is empty. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75660 ,10, '75660^INV PKGRCVPHON', 'us_english'

-- 75661: Package Type is empty. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75661 ,10, '75661^INV PKGTYPE', 'us_english'

-- 75662: Package Weight is empty. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75662 ,10, '75662^INV PACKWEIGHT', 'us_english'

-- 75663: Failed to obtain BatchNo. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75663 ,10, '75663^GET BATNO FAIL', 'us_english'

-- 75664: Error inserting into [DTSITF].[dbo].[WebService_Log] Table. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75664 ,10, '75664^INSRT LOG FAIL', 'us_english'

-- 75665: Error executing [master].[dbo].[isp_GenericWebServiceClient]. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75665 ,10, '75665^SEND WS FAIL', 'us_english'

-- 75666: Error updating [DTSITF].[dbo].[WebService_Log] Table. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75666 ,10, '75666^UPDT LOG FAIL', 'us_english'

-- 75667: Error inserting into [DTSITF].[dbo].[WebService_Log] Table. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75667 ,10, '75667^INSRT LOG FAIL', 'us_english'

-- 75668: Incorrect Transaction Identifier returned. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75668 ,10, '75668^WRG TRNSCTN ID', 'us_english'

-- 75669: Respond Failed (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75669 ,10, '75669^WS RESP FAIL', 'us_english'

-- 75670: Tracking Number is empty. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75670 ,10, '75670^INV TRACKINGNO', 'us_english'

-- 75671: Error updating [dbo].[PackDetail] Table. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75671 ,10, '75671^UPDT PKDT FAIL', 'us_english'

-- 75672: Error updating [dbo].[Orders] Table. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75672 ,10, '75672^UPDT ORD FAIL', 'us_english'

-- 75673: Error inserting into [dbo].[CartonShipmentDetail] Table. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75673 ,10, '75673^INSRT CSD FAIL', 'us_english'

-- 75674: Invalid Status Code. (isp1156P_Agile_Rate)
EXECUTE rdt.rdtAddMsg 75674 ,10, '75674^INV STATUSCODE', 'us_english'

-- NEW

-- 75675: Error updating [dbo].[CartonShipmentDetail] Table. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75675 ,10, '75675^UPDT CSD FAIL', 'us_english'

-- 75676: Failed to obtain InterfaceLogID. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75676 ,10, '75676^GET LOGID FAIL', 'us_english'

-- 75677: Failed to obtain FileKey. (isp1155P_Agile_ShipmentToHold)
EXECUTE rdt.rdtAddMsg 75677 ,10, '75677^GET FLKEY FAIL', 'us_english'

-- 75678: Agile Web Service Request URL is empty. (isp1155P_Agile_ShipmentToHold) 
EXECUTE rdt.rdtAddMsg 75678 ,10, '75678^INV AGILE URL', 'us_english'

--execute rdt.rdtDropMsg '75680'