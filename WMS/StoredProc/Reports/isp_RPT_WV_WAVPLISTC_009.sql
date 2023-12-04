SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/
/* Stored Procedure: isp_RPT_WV_WAVPLISTC_009                              */
/* Creation Date: 25-Oct-2023                                              */
/* Copyright: MAERSK                                                       */
/* Written by: WLChooi                                                     */
/*                                                                         */
/* Purpose: WMS-23949 - New Consolidate pickslip report for FNA            */
/*                                                                         */
/* Called By: RPT_WV_WAVPLISTC_009                                         */
/*                                                                         */
/* GitHub Version: 1.0                                                     */
/*                                                                         */
/* Version: 1.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date        Author  Ver   Purposes                                      */
/* 25-Oct-2023 WLChooi 1.0   DevOps Combine Script                         */
/***************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_RPT_WV_WAVPLISTC_009]
(
   @c_WaveKey       NVARCHAR(10)
 , @c_PreGenRptData NVARCHAR(10) = ''
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_StartTranCnt  INT
         , @n_continue      INT
         , @n_err           INT
         , @b_Success       INT
         , @c_errmsg        NVARCHAR(255)
         , @c_PickHeaderKey NVARCHAR(10)
         , @c_PrintedFlag   NVARCHAR(1)
         , @c_Loadkey       NVARCHAR(10)
         , @n_CtnOrder      INT
         , @n_TTLQTY        INT
         , @c_VASCode       NVARCHAR(20)
         , @c_LogoType      NVARCHAR(1)  = N'1'
         , @c_Report        NVARCHAR(60) = N'RPT_WV_WAVPLISTC_009'
         , @c_RetVal        NVARCHAR(255)
         , @c_Storerkey     NVARCHAR(15)
         , @n_RowID         INT

   SET @n_StartTranCnt = @@TRANCOUNT
   SET @n_continue = 1
   SET @n_err = 0
   SET @b_Success = 1
   SET @c_errmsg = N''
   SET @c_PickHeaderKey = N''
   SET @c_PrintedFlag = N'N'
   SET @n_CtnOrder = 1
   SET @n_TTLQTY = 1

   CREATE TABLE #TEMP_Wave
   (
      Wavekey       NVARCHAR(10)
    , Pickheaderkey NVARCHAR(10)
    , PrintedFlag   NVARCHAR(1)
   )

   INSERT INTO #TEMP_Wave
   SELECT DISTINCT WD.WaveKey
                 , ISNULL(PH.PickHeaderKey, '')
                 , CASE WHEN ISNULL(PH.PickHeaderKey, '') = '' THEN 'N'
                        ELSE 'Y' END AS PrintedFlag
   FROM WAVEDETAIL WD (NOLOCK)
   LEFT JOIN PICKHEADER PH (NOLOCK) ON PH.WaveKey = WD.WaveKey
   WHERE WD.WaveKey = @c_WaveKey

   SELECT @n_CtnOrder = COUNT(DISTINCT OrderKey)
   FROM WAVEDETAIL WITH (NOLOCK)
   WHERE WaveKey = @c_WaveKey

   SELECT @n_TTLQTY = SUM(PD.Qty)
   FROM WAVEDETAIL WD WITH (NOLOCK)
   JOIN PICKHEADER PH WITH (NOLOCK) ON PH.WaveKey = WD.WaveKey
   JOIN ORDERS OH WITH (NOLOCK) ON WD.OrderKey = OH.OrderKey
   JOIN PICKDETAIL PD WITH (NOLOCK) ON PD.OrderKey = OH.OrderKey
   WHERE WD.WaveKey = @c_WaveKey AND PD.Qty > 0

   SELECT @c_Storerkey = OH.StorerKey
   FROM WAVEDETAIL WD (NOLOCK)
   JOIN ORDERS OH (NOLOCK) ON OH.OrderKey = WD.OrderKey
   WHERE WD.WaveKey = @c_WaveKey
 
   IF ISNULL(@c_PreGenRptData, '') = 'Y'
   BEGIN
      WHILE @@TRANCOUNT > 0 
      BEGIN
         COMMIT TRAN
      END

      IF @@TRANCOUNT = 0
         BEGIN TRAN

      IF EXISTS (  SELECT TOP 1 1
                   FROM #TEMP_Wave
                   WHERE PrintedFlag = 'Y')
      BEGIN
         SET @c_PrintedFlag = N'Y'

         DECLARE CUR_PSLIP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT DISTINCT Pickheaderkey
         FROM #TEMP_Wave
         WHERE Wavekey = @c_WaveKey

         OPEN CUR_PSLIP

         FETCH NEXT FROM CUR_PSLIP
         INTO @c_PickHeaderKey

         WHILE @@FETCH_STATUS <> -1
         BEGIN
            UPDATE PICKHEADER WITH (ROWLOCK)
            SET PickType = '1'
              , EditWho = SUSER_NAME()
              , EditDate = GETDATE()
              , TrafficCop = NULL
            FROM PICKHEADER
            WHERE PickHeaderKey = @c_PickHeaderKey

            FETCH NEXT FROM CUR_PSLIP
            INTO @c_PickHeaderKey
         END
         CLOSE CUR_PSLIP
         DEALLOCATE CUR_PSLIP
      END
      ELSE
      BEGIN
         EXECUTE nspg_GetKey 'PICKSLIP'
                           , 9
                           , @c_PickHeaderKey OUTPUT
                           , @b_Success OUTPUT
                           , @n_err OUTPUT
                           , @c_errmsg OUTPUT
                           , 0
                           , 1

         SET @c_PickHeaderKey = N'P' + @c_PickHeaderKey

         INSERT INTO PICKHEADER (PickHeaderKey, OrderKey, ExternOrderKey, PickType, Zone, TrafficCop, WaveKey, StorerKey)
         SELECT @c_PickHeaderKey
              , ''
              , ''
              , '0'
              , 'C'
              , ''
              , @c_WaveKey
              , @c_Storerkey

         SELECT @n_err = @@ERROR

         IF @n_err <> 0
         BEGIN
            SET @n_continue = 3
            SET @n_err = 63400
            SET @c_errmsg = N'NSQL' + CONVERT(CHAR(5), @n_err)
                            + +N': Insert PICKHEADER Failed. (isp_RPT_WV_WAVPLISTC_009)'
            GOTO QUIT_SP
         END
      END

      WHILE @@TRANCOUNT > 0
      BEGIN
         COMMIT TRAN
      END
   END

   IF ISNULL(@c_PreGenRptData, '') = ''
   BEGIN
      EXEC [dbo].[isp_GetCompanyInfo] @c_Storerkey = @c_Storerkey
                                    , @c_Type = @c_LogoType
                                    , @c_DataWindow = @c_Report
                                    , @c_RetVal = @c_RetVal OUTPUT

      ;WITH CTE AS (
      SELECT ISNULL(TRIM(PICKHEADER.PickHeaderKey), '') AS PickHeaderKey
           , IIF(@c_PrintedFlag = 'Y', 'REPRINT', '') AS PrintedFlag
           , ISNULL(TRIM(WD.WaveKey), '') AS Wavekey
           , LoadPlan.lpuserdefdate01
           , ISNULL(TRIM(LoadPlan.[Route]), '') AS [Route]
           , ISNULL(TRIM(LoadPlan.TrfRoom), '') AS TrfRoom
           , ISNULL(TRIM(PICKDETAIL.Storerkey), '') AS Storerkey
           , ISNULL(TRIM(STORER.Company), '') AS Company
           , ISNULL(TRIM(PICKDETAIL.Sku), '') AS Sku
           , ISNULL(TRIM(PICKDETAIL.Loc), '') AS Loc
           , ISNULL(PICKDETAIL.Qty, 0) AS Qty
           , ISNULL(TRIM(SKU.DESCR), '') AS SKUDescr
           , ISNULL(TRIM(SKU.ALTSKU), '') AS AltSku
           , ISNULL(TRIM(SKU.MANUFACTURERSKU), '') AS ManufacturerSKU
           , ISNULL(SKU.STDCUBE, 0.0) AS StdCube
           , ISNULL(SKU.STDGROSSWGT, 0.0) AS StdGrossWgt
           , ISNULL(PACK.CaseCnt, 0.0) AS CaseCnt
           , ISNULL(PACK.InnerPack, 0.0) AS InnerPack
           , ISNULL(PICKDETAIL.ID, '') AS PalletID
           , ISNULL(TRIM(LOTATTRIBUTE.Lottable02), '') AS Lottable02
           , ISNULL(TRIM(LOTATTRIBUTE.Lottable03), '') AS Lottable03
           , ISNULL(LOTATTRIBUTE.Lottable04, '01/01/1900') AS Lottable04
           , ISNULL(TRIM(L.PutawayZone), '') AS PutawayZone
           , UPPER(ISNULL(TRIM(Z.Descr), '')) AS ZoneDescr
           , ISNULL(TRIM(PACK.PackUOM1), '') AS PackUOM1
           , ISNULL(TRIM(PACK.PackUOM2), '') AS PackUOM2
           , ISNULL(TRIM(PACK.PackUOM3), '') AS PackUOM3
           , UPPER(ISNULL(TRIM(L.PickZone), '')) AS PickZone
           , ISNULL(TRIM(LoadPlan.LoadKey), '') AS Loadkey
           , @n_CtnOrder AS TTLORD
           , @n_TTLQTY AS PTTLQTY
           , @c_RetVal AS Logo
           , ISNULL(TRIM(SKU.Style), '') AS Style
           , ISNULL(TRIM(SKU.Color), '') AS Color
           , ISNULL(TRIM(SKU.Size), '') AS Size
           , ISNULL(TRIM(SKU.SKUGroup), '') AS SKUGroup
           , ISNULL(TRIM(SKU.Measurement), '') AS Measurement
           , ISNULL(TRIM(PICKDETAIL.Storerkey), '') + ISNULL(TRIM(STORER.Company), '') AS StorerCompany
           , ISNULL(TRIM(WD.WaveKey), '') AS Group1
           , ISNULL(TRIM(WD.WaveKey), '') + UPPER(ISNULL(TRIM(L.PickZone), '')) AS Group2
           , ISNULL(TRIM(WD.WaveKey), '') + UPPER(ISNULL(TRIM(L.PickZone), '')) + 
             ISNULL(TRIM(PICKDETAIL.Loc), '') + ISNULL(TRIM(PICKDETAIL.Sku), '') + 
             ISNULL(TRIM(LOTATTRIBUTE.Lottable02), '') + ISNULL(TRIM(LOTATTRIBUTE.Lottable03), '') + 
             CONVERT(NVARCHAR, ISNULL(LOTATTRIBUTE.Lottable04, '01/01/1900'), 121) AS Group3
           , Cartons = IIF(PACK.CaseCnt = 0, 0, CAST(ISNULL(PICKDETAIL.Qty, 0) / ISNULL(PACK.CaseCnt, 0.0) AS INT) )
           , InnerP = CAST(IIF(ISNULL(PACK.InnerPack, 0.0) = 0, 0, IIF(PACK.CaseCnt = 0, 
                                                                       CAST(ISNULL(PICKDETAIL.Qty, 0) / ISNULL(PACK.InnerPack, 0.0) AS INT),
                                                                       CAST((ISNULL(PICKDETAIL.Qty, 0) % CAST(PACK.CaseCnt AS INT)) / ISNULL(PACK.InnerPack, 0.0) AS INT)
                                                                      )
                              ) AS INT)
      FROM WAVEDETAIL WD WITH (NOLOCK)
      INNER JOIN PICKHEADER WITH (NOLOCK) ON (WD.Wavekey = PICKHEADER.Wavekey)
      INNER JOIN LoadPlanDetail WITH (NOLOCK) ON (WD.OrderKey = LoadPlanDetail.OrderKey)
      INNER JOIN LoadPlan WITH (NOLOCK) ON (LoadPlan.LoadKey = LoadPlanDetail.LoadKey)
      INNER JOIN PICKDETAIL WITH (NOLOCK) ON (PICKDETAIL.OrderKey = LoadPlanDetail.OrderKey)
      INNER JOIN STORER WITH (NOLOCK) ON (STORER.StorerKey = PICKDETAIL.Storerkey)
      INNER JOIN SKU WITH (NOLOCK) ON (SKU.StorerKey = PICKDETAIL.Storerkey) AND (SKU.Sku = PICKDETAIL.Sku)
      INNER JOIN PACK WITH (NOLOCK) ON (PACK.PackKey = SKU.PACKKey)
      INNER JOIN LOTATTRIBUTE WITH (NOLOCK) ON (LOTATTRIBUTE.Lot = PICKDETAIL.Lot)
      INNER JOIN LOC L WITH (NOLOCK) ON (L.Loc = PICKDETAIL.Loc)
      INNER JOIN PutawayZone Z WITH (NOLOCK) ON (Z.PutawayZone = L.PutawayZone)
      WHERE WD.WaveKey = @c_WaveKey AND PICKDETAIL.Qty > 0)
      SELECT CTE.PickHeaderKey
           , CTE.PrintedFlag
           , CTE.Wavekey
           , CTE.lpuserdefdate01
           , CTE.Route
           , CTE.TrfRoom
           , CTE.Storerkey
           , CTE.Company
           , CTE.Sku
           , CTE.Loc
           , CTE.Qty
           , CTE.SKUDescr
           , CTE.AltSku
           , CTE.ManufacturerSKU
           , CTE.StdCube
           , CTE.StdGrossWgt
           , CTE.CaseCnt
           , CTE.InnerPack
           , CTE.PalletID
           , CTE.Lottable02
           , CTE.Lottable03
           , CTE.Lottable04
           , CTE.PutawayZone
           , CTE.ZoneDescr
           , CTE.PackUOM1
           , CTE.PackUOM2
           , CTE.PackUOM3
           , CTE.PickZone
           , CTE.Loadkey
           , CTE.TTLORD
           , CTE.PTTLQTY
           , CTE.Logo
           , CTE.Style
           , CTE.Color
           , CTE.Size
           , CTE.SKUGroup
           , CTE.Measurement
           , CTE.StorerCompany
           , CTE.Group1
           , CTE.Group2
           , CTE.Group3
           , CTE.Cartons
           , CTE.InnerP
           , Pieces = CTE.Qty - 
                      (CAST(CTE.Cartons AS INT) * CAST(CTE.CaseCnt AS INT)) - 
                      (CAST(CTE.InnerP AS INT) * CAST(CTE.InnerPack AS INT))
      FROM CTE
      ORDER BY LoadKey
             , PickZone
             , Loc
             , Sku
             , Lottable02
             , Lottable04
             , Lottable03
   END

   QUIT_SP:
   IF CURSOR_STATUS('LOCAL', 'CUR_PSLIP') IN (0 , 1)
   BEGIN
      CLOSE CUR_PSLIP
      DEALLOCATE CUR_PSLIP   
   END

   IF OBJECT_ID('tempdb..#TEMP_Wave') IS NOT NULL
      DROP TABLE #TEMP_Wave

   IF @n_continue = 3
   BEGIN
      SELECT @b_success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_StartTranCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTranCnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'isp_RPT_WV_WAVPLISTC_009'
      RAISERROR(@c_errmsg, 16, 1) WITH SETERROR
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTranCnt
      BEGIN
         COMMIT TRAN
      END
   END
END
GO
GRANT EXECUTE ON [dbo].[isp_RPT_WV_WAVPLISTC_009] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_RPT_WV_WAVPLISTC_009] TO [LogiReportRoleWM]
GO