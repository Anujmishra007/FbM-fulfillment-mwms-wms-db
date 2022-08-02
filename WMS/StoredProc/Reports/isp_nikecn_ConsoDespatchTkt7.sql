if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_nikecn_ConsoDespatchTkt7]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[isp_nikecn_ConsoDespatchTkt7]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


/************************************************************************/
/* Stored Procedure: isp_nikecn_ConsoDespatchTkt7                       */
/* Creation Date: 08-Mar-2017                                           */
/* Copyright: LF                                                        */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: WMS-1269-IDSCN-Nike SDC Shipping Label                      */
/*                                                                      */
/* Called By: r_dw_despatch_ticket_nikecn7                              */
/*            modified from isp_nikecn_ConsoDespatchTkt5                */
/*                          r_dw_despatch_ticket_nikecn5                */
/* PVCS Version: 2.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author  Ver   Purposes                                  */
/* 30-MAY-2017  CSCHONG 1.0   WMS-2022 - Add new field (CS01)           */
/* 08-FRB-2017  CSCHONG 1.1   WMS-3941 - Add new field (CS02)           */
/* 21-Aug-2018  CSCHONG 1.2   WMS-5448 group by caseid (CS03)           */
/* 26-Jun-2019  CSCHONG 1.3   Remove traceinfo (CS04)                   */
/* 17-Jul-2020  CSCHONG 1.4   WMS-14206 - revised field logic (CS04)    */
/************************************************************************/

CREATE PROC [dbo].[isp_nikecn_ConsoDespatchTkt7]
   @c_pickslipno     NVARCHAR(10),
   @n_StartCartonNo  INT = 0,
   @n_EndCartonNo    INT = 0,
   @c_StartLabelNo   NVARCHAR(20) = '',
   @c_EndLabelNo     NVARCHAR(20) = ''
AS
BEGIN

   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_getOrderkey    NVARCHAR(30)
         , @c_LoadKey        NVARCHAR(10)
         , @i_ExtCnt         INT
         , @i_LineCnt        INT
         , @SQL              NVARCHAR(1000)
         , @nMaxCartonNo     INT
         , @nCartonNo        INT
         , @nSumPackQty      INT
         , @nSumPickQty      INT
         , @c_ConsigneeKey   NVARCHAR(15)
         , @c_Company        NVARCHAR(45)
         , @c_Address1       NVARCHAR(45)
         , @c_Address2       NVARCHAR(45)
         , @c_Address3       NVARCHAR(45)
         , @c_Address4       NVARCHAR(45)
         , @c_City           NVARCHAR(45)
         , @d_DeliveryDate   DATETIME
         , @c_Orderkey       NVARCHAR(10)  
         , @c_Storerkey      NVARCHAR(15)             
         , @c_ShowQty_Cfg    NVARCHAR(10)             
         , @c_ShowOrdType_Cfg NVARCHAR(10)              
         , @c_susr4           NVARCHAR(10)             
         , @c_Stop            NVARCHAR(10)
         , @c_showfield        NVARCHAR(1)           
         , @c_showCRD         NVARCHAR(1)  
         , @c_BU              NVARCHAR(5)  
         , @c_Gender          NVARCHAR(20)
         , @c_category        NVARCHAR(30) 
                  

   SET @c_Storerkey  = ''                            
   SET @c_ShowQty_Cfg= ''                             
   SET @c_ShowOrdType_Cfg = ''                        
   SET @c_susr4         = ''                         
   SET @c_showfield = 'N'                              
   SET @c_showCRD   = ''                              

   SELECT distinct @c_Orderkey = Orderkey 
         ,@c_Storerkey= ISNULL(RTRIM(Storerkey),'')   
   FROM PICKDETAIL (NOLOCK)
   WHERE Pickslipno = @c_Pickslipno

   CREATE TABLE #RESULT (
       ROWREF INT NOT NULL IDENTITY(1,1) Primary Key,
       PickSlipNo NVARCHAR(10) NULL,
       LoadKey NVARCHAR(10) NULL,
       ConsigneeKey NVARCHAR(15) NULL,
       C_Company NVARCHAR(45) NULL,
       C_Address1 NVARCHAR(45) NULL,
       C_Address2 NVARCHAR(45) NULL,
       C_Address3 NVARCHAR(45) NULL,
       C_Address4 NVARCHAR(45) NULL,
       C_City NVARCHAR(45) NULL,
       Caseid NVARCHAR(20) NULL,
       CartonNo INT NULL,
       TotalPcs INT NULL,
       MaxCarton NVARCHAR(10) NULL      
      ,SUSR4      NVARCHAR(20) NULL            
      ,CRD        NVARCHAR(10) NULL            
      ,BU        NVARCHAR(10) NULL 
      ,Gender    NVARCHAR(20) NULL 
      ,orderkey  NVARCHAR(30) NULL
      ,Category  NVARCHAR(30) NULL
      ,LIRP      NVARCHAR(10) NULL              --CS01
      ,Pickcode  NVARCHAR(10) NULL              --CS02
      )

   CREATE INDEX IX_RESULT_01 on #RESULT ( LoadKey )
   CREATE INDEX IX_RESULT_02 on #RESULT ( CartonNo )
   --CS04 Start
   /*
   INSERT INTO TraceInfo (TraceName, TimeIn, Col1, Col2, Col3, Col4, Col5) 
   VALUES ('isp_nikecn_ConsoDespatchTkt7: ' + RTRIM(SUSER_SNAME()), GETDATE()
         , @c_pickslipno, @n_StartCartonNo, @n_EndCartonNo
         , @c_StartLabelNo, @c_EndLabelNo)
  */
   --CS04 End
      INSERT INTO #RESULT   ( PickSlipNo, LoadKey, ConsigneeKey,C_Company, C_Address1,  C_Address2,  
                             C_Address3,C_Address4,C_City,caseid,  CartonNo, TotalPcs,
                            MaxCarton, SUSR4,CRD, BU,Gender,orderkey,Category,LIRP,Pickcode         --CS01    --CS02                                    
                           )

      SELECT PD.PickSlipNo,
            ORDERS.LoadKey,
            ISNULL(MAX(ORDERS.Consigneekey),'') as ConsigneeKey,
            ISNULL(MAX(Orders.C_Company),'') as C_Company,
            ISNULL(MAX(Orders.C_Address1),'') as C_Address1,
            ISNULL(MAX(Orders.C_Address2),'') as C_Address2,
            ISNULL(MAX(Orders.C_Address3),'') as C_Address3,
            ISNULL(MAX(Orders.C_Address4),'') as C_Address4,
            ISNULL(MAX(Orders.C_City),'') as C_City,
            PD.CaseID,
            CL.Seqno,--PAD.CartonNo,   
            SUM(PD.Qty) AS TotalPcs,      
            MaxCarton = ''--(COUNT(DISTINCT PD.CaseID))      
         ,  Plant = F.UserDefine03
         ,  CRD = ISNULL(ORDERS.DeliveryNote,'')--ISNULL(MAX(OIF.OrderInfo07),'')   --CS04
         , BU = MIN(C.UDF02)
         , Gender = ISNULL(MIN(C1.UDF02),'')
         , ORDERS.orderkey
         , Category = ''--ISNULL(MIN(C2.UDF02),'')        --CS02
         ,LIRP = CASE OIF.OrderInfo10                     --CS01
                     WHEN 'N' THEN 'LI'
                     WHEN 'R' THEN 'FI'
                     ELSE '' END   
         ,pickcode = ISNULL(OD.PickCode,'')              --CS02                      
      FROM Orders Orders WITH (NOLOCK)
      JOIN ORDERDETAIL OD WITH (NOLOCK) ON OD.OrderKey = Orders.OrderKey
      JOIN Pickdetail PD WITH (NOLOCK) ON (PD.ORDERKEY = OD.OrderKey AND PD.SKU = OD.SKU AND PD.OrderLineNumber=OD.OrderLineNumber)
      --LEFT JOIN PackDetail AS PAD WITH (NOLOCK) ON PAD.LABELNO = PD.CASEID 
      LEFT JOIN ORDERINFO OIF (NOLOCK) ON OIF.OrderKey = Orders.OrderKey 
      LEFT JOIN FACILITY F WITH (NOLOCK) ON F.Facility=ORDERS.Facility  
      LEFT JOIN CartonListDetail CLD WITH (NOLOCK) ON CLD.PickDetailKey=PD.PickDetailKey
      LEFT JOIN CartonList AS CL WITH (NOLOCK) ON CL.CartonKey = CLD.CartonKey
      JOIN SKU S WITH (NOLOCK) ON S.StorerKey = PD.Storerkey AND s.sku = PD.Sku
      LEFT JOIN Codelkup C WITH (NOLOCK) ON  C.listname='SKUGROUP' and C.code=S.BUSR7 --AND C.Storerkey=Orders.StorerKey
      LEFT JOIN Codelkup C1 WITH (NOLOCK) ON  C1.listname='NKSGenger' and C1.code=S.BUSR5    
      LEFT JOIN Codelkup C2 WITH (NOLOCK) ON  C2.listname='NKSCate' and C2.code=S.SUSR4                                      
      WHERE PD.PickSlipNo = @c_pickslipno
      AND CL.SeqNo BETWEEN CASE WHEN @n_StartCartonNo = 0 THEN 1 ELSE @n_StartCartonNo END AND
                                      CASE WHEN @n_EndCartonNo   = 0 THEN 9999 ELSE @n_EndCartonNo END
      AND pd.CaseID<>''
     GROUP BY PD.PickSlipNo,
            Orders.LoadKey,
            ORDERS.Consigneekey,
            Orders.DeliveryDate,
            Orders.C_Company,
            ISNULL(Orders.C_Address1,'') ,
            ISNULL(Orders.C_Address2,'') ,
            ISNULL(Orders.C_Address3,'') ,
            ISNULL(Orders.C_Address4,'') ,
            Orders.C_City,
            PD.CASEID,
            --PAD.CartonNo,--CASE WHEN ISNULL(PAD.CartonNo,0) <> 0 THEN  ELSE CL.CurrCount END,
            CL.Seqno,
            F.UserDefine03,ISNULL(OIF.OrderInfo07,''), ORDERS.orderkey,OIF.OrderInfo10              --CS01
            ,ISNULL(OD.PickCode,'')              --CS02 
            ,ISNULL(ORDERS.DeliveryNote,'')      --CS04 

   DECLARE @nCartonIndex int

   IF @n_StartCartonNo <> 0 AND  @n_EndCartonNo <> 0
   BEGIN
      SET @nCartonIndex = @n_StartCartonNo
      WHILE @nCartonIndex <= @n_EndCartonNo
      BEGIN
      IF NOT EXISTS(SELECT 1 FROM #RESULT
                    WHERE PickSlipNo = @c_pickslipno
                    AND CartonNo = @nCartonIndex)
         BEGIN
            SET ROWCOUNT 1
              
                  INSERT INTO #RESULT   ( PickSlipNo, LoadKey, ConsigneeKey,C_Company, C_Address1,  C_Address2,  
                             C_Address3,C_Address4,C_City,caseid,  CartonNo, TotalPcs,
                            MaxCarton, SUSR4,CRD, BU,Gender ,orderkey,Category ,LIRP,Pickcode       --CS01  --CS02                                    
                           )

      SELECT PD.PickSlipNo,
            ORDERS.LoadKey,
            ISNULL(MAX(ORDERS.Consigneekey),'') as ConsigneeKey,
            ISNULL(MAX(Orders.C_Company),'') as C_Company,
            ISNULL(MAX(Orders.C_Address1),'') as C_Address1,
            ISNULL(MAX(Orders.C_Address2),'') as C_Address2,
            ISNULL(MAX(Orders.C_Address3),'') as C_Address3,
            ISNULL(MAX(Orders.C_Address4),'') as C_Address4,
            ISNULL(MAX(Orders.C_City),'') as C_City,
            PD.CaseID,
            CL.Seqno,--PAD.CartonNo,   
            SUM(DISTINCT PD.Qty) AS TotalPcs,      
            MaxCarton = ''--(COUNT(DISTINCT PD.CaseID))      
         ,  Plant = F.UserDefine03
         ,  CRD = ISNULL(ORDERS.DeliveryNote,'') --ISNULL(MAX(OIF.OrderInfo07),'')   --CS04
         , BU = MIN(C.UDF02)
         , Gender = ISNULL(MIN(C1.UDF02),'')
         , ORDERS.orderkey
         , Category = ''--ISNULL(MIN(C2.UDF02),'')                  --CS02
         ,LIRP = CASE OIF.OrderInfo10                               --CS01
                     WHEN 'N' THEN 'LI'
                     WHEN 'R' THEN 'FI'
                     ELSE '' END   
          ,pickcode = ISNULL(OD.PickCode,'')              --CS02                      
      FROM Orders Orders WITH (NOLOCK)
      JOIN ORDERDETAIL OD WITH (NOLOCK) ON OD.OrderKey = Orders.OrderKey
      JOIN Pickdetail PD WITH (NOLOCK) ON (PD.ORDERKEY = OD.OrderKey AND PD.SKU = OD.SKU AND PD.OrderLineNumber=OD.OrderLineNumber)
     -- LEFT JOIN PackDetail AS PAD WITH (NOLOCK) ON PAD.LABELNO = PD.CASEID 
      LEFT JOIN ORDERINFO OIF (NOLOCK) ON OIF.OrderKey = Orders.OrderKey 
      LEFT JOIN FACILITY F WITH (NOLOCK) ON F.Facility=ORDERS.Facility  
      LEFT JOIN CartonListDetail CLD WITH (NOLOCK) ON CLD.PickDetailKey=PD.PickDetailKey
      LEFT JOIN CartonList AS CL WITH (NOLOCK) ON CL.CartonKey = CLD.CartonKey
      JOIN SKU S WITH (NOLOCK) ON S.StorerKey = PD.Storerkey AND s.sku = PD.Sku
      LEFT JOIN Codelkup C WITH (NOLOCK) ON  C.listname='SKUGROUP' and C.code=S.BUSR7 --AND C.Storerkey=Orders.StorerKey
      LEFT JOIN Codelkup C1 WITH (NOLOCK) ON  C1.listname='NKSGenger' and C1.code=S.BUSR5          
      LEFT JOIN Codelkup C2 WITH (NOLOCK) ON  C2.listname='NKSCate' and C2.code=S.SUSR4                                    
      WHERE PD.PickSlipNo = @c_pickslipno
      --AND PAD.CartonNo BETWEEN CASE WHEN @n_StartCartonNo = 0 THEN 1 ELSE @n_StartCartonNo END AND
      --                                CASE WHEN @n_EndCartonNo   = 0 THEN 9999 ELSE @n_EndCartonNo END
      AND CL.SeqNo BETWEEN CASE WHEN @n_StartCartonNo = 0 THEN 1 ELSE @n_StartCartonNo END AND
                                      CASE WHEN @n_EndCartonNo   = 0 THEN 9999 ELSE @n_EndCartonNo END
      --AND pd.CaseID<>''
      GROUP BY PD.PickSlipNo,
            Orders.LoadKey,
            ORDERS.Consigneekey,
            Orders.DeliveryDate,
            Orders.C_Company,
            ISNULL(Orders.C_Address1,'') ,
            ISNULL(Orders.C_Address2,'') ,
            ISNULL(Orders.C_Address3,'') ,
            ISNULL(Orders.C_Address4,'') ,
            Orders.C_City,
            PD.CASEID,
            --PAD.CartonNo,--CASE WHEN ISNULL(PAD.CartonNo,0) <> 0 THEN  ELSE CL.CurrCount END,
            CL.Seqno,
            F.UserDefine03,ISNULL(OIF.OrderInfo07,''), ORDERS.orderkey,OIF.OrderInfo10              --CS01
            ,ISNULL(OD.PickCode,'')              --CS02 
            ,ISNULL(ORDERS.DeliveryNote,'')      --CS04 
              
            SET ROWCOUNT 0
         END

         -- SET @nCartonIndex = @n_StartCartonNo + 1 Edit by james, Logic error
         SET @nCartonIndex = @nCartonIndex + 1
      END
   END -- If start carton and end carton <> 0

   SET @nSumPackQty = 0
   SET @nSumPickQty = 0
   --SELECT @nMaxCartonNo = MAX(CartonNo) FROM PackDetail WITH (NOLOCK) WHERE PickSlipNo = @c_PickSlipNo
   
   SELECT @nMaxCartonNo = MAX(CL.Seqno) 
   FROM PickDetail  PD WITH (NOLOCK) 
   LEFT JOIN CartonListDetail CLD WITH (NOLOCK) ON CLD.PickDetailKey=PD.PickDetailKey
   LEFT JOIN CartonList AS CL WITH (NOLOCK) ON CL.CartonKey = CLD.CartonKey
   WHERE PickSlipNo = @c_PickSlipNo

   DECLARE CTN_CUR CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT CartonNo FROM #RESULT WITH (NOLOCK)
   WHERE PickSlipNo = @c_PickSlipNo
   ORDER BY CartonNo

   OPEN CTN_CUR
   FETCH NEXT FROM CTN_CUR INTO @nCartonNo

   WHILE @@FETCH_STATUS <> -1
   BEGIN
      SET @c_BU = ''
      SET @c_Gender = ''
      
     -- IF @nCartonNo = @nMaxCartonNo
     -- BEGIN
         SET @nSumPackQty = 0
         SET @nSumPickQty = 0

         SELECT @nSumPackQty = SUM(QTY) FROM PackDetail WITH (NOLOCK)
         WHERE PickSlipNo = @c_PickSlipNo

         --SELECT @nSumPickQty = SUM(QTY) FROM PickDetail With (NOLOCK) WHERE PickSlipNo = @c_PickSlipNo
         
            SELECT @nSumPickQty = SUM(PD.QTY)
            FROM PickDetail PD WITH (NOLOCK)
            WHERE PD.Orderkey = @c_Orderkey

        -- IF @nSumPackQty = @nSumPickQty
         --BEGIN
            UPDATE #RESULT 
            SET MaxCarton = ISNULL(RTRIM(Cast(@nCartonNo AS NVARCHAR( 5))), 0) + '/' + ISNULL(RTRIM(Cast(@nMaxCartonNo AS NVARCHAR( 5))), 0)
           -- ,BU = @c_BU
           -- ,Gender = @c_Gender
            WHERE PickSlipNo = @c_PickSlipNo AND CartonNo = @nCartonNo
      
      FETCH NEXT FROM CTN_CUR INTO @nCartonNo
   END
   CLOSE CTN_CUR
   DEALLOCATE CTN_CUR

   --CS03 Start
   SELECT DISTINCT PickSlipNo, LoadKey, ConsigneeKey,C_Company, C_Address1,  C_Address2,  
                             C_Address3,C_Address4,C_City,caseid,  CartonNo, sum(TotalPcs) as TotalPcs,
                            MaxCarton, SUSR4,CRD, BU,Gender,'' as orderkey ,Category ,LIRP,Pickcode          --CS01       --CS02                                          
   FROM #RESULT
   GROUP BY PickSlipNo, LoadKey, ConsigneeKey,C_Company, C_Address1,  C_Address2,  
                             C_Address3,C_Address4,C_City,caseid,  CartonNo, 
                            MaxCarton, SUSR4,CRD, BU,Gender,Category ,LIRP,Pickcode 
   ORDER BY CartonNo
   --CS03 End
   DROP TABLE #RESULT
END

GO
GRANT EXECUTE ON [dbo].[isp_nikecn_ConsoDespatchTkt7] TO nsql
GO

