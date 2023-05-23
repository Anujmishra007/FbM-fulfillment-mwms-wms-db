SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO  

/************************************************************************/    
/* Stored Proc: isp_delivery_note40_rpt                                 */    
/* Creation Date: 14-NOV-2019                                           */    
/* Copyright: LF Logistics                                              */    
/* Written by: WLChooi                                                  */    
/*                                                                      */    
/* Purpose: WMS-11130 - COS Japan Delivery Note datawindows             */    
/*        :                                                             */    
/* Called By: r_dw_delivery_note40_rpt                                  */    
/*          :                                                           */    
/* PVCS Version: 1.6                                                    */    
/*                                                                      */    
/* Version: 7.0                                                         */    
/*                                                                      */    
/* Data Modifications:                                                  */    
/*                                                                      */    
/* Updates:                                                             */    
/* Date        Author   Ver   Purposes                                  */    
/* 03-02-2020  WLChooi  1.1   WMS-11130 - Modified by Grick (WL01)      */    
/* 13-02-2020  WLChooi  1.2   Change hardcoded text (WL02)              */    
/* 04-05-2020  WLChooi  1.3   WMS-13213 Change mapping and logic (WL03) */    
/* 09-07-2020  WLChooi  1.4   WMS-13213 Fix sorting by loadkey (WL04)   */    
/* 21-08-2021  Mingle   1.5   WMS-17581 Modify logic (ML01)             */ 
/* 20-12-2021  Mingle   1.5   DevOps Combine Script                     */ 
/* 06-Apr-2023 WLChooi  1.6   WMS-22159 Extend Userdefine01 to 50 (C01) */ 
/************************************************************************/    
CREATE OR ALTER PROC [dbo].[isp_delivery_note40_rpt]    
           @c_Storerkey           NVARCHAR(15)   --WL03    
         , @c_SourcekeyStart      NVARCHAR(10)   --WL03    
         , @c_SourcekeyEnd        NVARCHAR(10)   --WL03    
         , @c_Type                NVARCHAR(10) = ''    
         , @c_Option              NVARCHAR(10) = ''    
AS    
BEGIN    
   SET NOCOUNT ON    
   SET ANSI_NULLS OFF    
   SET QUOTED_IDENTIFIER OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
    
   DECLARE @n_PageGroup       INT    
         , @n_NoOfLine        INT    
         , @n_NoOfLinePerPage INT    
         , @n_MaxSortID       INT     
                
         , @n_Continue        INT    
    
         --, @c_Storerkey       NVARCHAR(15)   --WL03    
         , @c_GetOrderkey     NVARCHAR(10)    
         , @n_TotalPage       INT    
         , @n_GetTotalPages   INT    
         , @n_Testing         INT    
         , @c_GetSKU          NVARCHAR(20)    
         , @n_Count           INT    
         , @n_GetTotalCopies  INT    
    
   SET @n_NoOfLinePerPage = 10    
   SET @n_Continue        = 1    
   SET @n_Count           = 1    
   SET @n_GetTotalCopies  = 1    
   SET @n_Testing         = 0    
    
   CREATE TABLE #TMP_ORDERS     
         (      
            Orderkey       NVARCHAR(10)   NOT NULL PRIMARY KEY    
         ,  Loadkey        NVARCHAR(10)   NULL DEFAULT ('')    
         )    
    
   CREATE TABLE #TMP_Page    
         (  Orderkey       NVARCHAR(10)   NOT NULL PRIMARY KEY    
         ,  TotalPages     INT    
         )    
    
   CREATE TABLE #TMP_OrderSKU    
         (  Orderkey       NVARCHAR(10)   NOT NULL    
         ,  SKU            NVARCHAR(20)     
         ,  FoundInPD      NVARCHAR(1)    NULL      
         )    
    
   CREATE TABLE #TMP_DETAIL_FINAL    
         (  RowID          INT            IDENTITY(1,1)     
         ,  Orderkey       NVARCHAR(10)    
         ,  C_Address1     NVARCHAR(45)    
         ,  C_Addresses    NVARCHAR(250)    
         ,  C_Company      NVARCHAR(45)    
         ,  C_City         NVARCHAR(45)    
         ,  ExternOrderkey NVARCHAR(50)    
         ,  MarkforKey     NVARCHAR(15)    
         ,  Notes2         NVARCHAR(250)    
         ,  OrderDate      NVARCHAR(20)    
         ,  C_State        NVARCHAR(45)    
         ,  UserDefine01   NVARCHAR(50)   --C01    
         ,  UserDefine02   NVARCHAR(20)    
         ,  UserDefine05   NVARCHAR(20)    
         ,  IncoTerm       NVARCHAR(10)    
         ,  CarrierCharges FLOAT    
         ,  OtherCharges   FLOAT    
         ,  PayableAmount  FLOAT    
         ,  F1             NVARCHAR(250)    
         ,  F2             NVARCHAR(250)    
         ,  F3             NVARCHAR(250)    
         ,  G1             NVARCHAR(250)    
         ,  G2             NVARCHAR(250)    
         ,  G3             NVARCHAR(250)    
         ,  H1             NVARCHAR(250)    
         ,  H3             NVARCHAR(250)    
         ,  H5             NVARCHAR(250)    
         ,  H7             NVARCHAR(250)    
         ,  H9             NVARCHAR(250)    
         ,  H11            NVARCHAR(250)    
         ,  H13            NVARCHAR(250)    
         ,  J1             NVARCHAR(250)    
         ,  J3             NVARCHAR(250)    
         ,  J5             NVARCHAR(250)    
         ,  J7             NVARCHAR(250)    
         ,  [Option]       NVARCHAR(250)    
         ,  Loadkey        NVARCHAR(10)   --WL04    
         )    
    
   CREATE TABLE #TMP_DETAIL_FINAL_Copies    
         (  RowID          INT            IDENTITY(1,1)     
         ,  Orderkey       NVARCHAR(10)    
         ,  C_Address1     NVARCHAR(45)    
         ,  C_Addresses    NVARCHAR(250)    
         ,  C_Company      NVARCHAR(45)    
         ,  C_City         NVARCHAR(45)    
         ,  ExternOrderkey NVARCHAR(50)    
         ,  MarkforKey     NVARCHAR(15)    
         ,  Notes2         NVARCHAR(250)    
         ,  OrderDate      NVARCHAR(20)    
         ,  C_State        NVARCHAR(45)    
         ,  UserDefine01   NVARCHAR(50)   --C01    
         ,  UserDefine02   NVARCHAR(20)    
         ,  UserDefine05   NVARCHAR(20)    
         ,  IncoTerm       NVARCHAR(10)    
         ,  CarrierCharges FLOAT    
         ,  OtherCharges   FLOAT    
         ,  PayableAmount  FLOAT    
         ,  F1             NVARCHAR(250)    
         ,  F2             NVARCHAR(250)    
         ,  F3             NVARCHAR(250)    
         ,  G1             NVARCHAR(250)    
         ,  G2             NVARCHAR(250)    
         ,  G3             NVARCHAR(250)    
         ,  H1             NVARCHAR(250)    
         ,  H3             NVARCHAR(250)    
         ,  H5             NVARCHAR(250)    
         ,  H7             NVARCHAR(250)    
         ,  H9             NVARCHAR(250)    
         ,  H11            NVARCHAR(250)    
         ,  H13            NVARCHAR(250)    
         ,  J1             NVARCHAR(250)    
         ,  J3             NVARCHAR(250)    
         ,  J5             NVARCHAR(250)    
         ,  J7             NVARCHAR(250)    
         ,  [Option]       NVARCHAR(250)    
         ,  Loadkey        NVARCHAR(10)   --WL04    
         )    
    
   IF EXISTS (SELECT 1 FROM Loadplan (NOLOCK) WHERE Loadkey BETWEEN @c_SourcekeyStart AND @c_SourcekeyEnd)   --WL03    
   BEGIN    
      INSERT INTO #TMP_ORDERS    
         (      
            Orderkey    
         ,  Loadkey     
         )     
      SELECT DISTINCT    
            LPD.Orderkey    
         ,  LPD.Loadkey    
      FROM LOADPLAN LP WITH (NOLOCK)    
      JOIN LOADPLANDETAIL LPD WITH (NOLOCK) ON (LP.LoadKey = LPD.Loadkey)    
      JOIN ORDERS OH WITH (NOLOCK) ON (LPD.Orderkey = OH.Orderkey)    
      WHERE (LP.Loadkey BETWEEN @c_SourcekeyStart AND @c_SourcekeyEnd) AND OH.StorerKey = @c_Storerkey   --WL03    
   END    
   ELSE    
   BEGIN    
      INSERT INTO #TMP_ORDERS    
         (      
            Orderkey    
         ,  Loadkey     
         )     
      SELECT DISTINCT    
            OH.Orderkey    
         ,  OH.Loadkey    
      FROM ORDERS OH WITH (NOLOCK)    
      WHERE OH.Orderkey = @c_SourcekeyStart AND OH.StorerKey = @c_Storerkey   --WL03    
   END    
    
   --Check if ALL SKU are in Pickdetail    
   /*IF (@n_Continue = 1 OR @n_Continue = 2)    
   BEGIN    
      INSERT INTO #TMP_OrderSKU    
      SELECT DISTINCT OH.Orderkey, OD.SKU, 'Y'    
      FROM ORDERS OH (NOLOCK)    
      JOIN ORDERDETAIL OD (NOLOCK) ON OD.OrderKey = OH.OrderKey    
      JOIN #TMP_ORDERS t (NOLOCK) ON t.Orderkey = OH.OrderKey    
    
      DECLARE cur_SKU CURSOR FAST_FORWARD READ_ONLY FOR    
      SELECT DISTINCT Orderkey, SKU    
      FROM #TMP_OrderSKU    
    
      OPEN cur_SKU    
    
      FETCH NEXT FROM cur_SKU INTO @c_GetOrderkey, @c_GetSKU    
    
      WHILE @@FETCH_STATUS <> -1    
      BEGIN    
         IF NOT EXISTS (SELECT 1 FROM PICKDETAIL (NOLOCK) WHERE Orderkey = @c_GetOrderkey AND SKU = @c_GetSKU)    
         BEGIN    
            UPDATE #TMP_OrderSKU    
            SET FoundInPD = 'N'    
            WHERE Orderkey = @c_GetOrderkey AND SKU = @c_GetSKU    
         END    
    
         FETCH NEXT FROM cur_SKU INTO @c_GetOrderkey, @c_GetSKU    
      END    
      CLOSE cur_SKU    
      DEALLOCATE cur_SKU    
    
      --IF @n_Testing = 1    
      --BEGIN    
      --   UPDATE #TMP_OrderSKU    
      --   SET FoundInPD = 'Y'    
      --   WHERE ORDERKEY = '0000575453'    
      --END    
    
   END*/    
    
   IF (@n_Continue = 1 OR @n_Continue = 2)    
   BEGIN    
      SELECT   OH.Orderkey    
             , ISNULL(OH.C_Address1,'') AS C_Address1    
             , LTRIM(RTRIM(ISNULL(OH.C_State,''))) + LTRIM(RTRIM(ISNULL(OH.C_City,''))) + LTRIM(RTRIM(ISNULL(OH.C_Address1,''))) + ' ' +     
               LTRIM(RTRIM(ISNULL(OH.C_Address2,''))) + ' ' + LTRIM(RTRIM(ISNULL(OH.C_Address3,''))) AS C_Addresses  --WL01    
             , ISNULL(OH.C_Company,'') + N' ��' AS C_Company  --WL01    
             , ISNULL(OH.C_City,'') AS C_City    
             , ISNULL(OH.ExternOrderkey,'') AS ExternOrderkey    
             , ISNULL(OH.MarkforKey,'') AS MarkforKey    
             , ISNULL(OH.Notes2,'') AS Notes2    
             , CAST(DATEPART(YYYY,ISNULL(OH.OrderDate,'1900/01/01')) AS NVARCHAR(10)) + N'��' +     
               CAST(DATEPART(MM,ISNULL(OH.OrderDate,'1900/01/01')) AS NVARCHAR(10)) + N'��' +    
               CAST(DATEPART(DD,ISNULL(OH.OrderDate,'1900/01/01')) AS NVARCHAR(10)) + N'��' AS OrderDate    
             , ISNULL(OH.C_State,'') AS C_State    
             , ISNULL(OH.UserDefine01,'') AS UserDefine01    
             , ISNULL(OH.UserDefine02,'') AS UserDefine02    
             , ISNULL(OH.UserDefine05,'') AS UserDefine05    
             , ISNULL(OH.IncoTerm,'') AS IncoTerm    
             , OD.ExternLineNo    
             , OD.Sku    
             , OD.UnitPrice    
             , ISNULL(OI.CarrierCharges,0.00) AS CarrierCharges    
             , ISNULL(OI.OtherCharges,0.00) AS OtherCharges    
             , ISNULL(OI.PayableAmount,0.00) AS PayableAmount    
             --, ISNULL(S.BUSR7,'') AS BUSR7    
             , LTRIM(RTRIM(ISNULL(OD.UserDefine04,''))) AS BUSR7   --WL03    
             --, ISNULL(S.COLOR,'') AS COLOR    
             , LTRIM(RTRIM(ISNULL(OD.UserDefine03,''))) AS COLOR   --WL03    
             --, ISNULL(S.DESCR,'') AS DESCR    
             , CASE WHEN LTRIM(RTRIM(ISNULL(OD.UserDefine01,''))) + LTRIM(RTRIM(ISNULL(OD.UserDefine02,''))) = '' THEN S.DESCR    
                    ELSE LTRIM(RTRIM(ISNULL(OD.UserDefine01,''))) + LTRIM(RTRIM(ISNULL(OD.UserDefine02,''))) END AS DESCR   --WL03    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'A1'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'��Ʒ�h��'    
                               END),'') AS A1    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'B1'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'����`'    
                               END),'') AS B1    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'C1'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'������'    
             END),'') AS C1    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'D1'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'��Ʒ����'    
                               END),'') AS D1    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'E1'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               --ELSE N'�g��:'  --WL02   
                               ELSE N'�g�� '    --ML01    
                               END),'') AS E1    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'F1'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'ע�ķ���:'    
                               END),'') AS F1    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'F2'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'ע����:'    
                               END),'') AS F2    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'F3'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'֧�B������:'    
                               END),'') AS F3    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'G1'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'���͘�����:'    
                               END),'') AS G1    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'G2'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               --ELSE N'���͘�ס��:'    
                               ELSE '' --ML01  
                               END),'') AS G2    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'G3'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               --ELSE N'E��`��:'    
                               ELSE '' --ML01  
                               END),'') AS G3    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'H1'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'��Ӌ���~(˰�z)'    
                               END),'') AS H1    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'H3'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'����(˰�z)'    
                               END),'') AS H3    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'H5'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'�������Q������(˰�z)'    
                               END),'') AS H5    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'H7'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'����'    
                               END),'') AS H7    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'H9'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'�ݥ����'    
                               END),'') AS H9    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'H11'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'���I�T����'    
                               END),'') AS H11    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'H13'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'֧�B�t�~(˰�z)'    
                               END),'') AS H13    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'J1'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'���͘�����:'    
                               END),'') AS J1    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'J3'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'ע�ķ���:'    
                               END),'') AS J3    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'J5'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'ע����:'    
                               END),'') AS J5    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'J7'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               --ELSE N'E ��`��:'  
                               ELSE '' --ML01   
                               END),'') AS J7    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'K1'    
                             THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'��Ʒ���`��'    
                               END),'') AS K1    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'M1'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'��Ʒ�h��'    
                               END),'') AS M1    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'N1'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'����`'    
                               END),'') AS N1    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'P1'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'������'    
                               END),'') AS P1    
             , ISNULL(MAX(CASE WHEN ISNULL(RTRIM(CL.Code),'') = 'Q1'    
                               THEN ISNULL(RTRIM(CL.Description),'')    
                               ELSE N'��Ʒ����'    
                               END),'') AS Q1        
             , CASE WHEN SUM(OD.ShippedQty) = 0 AND SUM(OD.QtyAllocated) = 0 AND SUM(OD.QtyPicked) = 0 THEN 'Y' ELSE 'N' END AS ShortPick    
             , OH.Loadkey   --WL04    
      INTO #TMP_DETAIL    
      FROM ORDERS OH (NOLOCK)    
      JOIN ORDERDETAIL OD (NOLOCK) ON OD.OrderKey = OH.OrderKey    
      LEFT JOIN ORDERINFO OI (NOLOCK) ON OI.Orderkey = OH.Orderkey    
      JOIN SKU S (NOLOCK) ON S.StorerKey = OH.StorerKey AND S.SKU = OD.Sku    
      LEFT JOIN CODELKUP CL (NOLOCK) ON CL.LISTNAME = 'COSDN' AND CL.Storerkey = OH.Storerkey    
      JOIN #TMP_ORDERS t ON t.Orderkey = OH.Orderkey    
      GROUP BY OH.Orderkey    
             , ISNULL(OH.C_Address1,'')    
             , LTRIM(RTRIM(ISNULL(OH.C_State,''))) + LTRIM(RTRIM(ISNULL(OH.C_City,''))) + LTRIM(RTRIM(ISNULL(OH.C_Address1,''))) + ' ' +     
               LTRIM(RTRIM(ISNULL(OH.C_Address2,''))) + ' ' + LTRIM(RTRIM(ISNULL(OH.C_Address3,'')))  --WL01    
             , ISNULL(OH.C_Company,'') + N' ��'  --WL01    
             , ISNULL(OH.C_City,'')    
             , ISNULL(OH.ExternOrderkey,'')     
             , ISNULL(OH.MarkforKey,'')     
             , ISNULL(OH.Notes2,'')     
             , CAST(DATEPART(YYYY,ISNULL(OH.OrderDate,'1900/01/01')) AS NVARCHAR(10)) + N'��' +     
               CAST(DATEPART(MM,ISNULL(OH.OrderDate,'1900/01/01')) AS NVARCHAR(10)) + N'��' +    
               CAST(DATEPART(DD,ISNULL(OH.OrderDate,'1900/01/01')) AS NVARCHAR(10)) + N'��'    
             , ISNULL(OH.C_State,'')    
             , ISNULL(OH.UserDefine01,'')    
             , ISNULL(OH.UserDefine02,'')    
             , ISNULL(OH.UserDefine05,'')    
             , ISNULL(OH.IncoTerm,'')    
             , OD.ExternLineNo    
             , OD.Sku    
             , OD.UnitPrice    
             , ISNULL(OI.CarrierCharges,0.00)    
             , ISNULL(OI.OtherCharges,0.00)    
             , ISNULL(OI.PayableAmount,0.00)     
             --, ISNULL(S.BUSR7,'')    
             , LTRIM(RTRIM(ISNULL(OD.UserDefine04,'')))   --WL03    
             --, ISNULL(S.COLOR,'')    
             , LTRIM(RTRIM(ISNULL(OD.UserDefine03,'')))   --WL03    
             --, ISNULL(S.DESCR,'')    
             , CASE WHEN LTRIM(RTRIM(ISNULL(OD.UserDefine01,''))) + LTRIM(RTRIM(ISNULL(OD.UserDefine02,''))) = '' THEN S.DESCR    
                    ELSE LTRIM(RTRIM(ISNULL(OD.UserDefine01,''))) + LTRIM(RTRIM(ISNULL(OD.UserDefine02,''))) END   --WL03    
             , OH.Loadkey   --WL04    
   END    
       
   --For testing purpose    
   IF (@n_Continue = 1 OR @n_Continue = 2) AND @n_Testing = 1    
   BEGIN    
      INSERT INTO #TMP_DETAIL    
      SELECT * FROM #TMP_DETAIL    
      UNION ALL    
      SELECT * FROM #TMP_DETAIL    
      UNION ALL    
      SELECT * FROM #TMP_DETAIL    
      UNION ALL    
      SELECT * FROM #TMP_DETAIL    
      UNION ALL    
      SELECT * FROM #TMP_DETAIL    
      UNION ALL    
      SELECT * FROM #TMP_DETAIL    
   END    
    
   --Create Final Result table with empty result    
   /*IF (@n_Continue = 1 OR @n_Continue = 2)    
   BEGIN    
      SELECT DISTINCT     
            Orderkey    
          , C_Address1    
          , C_Addresses    
          , C_Company    
          , C_City    
          , ExternOrderkey    
          , MarkforKey    
          , Notes2    
          , OrderDate    
          , C_State    
          , UserDefine01    
          , UserDefine02    
          , UserDefine05    
          , IncoTerm    
          , CarrierCharges    
          , OtherCharges    
          , PayableAmount    
          , F1    
          , F2    
          , F3    
          , G1    
          , G2    
          , G3    
          , H1    
          , H3    
          , H5    
          , H7    
          , H9    
          , H11    
          , H13    
          , J1    
          , J3    
          , J5    
          , J7    
          , CAST('' AS NVARCHAR(10)) AS [Option]    
      INTO #TMP_DETAIL_FINAL    
      FROM #TMP_DETAIL    
      WHERE 1=2    
   END*/    
    
   --Save shipping detail and return detail into temp table    
   IF (@n_Continue = 1 OR @n_Continue = 2)    
   BEGIN    
      SELECT --DISTINCT     
                (Row_Number() OVER (PARTITION BY Orderkey ORDER BY SKU Asc) - 1 ) + 1 AS ExternLineNo   --WL03    
              , DESCR    
              , COLOR    
              , BUSR7    
              , SKU    
              , UnitPrice    
              , A1    
              , B1    
              , C1    
              , D1    
              , E1    
              , ((Row_Number() OVER (PARTITION BY Orderkey ORDER BY SKU Asc) - 1 ) / @n_NoOfLinePerPage) + 1  AS PageNo   --WL03    
              , Orderkey    
              , ShortPick    
      INTO #TMP_DETAIL_T    
      FROM #TMP_DETAIL    
      --ORDER BY CAST(ExternLineNo AS INT)    
      ORDER BY SKU   --WL03    
    
      SELECT --DISTINCT     
                K1    
              , M1    
              , N1    
              , P1    
              , Q1    
              , SKU    
              , (Row_Number() OVER (PARTITION BY Orderkey ORDER BY SKU Asc) - 1 ) + 1 AS ExternLineNo   --WL03    
              , DESCR    
              , COLOR    
              , BUSR7    
              , ((Row_Number() OVER (PARTITION BY Orderkey ORDER BY SKU Asc) - 1 ) / @n_NoOfLinePerPage) + 1 AS PageNo   --WL03    
              , Orderkey    
              , ShortPick    
      INTO #TMP_DETAIL_B    
      FROM #TMP_DETAIL    
      --ORDER BY CAST(ExternLineNo AS INT)    
      ORDER BY SKU   --WL03    
   END    
    
   --Output Shipping details and return details    
   IF (@n_Continue = 1 OR @n_Continue = 2)    
   BEGIN    
      IF @c_Type = 'T'    
      BEGIN    
         SELECT ExternLineNo, DESCR, COLOR, BUSR7, SKU, UnitPrice,     
                A1, B1, C1, D1, E1, PageNo, ShortPick    
         FROM #TMP_DETAIL_T    
         WHERE Orderkey = @c_SourcekeyStart   --WL03    
         AND PageNo = CASE WHEN ISNULL(@c_Option,'') = '' THEN PageNo ELSE @c_Option END    
         --ORDER BY CAST(ExternLineNo AS INT)    
         ORDER BY SKU   --WL03    
    
         GOTO QUIT_SP    
      END    
      ELSE IF @c_Type = 'B'    
      BEGIN    
         SELECT K1, M1, N1, P1, Q1,    
                SKU, ExternLineNo, DESCR, COLOR, BUSR7, PageNo, ShortPick    
         FROM #TMP_DETAIL_B    
         WHERE Orderkey = @c_SourcekeyStart   --WL03    
         AND PageNo = CASE WHEN ISNULL(@c_Option,'') = '' THEN PageNo ELSE @c_Option END    
         --ORDER BY CAST(ExternLineNo AS INT)    
         ORDER BY SKU   --WL03    
    
         GOTO QUIT_SP    
      END    
   END    
    
   --Find total pages per orderkey based on externlineno and @n_NoOfLinePerPage    
   IF (@n_Continue = 1 OR @n_Continue = 2)    
   BEGIN    
      DECLARE cur_Loop CURSOR FAST_FORWARD READ_ONLY FOR    
      SELECT DISTINCT Orderkey    
      FROM #TMP_DETAIL    
    
      OPEN cur_Loop    
    
      FETCH NEXT FROM cur_Loop INTO @c_GetOrderkey    
    
      WHILE @@FETCH_STATUS <> -1    
      BEGIN    
         INSERT INTO #TMP_Page    
         SELECT @c_GetOrderkey, CEILING((SELECT COUNT(ExternLineNo) FROM ORDERDETAIL (NOLOCK) WHERE ORDERKEY = @c_GetOrderkey) / CAST(@n_NoOfLinePerPage AS FLOAT))    
         --SELECT @c_GetOrderkey, CEILING((SELECT COUNT(ExternLineNo) FROM #TMP_DETAIL (NOLOCK) WHERE ORDERKEY = @c_GetOrderkey) / CAST(@n_NoOfLinePerPage AS FLOAT))    
    
         FETCH NEXT FROM cur_Loop INTO @c_GetOrderkey    
      END    
      CLOSE cur_Loop    
      DEALLOCATE cur_Loop    
   END    
    
   --INSERT final data    
   IF (@n_Continue = 1 OR @n_Continue = 2)    
   BEGIN    
      DECLARE cur_LoopFinal CURSOR FAST_FORWARD READ_ONLY FOR    
      SELECT DISTINCT Orderkey, TotalPages    
      FROM #TMP_Page    
    
      OPEN cur_LoopFinal    
    
      FETCH NEXT FROM cur_LoopFinal INTO @c_GetOrderkey, @n_GetTotalPages    
    
      WHILE @@FETCH_STATUS <> -1    
      BEGIN    
         WHILE @n_GetTotalPages > 0    
         BEGIN    
            INSERT INTO #TMP_DETAIL_FINAL    
            SELECT DISTINCT    
                   Orderkey    
                 , C_Address1    
                 , C_Addresses    
                 , C_Company    
                 , C_City    
                 , ExternOrderkey    
                 , MarkforKey    
                 , Notes2    
                 , OrderDate    
                 , C_State    
                 , UserDefine01    
                 , UserDefine02    
                 , UserDefine05    
                 , IncoTerm    
                 , CarrierCharges    
                 , OtherCharges    
                 , PayableAmount    
                 , F1    
                 , F2    
                 , F3    
                 , G1    
                 , G2    
                 , G3    
                 , H1    
                 , H3    
                 , H5    
                 , H7    
                 , H9    
                 , H11    
                 , H13    
                 , J1    
                 , J3    
                 , J5    
                 , J7    
                 , @n_Count    
                 , Loadkey   --WL04    
            FROM #TMP_DETAIL    
            WHERE OrderKey = @c_GetOrderkey    
    
            SET @n_GetTotalPages = @n_GetTotalPages - 1    
            SET @n_Count = @n_Count + 1    
         END    
    
         SET @n_Count = 1    
    
         FETCH NEXT FROM cur_LoopFinal INTO @c_GetOrderkey, @n_GetTotalPages    
      END    
      CLOSE cur_LoopFinal    
      DEALLOCATE cur_LoopFinal    
   END    
    
   SET @n_Count = 1    
    
   --INSERT final data copies (based on max cartonno) -- Not needed for now    
   IF (@n_Continue = 1 OR @n_Continue = 2)    
   BEGIN    
      DECLARE cur_LoopFinalCopies CURSOR FAST_FORWARD READ_ONLY FOR    
      --SELECT DISTINCT Orderkey    
      --FROM #TMP_DETAIL    
      SELECT Orderkey   --WL04    
      FROM #TMP_DETAIL    
      GROUP BY Orderkey,Loadkey   --WL04    
      ORDER BY Loadkey,Orderkey   --WL04    
    
      OPEN cur_LoopFinalCopies    
    
      FETCH NEXT FROM cur_LoopFinalCopies INTO @c_GetOrderkey    
    
      WHILE @@FETCH_STATUS <> -1    
      BEGIN    
         /*SELECT @n_GetTotalCopies = MAX(CartonNo)    
         FROM PACKHEADER PH (NOLOCK)    
         JOIN PACKDETAIL PD (NOLOCK) ON PH.PickSlipNo = PD.PickSlipNo    
         WHERE PH.OrderKey = @c_GetOrderkey    
    
         IF ISNULL(@n_GetTotalCopies,0) = 0    
         BEGIN    
            GOTO NEXT_ORD    
         END*/    
    
         SELECT @n_GetTotalCopies = 1    
    
         WHILE @n_GetTotalCopies > 0    
         BEGIN    
            INSERT INTO #TMP_DETAIL_FINAL_Copies    
            SELECT DISTINCT    
                   Orderkey    
                 , C_Address1    
                 , C_Addresses    
                 , C_Company    
                 , C_City    
                 , ExternOrderkey    
                 , MarkforKey    
                 , Notes2    
                 , OrderDate    
                 , C_State    
                 , UserDefine01    
                 , UserDefine02    
                 , UserDefine05    
                 , IncoTerm    
                 , CarrierCharges    
                 , OtherCharges    
                 , PayableAmount    
                 , F1    
                 , F2    
                 , F3    
                 , G1    
                 , G2    
                 , G3    
                 , H1    
                 , H3    
                 , H5    
                 , H7    
                 , H9    
                 , H11    
                 , H13    
                 , J1    
                 , J3    
                 , J5    
                 , J7    
                 , [Option]    
               , Loadkey   --WL04    
            FROM #TMP_DETAIL_FINAL    
            WHERE OrderKey = @c_GetOrderkey    
    
            SET @n_GetTotalCopies = @n_GetTotalCopies - 1    
         END    
    
         SET @n_Count = 1    
    
NEXT_ORD:    
         FETCH NEXT FROM cur_LoopFinalCopies INTO @c_GetOrderkey    
      END    
      CLOSE cur_LoopFinalCopies    
      DEALLOCATE cur_LoopFinalCopies    
   END    
    
   --Final Result (Header)    
   IF (@n_Continue = 1 OR @n_Continue = 2)    
   BEGIN    
      SELECT     
            t1.Orderkey    
          , C_Address1    
          , C_Addresses    
          , C_Company    
          , C_City    
          , ExternOrderkey    
          , MarkforKey    
          , Notes2    
          , OrderDate    
          , C_State    
          , UserDefine01    
          , UserDefine02    
          , UserDefine05    
          , IncoTerm    
          , CarrierCharges    
          , OtherCharges    
          , PayableAmount    
          , F1    
          , F2    
          , F3    
          , G1    
          , G2    
          , G3    
          , H1    
          , H3    
          , H5    
          , H7    
          , H9    
          , H11    
          , H13    
          , J1    
          , J3    
          , J5    
          , J7    
          , [Option]    
          , @c_Storerkey AS Storerkey   --WL03    
       --   , (SELECT TOP 1 FoundInPD FROM #TMP_OrderSKU WHERE ORDERKEY = t1.Orderkey) AS FoundInPD    
      FROM #TMP_DETAIL_FINAL_Copies t1    
      ORDER BY RowID, t1.Orderkey, [Option]    
   END    
    
QUIT_SP:    
   IF OBJECT_ID('tempdb..#TMP_DETAIL') IS NOT NULL    
      DROP TABLE #TMP_DETAIL    
    
   IF OBJECT_ID('tempdb..#TMP_DETAIL_FINAL') IS NOT NULL    
      DROP TABLE #TMP_DETAIL_FINAL     
    
   IF OBJECT_ID('tempdb..#TMP_Page') IS NOT NULL    
      DROP TABLE #TMP_Page     
    
   IF OBJECT_ID('tempdb..#TMP_DETAIL_B') IS NOT NULL    
      DROP TABLE #TMP_DETAIL_B    
    
   IF OBJECT_ID('tempdb..#TMP_DETAIL_T') IS NOT NULL    
      DROP TABLE #TMP_DETAIL_T     
    
   IF OBJECT_ID('tempdb..#TMP_OrderSKU') IS NOT NULL    
      DROP TABLE #TMP_OrderSKU     
    
   IF OBJECT_ID('tempdb..#TMP_DETAIL_FINAL_Copies') IS NOT NULL    
      DROP TABLE #TMP_DETAIL_FINAL_Copies     
    
END -- procedure    
GO
GRANT EXECUTE ON [dbo].[isp_delivery_note40_rpt] TO nSQL 
GO  
     