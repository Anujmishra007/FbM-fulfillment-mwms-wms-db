SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_LevisZPLCL30Label                           */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Date        Rev  Author       Purposes                               */
/* 2025-01-23  1.0  CYU027       FCR-4774 Created                       */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_LevisZPLCL30Label
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
      @Hangers NVARCHAR(MAX) = '',
      @Orders_Facility NVARCHAR(MAX) = '';
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
      @Packdetail_LabelnoBarcode = CONCAT('00', Labelno),
      @PackDetail_Total_Qty = SUM(Qty)
   FROM dbo.PackDetail WITH(NOLOCK) 
   WHERE StorerKey = @cStorerKey 
      AND labelno = @cLabelNo
   GROUP BY LabelNo

   SET @Packdetail_Labelno = '(' + LEFT(@Packdetail_LabelnoBarcode, 2) + ') ' +
                                    SUBSTRING(@Packdetail_LabelnoBarcode, 3, 1) + ' ' +
                                    SUBSTRING(@Packdetail_LabelnoBarcode, 4, 7) + ' ' +
                                    SUBSTRING(@Packdetail_LabelnoBarcode, 11, 9) + ' ' +
                                    RIGHT(@Packdetail_LabelnoBarcode, 1)

   SELECT TOP 1
      @PackDetail_CartonNo = CartonNo,
      @PackDetail_DropId = RIGHT(DropID,9),
      @Packdetail_Carton_Count = (dbo.fnc_GetGNCarton(PICKSLIPNO))
   FROM dbo.PackDetail WITH(NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND labelno = @cLabelNo

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



   SELECT DISTINCT
--       ISNULL(P.[1],'@#*$@'),ISNULL(P.[2],'@#*$@'),ISNULL(P.[3],'@#*$@'),ISNULL(P.[4],'@#*$@'),ISNULL(P.[5],'@#*$@'),ISNULL(P.[6],'@#*$@'),ISNULL(P.[7],'@#*$@'),ISNULL(P.[8],'@#*$@'),
--       ISNULL(P.[9],'@#*$@'),ISNULL(P.[10],'@#*$@'),ISNULL(P.[11],'@#*$@'),ISNULL(P.[12],'@#*$@'),ISNULL(P.[13],'@#*$@'),ISNULL(P.[14],'@#*$@'),ISNULL(P.[15],'@#*$@'),ISNULL(P.[16],'@#*$@'),
--       ISNULL(P.[17],'@#*$@'),ISNULL(P.[18],'@#*$@'),ISNULL(P.[19],'@#*$@'),ISNULL(P.[20],'@#*$@'),ISNULL(P.[21],'@#*$@'),ISNULL(P.[22],'@#*$@'),ISNULL(P.[23],'@#*$@'),
--       P.[24], P.[25],
--       P.TOTALSQTY,P.PO,P.PALLETTYPE,
--       '','',
      @Orders_Consigneekey = LTRIM(SUBSTRING(P.CUSTOMER,LEN(P.CUSTOMER)-4,5)),
      @Orders_Billtokey = LTRIM(SUBSTRING(P.STORES,LEN(P.STORES)-4,5)),
      @OrderInfo_Notes = P.DEPT,
--       FORMAT(getdate(),'MM-dd'),
      @MBOL_Carrierkey = P.CAR,
--       P.SEQ,
--       dbo.fnc_GetGNCarton(P.PICKSLIPNO),
      @MBOL_ExternMBOLKey = P.BOL,
      @MBOL_CarrierAgent = P.PRO,
      @Orders_ExternOrderkey = P.OCN,
      @Packdetail_Labelno = (SUBSTRING(P.CARTONID,LEN(P.CARTONID)-8,9)),
--       dbo.fnc_GetGNVAScodes(P.ORDERKEY,P.CARTONID) AS SPECIALINS,
      @Hangers = CASE WHEN (dbo.fnc_GetGNHangers(P.ORDERKEY)='' ) OR(dbo.fnc_GetGNHangers(P.ORDERKEY)IS NULL )  THEN '' ELSE 'HANGERS' END,
      @wkOrdUDef2 = CASE WHEN (dbo.fnc_GetGNNewFlow(P.ORDERKEY)='' ) OR(dbo.fnc_GetGNNewFlow(P.ORDERKEY)IS NULL ) THEN '' ELSE 'N E W F L O W' END ,
      @LVSUSA_Packing_List = CASE WHEN (dbo.fnc_GetGNOLPL(P.CONSIGNEEKEY,P.BILLTOKEY)=1) AND (P.SEQ=(dbo.fnc_GetGNCarton(P.PICKSLIPNO))) THEN 'OLPL'
           WHEN ( ((dbo.fnc_GetGNOLPL(P.CONSIGNEEKEY,P.BILLTOKEY)=2) OR (dbo.fnc_GetGNOLPL(P.CONSIGNEEKEY,P.BILLTOKEY)=3) OR
                   (dbo.fnc_GetGNOLPL(P.CONSIGNEEKEY,P.BILLTOKEY)=5) )   AND (P.SEQ=(dbo.fnc_GetGNCarton(P.PICKSLIPNO))))
              THEN 'OLPL' ELSE  '' END,
--                    ,
--       SUBSTRING(P.CARTONID,1,17) AS SSCC,
--       '', '',
         @Orders_Facility = P.DC
--       P.WAVE,
--       '', '', '', '', '', '', '', '', '', ''
   FROM (
           SELECT
                          (dbo.fnc_GetGN30Item(S.STYLE,S.SIZE,S.MEASUREMENT,PD.QTY,S.RETAILSKU))AS ITEM,
                          O.ORDERKEY,O.C_Contact2 AS DC ,O.USERDEFINE09 AS WAVE,
                          PD.PICKSLIPNO,O.BuyerPO AS PO,''AS PALLETTYPE,(dbo.fnc_GetGNCarrier(O.ORDERKEY)) AS CAR,''AS SKID,''AS PALLETSTACK,
                          CASE WHEN (O.B_CONTACT1 IS NULL) OR (O.B_CONTACT1='') THEN O.BILLTOKEY   ELSE O.B_CONTACT1 END AS CUSTOMER,
                          CASE WHEN (O.M_CONTACT1 IS NULL) OR (O.M_CONTACT1='') THEN O.C_CONTACT1  ELSE O.M_CONTACT1 END AS STORES,O.STORERKEY,
                          CASE WHEN (O.M_CONTACT1 IS NULL) OR (O.M_CONTACT1='') THEN O.C_CONTACT1  ELSE O.M_CONTACT1 END AS CONTACT,
                          OI.NOTES AS DEPT,PD.LABELNO AS CARTONID, PD.CARTONNO AS SEQ,MAX(PH.TTLCNTS) AS COUNTS,
                          RIGHT(M.EXTERNMBOLKEY,17) AS BOL ,M.Carrieragent AS PRO,O.ExternOrderKey AS OCN,M.EXTERNMBOLKEY,M.MBOLKEY,O.CONSIGNEEKEY,
                          O.BillToKey,S.SKUGROUP,PI.Qty AS TOTALSQTY,O.B_CONTACT1,
              ROWNUMBER = Row_Number() over (order by PD.SKU,PD.PICKSLIPNO)
           FROM ORDERS O
                   LEFT JOIN ORDERINFO OI ON OI.ORDERKEY=O.ORDERKEY
                   INNER JOIN ORDERDETAIL OD ON O.ORDERKEY=OD.ORDERKEY
                   INNER JOIN PACKHEADER PH ON PH.ORDERKEY=O.ORDERKEY
                   INNER JOIN PACKDETAIL PD  ON PD.PICKSLIPNO=PH.PICKSLIPNO AND PD.SKU=OD.SKU
                   LEFT JOIN PACKINFO PI ON PI.PickSlipNo=PD.PICKSLIPNO AND PI.CartonNo =PD.CartonNo
                   INNER JOIN SKU S ON S.SKU=OD.SKU AND S.STORERKEY=O.STORERKEY
                   LEFT JOIN MBOLDETAIL MD ON MD.OrderKey=O.ORDERKEY
                   LEFT JOIN MBOL M ON M.MBOLKEY=MD.MBOLKEY
           WHERE PD.LabelNo=@cLabelNo
           GROUP BY S.STYLE,PD.QTY,PD.PICKSLIPNO,PD.SKU,O.BUYERPO,M.CarrierKey,
                    O.ConsigneeKey,O.BillToKey,S.SKUGROUP,M.EXTERNMBOLKEY,PH.TTLCNTS,PD.LABELNO,PI.QTY,S.SIZE,PD.CARTONNO,S.Measurement,
                    O.M_Contact1,O.C_contact1,OI.Notes,M.Carrieragent,O.ExternOrderKey,O.ORDERKEY,O.STORERKEY,M.EXTERNMBOLKEY,O.B_CONTACT1,O.C_Contact2 ,O.USERDEFINE09 ,M.MBOLKEY,S.RETAILSKU
        )A
           PIVOT
           (MAX(ITEM) FOR ROWNUMBER  in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],
         [16],[17],[18],[19],[20],[21],[22],[23],[24],[25])) P


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
SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_Facility]]', ISNULL(@Orders_Facility, ''));

Quit:
RETURN
END

GO

GRANT EXECUTE ON rdt.rdt_LevisZPLCL30Label TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
