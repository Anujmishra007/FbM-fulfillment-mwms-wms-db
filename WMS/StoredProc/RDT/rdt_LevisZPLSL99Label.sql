SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdt_LevisZPLSL99Label                               */
/* Copyright      : Maersk                                              */
/* Desc: For ZPL     SL99                                               */
/*                                                                      */
/* Date        Rev  Author       Purposes                               */
/* 2025-05-06  1.0  Dennis       FCR-4243 Updated                       */
/************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_LevisZPLSL99Label
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

   SELECT @cOrderKey = CASE WHEN COUNT(DISTINCT OrderKey) = 1 THEN OrderKey ELSE 'MPOC' END
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
      @Orders_C_Address4 NVARCHAR(MAX) = '',
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
      @Orders_C_Zip_Barcode NVARCHAR(MAX) = '',
      @Orders_C_Zip_Readable NVARCHAR(MAX) = '',
      @Packdetail_LabelnoBarcode NVARCHAR(MAX) = '',

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
         @Orders_C_Zip = SUBSTRING(C_Zip, 1, 5),
         @Orders_C_Zip_Readable = CONCAT('(420) ', SUBSTRING(C_Zip, 1, 5)),
         @Orders_C_Zip_Barcode = CONCAT('420', SUBSTRING(C_Zip, 1, 5)),
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
      @PackDetail_Total_Qty = SUM(Qty)
   FROM dbo.PackDetail WITH(NOLOCK) 
   WHERE StorerKey = @cStorerKey 
      AND labelno = @cLabelNo
   GROUP BY LabelNo

   SELECT TOP 1
      @PackDetail_CartonNo = CartonNo,
      @Packdetail_Carton_Count = (dbo.fnc_GetGNCarton(PICKSLIPNO)),
      @Packdetail_Labelno = '00'+Labelno
   FROM dbo.PackDetail WITH(NOLOCK)
   WHERE StorerKey = @cStorerKey
      AND labelno = @cLabelNo

   select @Packdetail_LabelnoBarcode = @Packdetail_Labelno, @Packdetail_Labelno = '(' + LEFT(@Packdetail_Labelno, 2) + ') ' +
                                    SUBSTRING(@Packdetail_Labelno, 3, 1) + ' ' +
                                    SUBSTRING(@Packdetail_Labelno, 4, 7) + ' ' +
                                    SUBSTRING(@Packdetail_Labelno, 11, 9) + ' ' +
                                    RIGHT(@Packdetail_Labelno, 1)

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

   --Standard process ends
--    IF @cReportType = 'SL99VNDLbl'
--    BEGIN
--        SELECT DISTINCT
--          -- P.TOTALSQTY,
--          @Orders_BuyerPO = P.PO,
--          --P.PALLETTYPE,P.CAR,
--          -- P.SKID,P.PALLETSTACK,
--          @Orders_Billtokey =  CASE WHEN (P.B_CONTACT1 IS NOT NULL) THEN P.B_CONTACT1 ELSE RIGHT(P.BILLTOKEY,5) END,
--          @Orders_Consigneekey =  CONCAT('(91) ',CASE
--          WHEN LEN(P.CONTACT) % 2 = 1 THEN CONCAT('0', P.CONTACT)
--          ELSE P.CONTACT
--          END),
--          @Orders_ConsigneekeyBarcode = CONCAT('91',CASE
--          WHEN LEN(P.CONTACT) % 2 = 1 THEN CONCAT('0', P.CONTACT)
--          ELSE P.CONTACT
--          END),
--          @Orders_Markforkey = CASE WHEN ISNULL(@Orders_Markforkey,'')='' THEN P.CONTACT ELSE @Orders_Markforkey END,
--          @OrderInfo_Notes = P.DEPT,
--          @orderInfo_OrderInfo02 = P.DEPT,
--          -- (SUBSTRING(P.CARTONID,LEN(P.CARTONID)-8,9)),
--          -- P.SEQ,
--          @Packdetail_Carton_Count = (dbo.fnc_GetGNCarton(P.PICKSLIPNO)),
--          --P.BOL,
--          @MBOL_CarrierAgent = P.PRO,
--          --P.OCN,
--          -- dbo.fnc_GetGNVASCodes(P.ORDERKEY,P.CARTONID) AS SPECIALINS,
--          @Hangers = CASE WHEN (dbo.fnc_GetGNHangers(P.ORDERKEY)='' ) OR(dbo.fnc_GetGNHangers(P.ORDERKEY)IS NULL )  THEN '' ELSE 'HANGERS' END,
--
--          @wkordtype = CASE WHEN (dbo.fnc_GetGNNewFlow(P.ORDERKEY)='' ) OR(dbo.fnc_GetGNNewFlow(P.ORDERKEY)IS NULL ) THEN '' ELSE 'N E W F L O W' END,
--          @LVSUSA_Packing_List = CASE WHEN (dbo.fnc_GetGNOLPL(P.CUSTOMER,P.BILLTOKEY)=1) AND (P.SEQ=(dbo.fnc_GetGNCarton(P.PICKSLIPNO))) THEN 'OLPL'
--          WHEN ( ((dbo.fnc_GetGNOLPL(P.CUSTOMER,P.BILLTOKEY)=2) OR (dbo.fnc_GetGNOLPL(P.CUSTOMER,P.BILLTOKEY)=3) OR
--          (dbo.fnc_GetGNOLPL(P.CUSTOMER,P.BILLTOKEY)=5) )   AND (P.SEQ=(dbo.fnc_GetGNCarton(P.PICKSLIPNO))))
--          THEN 'OLPL' ELSE  '' END,
--          --'', '', '',
--          @Facility_Facility =  P.DC
--          --P.WAVE,
--          --'', '', '', '', '', '', '', '', '', ''
--          FROM (
--          SELECT
--          (CASE WHEN((S.MEASUREMENT IS NULL ) OR (S.MEASUREMENT='')) AND  ((S.SIZE IS NOT NULL ) OR (S.MEASUREMENT<>''))  THEN
--          CONCAT (S.STYLE,'#',CONCAT(S.SIZE,''),'*',PD. QTY,'$')
--          WHEN ((S.MEASUREMENT IS NOT NULL ) OR (S.MEASUREMENT<>'')) AND  ((S.SIZE IS  NULL ) OR (S.MEASUREMENT='')) THEN
--          CONCAT (S.STYLE,'#',CONCAT('','',S.Measurement),'*',PD. QTY,'$')
--          ELSE CONCAT (S.STYLE,'#',CONCAT(S.SIZE,'x',S.Measurement),'*',PD. QTY,'$')
--          END)
--          AS ITEM,
--          O.ORDERKEY,
--          PD.PICKSLIPNO,O.BuyerPO AS PO,''AS PALLETTYPE,(dbo.fnc_GetGNCarrier(O.ORDERKEY)) AS CAR,''AS SKID,''AS PALLETSTACK,
--          O.ConsigneeKey AS CUSTOMER,O.STORERKEY,O.SHIPPERKEY,
--          CASE WHEN (O.M_CONTACT1 IS NULL) OR (O.M_CONTACT1='') THEN O.C_CONTACT1  ELSE O.M_CONTACT1 END AS CONTACT,
--          OI.Notes AS DEPT
--          ,PD.LABELNO AS CARTONID, PD.CARTONNO AS SEQ,MAX(PH.TTLCNTS) AS COUNTS,
--          RIGHT(M.EXTERNMBOLKEY,17) AS BOL,M.Carrieragent AS PRO,O.ExternOrderKey AS OCN,M.MBOLKEY,
--          O.C_Contact2 AS DC,
--          O.USERDEFINE09 AS WAVE,
--          O.BillToKey,PI.Qty AS TOTALSQTY,O.B_CONTACT1,
--          ROWNUMBER = Row_Number() over (order by PD.SKU,PD.PICKSLIPNO)
--          FROM ORDERS O
--          LEFT JOIN ORDERINFO OI ON OI.ORDERKEY=O.ORDERKEY
--          INNER JOIN ORDERDETAIL OD ON O.ORDERKEY=OD.ORDERKEY
--          INNER JOIN PACKHEADER PH ON PH.ORDERKEY=O.ORDERKEY
--          INNER JOIN PACKDETAIL PD  ON PD.PICKSLIPNO=PH.PICKSLIPNO
--          LEFT JOIN PACKINFO PI ON PI.PickSlipNo=PD.PICKSLIPNO AND PI.CartonNo =PD.CartonNo
--          INNER JOIN SKU S ON S.SKU=PD.SKU AND S.STORERKEY=O.STORERKEY
--          LEFT JOIN MBOLDETAIL MD ON MD.OrderKey=O.ORDERKEY
--          LEFT JOIN MBOL M ON M.MBOLKEY=MD.MBOLKEY
--          WHERE  PD.LabelNo = @cLabelNo
--          GROUP BY S.STYLE,PD.QTY,PD.PICKSLIPNO,PD.SKU,O.BUYERPO,M.CarrierKey,
--          O.ConsigneeKey,O.BillToKey,M.EXTERNMBOLKEY,PH.TTLCNTS,PD.LABELNO,PI.QTY,SIZE,PD.CARTONNO,S.Measurement,
--          O.M_Contact1,O.C_contact1,OI.Notes,M.Carrieragent,O.ExternOrderKey,O.ORDERKEY,O.STORERKEY,M.MBOLKEY,O.B_CONTACT1,O.SHIPPERKEY,O.C_Contact2,O.USERDEFINE09
--          )A
--          PIVOT
--          (MAX(ITEM) FOR ROWNUMBER  in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],
--          [16],[17],[18],[19],[20],[21],[22],[23],[24],[25])) P
--    END

--    [[Label.Orders_Billtokey]]
-- [[Label.Orders_Markforkey_Consigneekey]]
-- [[Label.Orders_M_Company_C_

   SELECT @Facility_Description = t.Description,
          @Facility_Address1 = t.Address,
          @Facility_City = t.City,
          @Facility_State = t.State,
          @Facility_Zip = t.Zip,
          @Orders_C_Company = ISNULL(replace(TRIM(t.Company),',',' '),'') ,
          @Orders_C_Address1 = t.ShipToLoc,
          @Orders_C_Address2 = t.ShipToAddressStreetLine1,
          @Orders_C_Address4 = t.ShipToAddressStreetLine2,
          @Orders_C_City = t.CCity,
          @Orders_C_State = t.CState,
--           @Orders_C_Zip  t.CZip,
          @MBOL_Carrierkey = t.CarrierKey,
          @MBOL_CarrierAgent = t.Carrieragent,
          @MBOL_ExternMBOLKey = RIGHT(t.ExternMbolKey,17),
          @OrderInfo_Notes = t.OrdNotes,
          @Orders_BuyerPO = t.BuyerPO,
          @PackDetail_CartonNo = t.CartonNo,
          @Packdetail_Carton_Count = t.TotalCTN,
          @Orders_ExternOrderkey = t.ExternOrderKey,

          @Orders_ConsigneekeyBarcode = CONCAT('91', CASE
            WHEN LEN(t.SellToLocationId) % 2 = 1 THEN CONCAT('0', t.SellToLocationId)
               ELSE t.SellToLocationId END),
          @Orders_Consigneekey = CONCAT('(91) ',
            CASE WHEN LEN(t.SellToLocationId) % 2 = 1 THEN CONCAT('0', t.SellToLocationId)
            ELSE t.SellToLocationId END),


--           CASE WHEN (t.OrderGroup='10' OR t.OrderGroup='20') THEN CASE WHEN Isnull(t.selltolocationid,'') = '' THEN t.selltolocationid1 ELSE t.selltolocationid END
--                WHEN t.OrderGroup='30' THEN t.SellToLocationId1 ELSE '' END AS SellToLocationId,

          @Orders_Markforkey = t.MarkForInformation1,
          @Orders_Billtokey = trim(substring(t.MarkForInformation2,charindex('-',t.MarkForInformation2)+1, len(t.MarkForInformation2)-charindex('-',t.MarkForInformation2)))
--           t.Caseid,
--           '', '', '', '', '', '', '', '', '', '',
--           '', '', '', '', '', '', '', '', '', '',
--           '', '', '', '', '', '', '', '', '', '',
--           '', '','','',''
         FROM (
                                  SELECT DISTINCT
                                     max(FC.Descr) as Description, ISNULL(replace(TRIM(max(FC.Address1)),',',' '),'') as Address, max(FC.City) as City, max(FC.State) as State, max(FC.Zip) as Zip, max(ORD.C_Company) As Company,ISNULL(replace(TRIM(max(ORD.C_Address1)),',',' '),'') as ShipToLoc, concat(ISNULL(replace(TRIM(max(ORD.C_Address2)),',',' '),'') ,' ', ISNULL(replace(TRIM(max(ORD.C_Address3)),',',' '),'')) as ShipToAddressStreetLine1,ISNULL(replace(TRIM(max(ORD.C_Address4)),',',' '),'') as ShipToAddressStreetLine2,
                                     max(ORD.C_City) as CCity, max(ORD.C_State) as CState, max(ORD.C_Zip) As CZip,ML.CarrierKey, ML.Carrieragent, ML.ExternMbolKey, ISNULL(replace(TRIM(max(ORDINFO.Notes)),',',' '),'') as OrdNotes, ORD.BuyerPO, PCD.CartonNo,
                                     (SELECT count(DISTINCT CartonNo) FROM PackDetail WHERE PickSlipNo=PCD.PickSlipNo AND StorerKey=ORD.StorerKey) AS TotalCTN,
                                     ORD.ExternOrderKey,
                                     max(concat('0', C_contact1)) as ORDInfo2,
                                     CASE
                                        WHEN COALESCE(MAX(ORD.M_Contact1), MAX(ORD.C_Contact1), '') <> ''
                                           AND LEN(MAX(ORD.M_Contact1)) = 0 AND LEN(MAX(ORD.C_Contact1)) = 0
                                           THEN ''
                                        WHEN LEN(MAX(ORD.M_Contact1)) = 0
                                           THEN MAX(ORD.C_Contact1)
                                        ELSE COALESCE(MAX(ORD.M_Contact1), MAX(ORD.C_Contact1), '')
                                        END AS SellToLocationId,
                                     max(ORD.OrderGroup) AS OrderGroup,
                                     CASE WHEN isnull(max(M_Contact1), max(C_contact1))='' THEN max(C_contact1) ELSE max(M_Contact1) END AS MarkForInformation1,
                                     CASE WHEN isnull(max(M_Contact2), max(C_Contact2))=''THEN max(C_contact2) ELSE max(M_Contact2) END AS MarkForInformation2,
                                     substring(PD.CaseID,1,17) as Caseid
                                  FROM FACILITY FC (NOLOCK) INNER JOIN ORDERS ORD (NOLOCK) ON FC.Facility=ORD.Facility
                                                            LEFT JOIN OrderInfo ORDINFO (NOLOCK) ON ORD.OrderKey=ORDINFO.OrderKey
                                                            INNER JOIN PICKDETAIL PD (NOLOCK) ON PD.OrderKey=ORD.OrderKey AND PD.Storerkey=ORD.StorerKey
                                                            INNER JOIN packheader PCH (NOLOCK) ON PCH.OrderKey=ORD.OrderKey AND PCH.StorerKey=ORD.StorerKey
                                                            INNER JOIN PackDetail PCD (NOLOCK) ON PCD.PickSlipNo=pch.PickSlipNo AND PCD.LabelNo=PD.caseid AND PCD.SKU=PD.SKU
                                                            LEFT JOIN MBOL ML (NOLOCK) ON ML.Facility=ORD.Facility AND ML.MbolKey=ORD.MBOLKey
                                  WHERE PCD.LabelNo= @cLabelNo
                                  GROUP BY ML.CarrierKey, ML.Carrieragent, ML.ExternMbolKey, ORD.BuyerPO, PCD.CartonNo,PD.CaseID,ORD.ExternOrderKey,ORD.StorerKey,PCD.PickSlipNo )t



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
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_C_Address4]]', ISNULL(@Orders_C_Address4, ''));
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
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Packdetail_LabelnoBarcode]]', ISNULL(@Packdetail_LabelnoBarcode, ''));
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_C_Zip_Barcode]]', '' + ISNULL(@Orders_C_Zip_Barcode, '') + '');
   SET @cPrintData = REPLACE(@cPrintData, '[[Label.Orders_C_Zip_Readable]]', '' + ISNULL(@Orders_C_Zip_Readable, '') + '');
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

GRANT EXECUTE ON rdt.rdt_LevisZPLSL99Label TO NSQL
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
