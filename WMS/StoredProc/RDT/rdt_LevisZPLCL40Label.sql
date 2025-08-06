SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_LevisZPLCL40Label                               */
/* Copyright      : Maersk                                              */
/* Desc: For ZPL CL40                                                   */
/*                                                                      */
/* Date        Rev  Author       Purposes                               */
/* 2025-05-06  1.0  Dennis       FCR-4476 Updated                       */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_LevisZPLCL40Label
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
      QTY   INT,
      LOT   NVARCHAR(MAX)
   )
   
   -- DECLARE @tCartonSeq TABLE
   -- (
   --    [ID]    [INT] IDENTITY(1, 1)
   --  , [CCol01] [NVARCHAR](80)
   --  , [CCol02] [NVARCHAR](80)
   --  , [CCol03] [NVARCHAR](80)
   --  , [CCol04] [NVARCHAR](80)
   --  , [CCol05] [NVARCHAR](80)   )

   -- INSERT INTO @tCartonSeq (CCol01,CCol02,CCOl03,CCOl04,CCOl05)
   -- select  ph.consoorderkey, pd.labelno, (row_number() over (order by pd.labelno)),'',''
   -- FROM PackHeader ph  (NOLOCK)
   -- INNER JOIN PackDetail pd  (NOLOCK) on ph.pickslipno = pd.pickslipno
   -- WHERE ph.consoorderkey <> ''
   -- AND  ph.consoorderkey <> 'NULL'
   -- AND  ph.consoorderkey IN
   -- (SELECT DISTINCT (consoorderkey) FROM PackHeader (NOLOCK)
   -- WHERE pickslipno IN
   -- (select distinct pickslipno from PackDetail (NOLOCK)
   -- where labelno = @cLabelNo))
   -- Group By ph.consoorderkey,pd.labelno

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
      @Orders_Markforkey NVARCHAR(MAX) = '',
      @Orders_UserDefine04 NVARCHAR(MAX) = '',
      @Orders_UserDefine08 NVARCHAR(MAX) = '',
      @Orders_UserDefine09 NVARCHAR(MAX) = '',
      @PackDetail_Carton_Total_Qty NVARCHAR(MAX) = '',
      @Packdetail_Carton_Count NVARCHAR(MAX) = '',
      @Packdetail_Labelno NVARCHAR(MAX) = '',
      @Packdetail_Labelno_Barcode NVARCHAR(MAX) = '',
      @Packdetail_Dropid NVARCHAR(MAX) = '',
      @PackDetail_Total_Qty NVARCHAR(MAX) = '',
      @PackDetail_Total_Qty_by_SKU NVARCHAR(MAX) = '',
      @PackInfo_CartonType NVARCHAR(MAX) = '',
      @Storer_Company_Type7 NVARCHAR(MAX) = '',
      @Storer_Storerkey_Type7 NVARCHAR(MAX) = '',
      @MBOL_CarrierAgent NVARCHAR(MAX) = '',
      @PackDetail_CartonNo NVARCHAR(MAX) = '',
      @Storer_Company_Type_1 NVARCHAR(MAX) = '',
      @Storer_Storerkey_Type_1 NVARCHAR(MAX) = '',
      @SKU_RetailSKU NVARCHAR(MAX) = '',
      @SKU_Size_Measurement NVARCHAR(MAX) = '',
      @SKU_Style NVARCHAR(MAX) = '',
      @wkOrdUDef2 NVARCHAR(MAX) = '',
      @wkOrdUDef4 NVARCHAR(MAX) = '',
      @wkOrdType NVARCHAR(MAX) = '',
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
         @Orders_B_Address1 = B_Address1,
         @Orders_B_Address2 = B_Address2,
         @Orders_B_City = B_City,
         @Orders_B_Company = B_Company,
         @Orders_B_ISOCntryCode = B_ISOCntryCode,
         @Orders_B_State = B_State,
         @Orders_B_Zip = B_Zip,
         @Orders_Billtokey = BilltoKey,
         @Orders_BuyerPO = BuyerPO,
         @Orders_C_Address1 = C_Address1,
         @Orders_C_Address2 = C_Address2,
         @Orders_C_City = C_City,
         @Orders_C_Company = C_Company,
         @Orders_C_Contact1 = C_Contact1,
         @Orders_C_ISOCntryCode = C_ISOCntryCode,
         @Orders_C_State = C_State,
         @Orders_C_Zip = C_Zip,
         @Orders_Consigneekey = Consigneekey,
         @Orders_ConsigneekeyBarcode = Consigneekey,
         @Orders_ExternOrderkey = ExternOrderkey,
         @Orders_M_Address1 = M_Address1,
         @Orders_M_Address2 = M_Address2,
         @Orders_M_City = M_City,
         @Orders_M_Company = M_Company,
         @Orders_M_Contact1 = M_Contact1,
         @Orders_M_State = M_State,
         @Orders_M_Zip = M_Zip,
         @Orders_Markforkey = Markforkey,
         @Orders_UserDefine04 = Userdefine04,
         @Orders_UserDefine08 = Userdefine08,
         @Orders_UserDefine09 = Userdefine09,
         @cFacility = Facility,
         @DeliveryIDSuffix = CASE WHEN Facility = 'LEV01' THEN '72' ELSE '' END
      FROM dbo.Orders WITH(NOLOCK)
      WHERE OrderKey = @cOrderKey

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
      @Packdetail_Labelno = CONCAT('00',Labelno),
      @PackDetail_Total_Qty = SUM(Qty)
   FROM dbo.PackDetail WITH(NOLOCK) 
   WHERE StorerKey = @cStorerKey 
      AND labelno = @cLabelNo
   GROUP BY LabelNo

   SELECT TOP 1
      @PackDetail_CartonNo = CartonNo,
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

   INSERT INTO @tSkus(SKU,SKUSizeMeasurement,SKUStyle,QTY,LOT)
   SELECT
      CONCAT('',ISNULL(RetailSKU,''),''),
      CONCAT('',ISNULL(Size,'') ,'x', ISNULL(Measurement,''),''),
      CONCAT('',ISNULL(STYLE,''),''),
      SUM(PD.QTY),
      CASE 
         WHEN (dbo.fnc_GetGNJCPLOT(@cOrderKey, pd.sku) <> '') 
         THEN dbo.fnc_GetGNJCPLOT(@cOrderKey, pd.sku) 
         ELSE '               ' 
      END
   FROM dbo.SKU SKU WITH (NOLOCK)
   INNER JOIN dbo.PackDetail PD WITH(NOLOCK) ON PD.SKU = SKU.SKU AND PD.StorerKey = SKU.StorerKey
   WHERE PD.StorerKey = @cStorerKey 
      AND PD.labelno = @cLabelNo
   GROUP BY SKU.RetailSKU, SKU.Size, SKU.Measurement, SKU.Style,
   CASE WHEN (dbo.fnc_GetGNJCPLOT(@cOrderKey, pd.sku) <> '') 
         THEN dbo.fnc_GetGNJCPLOT(@cOrderKey, pd.sku) 
         ELSE '               ' END

   WHILE(1=1)
   BEGIN
      SELECT
         @SKU_RetailSKU =  SKU,
         @wkOrdUDef4 = Case when (dbo.fnc_GetGNJCPSKU(@cOrderKey,sku) <> '') then dbo.fnc_GetGNJCPSKU(@cOrderKey,sku) else '' end,
         @SKU_Size_Measurement = SKUSizeMeasurement,
         @SKU_Style = SKUStyle,
         @PackDetail_Total_Qty_by_SKU = Qty,
         @OrderDetail_Userdefine03 = LOT
      FROM @tSkus
      WHERE ID = @nLoopIndex

      IF @@ROWCOUNT = 0
      BEGIN
         SELECT @SKU_RetailSKU = '', @SKU_Size_Measurement = '', @SKU_Style = '', @PackDetail_Total_Qty_by_SKU = '',@OrderDetail_Userdefine03 = '',@wkOrdUDef4 = ''
      END

      SET @cPrintData = REPLACE(@cPrintData, CONCAT('[[Label.SKU_RetailSKU',@nLoopIndex,']]'), ISNULL(@SKU_RetailSKU, ''));
      SET @cPrintData = REPLACE(@cPrintData, CONCAT('[[Label.SKU_Size_Measurement',@nLoopIndex,']]'), ISNULL(@SKU_Size_Measurement, ''));
      SET @cPrintData = REPLACE(@cPrintData, CONCAT('[[Label.SKU_Style',@nLoopIndex,']]'), ISNULL(@SKU_Style, ''));
      SET @cPrintData = REPLACE(@cPrintData, CONCAT('[[Label.PackDetail_Total_Qty_by_SKU',@nLoopIndex,']]'), ISNULL(@PackDetail_Total_Qty_by_SKU, ''));
      SET @cPrintData = REPLACE(@cPrintData, CONCAT('[[Label.OrderDetail_Userdefine03_',@nLoopIndex,']]'), ISNULL(@OrderDetail_Userdefine03, ''));
      SET @cPrintData = REPLACE(@cPrintData, CONCAT('[[Label.WorkOrderDetail_WkOrdUdef4_',@nLoopIndex,']]'), ISNULL(@wkOrdUDef4, ''));

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

   SELECT @OrderInfo_Notes = dbo.fnc_GetGNDeptSL11(@cLabelNo)

   --Standard process ends
   IF @cReportType = 'CTNJCCL40'
   BEGIN
         SELECT DISTINCT 
            @Orders_Consigneekey = a.Customer#,
            @Facility_Facility = a.DC#,
            @Orders_Billtokey = a.Store#,
            @OrderInfo_Notes = a.department#,
            @wkordtype = a.midgrid,
            @MBOL_Carrierkey = a.Carrier,
            @wkOrdUDef2 = a.SI1,
            @Packdetail_Dropid = RIGHT(a.dropid,9),
            @Packdetail_Labelno = '(' + LEFT(@Packdetail_Labelno, 2) + ') ' + 
                              SUBSTRING(@Packdetail_Labelno, 3, 1) + ' ' + 
                              SUBSTRING(@Packdetail_Labelno, 4, 7) + ' ' + 
                              SUBSTRING(@Packdetail_Labelno, 11, 9) + ' ' + 
                              RIGHT(@Packdetail_Labelno, 1),
            @Packdetail_Labelno_Barcode = CONCAT('00',a.labelno)
         FROM 
         (
            SELECT 
               o.orderkey,
               o.userdefine09 AS Wave#,
               o.c_contact2 AS DC#,
               O.BuyerPO,
               (CASE 
                     WHEN o.B_Contact1 IS NOT NULL AND LEN(O.B_Contact1) > 0 
                     THEN o.B_Contact1 
                     ELSE SUBSTRING(O.BilltoKey, (LEN(O.BilltoKey) - 4), 5) 
                  END) AS Customer#,
               (CASE 
                     WHEN COALESCE(o.M_CONTACT1, o.C_CONTACT1, ' ') <> ' ' AND (LEN(o.M_CONTACT1) = 0 AND LEN(o.C_CONTACT1) = 0) THEN ' '  
                     WHEN LEN(o.M_CONTACT1) = 0 THEN O.C_CONTACT1  
                     ELSE COALESCE(o.M_CONTACT1, o.C_CONTACT1, ' ') 
                  END) AS Store#, 
               OI.Notes AS department#,
               SUBSTRING(dbo.fnc_GetGNVAScodes(O.ORDERKEY, @cLabelNo), 13, 11) AS midgrid, 
               dbo.fnc_GetGNCarrier(O.ORDERKEY) AS Carrier,
               Mbol.ExternMbolKey AS BOL#,
               Mbol.Carrieragent AS PRO#,
               CASE 
                     WHEN dbo.fnc_GetGNCartSeq(@cLabelNo) <> '' 
                     THEN ph.consoorderkey 
                     ELSE O.Externorderkey 
               END AS OCN#, 
               pkd.dropid, 
               pkd.sku AS Item,
               CASE 
                     WHEN (dbo.fnc_GetGNHangers(O.ORDERKEY) = '' )OR (dbo.fnc_GetGNHangers(O.ORDERKEY) IS NULL)  
                     THEN '' 
                     ELSE 'HANGERS' 
               END AS Hanger, 
               CASE 
                     WHEN ((dbo.fnc_GetGNOLPSplacement(O.Orderkey) = 1 
                           OR dbo.fnc_GetGNOLPSplacement(O.Orderkey) = 2 
                           OR dbo.fnc_GetGNOLPSplacement(O.Orderkey) = 3 
                           OR dbo.fnc_GetGNOLPSplacement(O.Orderkey) = 5) 
                           AND (pkd.CartonNo = dbo.fnc_GetGNCarton(pkd.PICKSLIPNO))) 
                     THEN 'OLPL' 
                     ELSE '' 
               END AS SI2,
               dbo.fnc_GetGNVAScodes(O.ORDERKEY, @cLabelNo) AS SI1,
               -- CASE 
               --       WHEN dbo.fnc_GetGNCartSeq(@cLabelNo) <> '' 
               --       THEN (SELECT CCol03 FROM #cartseq WHERE CCol02 = @cLabelNo) 
               --       ELSE pkd.CartonNo 
               -- END AS Ctnseq#,
               -- CASE 
               --       WHEN dbo.fnc_GetGNCartSeq(@cLabelNo) <> '' 
               --       THEN dbo.fnc_GetGNcarton_MPOC(ph.consoorderkey) 
               --       ELSE (dbo.fnc_GetGNCarton(Pkd.PICKSLIPNO)) 
               -- END AS Totalctn,
               pkd.PickslipNo, 
               pkd.LabelNo, 
               CASE 
                     WHEN (dbo.fnc_GetGNJCPLOT(o.orderkey, pkd.sku) <> '') 
                     THEN dbo.fnc_GetGNJCPLOT(o.orderkey, pkd.sku) 
                     ELSE '               ' 
               END AS lot#,
               SUBSTRING(MAX(pkd.LabelNo), 1, 17) AS SSCC#,
               SUM(pkd.qty) AS Totalqty  
            FROM 
               orders O (NOLOCK)
               LEFT JOIN Orderinfo OI (NOLOCK) ON OI.orderkey = O.orderkey 
               LEFT JOIN MBOL (NOLOCK) ON mbol.mbolkey = o.mbolkey 
               LEFT JOIN packheader ph (NOLOCK) ON ph.orderkey = o.orderkey AND ph.storerkey = o.storerkey 
               LEFT JOIN packdetail pkd (NOLOCK) ON pkd.pickslipno = ph.pickslipno  
               LEFT JOIN orderdetail OD (NOLOCK) ON od.storerkey = o.storerkey AND od.sku = pkd.sku AND od.orderkey = o.orderkey 
            GROUP BY 
               o.orderkey,
               o.userdefine09,
               o.c_contact2,
               O.BuyerPO,
               O.B_Contact1,
               O.Billtokey,
               (CASE 
                     WHEN COALESCE(o.M_CONTACT1, o.C_CONTACT1, ' ') <> ' ' AND (LEN(o.M_CONTACT1) = 0 AND LEN(o.C_CONTACT1) = 0) THEN ' '  
                     WHEN LEN(o.M_CONTACT1) = 0 THEN O.C_CONTACT1  
                     ELSE COALESCE(o.M_CONTACT1, o.C_CONTACT1, ' ') 
                  END), 
               OI.Notes, 
               ph.consoorderkey, 
               Mbol.CarrierKey,
               Mbol.ExternMbolKey,
               Mbol.Carrieragent,
               O.Externorderkey, 
               pkd.dropid,
               pkd.sku, 
               o.consigneekey,
               o.mbolkey,
               pkd.CartonNo,
               pkd.PickslipNo,
               pkd.LabelNo,
               od.userdefine06
         ) AS a,
         sku  
         WHERE 
            a.Item = sku.sku 
            AND sku.storerkey = @cStorerKey 
            AND a.LabelNo = @cLabelNo
   END

   SET @cPrintData = REPLACE(@cPrintData, '[[Label.CartonTrack_TrackingNo]]', ISNULL(@CartonTrack_TrackingNo, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Date_Time_Now]]', CONVERT(NVARCHAR(5), GETDATE(), 110));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Facility_Address1]]', ISNULL(@Facility_Address1, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Facility_Address2]]', ISNULL(@Facility_Address2, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Facility_City]]', ISNULL(@Facility_City, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Facility_Description]]', ISNULL(@Facility_Description, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Facility_Facility]]', ISNULL(@Facility_Facility, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_Facility]]', ISNULL(@Facility_Facility, ''));
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
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_Markforkey_Consigneekey]]', CASE WHEN ISNULL(@Orders_Markforkey, '') = '' THEN ISNULL(@Orders_Consigneekey, '') ELSE ISNULL(@Orders_Markforkey, '') END);
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_UserDefine04]]', ISNULL(@Orders_UserDefine04, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_UserDefine08]]', ISNULL(@Orders_UserDefine08, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_UserDefine09]]', ISNULL(@Orders_UserDefine09, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.PackDetail.Carton_Total_Qty]]', ISNULL(@PackDetail_Carton_Total_Qty, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Packdetail_Carton_Count]]', ISNULL(@Packdetail_Carton_Count, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Packdetail_Labelno]]', ISNULL(@Packdetail_Labelno, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Packdetail_Dropid]]', ISNULL(@Packdetail_Dropid, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.PackDetail_Total_Qty_by_SKU]]', ISNULL(@PackDetail_Total_Qty_by_SKU, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.PackInfo_CartonType]]', ISNULL(@PackInfo_CartonType, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Storer_Company_Type7]]', ISNULL(@Storer_Company_Type7, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Storer_Storerkey_Type7]]', ISNULL(@Storer_Storerkey_Type7, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[Label.MBOL_CarrierAgent]]', ISNULL(@MBOL_CarrierAgent, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[Label.PackDetail_CartonNo]]', ISNULL(@PackDetail_CartonNo, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[Label.Storer_Company_Type_1]]', ISNULL(@Storer_Company_Type_1, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[Label.Storer_Storerkey_Type_1]]', ISNULL(@Storer_Storerkey_Type_1, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.LVSUSA_Delivery_ID_Suffix]]', ISNULL(@DeliveryIDSuffix, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_ConsigneekeyBarcode]]', ISNULL(@Orders_ConsigneekeyBarcode, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Packdetail_LabelnoBarcode]]', ISNULL(@Packdetail_Labelno_Barcode, ''));
   /** LVSUS Spec **/
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.LVSUSA_Hangers_Included]]', ISNULL(@Hangers, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.WorkOrderDetail_WkOrdUDef2]]', ISNULL(@wkOrdUDef2, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.WorkOrderDetail_WkOrdUDef4]]', ISNULL(@wkOrdUDef4, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.LVSUSA_Packing_List]]', ISNULL(@LVSUSA_Packing_List, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.WorkOrderDetail_Type]]', ISNULL(@wkordtype, ''));

   Quit:
   RETURN
END

GO

GRANT EXECUTE ON rdt.rdt_LevisZPLCL40Label TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
