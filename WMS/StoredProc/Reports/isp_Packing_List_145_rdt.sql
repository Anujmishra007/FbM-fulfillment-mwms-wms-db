SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO  
/************************************************************************/    
/* Stored Proc: isp_Packing_List_145_rdt                                */    
/* Creation Date: 13-OCT-2023                                           */    
/* Copyright: Maersk                                                    */    
/* Written by: CSCHONG                                                  */    
/*                                                                      */    
/* Purpose: WMS-23774 -[CN] Moleskine - B2B Packing List_NEW            */    
/*        :                                                             */    
/* Called By: r_dw_packing_list_145_rdt                                 */    
/*          :                                                           */    
/* GitLab Version: 1.1                                                  */    
/*                                                                      */    
/* Version: 7.0                                                         */    
/*                                                                      */    
/* Data Modifications:                                                  */    
/*                                                                      */    
/* Updates:                                                             */    
/* Date         Author    Ver Purposes                                  */   
/* 13-OCT-2023  CSCHONG   1.0 Devops Scripts Combine                    */  
/************************************************************************/    
CREATE OR ALTER  PROC [dbo].[isp_Packing_List_145_rdt]  
            @c_Pickslipno    NVARCHAR(15),       
            @c_cartonNoStart NVARCHAR(5) = '',   
            @c_cartonNoEnd   NVARCHAR(5) =''    
AS    
BEGIN    
   SET NOCOUNT ON    
   SET ANSI_NULLS OFF    
   SET QUOTED_IDENTIFIER OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
    
   DECLARE    
           @n_StartTCnt       INT    
         , @n_Continue        INT    
         , @b_Success         INT    
         , @n_Err             INT    
         , @c_Errmsg          NVARCHAR(255)    
         , @c_SummPAck        NVARCHAR(5)  
  
  
    DECLARE   @c_A1              NVARCHAR(80)    
            , @c_A2              NVARCHAR(80)    
            , @c_A3              NVARCHAR(80)     
            , @c_A4              NVARCHAR(250)    
            , @c_A5              NVARCHAR(80)    
            , @c_A7              NVARCHAR(80)     
            , @c_A9              NVARCHAR(80)     
            , @c_A12             NVARCHAR(80)   
            , @c_A14             NVARCHAR(80)     
            , @c_A16             NVARCHAR(80)   
            , @c_A17             NVARCHAR(80)   
            , @c_A18             NVARCHAR(80)   
            , @c_B1              NVARCHAR(80)    
            , @c_B3              NVARCHAR(80)    
            , @c_B5              NVARCHAR(80)    
            , @c_B10             NVARCHAR(80)    
            , @c_B11             NVARCHAR(80)    
            , @c_B12             NVARCHAR(80)   
            , @c_B7              NVARCHAR(80)    
            , @c_B8              NVARCHAR(80)    
            , @c_B9              NVARCHAR(80)   
            , @c_B16             NVARCHAR(80)    
            , @c_B17             NVARCHAR(80)    
            , @c_B18             NVARCHAR(80)   
            , @c_B19             NVARCHAR(80)    
            , @c_C1              NVARCHAR(500)    
            , @c_C2              NVARCHAR(80)   
            , @c_C4              NVARCHAR(80)   
            , @c_ORDTYPE         NVARCHAR(5)  
            , @n_TTLWGT          DECIMAL(10,2)  
            , @n_TTLCUBE         DECIMAL(10,5)  
            , @n_TTLCTN          INT  
  
   SET @n_StartTCnt = @@TRANCOUNT    
   SET @n_Continue  = 1    
   SET @b_Success   = 1    
   SET @n_Err       = 0    
   SET @c_Errmsg    = ''   
   SET @c_SummPAck  = 'N'  
   SET @c_ORDTYPE   = ''  
  
   IF ISNULL(@c_cartonNoStart,'') = '' SET @c_cartonNoStart = '1'  
   IF ISNULL(@c_cartonNoEnd,'') = '' SET @c_cartonNoEnd = '99999'  
  
    
  
      SELECT @c_A1 = ISNULL(MAX(CASE WHEN CL.Code = 'A1'  THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_A2 = ISNULL(MAX(CASE WHEN CL.Code = 'A2'  THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_A3 = ISNULL(MAX(CASE WHEN CL.Code = 'A3'  THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_A4 = ISNULL(MAX(CASE WHEN CL.Code = 'A4'  THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_A5 = ISNULL(MAX(CASE WHEN CL.Code = 'A5'  THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_A7 = ISNULL(MAX(CASE WHEN CL.Code = 'A7'  THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_A9 = ISNULL(MAX(CASE WHEN CL.Code = 'A9'  THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_A12= ISNULL(MAX(CASE WHEN CL.Code = 'A12' THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_A14 = ISNULL(MAX(CASE WHEN CL.Code = 'A14'  THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_A16 = ISNULL(MAX(CASE WHEN CL.Code = 'A16'  THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_A18 = ISNULL(MAX(CASE WHEN CL.Code = 'A18'  THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_B1= ISNULL(MAX(CASE WHEN CL.Code = 'B1' THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_B3= ISNULL(MAX(CASE WHEN CL.Code = 'B3' THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_B5= ISNULL(MAX(CASE WHEN CL.Code = 'B5' THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_B10= ISNULL(MAX(CASE WHEN CL.Code = 'B10' THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_B11= ISNULL(MAX(CASE WHEN CL.Code = 'B11' THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_B12= ISNULL(MAX(CASE WHEN CL.Code = 'B12' THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_B7 = ISNULL(MAX(CASE WHEN CL.Code = 'B7' THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_B8= ISNULL(MAX(CASE WHEN CL.Code = 'B8' THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_B9= ISNULL(MAX(CASE WHEN CL.Code = 'B9' THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_C1= ISNULL(MAX(CASE WHEN CL.Code = 'C1' THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_C2= ISNULL(MAX(CASE WHEN CL.Code = 'C2' THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
            ,@c_C4= ISNULL(MAX(CASE WHEN CL.Code = 'C4' THEN ISNULL(RTRIM(CL.NOTES),'') ELSE '' END),'')  
   FROM CODELKUP CL WITH (NOLOCK)  
   WHERE CL.ListName = 'MSKB2BPKL'  
  
  
     SELECT @n_TTLWGT= SUM(PIF.Weight) ,  
            @n_TTLCUBE = CAST(SUM(PIF.Cube) AS DECIMAL(10,3)),  
            @n_TTLCTN = COUNT(DISTINCT PIF.cartonno)  
     FROM dbo.PackInfo PIF WITH (NOLOCK) WHERE PIF.PickSlipNo=@c_Pickslipno  
  
    
   SELECT ISNULL(OH.Externorderkey,'') AS Externorderkey  
        , LTRIM(RTRIM(ISNULL(OH.C_Company,'')))  AS CCompany  
        --, LTRIM(RTRIM(ISNULL(F.Address3,'')))  AS FAdd3   
        --, LTRIM(RTRIM(ISNULL(F.Address4,'')))  AS FAdd4  
        , OH.BuyerPO   --20    
        , @c_A2 AS A2    
        , @c_A3 AS A3  
        , PD.SKU      
        , @c_A1 AS A1  
        , SUM(PD.QTY) AS Qty   
        , S.DESCR      
        , PH.PickSlipNo AS Pickslipno  
        , PD.LabelNo--20    
        , @c_B1 AS B1  
        , @c_B3 AS B3  
        , @c_A7 AS A7  
        , @c_B5 AS B5  
        , @c_A9 AS A9  
        , @c_A4 AS A4  
        , @c_A12 AS A12  
        , @c_A16 AS A16  
        , @c_A14 AS A14  
        , @c_A18 AS A18  
        , @c_B10 AS B10  
        , @c_B11 AS B11  
        , @c_B12 AS B12  
        , @c_B7 AS B7  
        , @c_B8 AS B8  
        , @c_B9 AS B9  
        , @c_A5 AS A5  
        --, @c_A6 AS B17  
        --, @c_B18 AS B18  
        --, @c_B19 AS B19  
        , @c_C1 AS C1  
        , @c_C2 AS C2  
        , @c_C4 AS C4  
        , LTRIM(RTRIM(ISNULL(OH.C_Address1,''))) AS CAdd1   
        --, LTRIM(RTRIM(ISNULL(OH.C_Address2,''))) AS BAdd2  
        --, LTRIM(RTRIM(ISNULL(OH.C_City,''))) + ' ' +  LTRIM(RTRIM(ISNULL(OH.C_Zip,''))) + ' ' +  LTRIM(RTRIM(ISNULL(OH.C_Country,''))) AS BCityZip  
        , PD.CartonNo  
        , CAST(SUM(PIF.Weight) AS DECIMAL(10,2)) AS PIFWGT  
        , CAST(SUM(PIF.Cube) AS DECIMAL(10,3)) AS PIFCUBE  
        --, S.Style   
        --, S.Color   
        --, S.Size    
        , S.RETAILSKU  
      --  , S.SKU  
        , @n_TTLWGT AS TTLWGT  
        , @n_TTLCUBE AS TTLCUBE   
   FROM ORDERS OH (NOLOCK)  
   JOIN PACKHEADER PH (NOLOCK) ON OH.OrderKey = PH.OrderKey  
   JOIN PACKDETAIL PD (NOLOCK) ON PH.Pickslipno = PD.PickSlipNo                       
   JOIN SKU S (NOLOCK) ON S.SKU = PD.SKU AND S.StorerKey = OH.StorerKey  
   JOIN dbo.FACILITY F WITH (NOLOCK) ON F.Facility = OH.Facility  
   JOIN dbo.PackInfo PIF WITH (NOLOCK) ON PIF.PickSlipNo=PD.PickSlipNo AND PIF.CartonNo = PD.CartonNo  
   --CROSS APPLY (SELECT PIF.PickSlipNo,PIF.CartonNo,SUM(PIF.Weight) AS PIFWGT,CAST(SUM(PIF.Cube) AS DECIMAL(10,5)) AS PIFCUBE  
   --             FROM dbo.PackInfo PIF WITH (NOLOCK) WHERE PIF.PickSlipNo=PD.PickSlipNo AND PIF.CartonNo = PD.CartonNo  
   --             GROUP BY PIF.PickSlipNo,PIF.CartonNo) AS PIF  
   WHERE PH.PickSlipNo = @c_Pickslipno  
   AND OH.DocType='N'  
   GROUP BY ISNULL(OH.Externorderkey,''),LTRIM(RTRIM(ISNULL(OH.C_Company,'')))   
          --, LTRIM(RTRIM(ISNULL(F.Address1,''))) + ' ,' +  LTRIM(RTRIM(ISNULL(F.Address2,'')))  
          --, LTRIM(RTRIM(ISNULL(F.Address3,'')))    
          --, LTRIM(RTRIM(ISNULL(F.Address4,'')))   
          , OH.BuyerPO,PH.PickSlipNo  
          , S.DESCR  
          , PD.SKU  
          , PH.PickSlipNo  
          , PD.LabelNo  
          , LTRIM(RTRIM(ISNULL(OH.C_Address1,'')))   
          --, LTRIM(RTRIM(ISNULL(OH.C_Address2,'')))  
          --, LTRIM(RTRIM(ISNULL(OH.C_City,''))) + ' ' +  LTRIM(RTRIM(ISNULL(OH.C_Zip,''))) + ' ' +  LTRIM(RTRIM(ISNULL(OH.C_Country,'')))  
          , PD.CartonNo  
          --, S.Style  
          --, S.Color   
          --, S.Size   
          , S.RETAILSKU  
        --  , S.SKU  
    ORDER BY PH.PickSlipNo,PD.CartonNo  
  
  
QUIT_SP:    
  
END -- procedure  

GO
SET QUOTED_IDENTIFIER OFF
GO

GRANT EXECUTE ON [dbo].[isp_Packing_List_145_rdt] TO nSQL 
GO