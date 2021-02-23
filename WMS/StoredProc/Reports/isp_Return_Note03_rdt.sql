IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_Return_Note03_rdt]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_Return_Note03_rdt]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Function:   isp_Return_Note03_rdt                                    */  
/* Creation Date: 02-FEB-2021                                           */  
/* Copyright: IDS                                                       */  
/* Written by: CSCHONG                                                  */  
/*                                                                      */  
/* Purpose:                                                             */  
/*        : WMS-16045 - [KR] - iiCombined - Return Notes in English     */  
/*                                                                      */  
/* Called By:  r_dw_return_note03_rdt                                   */  
/*                                                                      */  
/* PVCS Version: 1.1                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author    Ver.  Purposes                                */  
/************************************************************************/  
  
CREATE PROC [dbo].[isp_Return_Note03_rdt]  (  
    @c_Orderkey           NVARCHAR(10)  
   ,@c_C_ISOCntryCode     NVARCHAR(20) = ''  
   ,@c_Facility           NVARCHAR(10) = '' 
   ,@c_Type               NVARCHAR(10) = '' 
)  
AS                                   
BEGIN    
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF   
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @n_InvAmt             FLOAT  
         , @n_ShippingHandling   FLOAT  
         , @n_NoOfLine           INT  
         , @c_Country            NVARCHAR(10)
         , @c_Storerkey          NVARCHAR(15)  
  
   DECLARE  @n_MaxLineno       INT
      , @n_MaxId           INT
	   , @n_MaxRec          INT
      , @n_CurrentRec      INT
  
   SET @n_MaxLineno = 14
   
   SELECT @c_Storerkey = Storerkey
   FROM ORDERS (NOLOCK)
   WHERE OrderKey = @c_Orderkey
   
   DECLARE @c_A2  NVARCHAR(250) = ''
         , @c_A3  NVARCHAR(250) = ''
         , @c_A4  NVARCHAR(250) = ''
         , @c_A5  NVARCHAR(250) = ''
         , @c_A6  NVARCHAR(250) = ''
         , @c_A7  NVARCHAR(250) = ''
         , @c_A8  NVARCHAR(250) = ''
         , @c_A9  NVARCHAR(250) = ''
         , @c_A10 NVARCHAR(250) = ''
         , @c_A11 NVARCHAR(250) = ''
         , @c_A12 NVARCHAR(250) = ''
         , @c_A13 NVARCHAR(250) = ''
         , @c_A14 NVARCHAR(250) = ''
   
   SELECT @c_A2  = ISNULL(MAX(CASE WHEN C.Code ='A2'  THEN RTRIM(C.long) ELSE 'RETURNS REQUEST' END),'')
        , @c_A3  = ISNULL(MAX(CASE WHEN C.Code ='A3'  THEN RTRIM(C.long) ELSE 'FROM' END),'')           
        , @c_A4  = ISNULL(MAX(CASE WHEN C.Code ='A4'  THEN RTRIM(C.long) ELSE 'ORDER NUMBER' END),'')   
        , @c_A5  = ISNULL(MAX(CASE WHEN C.Code ='A5'  THEN RTRIM(C.long) ELSE 'SHIP TO' END),'')        
        , @c_A6  = ISNULL(MAX(CASE WHEN C.Code ='A6'  THEN RTRIM(C.long) ELSE 'PAYMENT DETAILS' END),'')   
        , @c_A7  = ISNULL(MAX(CASE WHEN C.Code ='A7'  THEN RTRIM(C.long) ELSE 'SHIPPING METHOD' END),'')   
        , @c_A8  = ISNULL(MAX(CASE WHEN C.Code ='A8'  THEN RTRIM(C.long) ELSE 'SHIPPING DATE' END),'')  
        , @c_A9  = ISNULL(MAX(CASE WHEN C.Code ='A9'  THEN RTRIM(C.long) ELSE 'QTY' END),'')            
        , @c_A10 = ISNULL(MAX(CASE WHEN C.Code ='A10' THEN RTRIM(C.long) ELSE 'PRODUCT' END),'')       
        , @c_A11 = ISNULL(MAX(CASE WHEN C.Code ='A11' THEN RTRIM(C.long) ELSE 'RETURN QTY' END),'')    
        , @c_A12 = ISNULL(MAX(CASE WHEN C.Code ='A12' THEN RTRIM(C.long) ELSE '*RETURN REASON' END),'') 
        , @c_A13 = ISNULL(MAX(CASE WHEN C.Code ='A13' THEN RTRIM(C.long) ELSE 'HOW TO RETURN' END),'') 
        , @c_A14 = ISNULL(MAX(CASE WHEN C.Code ='A14' THEN RTRIM(C.long) ELSE '*RETURN REASON' END),'')  
   FROM CODELKUP C WITH (NOLOCK) 
   WHERE C.listname = 'RTNENCONST' 
   AND C.UDF01 = @c_C_ISOCntryCode 
   AND C.UDF02 = @c_Facility 
   AND C.storerkey = @c_Storerkey 

   CREATE TABLE #TMP_RDTNOTE03RDT   
         (  SeqNo                INT IDENTITY (1,1)  
         ,  RecGroup             INT   
         ,  Orderkey             NVARCHAR(10)  
         ,  Sku                  NVARCHAR(20)  
         ,  Descr                NVARCHAR(250)  
         ,  ExtOrderkey          NVARCHAR(50)  
         ,  Company              NVARCHAR(45)  
         ,  OrderDate            DATETIME  
         ,  OHUDF02              NVARCHAR(20)  
         ,  OHUDF05              NVARCHAR(20)  
         ,  C_Address1           NVARCHAR(45)   
         ,  A2                   NVARCHAR(250)      
         ,  A3                   NVARCHAR(250)      
         ,  A4                   NVARCHAR(250)   
         ,  A5                   NVARCHAR(250)                  
         ,  A6                   NVARCHAR(250)       
         ,  A7                   NVARCHAR(250)      
         ,  A8                   NVARCHAR(250)                  
         ,  A9                   NVARCHAR(250)       
         ,  A10                  NVARCHAR(250)       
         ,  A11                  NVARCHAR(250)      
         ,  A12                  NVARCHAR(250)      
         ,  A13                  NVARCHAR(250)   
         ,  A14                  NVARCHAR(250)  
         ,  Qty                  INT              
         ,  QtyUnit              NVARCHAR(5)    
         ,  C_Address2           NVARCHAR(45)   
         ,  C_Address3           NVARCHAR(45)   
         ,  C_Address4           NVARCHAR(45)    
         ,  C_Zip                NVARCHAR(45)      
         )  
  
   INSERT INTO #TMP_RDTNOTE03RDT   
         (  recgroup  
         ,  Orderkey                
         ,  Sku                     
         ,  Descr               
         ,  ExtOrderkey                   
         ,  Company                    
         ,  OrderDate               
         ,  OHUDF02             
         ,  OHUDF05                     
         ,  C_Address1                                       
         ,  A2                     
         ,  A3                      
         ,  A4                     
         ,  A5                     
         ,  A6   
         ,  A7              
         ,  A8                     
         ,  A9                     
         ,  A10                     
         ,  A11   
         ,  A12              
         ,  A13  
         ,  A14  
         ,  Qty  
         ,  QtyUnit        
         ,  C_Address2  
         ,  C_Address3  
         ,  C_Address4  
         ,  C_Zip                       
         )  
   SELECT 1 as recgroup  
         ,OD.Orderkey  
         ,OD.Sku  
         ,Descr =  ISNULL(S.descr,'')  
         ,ExtOrderkey     = OH.Externorderkey  
         ,Company         = OH.C_Company  
         ,OH.OrderDate  
         ,ISNULL(OH.userdefine02,'')  
         ,ISNULL(OH.userdefine05,'')  
         ,ISNULL(OH.C_Address1,'')  
         ,A2 = @c_A2 
         ,A3 = @c_A3 
         ,A4 = @c_A4 
         ,A5 = @c_A5 
         ,A6 = @c_A6             
         ,A7 = @c_A7          
         ,A8 = @c_A8 
         ,A9 = @c_A9 
         ,A10 = @c_A10
         ,A11 = @c_A11
         ,A12 = @c_A12
         ,A13 = @c_A13
         ,A14 = @c_A14
         ,SUM(PD.Qty)          
         ,' X' 
         ,ISNULL(OH.C_Address2,'')  
         ,ISNULL(OH.C_Address3,'')  
         ,ISNULL(OH.C_Address4,'')  
         ,ISNULL(OH.C_Zip,'')  
   FROM ORDERDETAIL OD  WITH (NOLOCK)
   JOIN ORDERS      OH  WITH (NOLOCK) ON (OD.Orderkey = OH.Orderkey)
   JOIN SKU S WITH (NOLOCK) ON s.storerkey = OD.storerkey AND S.sku = OD.sku
   JOIN PICKDETAIL PD (NOLOCK) ON (PD.ORDERKEY = OD.ORDERKEY AND PD.SKU = OD.SKU AND PD.ORDERLINENUMBER = OD.ORDERLINENUMBER) 
   --LEFT JOIN CODELKUP C WITH (NOLOCK) ON C.listname = 'RTNENCONST' AND C.UDF01 = @c_C_ISOCntryCode AND C.UDF02 = @c_Facility AND C.storerkey = OH.Storerkey  
   WHERE OH.Orderkey = @c_Orderkey   
   AND OH.C_ISOCntryCode = @c_C_ISOCntryCode  
   AND OH.Facility = @c_Facility  
   GROUP BY OD.Orderkey  
         ,OD.Sku  
         ,ISNULL(OH.userdefine02,'')   
         ,ISNULL(OH.userdefine05,'')  
         ,ISNULL(S.descr,'')  
         ,OH.Externorderkey  
         ,OH.C_Company  
         ,OH.OrderDate  
         ,ISNULL(OH.C_Address1,'')  
         ,ISNULL(OH.C_Address2,'')  
         ,ISNULL(OH.C_Address3,'')  
         ,ISNULL(OH.C_Address4,'')  
         ,ISNULL(OH.C_Zip,'')    
   ORDER BY OD.SKU  

   SELECT @n_MaxRec = COUNT(1) FROM #TMP_RDTNOTE03RDT

   SET @n_CurrentRec = @n_MaxRec % @n_MaxLineno

   WHILE(@n_MaxRec % @n_MaxLineno <> 0 AND @n_CurrentRec < @n_MaxLineno)
   BEGIN
   INSERT INTO #TMP_RDTNOTE03RDT   
         (  recgroup  
         ,  Orderkey                
         ,  Sku                     
         ,  Descr               
         ,  ExtOrderkey                   
         ,  Company                    
         ,  OrderDate               
         ,  OHUDF02             
         ,  OHUDF05                     
         ,  C_Address1                                       
         ,  A2                     
         ,  A3                      
         ,  A4                     
         ,  A5                     
         ,  A6   
         ,  A7              
         ,  A8                     
         ,  A9                     
         ,  A10                     
         ,  A11   
         ,  A12              
         ,  A13  
         ,  A14  
         ,  Qty  
         ,  QtyUnit        
         ,  C_Address2  
         ,  C_Address3  
         ,  C_Address4  
         ,  C_Zip                       
         )  
   SELECT TOP 1 recgroup  
         ,  Orderkey                
         ,  NULL                     
         ,  NULL               
         ,  ExtOrderkey                   
         ,  Company                    
         ,  OrderDate               
         ,  NULL             
         ,  NULL                     
         ,  C_Address1                                       
         ,  A2                     
         ,  A3                      
         ,  A4                     
         ,  A5                     
         ,  A6   
         ,  A7              
         ,  A8                     
         ,  A9                     
         ,  A10                     
         ,  A11   
         ,  A12              
         ,  A13  
         ,  A14  
         ,  NULL  
         ,  NULL        
         ,  C_Address2  
         ,  C_Address3  
         ,  C_Address4  
         ,  C_Zip                                                                                                            
   FROM #TMP_RDTNOTE03RDT T_INV  
   Order BY SKU  
    
   SET @n_CurrentRec = @n_CurrentRec + 1
   END
    
   SELECT   recgroup  
         ,  Orderkey                
         ,  Sku                     
         ,  Descr               
         ,  ExtOrderkey                   
         ,  Company                    
         ,  OrderDate                                                                       
         ,  A2                     
         ,  A3                      
         ,  A4                     
         ,  A5                     
         ,  A6   
         ,  A7              
         ,  A8                     
         ,  A9     
         ,  A10                     
         ,  A11   
         ,  A12              
         ,  A13  
         ,  A14                           
         ,  Qty  
         ,  QtyUnit  
         ,  CAST(Qty as NVARCHAR(5)) + QtyUnit AS QtyWithPF               
         ,  C_Address1                                                                                                                                                
         ,  C_Address2  
         ,  C_Address3  
         ,  C_Address4  
         ,  C_Zip  
         ,  OHUDF02             
         ,  OHUDF05     
   FROM #TMP_RDTNOTE03RDT T_INV  
   Order BY CASE WHEN SKU <> '' THEN 1 ELSE 2 END
     
   GOTO QUIT  
    
QUIT:  
   IF OBJECT_ID('tempdb..#TMP_RDTNOTE03RDT') IS NOT NULL
      DROP TABLE #TMP_RDTNOTE03RDT
END  
GO
GRANT EXECUTE ON isp_Return_Note03_rdt TO NSQL
GO
