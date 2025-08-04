SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_LevisZPLSL05Label                               */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Date        Rev  Author       Purposes                               */
/* 2025-01-23  1.0  CYU027       FCR-1824 Created                       */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_LevisZPLSL07Label
   @nMobile      INT,             
   @nFunc        INT,             
   @cLangCode    NVARCHAR( 3),    
   @cStorerKey   NVARCHAR( 15),   
   @cValue01     NVARCHAR( 20),   
   @cValue02     NVARCHAR( 20),   
   @cValue03     NVARCHAR( 20),   
   @cValue04     NVARCHAR( 20),   
   @cValue05     NVARCHAR( 20),   
   @cValue06     NVARCHAR( 20),   
   @cValue07     NVARCHAR( 20),   
   @cValue08     NVARCHAR( 20),   
   @cValue09     NVARCHAR( 20),   
   @cValue10     NVARCHAR( 20),   
   @cTemplate    NVARCHAR( MAX),  
   @cPrintData   NVARCHAR( MAX) OUTPUT,  
   @nErrNo       INT            OUTPUT,
   @cErrMsg      NVARCHAR( 20)  OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nRowCount   INT
   DECLARE @cPickSlipNo NVARCHAR(10)
   DECLARE @cOrderKey   NVARCHAR(10)
   DECLARE @cLabelNo    NVARCHAR(20)
   DECLARE @cExtTemplateSP    NVARCHAR(20),
   @cSQL           NVARCHAR( MAX),
   @cSQLParam      NVARCHAR( MAX),
   @cUserName      NVARCHAR( 20),
   @cReportType    NVARCHAR( 10),
   @cUDF02         NVARCHAR( 10),
   @cFacility      NVARCHAR( 5),
   @nSKUCnt        INT,
   @nLoopIndex     INT = 1

   DECLARE @tSkus TABLE
   (
      ID    INT IDENTITY(1,1),
      SKU   NVARCHAR(20),
      SKUStyle NVARCHAR(MAX),
      SKUSizeMeasurement NVARCHAR(MAX),
      QTY   INT
   )


   SELECT @cFacility = FACILITY FROM rdt.rdtMobRec WITH (NOLOCK) WHERE Mobile = @nMobile
   SELECT @cLabelNo = @cValue01, @cReportType = @cValue02

   SELECT @cOrderKey = CASE WHEN COUNT(OrderKey) = 1 THEN OrderKey ELSE 'MPOC' END
   FROM dbo.PickDetail WITH(NOLOCK)
   WHERE StorerKey = @cStorerKey 
      AND CaseID <> ''
      AND CaseID = @cLabelNo
   GROUP BY OrderKey

   SET @cPrintData = @cTemplate;

   DECLARE @CartonTrack_TrackingNo NVARCHAR(MAX) = '',
      @Facility_Address1 NVARCHAR(MAX) = '',
      @Facility_Address2 NVARCHAR(MAX) = '',
      @Facility_City NVARCHAR(MAX) = '',
      @Facility_Description NVARCHAR(MAX) = '',
      @Facility_Facility NVARCHAR(MAX) = '',
      @Facility_State NVARCHAR(MAX) = '',
      @Facility_Zip NVARCHAR(MAX) = '',
      @MBOL_Carrierkey NVARCHAR(MAX) = '',
      @MBOL_Door NVARCHAR(MAX) = '',
      @MBOL_ExternMBOLKey NVARCHAR(MAX) = '',
      @MBOL_MBOLKEY NVARCHAR(MAX) = '',
      @OrderDetail_Userdefine07 NVARCHAR(MAX) = '',
      @OrderDetail_SKU NVARCHAR(MAX) = '',
      @OrderDetail_Userdefine03 NVARCHAR(MAX) = '',
      @OrderInfo_Notes NVARCHAR(MAX) = '',
      @OrderInfo_OrderInfo02 NVARCHAR(MAX) = '',
      @OrderInfo_OrderInfo05 NVARCHAR(MAX) = '',
      @Orders_B_Address1 NVARCHAR(MAX) = '',
      @Orders_B_Address2 NVARCHAR(MAX) = '',
      @Orders_B_City NVARCHAR(MAX) = '',
      @Orders_B_Company NVARCHAR(MAX) = '',
      @Orders_B_ISOCntryCode NVARCHAR(MAX) = '',
      @Orders_B_State NVARCHAR(MAX) = '',
      @Orders_B_Zip NVARCHAR(MAX) = '',
      @Orders_Billtokey NVARCHAR(MAX) = '',
      @Orders_BuyerPO NVARCHAR(MAX) = 'VARIOUS',
      @Orders_C_Address1 NVARCHAR(MAX) = '',
      @Orders_C_Address2 NVARCHAR(MAX) = '',
      @Orders_C_City NVARCHAR(MAX) = '',
      @Orders_C_Company NVARCHAR(MAX) = '',
      @Orders_C_Contact1 NVARCHAR(MAX) = '',
      @Orders_C_ISOCntryCode NVARCHAR(MAX) = '',
      @Orders_C_State NVARCHAR(MAX) = '',
      @Orders_C_Zip NVARCHAR(MAX) = '',
      @Orders_Consigneekey NVARCHAR(MAX) = '',
      @Orders_ConsigneekeyBarcode NVARCHAR(MAX) = '',
      @Orders_ExternOrderkey NVARCHAR(MAX) = '',
      @Orders_M_Address1 NVARCHAR(MAX) = '',
      @Orders_M_Address2 NVARCHAR(MAX) = '',
      @Orders_M_City NVARCHAR(MAX) = '',
      @Orders_M_Company NVARCHAR(MAX) = '',
      @Orders_M_Contact1 NVARCHAR(MAX) = '',
      @Orders_M_State NVARCHAR(MAX) = '',
      @Orders_M_Zip NVARCHAR(MAX) = '',
      @Orders_C_Zip_Barcode NVARCHAR(MAX) = '',
      @Orders_C_Zip_Readable NVARCHAR(MAX) = '',
      @Orders_Markforkey NVARCHAR(MAX) = '',
      @Orders_UserDefine04 NVARCHAR(MAX) = '',
      @Orders_UserDefine08 NVARCHAR(MAX) = '',
      @Orders_UserDefine09 NVARCHAR(MAX) = '',
      @PackDetail_Carton_Total_Qty NVARCHAR(MAX) = '',
      @Packdetail_Carton_Count NVARCHAR(MAX) = '',
      @Packdetail_Labelno NVARCHAR(MAX) = '',
      @Packdetail_LabelnoBarcode NVARCHAR(MAX) = '',
      @PackDetail_Total_Qty NVARCHAR(MAX) = '',
      @PackDetail_Total_Qty_by_SKU NVARCHAR(MAX) = '',
      @PackInfo_CartonType NVARCHAR(MAX) = '',
      @Storer_Company_Type7 NVARCHAR(MAX) = '',
      @Storer_Storerkey_Type7 NVARCHAR(MAX) = '',
      @MBOL_CarrierAgent NVARCHAR(MAX) = '',
      @PackDetail_CartonNo NVARCHAR(MAX) = '',
      @PackDetail_DropId NVARCHAR(MAX) = '',
      @Storer_Company_Type_1 NVARCHAR(MAX) = '',
      @Storer_Storerkey_Type_1 NVARCHAR(MAX) = '',
      @SKU_RetailSKU NVARCHAR(MAX) = '',
      @SKU_Size_Measurement NVARCHAR(MAX) = '',
      @SKU_Style NVARCHAR(MAX) = '',
      @wkOrdUDef2 NVARCHAR(MAX) = '',
      @wkOrdUDef4 NVARCHAR(MAX) = '',
      @wkOrdType NVARCHAR(MAX) = '',
      @costCenter NVARCHAR(MAX) = '',
      @naturalAcct NVARCHAR(MAX) = '',
      @LVSUSA_Packing_List NVARCHAR(MAX) = '',
      @Hangers NVARCHAR(MAX) = '';
   DECLARE
      @DeliveryIDSuffix  NVARCHAR(MAX) = ''

   SELECT
      @CartonTrack_TrackingNo = ''

   IF @cOrderKey <> 'MPOC'
   BEGIN
      SELECT TOP 1
         @MBOL_Carrierkey = M.Carrierkey,
         @MBOL_Door = O.DOOR,
         @MBOL_ExternMBOLKey = M.ExternMBOLKEY,
         @MBOL_MBOLKEY = M.MBOLKEY
      FROM dbo.MBOL M WITH(NOLOCK)
      INNER JOIN dbo.MBOLDetail MD WITH(NOLOCK) ON (M.MBOLKey = MD.MBOLKey) 
      INNER JOIN ORDERS     O  WITH (NOLOCK) ON (MD.OrderKey = O.OrderKey) 
      WHERE O.OrderKey = @cOrderKey

      SELECT
         @Orders_B_Address1 = O.B_Address1,
         @Orders_B_Address2 = O.B_Address2,
         @Orders_B_City = O.B_City,
         @Orders_B_Company = O.B_Company,
         @Orders_B_ISOCntryCode = O.B_ISOCntryCode,
         @Orders_B_State = O.B_State,
         @Orders_B_Zip = O.B_Zip,
         @Orders_Billtokey = O.BilltoKey,
         @Orders_BuyerPO = O.BuyerPO,
         @Orders_C_Address1 = O.C_Address1,
         @Orders_C_Address2 = O.C_Address2,
         @Orders_C_City = O.C_City,
         @Orders_C_Company = O.C_Company,
         @Orders_C_Contact1 = O.C_Contact1,
         @Orders_C_ISOCntryCode = O.C_ISOCntryCode,
         @Orders_C_State = O.C_State,
         @Orders_C_Zip = O.C_Zip,
         @Orders_C_Zip_Readable = CONCAT('(420) ', SUBSTRING(O.C_Zip, 1, 5)),
         @Orders_C_Zip_Barcode = CONCAT('420', SUBSTRING(O.C_Zip, 1, 5)),
         @Orders_Consigneekey = O.Consigneekey,
         @Orders_ConsigneekeyBarcode = O.Consigneekey,
         @Orders_ExternOrderkey = O.ExternOrderkey,
         @Orders_M_Address1 = O.M_Address1,
         @Orders_M_Address2 = O.M_Address2,
         @Orders_M_City = O.M_City,
         @Orders_M_Company = O.M_Company,
         @Orders_M_Contact1 = O.M_Contact1,
         @Orders_M_State = O.M_State,
         @Orders_M_Zip = O.M_Zip,
         @Orders_Markforkey = O.Markforkey,
         @Orders_UserDefine04 = O.Userdefine04,
         @Orders_UserDefine08 = O.Userdefine08,
         @Orders_UserDefine09 = O.Userdefine09,
         @cFacility = O.Facility,
         @DeliveryIDSuffix = CASE WHEN O.Facility = 'LEV01' THEN '72' ELSE '' END,
         @OrderInfo_OrderInfo02 = OI.OrderInfo02
      FROM dbo.Orders O WITH(NOLOCK)
         LEFT JOIN OrderInfo OI (NOLOCK) ON O.OrderKey = OI.OrderKey
      WHERE O.OrderKey = @cOrderKey

      SELECT TOP 1
         @OrderDetail_Userdefine07 = Userdefine07,
         @OrderDetail_SKU = SKU,
         @OrderDetail_Userdefine03 = Userdefine03
      FROM dbo.OrderDetail WITH(NOLOCK)
      WHERE OrderKey = @cOrderKey
   END

   SELECT TOP 1
      @Facility_Address1 = Address1,
      @Facility_Address2 = Address2,
      @Facility_City = City,
      @Facility_Description = Descr,
      @Facility_Facility = Facility,
      @Facility_State = State,
      @Facility_Zip = Zip
   FROM dbo.Facility WITH(NOLOCK)
   WHERE FACILITY = @cFacility

   SELECT
      @PackDetail_Carton_Total_Qty = SUM(Qty),
      @Packdetail_Labelno = Labelno,
      @PackDetail_Total_Qty = SUM(Qty)
   FROM dbo.PackDetail WITH(NOLOCK) 
   WHERE StorerKey = @cStorerKey 
      AND labelno = @cLabelNo
   GROUP BY LabelNo

   SELECT TOP 1
      @PackDetail_CartonNo = CartonNo,
      @Packdetail_LabelnoBarcode = CONCAT('00', Labelno),
      @Packdetail_Carton_Count = (dbo.fnc_GetGNCarton(PICKSLIPNO)),
      @PackDetail_DropId = DropID
   FROM dbo.PackDetail WITH(NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND labelno = @cLabelNo

   SET @Packdetail_Labelno = '(' + LEFT(@Packdetail_LabelnoBarcode, 2) + ') ' +
                                    SUBSTRING(@Packdetail_LabelnoBarcode, 3, 1) + ' ' +
                                    SUBSTRING(@Packdetail_LabelnoBarcode, 4, 7) + ' ' +
                                    SUBSTRING(@Packdetail_LabelnoBarcode, 11, 9) + ' ' +
                                    RIGHT(@Packdetail_LabelnoBarcode, 1)

   SELECT TOP 1
      @PackInfo_CartonType = CartonType
   FROM dbo.PackInfo PI WITH(NOLOCK) 
   WHERE PI.RefNo IS NOT NULL
      AND PI.RefNo = @cLabelNo

   SELECT TOP 1
      @Storer_Company_Type7 = Company,
      @Storer_Storerkey_Type7 = Storerkey
   FROM dbo.Storer WITH (NOLOCK)
   WHERE StorerKey = @cStorerKey

   SELECT
      @nSKUCnt = COUNT(SKU)
   FROM dbo.PackDetail WITH(NOLOCK) 
   WHERE StorerKey = @cStorerKey 
      AND labelno = @cLabelNo

   INSERT INTO @tSkus(SKU,SKUSizeMeasurement,SKUStyle,QTY)
   SELECT
      CONCAT('',ISNULL(RetailSKU,''),''),
      CONCAT('',ISNULL(Size,'') ,'x', ISNULL(Measurement,''),''),
      CONCAT('',ISNULL(STYLE,''),''),
      SUM(PD.QTY)
   FROM dbo.SKU SKU WITH (NOLOCK)
   INNER JOIN dbo.PackDetail PD WITH(NOLOCK) ON PD.SKU = SKU.SKU AND PD.StorerKey = SKU.StorerKey
   WHERE PD.StorerKey = @cStorerKey 
      AND PD.labelno = @cLabelNo
   GROUP BY SKU.RetailSKU, SKU.Size, SKU.Measurement, SKU.Style

   WHILE(1=1)
   BEGIN
      SELECT
         @SKU_RetailSKU = SKU,
         @SKU_Size_Measurement = SKUSizeMeasurement,
         @SKU_Style = SKUStyle,
         @PackDetail_Total_Qty_by_SKU = Qty
      FROM @tSkus
      WHERE ID = @nLoopIndex
      IF @@ROWCOUNT = 0
      BEGIN
         SELECT @SKU_RetailSKU = '', @SKU_Size_Measurement = '', @SKU_Style = '', @PackDetail_Total_Qty_by_SKU = ''
      END

      SET @cPrintData = REPLACE(@cPrintData, CONCAT('[[Label.SKU_RetailSKU',@nLoopIndex,']]'), ISNULL(@SKU_RetailSKU, ''));
      SET @cPrintData = REPLACE(@cPrintData, CONCAT('[[Label.SKU_Size_Measurement',@nLoopIndex,']]'), ISNULL(@SKU_Size_Measurement, ''));
      SET @cPrintData = REPLACE(@cPrintData, CONCAT('[[Label.SKU_Style',@nLoopIndex,']]'), ISNULL(@SKU_Style, ''));
      SET @cPrintData = REPLACE(@cPrintData, CONCAT('[[Label.PackDetail_Total_Qty_by_SKU',@nLoopIndex,']]'), ISNULL(@PackDetail_Total_Qty_by_SKU, ''));

      SET @nLoopIndex = @nLoopIndex + 1
      IF @nLoopIndex > 23
         BREAK
   END

   SELECT top 1 
      @wkordtype = CASE WHEN ISNULL((dbo.fnc_GetGNNewFlow(PKD.ORDERKEY) ),'') <> '' THEN  'N E W F L O W' ELSE '' END,
      @wkOrdUDef2 = CASE WHEN ISNULL((dbo.fnc_GetGNHangers(PKD.ORDERKEY) ),'') <> '' THEN dbo.fnc_GetGNHangers(Pkd.ORDERKEY) ELSE 'N E W F L O W' END,
      @wkOrdUDef4 = wod.WkOrdUdef4,
      @Hangers = IIF(CLK.udf01 = 'H','Hanger','')
   FROM dbo.WorkOrderDetail wod (NOLOCK)
      INNER JOIN dbo.PickDetail pkd WITH(NOLOCK) ON wod.StorerKey = pkd.StorerKey AND ISNULL(wod.ExternWorkOrderKey, '') = pkd.OrderKey AND pkd.OrderLinenumber = wod.ExternLineNo
      LEFT JOIN dbo.CODELKUP CLK WITH(NOLOCK)
         ON CLK.StorerKey = wod.StorerKey AND CLK.LISTNAME = 'wkordtype' AND WOD.Type = CLK.Code
      WHERE ISNULL(pkd.CaseID, '') = @cLabelNo
      AND WOD.StorerKey = @cStorerKey


   SELECT
--       t.Description,
--       t.FromAddress,
--       t.FromCity,
--       t.FromState,
--       t.FromZip,
--       t.ToCompany,
--       t.ToLoc,
--       t.ShipToAddressStreetLine,
--       t.ShipToAddressStreetLine1,
--       t.ShipToAddressStreetLine2,
--       t.ToCity,
--       t.ToState,
--       t.ToZip,
--       t.ShipToPost,
--       t.Vendor,
--       CASE
--          WHEN dbo.fnc_getGNMPOC(@cLabelNo) > 1 THEN 'VARIOUS'
--          ELSE t.PO
--          END AS PO,
--       dbo.fnc_GetGNdept_MPOC(@cLabelNo) AS Dept,
--       t.OrderInfo,
      @MBOL_ExternMBOLKey = t.EMbolKey,
      @MBOL_Carrierkey = t.CarrierKey,
      @MBOL_CarrierAgent = t.CarrierAgent,
      @OrderInfo_Notes = t.OrdNotes,
      @Orders_ConsigneekeyBarcode = CONCAT('91',CASE
         WHEN LEN(t.SellTo) % 2 = 1 THEN CONCAT('0', t.SellTo)
         ELSE t.SellTo
      END),
      @Orders_Consigneekey = CONCAT('(91) ',CASE
        WHEN LEN(t.SellTo) % 2 = 1 THEN CONCAT('0', t.SellTo)
        ELSE t.SellTo
      END),
      @Orders_Billtokey = t.SellTo,
      @Orders_M_State = t.ProvinceCode,
      @Orders_UserDefine08 = t.Vendor,
      @Orders_BuyerPO = t.PO
--       CASE
--          WHEN LEN(t.SellTo) % 2 <> 0 THEN CONCAT('0', t.SellTo)
--          ELSE t.SellTo
--          END AS SellToFormatted,
--       t.SellTo,
--       t.ProvinceCode,
--       t.SSCC,

   FROM (
           SELECT DISTINCT
              MAX(F.Descr) AS Description,
              ISNULL(REPLACE(TRIM(MAX(F.Address1)), ',', ' '), '') AS FromAddress,
              MAX(F.City) AS FromCity,
              MAX(F.State) AS FromState,
              MAX(F.Zip) AS FromZip,

              MAX(O.C_Company) AS ToCompany,
              ISNULL(REPLACE(TRIM(MAX(O.C_Address1)), ',', ' '), '') AS ToLoc,
              ISNULL(REPLACE(TRIM(MAX(O.C_Address2)), ',', ' '), '') AS ShipToAddressStreetLine,
              ISNULL(REPLACE(TRIM(MAX(O.C_Address3)), ',', ' '), '') AS ShipToAddressStreetLine1,
              ISNULL(REPLACE(TRIM(MAX(O.C_Address4)), ',', ' '), '') AS ShipToAddressStreetLine2,

              MAX(O.C_City) AS ToCity,
              MAX(O.C_State) AS ToState,
              MAX(O.C_Zip) AS ToZip,
              MAX(SUBSTRING(O.C_Zip, 1, 5)) AS ShipToPost,
              MAX(O.UserDefine08) AS Vendor,
              O.BuyerPO AS PO,
              ISNULL(REPLACE(TRIM(MAX(OI.Notes)), ',', ' '), '') AS OrdNotes,
              MAX(OI.OrderInfo02) AS OrderInfo,

              RIGHT(M.ExternMbolKey, 17) AS EMbolKey,
              dbo.fnc_GetGNCarrier(O.OrderKey) AS CarrierKey,
              M.CarrierAgent,

              -- SellTo
              (CASE
                  WHEN COALESCE(MAX(O.M_CONTACT1), MAX(O.C_CONTACT1), '') <> '' AND
                       (LEN(MAX(O.M_CONTACT1)) = 0 AND LEN(MAX(O.C_CONTACT1)) = 0) THEN ''
                  WHEN LEN(MAX(O.M_CONTACT1)) = 0 THEN MAX(O.C_CONTACT1)
                  ELSE COALESCE(MAX(O.M_CONTACT1), MAX(O.C_CONTACT1), '')
                 END) AS SellTo,

              -- ProvinceCode
              (CASE
                  WHEN COALESCE(MAX(O.M_State), MAX(O.C_State), '') <> '' AND
                       (LEN(MAX(O.M_State)) = 0 AND LEN(MAX(O.C_State)) = 0) THEN ''
                  WHEN LEN(MAX(O.M_State)) = 0 THEN MAX(O.C_State)
                  ELSE COALESCE(MAX(O.M_State), MAX(O.C_State), '')
                 END) AS ProvinceCode,

              SUBSTRING(PCD.LabelNo, 1, 17) AS SSCC
           FROM
              FACILITY F WITH (NOLOCK)
                 INNER JOIN ORDERS O WITH (NOLOCK) ON F.Facility = O.Facility
                 LEFT JOIN OrderInfo OI WITH (NOLOCK) ON O.OrderKey = OI.OrderKey
                 INNER JOIN PACKHEADER PCH WITH (NOLOCK) ON PCH.OrderKey = O.OrderKey AND PCH.StorerKey = O.StorerKey
                 INNER JOIN PACKDETAIL PCD WITH (NOLOCK) ON PCD.PickSlipNo = PCH.PickSlipNo AND PCD.LabelNo = @cLabelNo
                 LEFT JOIN MBOL M WITH (NOLOCK) ON M.Facility = O.Facility AND M.MbolKey = O.MBOLKey
           WHERE
              PCD.LabelNo = @cLabelNo
           GROUP BY
              O.BuyerPO, O.OrderKey, M.CarrierAgent, M.ExternMbolKey, PCD.LabelNo
        ) t
   GROUP BY
      t.Description,
      t.FromAddress,
      t.FromCity,
      t.FromState,
      t.FromZip,
      t.ToCompany,
      t.ToLoc,
      t.ShipToAddressStreetLine,
      t.ShipToAddressStreetLine1,
      t.ShipToAddressStreetLine2,
      t.ToCity,
      t.ToState,
      t.ToZip,
      t.ShipToPost,
      t.Vendor,
      t.OrdNotes,
      CASE
         WHEN dbo.fnc_getGNMPOC(@cLabelNo) > 1 THEN 'VARIOUS'
         ELSE t.PO
         END,
      t.OrderInfo,
      t.EMbolKey,
      t.CarrierKey,
      t.CarrierAgent,
      CASE
         WHEN LEN(t.SellTo) % 2 <> 0 THEN CONCAT('0', t.SellTo)
         ELSE t.SellTo
         END,
      t.SellTo,
      t.ProvinceCode,
      t.SSCC,
      t.Vendor,
      t.PO
   ;




   SET @cPrintData = REPLACE(@cPrintData, '[[Label.CartonTrack_TrackingNo]]', ISNULL(@CartonTrack_TrackingNo, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Date_Time_Now]]', CONVERT(NVARCHAR(5), GETDATE(), 110));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Facility_Address1]]', ISNULL(@Facility_Address1, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Facility_Address2]]', ISNULL(@Facility_Address2, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Facility_City]]', ISNULL(@Facility_City, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Facility_Description]]', ISNULL(@Facility_Description, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Facility_Facility]]', ISNULL(@Facility_Facility, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Facility_State]]', ISNULL(@Facility_State, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Facility_Zip]]', ISNULL(@Facility_Zip, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.MBOL_Carrierkey]]', ISNULL(@MBOL_Carrierkey, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.MBOL_Door]]', ISNULL(@MBOL_Door, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.MBOL_ExternMBOLKey]]', ISNULL(@MBOL_ExternMBOLKey, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.MBOL_MBOLKEY]]', ISNULL(@MBOL_MBOLKEY, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.OrderDetail.Userdefine07]]', ISNULL(@OrderDetail_Userdefine07, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.OrderDetail_SKU]]', ISNULL(@OrderDetail_SKU, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.OrderDetail_Userdefine03]]', ISNULL(@OrderDetail_Userdefine03, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.OrderInfo_Notes]]', ISNULL(@OrderInfo_Notes, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.OrderInfo_OrderInfo02]]', ISNULL(@OrderInfo_OrderInfo02, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.OrderInfo_OrderInfo05]]', ISNULL(@OrderInfo_OrderInfo05, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_B_Address1]]', ISNULL(@Orders_B_Address1, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_B_Address2]]', ISNULL(@Orders_B_Address2, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_B_City]]', ISNULL(@Orders_B_City, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_B_Company]]', ISNULL(@Orders_B_Company, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_B_ISOCntryCode]]', ISNULL(@Orders_B_ISOCntryCode, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_B_State]]', ISNULL(@Orders_B_State, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_B_Zip]]', ISNULL(@Orders_B_Zip, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_Billtokey]]', ISNULL(@Orders_Billtokey, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_BuyerPO]]', ISNULL(@Orders_BuyerPO, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_C_Address1]]', ISNULL(@Orders_C_Address1, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_C_Address2]]', ISNULL(@Orders_C_Address2, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_C_City]]', ISNULL(@Orders_C_City, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_C_Company]]', ISNULL(@Orders_C_Company, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_C_Contact1]]', ISNULL(@Orders_C_Contact1, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_C_ISOCntryCode]]', ISNULL(@Orders_C_ISOCntryCode, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_C_State]]', ISNULL(@Orders_C_State, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_C_Zip]]', '' + ISNULL(@Orders_C_Zip, '') + '');
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_Consigneekey]]', ISNULL(@Orders_Consigneekey, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_ExternOrderkey]]', ISNULL(@Orders_ExternOrderkey, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_M_Address1]]', ISNULL(@Orders_M_Address1, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_M_Address2]]', ISNULL(@Orders_M_Address2, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_M_City]]', ISNULL(@Orders_M_City, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_M_Company_C_Company]]', CASE WHEN ISNULL(@Orders_M_Company, '') = '' THEN ISNULL(@Orders_C_Company, '') ELSE ISNULL(@Orders_M_Company, '') END);
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_M_Contact1_C_Contact1]]', CASE WHEN ISNULL(@Orders_M_Contact1, '') = '' THEN ISNULL(@Orders_C_Contact1, '') ELSE ISNULL(@Orders_M_Contact1, '') END);
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_M_State_C_State]]', CASE WHEN ISNULL(@Orders_M_State, '') = '' THEN ISNULL(@Orders_C_State, '') ELSE ISNULL(@Orders_M_State, '') END);
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_M_Zip]]', ISNULL(@Orders_M_Zip, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_C_Zip_Barcode]]', '' + ISNULL(@Orders_C_Zip_Barcode, '') + '');
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_C_Zip_Readable]]', '' + ISNULL(@Orders_C_Zip_Readable, '') + '');
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_Markforkey_Consigneekey]]', CASE WHEN ISNULL(@Orders_Markforkey, '') = '' THEN ISNULL(@Orders_Consigneekey, '') ELSE ISNULL(@Orders_Markforkey, '') END);
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_UserDefine04]]', ISNULL(@Orders_UserDefine04, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_UserDefine08]]', ISNULL(@Orders_UserDefine08, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_UserDefine09]]', ISNULL(@Orders_UserDefine09, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.PackDetail.Carton_Total_Qty]]', ISNULL(@PackDetail_Carton_Total_Qty, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Packdetail_Carton_Count]]', ISNULL(@Packdetail_Carton_Count, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Packdetail_Labelno]]', ISNULL(@Packdetail_Labelno, ''));
SET @cPrintData = REPLACE(@cPrintData, '[[Label.Packdetail_LabelnoBarcode]]', ISNULL(@Packdetail_LabelnoBarcode, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.PackDetail_Total_Qty_by_SKU]]', ISNULL(@PackDetail_Total_Qty_by_SKU, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.PackInfo_CartonType]]', ISNULL(@PackInfo_CartonType, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Storer_Company_Type7]]', ISNULL(@Storer_Company_Type7, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Storer_Storerkey_Type7]]', ISNULL(@Storer_Storerkey_Type7, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[Label.MBOL_CarrierAgent]]', ISNULL(@MBOL_CarrierAgent, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[Label.PackDetail_CartonNo]]', ISNULL(@PackDetail_CartonNo, ''));
SET @cPrintData = REPLACE(@cPrintData, '[[Label.PackDetail_DropId]]', ISNULL(@PackDetail_DropId, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[Label.Storer_Company_Type_1]]', ISNULL(@Storer_Company_Type_1, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[Label.Storer_Storerkey_Type_1]]', ISNULL(@Storer_Storerkey_Type_1, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.LVSUSA_Delivery_ID_Suffix]]', ISNULL(@DeliveryIDSuffix, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_ConsigneekeyBarcode]]', ISNULL(@Orders_ConsigneekeyBarcode, ''));

   /** LVSUS Spec **/
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.LVSUSA_Hangers_Included]]', ISNULL(@Hangers, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.WorkOrderDetail_WkOrdUDef2]]', ISNULL(@wkOrdUDef2, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.WorkOrderDetail_WkOrdUDef4]]', ISNULL(@wkOrdUDef4, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.LVSUSA_Packing_List]]', ISNULL(@LVSUSA_Packing_List, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.WorkOrderDetail_Type]]', ISNULL(@wkordtype, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.LVSUSA_Cost_Center]]', ISNULL(@costCenter, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.LVSUSA_Natural_Acct]] ', ISNULL(@naturalAcct, ''));

   Quit:
   RETURN
END

GO

GRANT EXECUTE ON rdt.rdt_LevisZPLSL07Label TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
