IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_Despatch_Ticket_SPZ_B2C_RDT]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE [dbo].[isp_Despatch_Ticket_SPZ_B2C_RDT]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
 
/************************************************************************/  
/* Stored Procedure: isp_Despatch_Ticket_SPZ_B2C_RDT                    */  
/* Creation Date: 04-Nov-2020                                           */  
/* Copyright: LFL                                                       */  
/* Written by: WLChooi                                                  */  
/*                                                                      */  
/* Purpose: WMS-15452 - SPZ B2C Commercial Invoice                      */  
/*                                                                      */  
/* Called By: report dw = r_dw_Despatch_Ticket_SPZ_B2C_rdt              */  
/*                                                                      */  
/* GitLab Version: 1.0                                                  */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author    Ver.  Purposes                                */  
/************************************************************************/  
CREATE PROC [dbo].[isp_Despatch_Ticket_SPZ_B2C_RDT] (  
      @c_Pickslipno   NVARCHAR(10)  
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET ANSI_DEFAULTS OFF  
  
   DECLARE @c_Orderkey      NVARCHAR(10)
   
   SET @c_Orderkey = @c_Pickslipno
   
   IF EXISTS (SELECT 1 FROM PACKHEADER (NOLOCK) WHERE PickSlipNo = @c_Pickslipno)
   BEGIN
      SELECT @c_Orderkey = OrderKey
      FROM PACKHEADER (NOLOCK)
      WHERE PickSlipNo = @c_Pickslipno
   END
   
   CREATE TABLE #TMP_SUM (
	      Orderkey              NVARCHAR(10) NULL
	    , UnitPricexQtyPicked   FLOAT        NULL
	    , QtyPicked             INT          NULL
       , Tax                   FLOAT        NULL )
       
   CREATE TABLE #TMP_RESULT (
   	   Externorderkey          NVARCHAR(50)  NULL
   	 , STCompany               NVARCHAR(45)  NULL
   	 , STNotes1                NVARCHAR(255) NULL
   	 , STAddress               NVARCHAR(500) NULL
   	 , STCountry               NVARCHAR(45)  NULL
   	 , C_Country               NVARCHAR(45)  NULL
   	 , OHUserDefine01          NVARCHAR(20)  NULL
   	 , C_Contact1              NVARCHAR(45)  NULL
   	 , C_Address1              NVARCHAR(45)  NULL
       , C_Address2              NVARCHAR(45)  NULL
       , C_Address3              NVARCHAR(45)  NULL
   	 , C_Phone1                NVARCHAR(45)  NULL
   	 , C_City                  NVARCHAR(500) NULL
   	 , Sku                     NVARCHAR(20)  NULL
   	 , DESCR                   NVARCHAR(60)  NULL
   	 , UserDefine01            NVARCHAR(18)  NULL
   	 , BUSR5                   NVARCHAR(30)  NULL
   	 , Lottable08              NVARCHAR(30)  NULL
   	 , UnitPrice               FLOAT NULL
   	 , QtyPicked               INT   NULL
   	 , ExtdValue               FLOAT NULL
   	 , SUMUnitPricexQtyPicked  NVARCHAR(20)  NULL
   	 , SUMQtyPicked            INT   NULL
   	 , UserDefine03            NVARCHAR(20)  NULL
   	 , TaxTitle                NVARCHAR(20)  NULL
   	 , SumTax                  FLOAT         NULL
   	 , Total                   NVARCHAR(255) NULL
   	 , M_Contact1              NVARCHAR(45)  NULL
       , M_Address1              NVARCHAR(45)  NULL
       , M_Address2              NVARCHAR(45)  NULL
       , M_Address3              NVARCHAR(45)  NULL
       , M_Address4              NVARCHAR(45)  NULL
       , M_City                  NVARCHAR(500) NULL
   )
   	 
   INSERT INTO #TMP_SUM (Orderkey, UnitPricexQtyPicked, QtyPicked, Tax)
   SELECT MAX(OH.Orderkey)
        , SUM(OD.UnitPrice * (OD.QtyPicked + OD.ShippedQty))
        , SUM(OD.QtyPicked + OD.ShippedQty)
        , SUM(OD.Tax01)
   FROM PACKHEADER PH (NOLOCK)
   JOIN ORDERS OH (NOLOCK) ON PH.OrderKey = OH.OrderKey
   JOIN ORDERDETAIL OD (NOLOCK) ON OD.OrderKey = OH.OrderKey
   WHERE OH.Orderkey = @c_Orderkey
   --SELECT MAX(OH.Orderkey)
   --     , SUM(OD.UnitPrice * PD.Qty)
   --     , SUM(PD.Qty)
   --     , SUM(OD.Tax01)
   --FROM ORDERS OH (NOLOCK)
   --JOIN ORDERDETAIL OD (NOLOCK) ON OD.OrderKey = OH.OrderKey
   --JOIN PICKDETAIL PD (NOLOCK) ON OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber
   --                           AND OD.SKU = PD.SKU
   --WHERE OH.Orderkey = @c_Orderkey

   INSERT INTO #TMP_RESULT
   SELECT OH.Externorderkey
        , ISNULL(ST.Company,'') AS STCompany
        , ISNULL(ST.Notes1,'') AS STNotes1
        , TRIM(ISNULL(ST.Address1,'')) + ' ' + TRIM(ISNULL(ST.Address2,'')) + ' ' +
          TRIM(ISNULL(ST.Address3,'')) + ' ' + TRIM(ISNULL(ST.City,''))     + ' ' +
          TRIM(ISNULL(ST.[State],''))  + ' ' + TRIM(ISNULL(ST.Zip,''))      + ' ' + 
          TRIM(ISNULL(ST.Country,''))  + ' ' + TRIM(ISNULL(ST.Contact1,'')) AS STAddress
        , ISNULL(ST.Country,'') AS STCountry
        , ISNULL(OH.C_Country,'') AS C_Country
        , ISNULL(OH.UserDefine01,'') AS OHUserDefine01
        , ISNULL(OH.C_Contact1,'') AS C_Contact1
        , ISNULL(OH.C_Address1,'') AS C_Address1
        , ISNULL(OH.C_Address2,'') AS C_Address2
        , ISNULL(OH.C_Address3,'') AS C_Address3
        , ISNULL(OH.C_Phone1,'') AS C_Phone1
        , CASE WHEN OH.C_City = NULL 
               THEN '(none)' 
               ELSE TRIM(ISNULL(OH.C_City,'')) + ' ' + TRIM(ISNULL(OH.C_State,'')) + ' ' + 
                    TRIM(ISNULL(OH.C_Country,'')) + ' ' + TRIM(ISNULL(OH.C_Zip,'')) END AS C_City
        , OD.Sku
        , S.DESCR
        , TRIM(OD.UserDefine01)
        , TRIM(ISNULL(S.BUSR5,'')) AS BUSR5
        , TRIM(ISNULL(LA.Lottable08,'')) AS Lottable08
        , OD.UnitPrice
        , (OD.QtyPicked + OD.ShippedQty)
        , ((OD.QtyPicked + OD.ShippedQty) * OD.UnitPrice) AS ExtdValue
        , '$' + CAST(FORMAT(t.UnitPricexQtyPicked,'##,###,##0.00') AS NVARCHAR(20)) AS SUMUnitPricexQtyPicked
        , t.QtyPicked AS SUMQtyPicked
        --, '$' + TRIM(ISNULL(OH.Userdefine03,''))
        , '$' + CASE WHEN ISNUMERIC(ISNULL(OH.Userdefine03,'')) = 1 THEN CAST(FORMAT(CAST(OH.Userdefine03 AS FLOAT),'##,###,##0.00') AS NVARCHAR(20)) ELSE TRIM(ISNULL(OH.Userdefine03,'')) END
        , TRIM(OD.Userdefine02) AS TaxTitle
        , t.Tax AS SumTax
        , '$' + CAST(FORMAT(t.Tax + t.UnitPricexQtyPicked +
          CASE WHEN ISNUMERIC(OH.Userdefine03) = 1 
               THEN CAST(OH.Userdefine03 AS FLOAT) 
               ELSE 0 END,'##,###,##0.00') AS NVARCHAR(20)) AS Total
        , ISNULL(OH.M_Contact1,'') AS M_Contact1
        , ISNULL(OH.M_Address1,'') AS M_Address1
        , ISNULL(OH.M_Address2,'') AS M_Address2
        , ISNULL(OH.M_Address3,'') AS M_Address3
        , ISNULL(OH.M_Address4,'') AS M_Address4
        , CASE WHEN OH.M_City = NULL 
               THEN '(none)' 
               ELSE TRIM(ISNULL(OH.M_City,'')) + ' ' + TRIM(ISNULL(OH.M_State,'')) + ' ' + 
                    TRIM(ISNULL(OH.M_Country,'')) + ' ' + TRIM(ISNULL(OH.M_Zip,'')) END AS M_City
   FROM ORDERS OH (NOLOCK)
   JOIN STORER ST (NOLOCK) ON OH.Storerkey = ST.StorerKey
   JOIN ORDERDETAIL OD (NOLOCK) ON OD.OrderKey = OH.OrderKey
   LEFT JOIN StorerSODefault SSOD (NOLOCK) ON SSOD.StorerKey = OH.ConsigneeKey
   JOIN SKU S (NOLOCK) ON OD.Sku = S.Sku AND OD.StorerKey = S.StorerKey
   --JOIN PICKDETAIL PD (NOLOCK) ON OD.OrderKey = PD.OrderKey AND OD.OrderLineNumber = PD.OrderLineNumber
   --                           AND OD.SKU = PD.SKU
   CROSS APPLY (SELECT DISTINCT Pickdetail.Lot FROM PICKDETAIL (NOLOCK) 
                WHERE PICKDETAIL.OrderKey = OD.Orderkey AND OD.OrderLineNumber = PICKDETAIL.OrderLineNumber
                AND OD.SKU = PICKDETAIL.SKU) AS PD
   JOIN LOTATTRIBUTE LA (NOLOCK) ON LA.Lot = PD.Lot
   JOIN #TMP_SUM t (NOLOCK) ON t.Orderkey = OH.Orderkey
   WHERE OH.Orderkey = @c_Orderkey

   SELECT * FROM #TMP_RESULT
   ORDER BY Sku
   
   IF OBJECT_ID('tempdb..#TMP_SUM') IS NOT NULL
      DROP TABLE #TMP_SUM
   
   IF OBJECT_ID('tempdb..#TMP_RESULT') IS NOT NULL
      DROP TABLE #TMP_RESULT  

END
GO
GRANT EXECUTE ON isp_Despatch_Ticket_SPZ_B2C_RDT TO NSQL
GO