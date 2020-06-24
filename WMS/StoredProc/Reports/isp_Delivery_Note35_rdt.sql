IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[isp_Delivery_Note35_rdt]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[isp_Delivery_Note35_rdt]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/*************************************************************************/
/* Stored Procedure: isp_Delivery_Note35_rdt                             */
/* Creation Date: 2019-03-11                                             */
/* Copyright: IDS                                                        */
/* Written by:                                                           */
/*                                                                       */
/* Purpose: WMS-8238 - KR_Nike_Workorder_Datawindow_New                  */
/*                                                                       */
/* Called By: r_dw_delivery_note35_rdt                                   */
/*                                                                       */
/* PVCS Version: 1.1                                                     */
/*                                                                       */
/* Version: 5.4                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date         Author  Ver   Purposes                                   */
/*************************************************************************/

CREATE PROC isp_Delivery_Note35_rdt 
         (  @c_Orderkey    NVARCHAR(10)
         ,  @c_Loadkey     NVARCHAR(10)= ''
         ,  @c_Type        NVARCHAR(1) = ''
         )           
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_DEFAULTS OFF  
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_NoOfLine        INT
         , @n_TotDetail       INT
         , @n_LineNeed        INT
         , @n_SerialNo        INT
         , @b_debug           INT
         , @c_DelimiterSign   NVARCHAR(1)
         , @n_Count           int
         , @c_GetOrdkey       NVARCHAR(20)
         , @c_sku             NVARCHAR(20)
         , @c_ODUDF0102       NVARCHAR(120)
         , @n_seqno           INT
         , @c_ColValue        NVARCHAR(20)   
         , @c_SStyle          NVARCHAR(50)
         , @c_SColor          NVARCHAR(50)
         , @c_SSize           NVARCHAR(50)
         , @n_maxLine         INT
   
   SET @n_NoOfLine = 15
   SET @n_TotDetail= 0
   SET @n_LineNeed = 0
   SET @n_SerialNo = 0
   SET @b_debug    = 0


      CREATE TABLE #TMP_ORD35
            (  SeqNo          INT IDENTITY (1,1)
            ,  Orderkey       NVARCHAR(10) DEFAULT ('')
            ,  OrdLineNumber  NVARCHAR(10) DEFAULT ('')
            ,  SKU            NVARCHAR(20) DEFAULT ('')
            ,  TotalQty       INT         DEFAULT (0)
            ,  RecGrp         INT         DEFAULT(0)
          
            )

      CREATE TABLE #TMP_HDR35
            (  SeqNo         INT            
            ,  Orderkey      NVARCHAR(10) NULL
            ,  Storerkey     NVARCHAR(15) NULL
            ,  OrdLineNumber NVARCHAR(10) NULL
            ,  m_company     NVARCHAR(45) NULL
            ,  C1Long        NVARCHAR(150) NULL
            ,  C2Long        NVARCHAR(150) NULL
            ,  SKU           NVARCHAR(120) NULL
            ,  Lottable08    NVARCHAR(30) NULL
            ,  Lottable09    NVARCHAR(30) NULL
            ,  Qty           INT  NULL
            ,  RecGrp        INT NULL              
            ,  C_Contact1    NVARCHAR(45) NULL
            ,  ODNotes       NVARCHAR(120) NULL
         )

      IF ISNULL(RTRIM(@c_Orderkey),'') = ''
      BEGIN
        
        INSERT INTO #TMP_ORD35
            (  Orderkey
            , OrdLineNumber
            ,  SKU
            ,  TotalQty
            ,  RecGrp
            )
         SELECT DISTINCT OH.Orderkey
                 ,OD.OrderLineNumber
               ,OD.sku
               ,Sum(OD.originalqty)
              ,(Row_Number() OVER (PARTITION BY OH.Orderkey ORDER BY OH.Orderkey,OD.sku Asc)-1)/@n_NoOfLine + 1 AS recgrp
         FROM Orders OH  WITH (NOLOCK) 
         JOIN OrderDetail OD (NOLOCK) ON OD.StorerKey = OH.StorerKey
                                      AND OD.Orderkey  = OH.OrderKey
         WHERE OH.Loadkey = @c_Loadkey
         GROUP BY OH.Orderkey, OD.OrderLineNumber ,OD.sku
       ORDER BY   OH.Orderkey, OD.OrderLineNumber ,OD.sku

      END 
      ELSE
      BEGIN
          INSERT INTO #TMP_ORD35
            (  Orderkey
            , OrdLineNumber
            ,  SKU
            ,  TotalQty
            ,  RecGrp
            )
         SELECT DISTINCT OH.Orderkey
                 , OD.OrderLineNumber
               ,OD.sku
               ,Sum(OD.originalqty)
              ,(Row_Number() OVER (PARTITION BY OH.Orderkey ORDER BY OH.Orderkey,OD.sku Asc)-1)/@n_NoOfLine + 1 AS recgrp
         FROM Orders OH  WITH (NOLOCK) 
         JOIN OrderDetail OD (NOLOCK) ON OD.StorerKey = OH.StorerKey
                                      AND OD.Orderkey  = OH.OrderKey
         WHERE OH.orderkey = @c_orderkey
         GROUP BY OH.Orderkey ,OD.sku, OD.OrderLineNumber
       ORDER BY   OH.Orderkey , OD.OrderLineNumber,OD.sku
      END

      INSERT INTO #TMP_HDR35
            (  SeqNo      
            ,  Orderkey   
            ,  Storerkey 
            ,  OrdLineNumber 
            ,  m_company   
            ,  C1Long     
            ,  C2Long     
            ,  SKU        
            ,  Lottable08        
            ,  Lottable09  
            ,  Qty        
            ,  RecGrp                     
            ,  C_Contact1  
            ,  ODNotes  
         )
      SELECT DISTINCT 
             TMP.SeqNo
            ,OH.orderkey
            ,OH.Storerkey
            ,OD.OrderLineNumber
            ,OH.M_Company
            ,C1Long   = ISNULL(C1.long,'')  
            ,C2Long   = ISNULL(C2.long,'') 
            ,SKU        = TMP.SKU
            ,Lottable08 = OD.Lottable08
            ,Lottable09  = OD.Lottable09
            ,Qty        = TMP.TotalQty
            ,RecGrp     = TMP.Recgrp
            ,C_Contact1 = ISNULL(oh.c_contact1,'')
            ,ODNotes     = ISNULL(OD.notes,'') 
      FROM #TMP_ORD35 TMP
      JOIN ORDERS      OH WITH (NOLOCK) ON (TMP.Orderkey = OH.Orderkey)
      JOIN STORER      ST WITH (NOLOCK) ON (OH.Storerkey = ST.Storerkey)
      JOIN ORDERDETAIL OD WITH (NOLOCK) ON (OH.Orderkey = OD.Orderkey) 
                                        and OD.sku = TMP.sku
      JOIN SKU S WITH (NOLOCK) ON OD.storerkey = S.storerkey AND OD.sku = S.sku
      LEFT JOIN CODELKUP C1 WITH (NOLOCK) ON C1.listname = 'PRESSSTYLE' And C1.storerkey = OH.Storerkey and C1.code=OD.lottable08
      LEFT JOIN CODELKUP C2 WITH (NOLOCK) ON C2.listname = 'PRESSLOC' And C2.storerkey = OH.Storerkey and C2.code=OD.lottable10
      GROUP BY   TMP.SeqNo
                 ,OH.orderkey
                 ,OH.Storerkey
                 ,OD.OrderLineNumber
                 ,OH.M_Company
                 ,ISNULL(C1.long,'')
                 ,ISNULL(C2.long,'') 
                 ,TMP.SKU
                 ,OD.Lottable08
                 ,OD.Lottable09
                 ,TMP.TotalQty
                 ,TMP.Recgrp
                 ,ISNULL(c_contact1,'')
                 ,ISNULL(OD.notes,'') 

      ORDER BY TMP.SeqNo

      
    
      SELECT   SeqNo      
            ,  Orderkey   
            ,  Storerkey 
            ,  OrdLineNumber 
            ,  m_company   
            ,  C1Long     
            ,  C2Long     
            ,  SKU        
            ,  Lottable08        
            ,  Lottable09  
            ,  Qty        
            ,  RecGrp                     
            ,  C_Contact1  
            ,  ODNotes  
      FROM #TMP_HDR35
      ORDER BY SeqNo                    

      
      DROP TABLE #TMP_HDR35
      GOTO QUIT_SP


QUIT_SP:  
END       
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF
GO
       
GRANT EXECUTE ON isp_Delivery_Note35_rdt TO NSQL
GO     
