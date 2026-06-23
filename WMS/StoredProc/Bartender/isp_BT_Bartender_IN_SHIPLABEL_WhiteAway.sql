      
/********************************************************************************/      
/* Copyright: MAERSK                                                            */      
/* Purpose: isp_BT_Bartender_IN_SHIPLABEL_WhiteAway                             */      
/*                                                                              */      
/* Modifications log:                                                           */      
/*                                                                              */      
/* Date       Rev  Author       Purposes                                        */      
/* 2026-05-04 1.0  Saurabh Sharma   Created (N/A)                               */      
/********************************************************************************/      
      
CREATE   PROC [dbo].[isp_BT_Bartender_IN_SHIPLABEL_WhiteAway]      
(  @c_Sparm01            NVARCHAR(250)   -- PickslipNo      
 , @c_Sparm02            NVARCHAR(250)   -- CartonNo      
 , @c_Sparm03            NVARCHAR(250)      
 , @c_Sparm04            NVARCHAR(250)      
 , @c_Sparm05            NVARCHAR(250)      
 , @c_Sparm06            NVARCHAR(250)      
 , @c_Sparm07            NVARCHAR(250)      
 , @c_Sparm08            NVARCHAR(250)      
 , @c_Sparm09            NVARCHAR(250)      
 , @c_Sparm10            NVARCHAR(250)      
 , @b_debug              INT = 0      
)      
AS      
BEGIN      
   SET NOCOUNT ON      
   SET ANSI_NULLS OFF      
   SET QUOTED_IDENTIFIER OFF      
   SET CONCAT_NULL_YIELDS_NULL OFF      
      
   DECLARE @c_PickslipNo NVARCHAR(10)  = @c_Sparm01      
         , @n_CartonNo   NVARCHAR(10)  = ISNULL(@c_Sparm02,'')      
         , @b_Success    INT           = 0      
         , @n_err        INT           = 0      
         , @c_errmsg     NVARCHAR(255) = ''      
      
   IF OBJECT_ID('tempdb..#TEMP_PACKDET','U') IS NOT NULL      
      DROP TABLE #TEMP_PACKDET;      
      
   CREATE TABLE [#Result]      
   (      
      [ID]    [INT]          IDENTITY(1, 1) NOT NULL      
    , [Col01] [NVARCHAR](80) NULL      
    , [Col02] [NVARCHAR](80) NULL      
    , [Col03] [NVARCHAR](80) NULL      
    , [Col04] [NVARCHAR](80) NULL      
    , [Col05] [NVARCHAR](80) NULL      
    , [Col06] [NVARCHAR](80) NULL      
    , [Col07] [NVARCHAR](80) NULL      
    , [Col08] [NVARCHAR](80) NULL      
    , [Col09] [NVARCHAR](80) NULL      
    , [Col10] [NVARCHAR](80) NULL      
    , [Col11] [NVARCHAR](80) NULL      
    , [Col12] [NVARCHAR](80) NULL      
    , [Col13] [NVARCHAR](80) NULL      
    , [Col14] [NVARCHAR](80) NULL      
    , [Col15] [NVARCHAR](80) NULL      
    , [Col16] [NVARCHAR](80) NULL      
    , [Col17] [NVARCHAR](80) NULL      
    , [Col18] [NVARCHAR](80) NULL      
    , [Col19] [NVARCHAR](80) NULL      
    , [Col20] [NVARCHAR](80) NULL      
    , [Col21] [NVARCHAR](80) NULL      
    , [Col22] [NVARCHAR](80) NULL      
    , [Col23] [NVARCHAR](80) NULL      
    , [Col24] [NVARCHAR](80) NULL      
    , [Col25] [NVARCHAR](80) NULL      
    , [Col26] [NVARCHAR](80) NULL      
    , [Col27] [NVARCHAR](80) NULL      
    , [Col28] [NVARCHAR](80) NULL      
    , [Col29] [NVARCHAR](80) NULL      
    , [Col30] [NVARCHAR](80) NULL      
    , [Col31] [NVARCHAR](80) NULL      
    , [Col32] [NVARCHAR](80) NULL      
    , [Col33] [NVARCHAR](80) NULL      
    , [Col34] [NVARCHAR](80) NULL      
    , [Col35] [NVARCHAR](80) NULL      
    , [Col36] [NVARCHAR](80) NULL      
    , [Col37] [NVARCHAR](80) NULL      
    , [Col38] [NVARCHAR](80) NULL      
    , [Col39] [NVARCHAR](80) NULL      
    , [Col40] [NVARCHAR](80) NULL      
    , [Col41] [NVARCHAR](80) NULL      
    , [Col42] [NVARCHAR](80) NULL      
    , [Col43] [NVARCHAR](80) NULL      
    , [Col44] [NVARCHAR](80) NULL      
    , [Col45] [NVARCHAR](80) NULL      
    , [Col46] [NVARCHAR](80) NULL      
    , [Col47] [NVARCHAR](80) NULL      
    , [Col48] [NVARCHAR](80) NULL      
    , [Col49] [NVARCHAR](80) NULL      
    , [Col50] [NVARCHAR](80) NULL      
    , [Col51] [NVARCHAR](80) NULL     
    , [Col52] [NVARCHAR](80) NULL      
    , [Col53] [NVARCHAR](80) NULL      
    , [Col54] [NVARCHAR](80) NULL      
    , [Col55] [NVARCHAR](80) NULL      
    , [Col56] [NVARCHAR](80) NULL     
    , [Col57] [NVARCHAR](80) NULL      
    , [Col58] [NVARCHAR](80) NULL      
    , [Col59] [NVARCHAR](80) NULL      
    , [Col60] [NVARCHAR](80) NULL      
   )      
      
   -- Discrete Orders      
   SELECT   
 LabelNo             = ISNULL(RTRIM(MAX(PD.LabelNo)),'')          
  , Address1            = ISNULL(RTRIM(MAX(FAC.Address1)),'')      
  , Address2            = ISNULL(RTRIM(MAX(FAC.Address2)),'')      
  , Address3            = ISNULL(RTRIM(MAX(FAC.Address3)),'')      
  , Address4            = ISNULL(RTRIM(MAX(FAC.Address4)),'')      
  , City                = ISNULL(RTRIM(MAX(FAC.City)),'')      
  , State               = ISNULL(RTRIM(MAX(FAC.State)),'')      
  , Zip                 = ISNULL(RTRIM(MAX(FAC.Zip)),'')      
  , ISOCntryCode        = ISNULL(RTRIM(MAX(FAC.ISOCntryCode)),'')        
  --, Email1            = ISNULL(RTRIM(MAX(FAC.Email1)),'')      
  --, Contact1          = ISNULL(RTRIM(MAX(FAC.Contact1)),'')      
  --, GSTIN             = ISNULL(RTRIM(MAX(FAC.UserDefine09)),'')      
  --, PAN               = ISNULL(RTRIM(MAX(FAC.UserDefine10)),'')      
  , ConsigneeKey        = ISNULL(RTRIM(MAX(OH.ConsigneeKey)),'')      
  --, C_Company         = ISNULL(RTRIM(MAX(OH.C_Company)),'')      
  , C_Contact1          = ISNULL(RTRIM(MAX(OH.C_Contact1)),'')      
  , C_Address1          = ISNULL(RTRIM(MAX(OH.C_Address1)),'')      
  , C_Address2          = ISNULL(RTRIM(MAX(OH.C_Address2)),'')      
  , C_Address3          = ISNULL(RTRIM(MAX(OH.C_Address3)),'')      
  , C_Address4          = ISNULL(RTRIM(MAX(OH.C_Address4)),'')      
  , C_City              = ISNULL(RTRIM(MAX(OH.C_City)),'')      
  , C_State             = ISNULL(RTRIM(MAX(OH.C_State)),'')      
  , C_Zip               = ISNULL(RTRIM(MAX(OH.C_Zip)),'')      
  , C_Country           = ISNULL(RTRIM(MAX(OH.C_Country)),'')      
  , Return_Address1     = ISNULL(RTRIM(MAX(SC.OPTION1)),'')      
  , Return_Address2     = ISNULL(RTRIM(MAX(SC.OPTION2)),'')      
  , Return_Address3     = ISNULL(RTRIM(MAX(SC.OPTION3)),'')      
  , Return_Address4     = ISNULL(RTRIM(MAX(SC.OPTION1)),'')      
  , Return_Address5     = ISNULL(RTRIM(MAX(SC.OPTION5)),'')  
  , ShipDate            = ISNULL(RTRIM(PD.AddDate),'')      
  , DeliveryDate        = ISNULL(RTRIM(OH.DeliveryDate),'')      
  , CartonNo            = ISNULL(RTRIM(PD.CartonNo), '')  
  , TTLCNTS             = ISNULL(RTRIM(PH.TTLCNTS),'')      
   
  , ExternOrderKey      = ISNULL(RTRIM(MAX(OH.ExternOrderKey)),'')      
  , OrderKey            = ISNULL(RTRIM(MAX(OH.OrderKey)),'')      
  , InvoiceNo           = ISNULL(RTRIM(MAX(OH.InvoiceNo)),'')      
  , C_Phone1            = ISNULL(RTRIM(MAX(OH.C_Phone1)),'')      
  , OrderDate           = ISNULL(RTRIM(MAX(OH.OrderDate)),'')        
  , Sku                 = ISNULL(RTRIM(PD.Sku),'')      
  , AltSku              = ISNULL(RTRIM(SKU.AltSku),'')      
  --, Color             = ISNULL(RTRIM(MAX(SKU.Color)),'')      
  --, Size              = ISNULL(RTRIM(MAX(SKU.Size)),'')      
  , DESCR               = ISNULL(RTRIM(MAX(SKU.DESCR)),'')      
  , Qty                 = SUM(PD.Qty)      
  --, Line_No             = ROW_NUMBER() OVER(PARTITION BY PD.PickslipNo, PD.CartonNo ORDER BY PD.Sku)      
  --, Descr             = ISNULL(RTRIM(MAX(FAC.Descr)),'')      
   INTO #TEMP_PACKDET      
   FROM dbo.PACKHEADER   PH  WITH(NOLOCK)      
   JOIN dbo.ORDERS       OH  WITH(NOLOCK) ON PH.Orderkey = OH.Orderkey      
   JOIN dbo.PACKDETAIL   PD  WITH(NOLOCK) ON PH.PickslipNo = PD.PickslipNo      
   JOIN dbo.SKU          SKU WITH(NOLOCK) ON PD.Storerkey = SKU.Storerkey AND PD.Sku = SKU.Sku      
   join dbo.FACILITY     FAC WITH(NOLOCK) ON OH.Facility = FAC.Facility      
   join dbo.StorerConfig SC  with(nolock) on OH.StorerKey = SC.StorerKey and SC.ConfigKey = 'DefaultReturnAddress'  
   WHERE PD.PickslipNo = @c_PickslipNo      
   AND PD.CartonNo = @n_CartonNo      
   GROUP BY PD.PickslipNo      
          , PD.CartonNo      
          , PD.Sku      
          , sku.ALTSKU    
    , PD.AddDate  
    , ph.TTLCNTS  
          , oh.DeliveryDate  
      
   INSERT INTO   
   #Result (  
            Col01, Col02, Col03, Col04, Col05, Col06, Col07, Col08, Col09, Col10, Col11, Col12, Col13, Col14, Col15, Col16, Col17, Col18, Col19,  
   Col20, Col21,Col22, Col23, Col24, Col25, Col26, Col27, Col28, Col29, Col30, Col31, Col32, Col33, Col34, Col35, Col36, Col37, Col38,  
   Col39, Col40, Col41, Col42, Col43, Col44, Col45, Col46, Col47, Col48, Col49, Col50, Col51, Col52, Col53, Col54, Col55, Col56, Col57,  
   Col58, Col59, Col60 )     
  SELECT      
 Col01 = ISNULL( MAX(X.LabelNo), '')    --ISNULL( MAX(X.InvoiceNo), '')    
  , Col02 = ISNULL( MAX(X.Address1), '')    
  , Col03 = ISNULL( MAX(X.Address2), '')    
  , Col04 = ISNULL( MAX(X.Address3), '')    
  , Col05 = ISNULL( MAX(X.Address4), '')    
  , Col06 = ISNULL( MAX(X.City), '')    
  , Col07 = ISNULL( MAX(X.State), '')    
  , Col08 = ISNULL( MAX(X.Zip), '')    
  , Col09 = ISNULL( MAX(X.ISOCntryCode), '')            
  , Col10 = ISNULL( MAX(X.ConsigneeKey), '')      
  , Col11 = ISNULL( MAX(X.C_Contact1), '')      
  , Col12 = ISNULL( MAX(X.C_Address1), '')      
  , Col13 = ISNULL( MAX(X.C_Address2), '')      
  , Col14 = ISNULL( MAX(X.C_Address3), '')     
  , Col15 = ISNULL( MAX(X.C_Address4), '')     
  , Col16 = ISNULL( MAX(X.C_City), '')     
  , Col17 = ISNULL( MAX(X.C_State), '')   
  , Col18 = ISNULL( MAX(X.C_Zip), '')   
  , Col19 = ISNULL( MAX(X.C_Country), '')  --ISNULL( MAX(X.OrderKey), '')   
  , Col20 = ISNULL( MAX(X.Return_Address1), '')   
  , Col21 = ISNULL( MAX(X.Return_Address2), '')   
  , Col22 = ISNULL( MAX(X.Return_Address3), '')   
  , Col23 = ISNULL( MAX(X.Return_Address4), '')   
  , Col24 = ISNULL( MAX(X.Return_Address5), '')   
  , Col25 = ISNULL( MAX(X.ShipDate), '')   
  , Col26 = ISNULL( MAX(X.DeliveryDate), '')   
  , Col27 = ISNULL( MAX(X.CartonNo), '')   
  , Col28 = ISNULL( MAX(X.TTLCNTS), '')   
  , Col29 = ''  
  , Col30 = ''  
  , Col31 = ''  
  , Col32 = ''  
  , Col33 = ''  
  , Col34 = ''  
  , Col35 = ''  
  , Col36 = ''  
  , Col37 = ''  
  , Col38 = ''  
  , Col39 = ''  
  , Col40 = ''  
  , Col41 = ''  
  , Col42 = ''  
  , Col43 = ''  
  , Col44 = ''  
  , Col45 = ''  
  , Col46 = ''  
  , Col47 = ''  
  , Col48 = ''  
  , Col49 = ''  
  , Col50 = ''  
  , Col51 = ''  
  , Col52 = ''  
  , Col53 = ''  
  , Col54 = ''  
  , Col55 = ''  
  , Col56 = ''  
  , Col57 = ''  
  , Col58 = ''  
  , Col59 = ''  
  , Col60 = ''  
  --, Col20 = ISNULL( MAX(CASE WHEN X.Line=1  THEN FORMAT(X.Line_No,'00') END), '')      
  --, Col21 = ISNULL( MAX(CASE WHEN X.Line=1  THEN X.AltSku   END), '')      
  --, Col22 = ISNULL( MAX(CASE WHEN X.Line=1  THEN X.DESCR   END), '')      
  --, Col23 = ISNULL( MAX(CASE WHEN X.Line=1  THEN CONVERT(NVARCHAR(10),X.Qty) END), '')      
  --, Col24 = ISNULL( MAX(CASE WHEN X.Line=2  THEN FORMAT(X.Line_No,'00') END), '')      
  --, Col25 = ISNULL( MAX(CASE WHEN X.Line=2  THEN X.AltSku   END), '')     
  --, Col26 = ISNULL( MAX(CASE WHEN X.Line=2  THEN X.DESCR   END), '')      
  --, Col27 = ISNULL( MAX(CASE WHEN X.Line=2  THEN CONVERT(NVARCHAR(10),X.Qty) END), '')      
  --, Col28 = ISNULL( MAX(CASE WHEN X.Line=3  THEN FORMAT(X.Line_No,'00') END), '')      
  --, Col29 = ISNULL( MAX(CASE WHEN X.Line=3  THEN X.AltSku   END), '')     
  --, Col30 = ISNULL( MAX(CASE WHEN X.Line=3  THEN X.DESCR   END), '')      
  --, Col31 = ISNULL( MAX(CASE WHEN X.Line=3  THEN CONVERT(NVARCHAR(10),X.Qty) END), '')      
  --, Col32 = ISNULL( MAX(CASE WHEN X.Line=4  THEN FORMAT(X.Line_No,'00') END), '')      
  --, Col33 = ISNULL( MAX(CASE WHEN X.Line=4  THEN X.AltSku   END), '')     
  --, Col34 = ISNULL( MAX(CASE WHEN X.Line=4  THEN X.DESCR   END), '')      
  --, Col35 = ISNULL( MAX(CASE WHEN X.Line=4  THEN CONVERT(NVARCHAR(10),X.Qty) END), '')      
  --, Col36 = ISNULL( MAX(CASE WHEN X.Line=5  THEN FORMAT(X.Line_No,'00') END), '')      
  --, Col37 = ISNULL( MAX(CASE WHEN X.Line=5  THEN X.AltSku   END), '')     
  --, Col38 = ISNULL( MAX(CASE WHEN X.Line=5  THEN X.DESCR   END), '')      
  --, Col39 = ISNULL( MAX(CASE WHEN X.Line=5  THEN CONVERT(NVARCHAR(10),X.Qty) END), '')      
  --, Col40 = ISNULL( MAX(CASE WHEN X.Line=6  THEN FORMAT(X.Line_No,'00') END), '')      
  --, Col41 = ISNULL( MAX(CASE WHEN X.Line=6  THEN X.AltSku   END), '')     
  --, Col42 = ISNULL( MAX(CASE WHEN X.Line=6  THEN X.DESCR   END), '')      
  --, Col43 = ISNULL( MAX(CASE WHEN X.Line=6  THEN CONVERT(NVARCHAR(10),X.Qty) END), '')        
  --, Col44 = ISNULL( MAX(CASE WHEN X.Line=7  THEN FORMAT(X.Line_No,'00') END), '')      
  --, Col45 = ISNULL( MAX(CASE WHEN X.Line=7  THEN X.AltSku   END), '')     
  --, Col46 = ISNULL( MAX(CASE WHEN X.Line=7  THEN X.DESCR   END), '')      
  --, Col47 = ISNULL( MAX(CASE WHEN X.Line=7  THEN CONVERT(NVARCHAR(10),X.Qty) END), '')        
  --, Col48 = ISNULL( MAX(CASE WHEN X.Line=8  THEN FORMAT(X.Line_No,'00') END), '')      
  --, Col49 = ISNULL( MAX(CASE WHEN X.Line=8  THEN X.AltSku   END), '')     
  --, Col50 = ISNULL( MAX(CASE WHEN X.Line=8  THEN X.DESCR   END), '')      
  --, Col51 = ISNULL( MAX(CASE WHEN X.Line=8  THEN CONVERT(NVARCHAR(10),X.Qty) END), '')        
  --, Col52 = ISNULL( MAX(CASE WHEN X.Line=9  THEN FORMAT(X.Line_No,'00') END), '')      
  --, Col53 = ISNULL( MAX(CASE WHEN X.Line=9  THEN X.AltSku   END), '')     
  --, Col54 = ISNULL( MAX(CASE WHEN X.Line=9  THEN X.DESCR   END), '')      
  --, Col55 = ISNULL( MAX(CASE WHEN X.Line=9  THEN CONVERT(NVARCHAR(10),X.Qty) END), '')        
  --, Col56 = ISNULL( MAX(CASE WHEN X.Line=10  THEN FORMAT(X.Line_No,'00') END), '')      
  --, Col57 = ISNULL( MAX(CASE WHEN X.Line=10  THEN X.AltSku   END), '')     
  --, Col58 = ISNULL( MAX(CASE WHEN X.Line=10  THEN X.DESCR   END), '')      
  --, Col59 = ISNULL( MAX(CASE WHEN X.Line=10  THEN CONVERT(NVARCHAR(10),X.Qty) END), '')        
  --, Col60 = ISNULL( MAX(CASE WHEN X.Line=10  THEN FORMAT(X.Line_No,'00') END), '')      
FROM     (  
      SELECT *      
  --         , PageNo   = (ROW_NUMBER() OVER(PARTITION BY PickslipNo, CartonNo ORDER BY Sku) - 1) / 1000 + 1      
      --     , Line     = (ROW_NUMBER() OVER(PARTITION BY PickslipNo, CartonNo ORDER BY Sku) - 1) % 1000 + 1      
      --     , TotalQty = SUM(Qty) OVER(PARTITION BY PickslipNo, CartonNo)      
    FROM #TEMP_PACKDET   ) X      
   --GROUP BY X.PickslipNo, X.CartonNo, X.PageNo      
   --ORDER BY X.PickslipNo, X.CartonNo, X.PageNo      
    SELECT * FROM #Result      
   ORDER BY ID      
      
END   