if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_UCC_Carton_Label_78]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[isp_UCC_Carton_Label_78]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store Procedure:  isp_UCC_Carton_Label_78                            */
/* Creation Date: 29-Mar-2019                                           */
/* Copyright: IDS                                                       */
/* Written by: WLCHOOI                                                  */
/*                                                                      */
/* Purpose:  To print Ucc Carton Label 78 (Carton Content)              */
/*           Copy from isp_UCC_Carton_Label_56                          */
/*                                                                      */
/* Input Parameters: (PickSlipNo, CartonNoStart, CartonNoEnd)           */
/*                   OR ExternOrderKey                                  */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By:  r_dw_ucc_carton_label_78                                 */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/* 2019-09-04   WLChooi  1.1  WMS-10453 - Restructure the code, add new */
/*                            mapping (WL01)                            */
/* 2019-11-07   WLChooi  1.2  Fixed barcode not showing completely when */
/*                            labelno with mixed char and number (WL02) */
/************************************************************************/

CREATE PROC dbo.isp_UCC_Carton_Label_78 (
			@c_PickSlipNo     NVARCHAR(20) = ''
		,  @c_StartCartonNo  NVARCHAR(20) = ''
		,  @c_EndCartonNo    NVARCHAR(20) = ''
)
AS
BEGIN

	SET NOCOUNT ON
	SET ANSI_DEFAULTS OFF
	SET QUOTED_IDENTIFIER OFF
	SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  @n_Continue      INT = 1
          , @b_debug         INT = 0
          , @c_EditWho       NVARCHAR(50) = ''
          , @d_EditDate      DATETIME
          , @nSumPackQty     INT = 0
          , @c_GetPickslipno NVARCHAR(20) = ''
          , @nCartonNo       INT

   --WL01 Start
   --IF OBJECT_ID('tempdb..#RESULT ','u') IS NOT NULL 
   --DROP TABLE #RESULT 

   CREATE TABLE #Temp_PACKDETAIL(
        Pickslipno     NVARCHAR(10) NULL,
        CartonFrom     NVARCHAR(10) NULL,
        CartonTo       NVARCHAR(10) NULL )

   CREATE TABLE #Temp_LOC(
        Loadkey        NVARCHAR(10) NULL,
        Pickslipno     NVARCHAR(10) NULL,
        Descr          NVARCHAR(30) NULL,
        LOC            NVARCHAR(10) NULL ) 

   --Check Pickslipno or ExternOrderKey
   IF EXISTS (SELECT 1 FROM ORDERS (NOLOCK) WHERE ExternOrderKey = @c_pickslipno)
   BEGIN
   	  --SELECT @c_pickslipno    = PH.PICKSLIPNO
   	  --FROM PACKHEADER PH (NOLOCK)
   	  --JOIN ORDERS ORD (NOLOCK) ON ORD.ORDERKEY = PH.ORDERKEY
   	  --WHERE ORD.EXTERNORDERKEY = @c_pickslipno
   	  --GROUP BY PH.PICKSLIPNO

      INSERT INTO #Temp_PACKDETAIL
      SELECT Pickslipno, @c_StartCartonNo, @c_EndCartonNo
      FROM PACKHEADER PH (NOLOCK)
   	JOIN ORDERS ORD (NOLOCK) ON ORD.ORDERKEY = PH.ORDERKEY
   	WHERE ORD.EXTERNORDERKEY = @c_pickslipno
   	GROUP BY PH.PICKSLIPNO

      INSERT INTO #Temp_LOC
      SELECT OH.Loadkey, PH.Pickslipno, 
      CASE WHEN COUNT(DISTINCT LPLD.LocationCategory) = 2 THEN 'OBStage Loc:' 
           WHEN COUNT(DISTINCT LPLD.LocationCategory) = 1 THEN CASE WHEN MAX(LPLD.LocationCategory) = 'Staging' THEN 'OBStage Loc:' 
                                                                    WHEN MAX(LPLD.LocationCategory) = 'PACK&HOLD' THEN 'P&H Loc:' ELSE '' END
           ELSE '' END, 
      CASE WHEN COUNT(DISTINCT LPLD.LocationCategory) = 1 
           THEN (SELECT TOP 1 LPLD.LOC FROM LoadPlanLaneDetail LPLD (NOLOCK) WHERE LPLD.LOADKEY = OH.LOADKEY AND LPLD.Externorderkey = OH.Externorderkey
                 AND LPLD.Consigneekey = OH.Consigneekey)
           WHEN COUNT(DISTINCT LPLD.LocationCategory) = 2 
           THEN (SELECT TOP 1 LPLD.LOC FROM LoadPlanLaneDetail LPLD (NOLOCK) WHERE LPLD.LOADKEY = OH.LOADKEY AND LPLD.Externorderkey = OH.Externorderkey
                 AND LPLD.Consigneekey = OH.Consigneekey AND LPLD.LocationCategory = 'STAGING')
           ELSE '' END
      FROM PACKHEADER PH (NOLOCK)
   	JOIN ORDERS OH (NOLOCK) ON OH.ORDERKEY = PH.ORDERKEY
      JOIN LoadplanLaneDetail LPLD (NOLOCK) ON LPLD.LOADKEY = OH.LOADKEY AND LPLD.Externorderkey = OH.Externorderkey
                                           AND LPLD.Consigneekey = OH.Consigneekey
   	WHERE OH.EXTERNORDERKEY = @c_pickslipno
      AND LTRIM(RTRIM(LPLD.LocationCategory)) IN ('PACK&HOLD', 'STAGING')
      GROUP BY OH.Loadkey, PH.Pickslipno, OH.ExternOrderKey, OH.Consigneekey
      
      --SELECT * FROM #TEMP_LOC
   END
   ELSE
   BEGIN
      INSERT INTO #Temp_PACKDETAIL
      SELECT @c_PickSlipNo, @c_StartCartonNo, @c_EndCartonNo

      INSERT INTO #Temp_LOC
      SELECT OH.Loadkey, PH.Pickslipno, 
      CASE WHEN COUNT(DISTINCT LPLD.LocationCategory) = 2 THEN 'OBStage Loc:' 
           WHEN COUNT(DISTINCT LPLD.LocationCategory) = 1 THEN CASE WHEN MAX(LPLD.LocationCategory) = 'Staging' THEN 'OBStage Loc:' 
                                                                    WHEN MAX(LPLD.LocationCategory) = 'PACK&HOLD' THEN 'P&H Loc:' ELSE '' END
           ELSE '' END, 
      CASE WHEN COUNT(DISTINCT LPLD.LocationCategory) = 1 
           THEN (SELECT TOP 1 LPLD.LOC FROM LoadPlanLaneDetail LPLD (NOLOCK) WHERE LPLD.LOADKEY = OH.LOADKEY AND LPLD.Externorderkey = OH.Externorderkey
                 AND LPLD.Consigneekey = OH.Consigneekey)
           WHEN COUNT(DISTINCT LPLD.LocationCategory) = 2 
           THEN (SELECT TOP 1 LPLD.LOC FROM LoadPlanLaneDetail LPLD (NOLOCK) WHERE LPLD.LOADKEY = OH.LOADKEY AND LPLD.Externorderkey = OH.Externorderkey
                 AND LPLD.Consigneekey = OH.Consigneekey AND LPLD.LocationCategory = 'STAGING')
           ELSE '' END
      FROM PACKHEADER PH (NOLOCK)
   	JOIN ORDERS OH (NOLOCK) ON OH.ORDERKEY = PH.ORDERKEY
      JOIN LoadplanLaneDetail LPLD (NOLOCK) ON LPLD.LOADKEY = OH.LOADKEY AND LPLD.Externorderkey = OH.Externorderkey
                                           AND LPLD.Consigneekey = OH.Consigneekey
   	WHERE PH.Pickslipno = @c_pickslipno
      AND LTRIM(RTRIM(LPLD.LocationCategory)) IN ('PACK&HOLD', 'STAGING')
      GROUP BY OH.Loadkey, PH.Pickslipno, OH.ExternOrderKey, OH.Consigneekey

      --SELECT * FROM #TEMP_LOC
   END
   --WL01 End

   CREATE TABLE #RESULT(
       PickSlipNo      NVARCHAR(10) NULL,
       LoadKey         NVARCHAR(10) NULL,
       SKU             NVARCHAR(50) NULL,
       Qty             INT NULL,
       BUSR7           NVARCHAR(50) NULL,
       PACKUOM3        NVARCHAR(50) NULL,
       LABELNO         NVARCHAR(20) NULL,
       EDITWHO         NVARCHAR(45) NULL,
       EditDate        DATETIME NULL,
       CartonNo        INT NULL,
       Descr           NVARCHAR(30) NULL, --WL01
       LOC             NVARCHAR(10) NULL  --WL01
   )

       INSERT INTO #RESULT
       SELECT PD.Pickslipno
             ,ORD.LOADKEY
             ,PD.SKU
             ,PD.QTY
             ,S.BUSR7
             ,P.PACKUOM3
             ,UPPER(PD.LABELNO) --WL02
             ,''
             ,''
             ,PD.CartonNo
             ,ISNULL(L.Descr,'') --WL01
             ,ISNULL(L.LOC,'')   --WL01
       FROM PACKDETAIL PD WITH (NOLOCK)
       JOIN PACKHEADER PH WITH (NOLOCK) ON PH.PICKSLIPNO = PD.PICKSLIPNO
       JOIN ORDERS ORD WITH (NOLOCK) ON ORD.ORDERKEY = PH.ORDERKEY
       JOIN SKU S WITH (NOLOCK) ON S.SKU = PD.SKU AND S.STORERKEY = ORD.STORERKEY
       JOIN PACK P  WITH (NOLOCK) ON P.PACKKEY = S.PACKKEY
       JOIN #Temp_PACKDETAIL T WITH (NOLOCK) ON T.Pickslipno = PD.Pickslipno AND PD.CartonNo BETWEEN T.CartonFrom AND T.CartonTo
       LEFT JOIN #Temp_LOC L WITH (NOLOCK) ON L.Loadkey = ORD.LoadKey AND L.Pickslipno = PH.PickSlipNo
       --WHERE PD.PICKSLIPNO = @c_PickSlipNo --AND PH.STORERKEY = @c_StorerKey                       --WL01
       --AND PD.CARTONNO BETWEEN CAST(@c_StartCartonNo AS INT) AND CAST(@c_EndCartonNo AS INT)       --WL01
       GROUP BY PD.Pickslipno
               ,ORD.LOADKEY
               ,PD.SKU
               ,PD.QTY
               ,S.BUSR7
               ,P.PACKUOM3
               ,UPPER(PD.LABELNO) --WL02
               ,PD.CartonNo
               ,ISNULL(L.Descr,'') --WL01
               ,ISNULL(L.LOC,'')   --WL01
       ORDER BY PD.Pickslipno, PD.CartonNo --WL01

       DECLARE CUR_EDITDATE CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
       SELECT DISTINCT PICKSLIPNO, CARTONNO
       FROM #RESULT
       ORDER BY PICKSLIPNO, CARTONNO

       OPEN CUR_EDITDATE

       FETCH NEXT FROM CUR_EDITDATE INTO @c_GetPickslipno, @nCartonNo

       WHILE @@FETCH_STATUS <> -1
       BEGIN
            SELECT @c_editwho   = MAX(EDITWHO) ,
                   @d_editdate  = MAX(EDITDATE)
            FROM PACKDETAIL (NOLOCK)
            WHERE PICKSLIPNO = @c_GetPickslipno 
            AND CARTONNO = @nCartonNo

            UPDATE #RESULT
            SET EditDate = @d_editdate, EditWho = @c_editwho
            WHERE PICKSLIPNO = @c_GetPickslipno 
            AND CARTONNO = @nCartonNo

       FETCH NEXT FROM CUR_EDITDATE INTO @c_GetPickslipno, @nCartonNo
       END
       CLOSE CUR_EDITDATE
       DEALLOCATE CUR_EDITDATE

   SELECT * FROM #RESULT
   ORDER BY PickSlipNo, CARTONNO  --WL01
   
   IF OBJECT_ID('tempdb..#RESULT ','u') IS NOT NULL 
   DROP TABLE #RESULT

   --WL01 Start
   IF OBJECT_ID('tempdb..#Temp_PACKDETAIL ','u') IS NOT NULL 
   DROP TABLE #Temp_PACKDETAIL 

   IF OBJECT_ID('tempdb..#Temp_LOC ','u') IS NOT NULL 
   DROP TABLE #Temp_LOC 
   --WL01 End
END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
GRANT EXECUTE ON isp_UCC_Carton_Label_78 TO NSQL
GO