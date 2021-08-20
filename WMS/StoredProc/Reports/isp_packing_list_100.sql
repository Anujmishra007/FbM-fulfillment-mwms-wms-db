IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_packing_list_100]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_packing_list_100]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: isp_packing_list_100                                    */
/* Creation Date: 26-APR-2021                                           */
/* Copyright: LF Logistics                                              */
/* Written by: CHONGCS                                                  */
/*                                                                      */
/* Purpose: WMS-16630 - [CN]Tapestry Sales memo/packing list_NEW        */
/*        :                                                             */
/* Called By: r_dw_packing_list_100                                     */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 2021-08-20  WLChooi  1.1   Fix @n_MaxLineno = 10 (WL01)              */
/************************************************************************/
CREATE PROC isp_packing_list_100
           @c_PickSlipNo      NVARCHAR(10)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  
           @n_StartTCnt       INT
         , @n_Continue        INT 
         , @n_MaxLineno       INT   
         , @n_MaxRec          INT     
         , @n_CurrentRec      INT     
         , @n_Maxrecgrp       INT 

   SET @n_StartTCnt = @@TRANCOUNT

   SET @n_MaxLineno = 10   --WL01

  CREATE TABLE #TMP_PICKLIST100 (
    ExternOrderkey        NVARCHAR(50),
    M_Company             NVARCHAR(45),
    SortBy                INT,
    RowNo                 INT,
    PickSlipNo            NVARCHAR(20),
    loadkey               NVARCHAR(20),
    ohudf06               DATETIME,
    consigneekey          NVARCHAR(45),
    st_bphone1            NVARCHAR(45),
    c_company             NVARCHAR(45),
    odnotes2              NVARCHAR(4000),
    manufacturersku       NVARCHAR(20),
    odunitprice           FLOAT,
    odextprice            FLOAT,
    qty                   INT,
    Storerkey             NVARCHAR(20),
    Orderkey              NVARCHAR(20),
    DISCNT                DECIMAL(20,5),
    recgrp                INT NULL,
    STSUSR5               NVARCHAR(20)
  )
  INSERT INTO #TMP_PICKLIST100
  (
      ExternOrderkey,
      M_Company,
      SortBy,
      RowNo,
      PickSlipNo,
      loadkey,
      ohudf06,
      consigneekey,
      st_bphone1,
      c_company,
      odnotes2,
      manufacturersku,
      odunitprice,
      odextprice,
      qty,
      Storerkey,
      Orderkey,
      DISCNT,
      recgrp,
      STSUSR5   
  )
  
   SELECT  ExternOrderkey = ISNULL(RTRIM(OH.ExternOrderkey),'')
         , M_Company = ISNULL(RTRIM(OH.M_Company),'')  
         , SortBy = ROW_NUMBER() OVER ( ORDER BY PH.PickSlipNo
                                                ,OH.Storerkey
                                                ,OH.Orderkey
                                                ,ISNULL(RTRIM(ST.Company),'') 
                                                ,ISNULL(RTRIM(SKU.Manufacturersku),'')
                                     )
         , RowNo  = ROW_NUMBER() OVER ( PARTITION BY PH.PickSlipNo,ISNULL(RTRIM(ST.Company),'') 
                                        ORDER BY PH.PickSlipNo
                                                ,OH.Storerkey
                                                ,OH.Orderkey
                                                ,ISNULL(RTRIM(ST.Company),'')
                                                ,ISNULL(RTRIM(SKU.Manufacturersku),'')
                                      )
  --       , PrintTime      = GETDATE()        
         , PH.PickSlipNo
         , OH.Loadkey        
         , OHUDF06 = ISNULL(RTRIM(OH.UserDefine06),'') 
         , consigneekey= ISNULL(RTRIM(ST.Company),'')--ISNULL(RTRIM(OH.ConsigneeKey),'') 
         , ST_Bphone1= ISNULL(RTRIM(ST.Phone2),'')  
         , C_company  = ISNULL(RTRIM(OH.C_Company),'') 
         , ODNotes2 = ISNULL(RTRIM(OD.notes2),'')
         , Manufacturersku  = ISNULL(RTRIM(SKU.Manufacturersku),'')         
         , ODUnitPrice = ISNULL(OD.UnitPrice,0)
         , ODExtPrice = ISNULL(OD.ExtendedPrice,0)
         , Qty = ISNULL(SUM(PD.Qty),0)  
         , OH.Storerkey
         , OH.Orderkey
         , DISCNT =  ISNULL((OD.ExtendedPrice/NULLIF(OD.UnitPrice,0)),1)
         , Recgrp = ROW_NUMBER() OVER ( PARTITION BY PH.PickSlipNo,ISNULL(RTRIM(ST.Company),'') 
                                        ORDER BY PH.PickSlipNo
                                                ,OH.Storerkey
                                                ,OH.Orderkey
                                                ,ISNULL(RTRIM(ST.Company),'')
                                                ,ISNULL(RTRIM(SKU.Manufacturersku),'')
                                      )/(@n_MaxLineno+1)
         ,STSUSR5 = ISNULL(ST.SUSR5,'')
   FROM PACKHEADER PH WITH (NOLOCK)
   JOIN ORDERS     OH WITH (NOLOCK) ON (PH.orderkey = OH.orderkey)
   JOIN ORDERDETAIL OD WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
   JOIN PICKDETAIL PD WITH (NOLOCK) ON (OD.Orderkey = PD.Orderkey AND OD.OrderLineNumber=PD.OrderLineNumber AND OD.SKU = PD.Sku)
   JOIN SKU       SKU WITH (NOLOCK) ON (PD.Storerkey= SKU.Storerkey)
                                    AND(PD.Sku = SKU.Sku)
   LEFT JOIN dbo.STORER ST WITH (NOLOCK) ON ST.StorerKey = OH.ConsigneeKey AND ST.type='2'
   WHERE PH.PickSlipNo = @c_PickSlipNo
   GROUP BY PH.PickSlipNo
         ,  OH.Storerkey
         ,  OH.Loadkey
         ,  OH.Orderkey
         ,  ISNULL(RTRIM(OH.UserDefine06),'')  
         ,  ISNULL(RTRIM(OH.ExternOrderkey),'')
         --,  ISNULL(RTRIM(OH.ConsigneeKey),'') 
         ,  ISNULL(RTRIM(ST.Company),'')
         ,  ISNULL(RTRIM(ST.Phone2),'')  
         ,  ISNULL(RTRIM(OH.C_Company),'')     
         ,  ISNULL(RTRIM(OH.M_Company),'')   
         ,  ISNULL(RTRIM(OD.notes2),'')
         ,  OD.UnitPrice
         ,  OD.ExtendedPrice
         ,  ISNULL(RTRIM(SKU.Manufacturersku),'')
         ,  ISNULL(ST.SUSR5,'')

    SET @n_Maxrecgrp = 1
    SET @n_MaxRec = 1

     SELECT @n_Maxrecgrp = MAX(recgrp)                 
     FROM #TMP_PICKLIST100                 
     WHERE PickSlipNo = @c_PickSlipNo   

     SELECT @n_MaxRec = COUNT(RowNo)                 
     FROM #TMP_PICKLIST100                 
     WHERE PickSlipNo = @c_PickSlipNo   
     AND recgrp = @n_Maxrecgrp                          
  
                
  SET @n_CurrentRec = @n_MaxRec % @n_MaxLineno   
  --SELECT  @n_MaxRec '@n_MaxRec',@n_MaxLineno '@n_MaxLineno',@n_CurrentRec '@n_CurrentRec'
  
  WHILE(@n_MaxRec % @n_MaxLineno <> 0 AND @n_CurrentRec < @n_MaxLineno)             
  BEGIN   

   INSERT INTO #TMP_PICKLIST100
  (
      ExternOrderkey,
      M_Company,
      SortBy,
      RowNo,
      PickSlipNo,
      loadkey,
      ohudf06,
      consigneekey,
      st_bphone1,
      c_company,
      odnotes2,
      manufacturersku,
      odunitprice,
      odextprice,
      qty,
      Storerkey,
      Orderkey,
      DISCNT,
      recgrp,STSUSR5 
  )
   SELECT TOP 1 
               ExternOrderkey,
               M_Company,
               SortBy + 1,
               RowNo + 1,
               PickSlipNo,
               loadkey,
               ohudf06,
               consigneekey,
               st_bphone1,
               c_company,
               '',--odnotes2,
               '',--manufacturersku,
               0,--odunitprice,
               0,--odextprice,
               0,--qty,
               Storerkey,
               Orderkey,
               0,--DISCNT,
               recgrp,STSUSR5 
  FROM #TMP_PICKLIST100
  WHERE PickSlipNo = @c_PickSlipNo
  AND recgrp = @n_Maxrecgrp 
  ORDER BY sortby desc,RowNo desc

   SET @n_CurrentRec = @n_CurrentRec + 1   
 
  END

--SELECT * FROM  #TMP_PICKLIST100

     SELECT ExternOrderkey,
      M_Company,
      SortBy,
      RowNo,
      PickSlipNo,
      loadkey,
      ohudf06,
      consigneekey,
      st_bphone1,
      c_company,
      odnotes2,
      manufacturersku,
      odunitprice,
      odextprice * qty AS odextprice ,
      qty,
      Storerkey,
      Orderkey,
      DISCNT,
      DISCNTRATE = CAST(CONVERT(DECIMAL(20,5),(1 - DISCNT)) * 100 AS DECIMAL(10,2)), -- (CASE WHEN DISCNT = 0 THEN 0 ELSE DISCNT END) * 100,
      recgrp,STSUSR5,
      N'亲爱的顾客，感谢您的光临。为保障您的权益，请详细检查商品。若有瑕疵请于' + STSUSR5 + N'日内，持原始销售票' AS RPTNotes1,
      N'据至原店办理鉴定与退换。请务必保留原始标签与吊牌，以利作业。商品若经修改或因使用不当致使产' AS RPTNotes2,
      N'品损害，恕不退货。'   AS RPTNotes3 
      --N'亲爱的顾客，感谢您的光临。为保障您的权益，请详细检查商品。若有瑕疵请于' + STSUSR5 + N'日' AS RPTNotes1,
      --N'内，持原始销售票据至原店办理鉴定与退换。请务必保留原始标签与吊牌，以利作' AS RPTNotes2,
      --N'业。商品若经修改或因使用不当致使产品损害，恕不退货。'   AS RPTNotes3
     
   FROM #TMP_PICKLIST100
   --ORDER BY PickSlipNo

END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_packing_list_100] TO nSQL 
GO