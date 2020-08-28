IF EXISTS (SELECT Name FROM dbo.sysobjects WHERE Name = 'isp_POD_28' AND Type = 'P')
   DROP PROC isp_POD_28  
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO 

/************************************************************************/
/* Stored Proc: isp_POD_28                                              */
/* Creation Date: 19-May-2020                                           */
/* Copyright: LF Logistics                                              */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: WMS-13440 - [CN] Sephora WMS_B2B_POD                        */	
/*                                                                      */
/* Called By: r_dw_pod_28                                               */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/************************************************************************/
CREATE PROC isp_POD_28
            (@c_MBOLKey NVARCHAR(15), @c_module NVARCHAR(10) = 'M', @c_Type NVARCHAR(1) = '') 
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  
           @n_StartTCnt       INT
         , @n_Continue        INT 
         , @c_Pickslipno      NVARCHAR(10) = ''
         , @c_RefNo           NVARCHAR(250) = ''
         , @f_TotalWeight     FLOAT
         , @c_Orderkey        NVARCHAR(10) = ''
         , @b_success         INT = 1
         , @n_Err             INT = 0
         , @c_ErrMsg          NVARCHAR(255) = ''
         , @c_ExternOrderkey1 NVARCHAR(4000) = ''
         , @c_ExternOrderkey2 NVARCHAR(4000) = ''
         , @c_ExternOrderkey3 NVARCHAR(4000) = ''
         , @c_ExternOrderkey4 NVARCHAR(4000) = ''
         , @c_ExternOrderkey5 NVARCHAR(4000) = ''

   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue = 1

   SET @c_MBOLKey = LEFT(LTRIM(RTRIM(@c_MBOLKey)),10)
   --SET @c_Module = RIGHT(LTRIM(RTRIM(@c_MBOLKey)),1)

   IF ISNULL(@c_module,'') = '' SET @c_module = 'M'

   IF ISNULL(@c_Type,'') = '' SET @c_Type = 'D'

   IF @c_Type = 'H'
   BEGIN
      CREATE TABLE #TMP_Palletkey (
         RowID        INT NOT NULL IDENTITY(1,1),
         MBOLKey      NVARCHAR(10),
         Palletkey    NVARCHAR(30) NULL )
      
      CREATE TABLE #TEMP_POD28 (
         MBOLKey      NVARCHAR(10),
         TotalWeight  FLOAT NULL,
         TotalCube    FLOAT NULL,
         TotalCarton  INT NULL,
         TotalLoad    INT NULL,
      )

      DECLARE @c_GetMBOLKey   NVARCHAR(10), @c_GetLoadkey   NVARCHAR(10), @c_GetPickslipno   NVARCHAR(10),
              @c_TotalWeight  FLOAT,
              @c_TotalCube    FLOAT,
              @c_TotalCarton  INT,
              @c_TotalLoad    INT

      DECLARE CUR_TOTAL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT MBOL.MBOLKey, LPD.Loadkey, PH.Pickslipno
      FROM MBOL MBOL (NOLOCK)
      JOIN MBOLDETAIL MD (NOLOCK) ON MD.MBOLKey = MBOL.MBOLKey
      JOIN LOADPLANDETAIL LPD (NOLOCK) ON LPD.Orderkey = MD.Orderkey
      JOIN PACKHEADER PH (NOLOCK) ON PH.Loadkey = LPD.Loadkey
      WHERE MBOL.MBOLKey = @c_MBOLKey
      GROUP BY MBOL.MBOLKey, LPD.Loadkey, PH.Pickslipno

      OPEN CUR_TOTAL

      FETCH NEXT FROM CUR_TOTAL INTO @c_GetMBOLKey, @c_GetLoadkey, @c_GetPickslipno

      WHILE @@FETCH_STATUS <> - 1
      BEGIN
         
         SELECT @c_TotalWeight = SUM([Weight])
              --, @c_TotalCube   = SUM([Cube])
         FROM PACKINFO (NOLOCK)
         WHERE Pickslipno = @c_GetPickslipno

         SELECT @c_TotalCube = SUM(CZ.[Cube])
         FROM CARTONIZATION CZ (NOLOCK)
         JOIN PACKINFO PIF (NOLOCK) ON PIF.CartonType = CZ.CartonType
         JOIN PACKHEADER PH (NOLOCK) ON PH.Pickslipno = PIF.Pickslipno
         JOIN STORER ST (NOLOCK) ON PH.Storerkey = ST.Storerkey AND CZ.CartonizationGroup = ST.CartonGroup
         WHERE PH.Pickslipno = @c_GetPickslipno

         SELECT @c_TotalCarton = COUNT(DISTINCT PD.LabelNo)
              , @c_TotalLoad   = COUNT(DISTINCT LPD.Loadkey)
         FROM MBOL MBOL (NOLOCK)
         JOIN MBOLDETAIL MD (NOLOCK) ON MD.MBOLKey = MBOL.MBOLKey
         JOIN LOADPLANDETAIL LPD (NOLOCK) ON LPD.Orderkey = MD.Orderkey
         JOIN PACKHEADER PH (NOLOCK) ON PH.Loadkey = LPD.Loadkey
         JOIN PACKDETAIL PD (NOLOCK) ON PD.Pickslipno = PH.Pickslipno
         WHERE MBOL.MBOLKey = @c_GetMBOLKey

         INSERT INTO #TEMP_POD28
         SELECT @c_GetMBOLKey, @c_TotalWeight, @c_TotalCube, @c_TotalCarton, @c_TotalLoad

         FETCH NEXT FROM CUR_TOTAL INTO @c_GetMBOLKey, @c_GetLoadkey, @c_GetPickslipno
      END

      --INSERT INTO #TMP_Palletkey
      --SELECT TOP 8 @c_MBOLKey, ISNULL(CD.Palletkey,'')
      --FROM CONTAINER C (NOLOCK)
      --JOIN CONTAINERDETAIL CD (NOLOCK) ON C.Containerkey = CD.Containerkey
      --WHERE C.MBOLKey = @c_MBOLKey
      --GROUP BY ISNULL(CD.Palletkey,'')
      --ORDER BY ISNULL(CD.Palletkey,'')

      INSERT INTO #TMP_Palletkey
      SELECT TOP 8 @c_MBOLKey, ISNULL(PLTD.Palletkey,'')
      FROM MBOL MBOL (NOLOCK)
      JOIN MBOLDETAIL MD (NOLOCK) ON MD.MBOLKey = MBOL.MBOLKey
      JOIN LOADPLANDETAIL LPD (NOLOCK) ON LPD.Orderkey = MD.Orderkey
      JOIN PACKHEADER PH (NOLOCK) ON PH.Loadkey = LPD.Loadkey
      JOIN PACKDETAIL PD (NOLOCK) ON PD.Pickslipno = PH.Pickslipno
      JOIN PALLETDETAIL PLTD (NOLOCK) ON PLTD.CaseID = PD.LabelNo AND PLTD.SKU = PD.SKU AND PLTD.Storerkey = PH.Storerkey
      WHERE MBOL.MBOLKey = @c_MBOLKey
      GROUP BY ISNULL(PLTD.Palletkey,'')
      ORDER BY ISNULL(PLTD.Palletkey,'')

      --Testing
      --INSERT INTO #TMP_Palletkey
      --SELECT @c_MBOLKey,'SPC000000001' UNION ALL SELECT @c_MBOLKey,'SPC000000002' 
      --       UNION ALL SELECT @c_MBOLKey,'SPC000000003' UNION ALL SELECT @c_MBOLKey,'SPC000000004'
      --       UNION ALL SELECT @c_MBOLKey,'SPC000000005' UNION ALL SELECT @c_MBOLKey,'SPC000000006' 
      --       UNION ALL SELECT @c_MBOLKey,'SPC000000007' UNION ALL SELECT @c_MBOLKey,'SPC000000008'

      SELECT DISTINCT 
             MB.MBOLKey
           , ISNULL(F.Contact1,'') AS FContact1
           , OH.Consigneekey
           , t.TotalWeight AS TotalWeight
           , t.TotalCube AS TotalCube
           , t.TotalCarton AS TotalCarton
           , t.TotalLoad AS TotalLoad
           , ISNULL(CLK.Long,'') AS CLPhone
           , ISNULL((SELECT MAX(Palletkey) FROM #TMP_Palletkey WHERE RowID = 1),'') AS Palletkey1
           , ISNULL((SELECT MAX(Palletkey) FROM #TMP_Palletkey WHERE RowID = 2),'') AS Palletkey2
           , ISNULL((SELECT MAX(Palletkey) FROM #TMP_Palletkey WHERE RowID = 3),'') AS Palletkey3
           , ISNULL((SELECT MAX(Palletkey) FROM #TMP_Palletkey WHERE RowID = 4),'') AS Palletkey4
           , ISNULL((SELECT MAX(Palletkey) FROM #TMP_Palletkey WHERE RowID = 5),'') AS Palletkey5
           , ISNULL((SELECT MAX(Palletkey) FROM #TMP_Palletkey WHERE RowID = 6),'') AS Palletkey6
           , ISNULL((SELECT MAX(Palletkey) FROM #TMP_Palletkey WHERE RowID = 7),'') AS Palletkey7
           , ISNULL((SELECT MAX(Palletkey) FROM #TMP_Palletkey WHERE RowID = 8),'') AS Palletkey8
      FROM MBOL MB (NOLOCK)
      JOIN MBOLDETAIL MD (NOLOCK) ON MD.MBOLKey = MB.MBOLKey
      JOIN ORDERS OH (NOLOCK) ON OH.Orderkey = MD.Orderkey
      JOIN Facility F (NOLOCK) ON F.Facility = OH.Facility
      JOIN #TEMP_POD28 t ON t.MBOLKey = MB.MBOLKey
      OUTER APPLY (SELECT MAX(ISNULL(CL.Long,'')) AS Long FROM Codelkup CL (NOLOCK) WHERE CL.LISTNAME = 'SephoraPOD' AND CL.Storerkey = OH.Storerkey) AS CLK

      IF OBJECT_ID('tempdb..#TempPOD28') IS NOT NULL
         DROP TABLE #TempPOD28
   END
   ELSE IF @c_Type = 'D'
   BEGIN
      CREATE TABLE #TEMP_Loadkey (
         Loadkey   NVARCHAR(10) )

      IF EXISTS (SELECT 1 FROM MBOL (NOLOCK) WHERE MBOLKey = @c_MBOLKey) AND @c_module = 'M'
      BEGIN
         INSERT INTO #TEMP_Loadkey
         SELECT DISTINCT OH.Loadkey
         FROM MBOLDETAIL MD (NOLOCK) 
         JOIN ORDERS OH (NOLOCK) ON MD.Orderkey = OH.Orderkey
         WHERE MD.MBOLKey = @c_MBOLKey
      END
      ELSE IF EXISTS (SELECT 1 FROM LOADPLAN (NOLOCK) WHERE Loadkey = @c_MBOLKey) AND @c_module = 'L'
      BEGIN
         INSERT INTO #TEMP_Loadkey
         SELECT @c_MBOLKey
      END
      ELSE
      BEGIN
         INSERT INTO #TEMP_Loadkey
         SELECT DISTINCT PACKHEADER.Loadkey
         FROM PACKHEADER (NOLOCK)
         WHERE PACKHEADER.Pickslipno = @c_MBOLKey
      END

      CREATE TABLE #TMP_DECRYPTEDDATA (
         Orderkey     NVARCHAR(10) NULL,
         C_Company    NVARCHAR(45) NULL,
         C_Address2   NVARCHAR(45) NULL,
         C_Address3   NVARCHAR(45) NULL
      )
      CREATE NONCLUSTERED INDEX IDX_TMP_DECRYPTEDDATA ON #TMP_DECRYPTEDDATA (Orderkey)

      CREATE TABLE #TMP_Externorderkey (
         RowRef            INT NOT NULL IDENTITY(1,1),
         Externorderkey    NVARCHAR(50)
      )

      EXEC isp_Open_Key_Cert_Orders_PI
         @n_Err    = @n_Err    OUTPUT,
         @c_ErrMsg = @c_ErrMsg OUTPUT

      IF ISNULL(@c_ErrMsg,'') <> ''
      BEGIN
         SET @n_Continue = 3
         GOTO QUIT_SP
      END

      DECLARE CUR_LOOP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT LPD.Orderkey
      FROM LOADPLANDETAIL LPD (NOLOCK)
      JOIN #TEMP_Loadkey t ON t.Loadkey = LPD.Loadkey
      
      OPEN CUR_LOOP
      
      FETCH NEXT FROM CUR_LOOP INTO @c_Orderkey
      
      WHILE @@FETCH_STATUS <> -1
      BEGIN
         INSERT INTO #TMP_DECRYPTEDDATA
         SELECT Orderkey, C_Company, C_Address2, C_Address3 FROM fnc_GetDecryptedOrderPI(@c_Orderkey)
      
         FETCH NEXT FROM CUR_LOOP INTO @c_Orderkey
      END

      INSERT INTO #TMP_Externorderkey
      SELECT DISTINCT ORDERS.Externorderkey
      FROM ORDERS (NOLOCK)
      JOIN LOADPLANDETAIL (NOLOCK) ON LOADPLANDETAIL.Loadkey = ORDERS.Loadkey
      JOIN #TEMP_Loadkey t ON t.Loadkey = LOADPLANDETAIL.Loadkey
      ORDER BY ORDERS.Externorderkey

      SELECT @c_ExternOrderkey1 = STUFF((SELECT ', ' + RTRIM(Externorderkey) FROM #TMP_Externorderkey WHERE RowRef BETWEEN 1 AND 3 ORDER BY Externorderkey FOR XML PATH('')),1,1,'' )
      SELECT @c_ExternOrderkey2 = STUFF((SELECT ', ' + RTRIM(Externorderkey) FROM #TMP_Externorderkey WHERE RowRef BETWEEN 4 AND 6 ORDER BY Externorderkey FOR XML PATH('')),1,1,'' )
      SELECT @c_ExternOrderkey3 = STUFF((SELECT ', ' + RTRIM(Externorderkey) FROM #TMP_Externorderkey WHERE RowRef BETWEEN 7 AND 9 ORDER BY Externorderkey FOR XML PATH('')),1,1,'' )
      SELECT @c_ExternOrderkey4 = STUFF((SELECT ', ' + RTRIM(Externorderkey) FROM #TMP_Externorderkey WHERE RowRef BETWEEN 10 AND 12 ORDER BY Externorderkey FOR XML PATH('')),1,1,'' )
      SELECT @c_ExternOrderkey5 = STUFF((SELECT ', ' + RTRIM(Externorderkey) FROM #TMP_Externorderkey WHERE RowRef BETWEEN 13 AND 15 ORDER BY Externorderkey FOR XML PATH('')),1,1,'' )

      SELECT OH.Loadkey
           , ISNULL(F.Contact1,'') AS FContact1
           , ISNULL(F.Address1,'') AS FAddress1
           , ISNULL(F.Address2,'') AS FAddress2
           , ISNULL(F.Address3,'') AS FAddress3
           , t1.C_Company
           , t1.C_Address2
           , CASE WHEN CHARINDEX(' ',ISNULL(t1.C_Address3,''),20) = 0 THEN SUBSTRING(ISNULL(t1.C_Address3,''),1,23) ELSE ISNULL(t1.C_Address3,'') END AS C_Address3,
             CASE WHEN CHARINDEX(' ',ISNULL(t1.C_Address3,''),20) = 0 THEN SUBSTRING(ISNULL(t1.C_Address3,''),24,22) ELSE '' END AS C_Address3_2
           , ISNULL(LP.Load_userdef2,'') AS Load_userdef2
           , PD.LabelNo
           , PIF.[Weight]
           , CZ.[Cube]   --PIF.[Cube]
           , PIF.RefNo
           , LTRIM(RTRIM(@c_ExternOrderkey1)) AS ExternOrderkey1
           , LTRIM(RTRIM(@c_ExternOrderkey2)) AS ExternOrderkey2
           , LTRIM(RTRIM(@c_ExternOrderkey3)) AS ExternOrderkey3
           , LTRIM(RTRIM(@c_ExternOrderkey4)) AS ExternOrderkey4
           , LTRIM(RTRIM(@c_ExternOrderkey5)) AS ExternOrderkey5
      FROM LOADPLAN LP (NOLOCK) 
      JOIN LOADPLANDETAIL LPD (NOLOCK) ON LPD.Loadkey = LP.Loadkey
      JOIN ORDERS OH (NOLOCK) ON LPD.Orderkey = OH.Orderkey
      JOIN FACILITY F (NOLOCK) ON F.Facility = OH.Facility
      JOIN PACKHEADER PH (NOLOCK) ON LP.Loadkey = PH.Loadkey
      JOIN PACKDETAIL PD (NOLOCK) ON PH.Pickslipno = PD.Pickslipno
      JOIN PACKINFO PIF (NOLOCK) ON PIF.Pickslipno = PD.Pickslipno AND PIF.CartonNo = PD.CartonNo
      JOIN #TEMP_Loadkey t ON t.Loadkey = LP.Loadkey
      LEFT JOIN #TMP_DECRYPTEDDATA t1 ON t1.Orderkey = OH.Orderkey
      CROSS APPLY (SELECT CARTONIZATION.[Cube]
                   FROM CARTONIZATION (NOLOCK)
                   JOIN PACKINFO (NOLOCK) ON PACKINFO.CartonType = CARTONIZATION.CartonType
                   JOIN PACKHEADER (NOLOCK) ON PACKHEADER.Pickslipno = PACKINFO.Pickslipno
                   JOIN STORER (NOLOCK) ON PACKHEADER.Storerkey = STORER.Storerkey AND CARTONIZATION.CartonizationGroup = STORER.CartonGroup
                   WHERE PACKHEADER.Pickslipno = PH.Pickslipno AND PACKINFO.CartonNo = PD.CartonNo ) AS CZ
      GROUP BY  OH.Loadkey
           , ISNULL(F.Contact1,'')
           , ISNULL(F.Address1,'')
           , ISNULL(F.Address2,'')
           , ISNULL(F.Address3,'')
           , t1.C_Company
           , t1.C_Address2
           , CASE WHEN CHARINDEX(' ',ISNULL(t1.C_Address3,''),20) = 0 THEN SUBSTRING(ISNULL(t1.C_Address3,''),1,23) ELSE ISNULL(t1.C_Address3,'') END,
             CASE WHEN CHARINDEX(' ',ISNULL(t1.C_Address3,''),20) = 0 THEN SUBSTRING(ISNULL(t1.C_Address3,''),24,22) ELSE '' END
           , ISNULL(LP.Load_userdef2,'')
           , PD.LabelNo
           , PIF.[Weight]
           , CZ.[Cube]   --PIF.[Cube]
           , PIF.RefNo

      IF OBJECT_ID('tempdb..#TEMP_Loadkey') IS NOT NULL
         DROP TABLE #TEMP_Loadkey

      IF OBJECT_ID('tempdb..#TMP_DECRYPTEDDATA') IS NOT NULL
         DROP TABLE #TMP_DECRYPTEDDATA

      IF CURSOR_STATUS('LOCAL', 'CUR_LOOP') IN (0 , 1)
      BEGIN
         CLOSE CUR_LOOP
         DEALLOCATE CUR_LOOP   
      END
   END
QUIT_SP:
END -- procedure

GO
GRANT EXECUTE ON isp_POD_28 TO NSQL
GO   

