if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_r_hk_replenishment_report_07]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[isp_r_hk_replenishment_report_07]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/*************************************************************************/
/* Stored Procedure: isp_r_hk_replenishment_report_07                    */
/* Creation Date: 26-Sep-2018                                            */
/* Copyright: LFL                                                        */
/* Written by: Michael Lam (HK LIT)                                      */
/*                                                                       */
/* Purpose: Wave Pickslip                                                */
/*                                                                       */
/* Called By: RCM - Generate Pickslip in Waveplan                        */
/*            Datawidnow r_hk_replenishment_report_07 (WMS-6361)         */
/*                                                                       */
/* PVCS Version: 1.0                                                     */
/*                                                                       */
/* Version: 7.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date         Author   Ver  Purposes                                   */
/* 2019-04-04   ML       1.1  Jira WMS8570 - Add Brand code              */
/*************************************************************************/

CREATE PROCEDURE [dbo].[isp_r_hk_replenishment_report_07] (
       @as_wavekey  NVARCHAR(10)
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cDataWidnow         NVARCHAR(40)
         , @n_StartTCnt         INT
         , @c_Storerkey         NVARCHAR(15)
         , @b_MultiOrderGroup   INT
         , @b_InvalidOrderGroup INT
         , @b_BlankLoadkey      INT
         , @c_OrderGroup        NVARCHAR(60)
         , @b_Success           INT
         , @n_Err               INT
         , @c_ErrMsg            NVARCHAR(250)

   IF ISNULL(@as_wavekey,'')=''
   BEGIN
      RAISERROR ('Wavekey is Blank', 16, 1) WITH SETERROR
      GOTO QUIT
   END

   SELECT @cDataWidnow  = 'r_hk_replenishment_report_07'
        , @n_StartTCnt  = @@TRANCOUNT
        , @b_MultiOrderGroup   = 0
        , @b_InvalidOrderGroup = 0
        , @b_BlankLoadkey      = 0
        , @c_OrderGroup        = ''
        , @c_ErrMsg            = ''
        , @c_Storerkey         = (SELECT TOP 1 Storerkey FROM ORDERS (NOLOCK) WHERE Userdefine09<>'' AND Userdefine09=@as_wavekey)



   IF OBJECT_ID('tempdb..#TEMP_PICKDETAIL') IS NOT NULL
      DROP TABLE #TEMP_PICKDETAIL

   CREATE TABLE #TEMP_PICKDETAIL (
        Storerkey        NVARCHAR(15)
      , Wavekey          NVARCHAR(10)
      , PutawayZone      NVARCHAR(10)
      , PA_Descr         NVARCHAR(60)
      , LogicalLoc       NVARCHAR(18)
      , Loc              NVARCHAR(10)
      , ID               NVARCHAR(18)
      , Sku              NVARCHAR(20)
      , Sku_Descr        NVARCHAR(60)
      , Qty              INT
      , PikDetUOM        NVARCHAR(10)
      , ToZone           NVARCHAR(60)
      , Remarks          NVARCHAR(200)
      , ErrMsg           NVARCHAR(250)
      , Brand            NVARCHAR(60)
   )


   SELECT TOP 1
          @b_MultiOrderGroup   = CASE WHEN COUNT(DISTINCT X.OrderGroup) > 1 THEN 1 ELSE 0 END
        , @b_InvalidOrderGroup = MAX(IIF(X.OrderGroup IN ('C','D'), 0, 1))
        , @b_BlankLoadkey      = MAX(X.BlankLoadKey)
        , @c_OrderGroup        = MAX(X.OrderGroup)
   FROM (
      SELECT DISTINCt
             Wavekey      = ISNULL(a.Userdefine09,'')
           , OrderGroup   = CASE WHEN a.OrderGroup='W' AND ISNULL(a.DeliveryNote,'') NOT IN ( '','NA') THEN a.DeliveryNote ELSE b.UDF02 END    --D=Discrete C=Consolidate
           , BlankLoadKey = IIF(ISNULL(a.Loadkey,'')='', 1, 0)
        FROM ORDERS   a(NOLOCK)
        JOIN CODELKUP b(NOLOCK) ON a.OrderGroup = b.Code AND a.Storerkey = b.Storerkey AND b.Listname = 'ORDERGROUP'
   ) X
   WHERE X.Wavekey = @as_wavekey
   GROUP BY X.Wavekey


   SET @c_ErrMsg = ''
   IF ISNULL(@b_MultiOrderGroup, 0) <> 0
      SET @c_ErrMsg += IIF(@c_ErrMsg<>'',', ', '') + 'Multiple OrderGroup Found'

   IF ISNULL(@b_InvalidOrderGroup, 0) <> 0
      SET @c_ErrMsg += IIF(@c_ErrMsg<>'',', ', '') + 'Invalid OrderGroup Found'

   IF ISNULL(@b_BlankLoadkey, 0) <> 0
      SET @c_ErrMsg += IIF(@c_ErrMsg<>'',', ', '') + 'Blank Loadkey Found'

   IF ISNULL(@c_ErrMsg,'')<>''
   BEGIN
      RAISERROR (@c_ErrMsg, 16, 1) WITH SETERROR
      GOTO QUIT
   END


   IF ISNULL(@c_OrderGroup,'') = 'D' --create discrete pickslip for the wave
   BEGIN
      EXEC isp_CreatePickSlip
           @c_Wavekey            = @as_wavekey
         , @c_LinkPickSlipToPick = 'Y'  --Y=Update pickslipno to pickdetail.pickslipno
         , @b_Success            = @b_Success OUTPUT
         , @n_Err                = @n_Err     OUTPUT
         , @c_ErrMsg             = @c_ErrMsg  OUTPUT

      IF @b_Success = 0
      BEGIN
         RAISERROR (@c_ErrMsg, 16, 1) WITH SETERROR
         GOTO QUIT
      END
   END
   ELSE
   BEGIN --create load conso pickslip for the wave
      EXEC isp_CreatePickSlip
           @c_Wavekey            = @as_wavekey
         , @c_ConsolidateByLoad  = 'Y'  --Y=Create load consolidate pickslip
         , @c_LinkPickSlipToPick = 'Y'  --Y=Update pickslipno to pickdetail.pickslipno
         , @b_Success            = @b_Success OUTPUT
         , @n_Err                = @n_Err     OUTPUT
         , @c_ErrMsg             = @c_ErrMsg  OUTPUT

      IF @b_Success = 0
      BEGIN
         RAISERROR (@c_ErrMsg, 16, 1) WITH SETERROR
         GOTO QUIT
      END
   END



   INSERT INTO #TEMP_PICKDETAIL (
          Storerkey, Wavekey, PutawayZone, PA_Descr, LogicalLoc, Loc, ID,
          Sku, Sku_Descr, Qty, PikDetUOM, ToZone, Remarks, ErrMsg, Brand)
   SELECT X.Storerkey, X.Wavekey, X.PutawayZone, X.PA_Descr, X.LogicalLoc, X.Loc,
          X.ID, X.Sku, X.Sku_Descr, SUM(X.Qty), X.PikDetUOM, X.ToZone, X.Remarks, '', MAX(X.Brand)
   FROM (
      SELECT Storerkey   = RTRIM( OH.Storerkey )
           , Wavekey     = RTRIM( OH.Userdefine09 )
           , PutawayZone = RTRIM( LOC.PutawayZone )
           , PA_Descr    = RTRIM( PA.Descr )
           , LogicalLoc  = RTRIM( LOC.LogicalLocation )
           , Loc         = RTRIM( PD.Loc )
           , ID          = RTRIM( PD.ID )
           , Sku         = RTRIM( PD.Sku )
           , Sku_Descr   = RTRIM( SKU.Descr )
           , Qty         = PD.Qty
           , PikDetUOM   = RTRIM( PD.UOM )
           , ToZone      = CASE WHEN PD.UOM='2' THEN 'FCP'
                                WHEN PD.UOM IN ('6', '7') THEN
                                   CASE WHEN
                                     (SELECT SUM(b.Qty) FROM ORDERS a(NOLOCK), PICKDETAIL b(NOLOCK)
                                         WHERE a.Orderkey=b.Orderkey AND b.Status<>'9'
                                           AND a.Storerkey=OH.Storerkey AND a.Userdefine09=OH.Userdefine09
                                           AND b.ID=PD.ID AND b.Sku=PD.Sku AND b.Loc=PD.Loc AND b.Lot=PD.Lot) =
                                     (SELECT SUM(a.Qty) FROM LOTxLOCxID a(NOLOCK)
                                         WHERE a.Storerkey=OH.Storerkey
                                           AND a.ID=PD.ID AND a.Sku=PD.Sku AND a.Loc=PD.Loc AND a.Lot=PD.Lot)
                                        THEN 'DP'
                                     ELSE 'Residual'
                                END
                           END
           , Remarks     = CAST(STUFF((SELECT DISTINCT ', ', RTRIM(a.Userdefine09) FROM ORDERS a(NOLOCK), PICKDETAIL b(NOLOCK)
                           WHERE a.Orderkey=b.Orderkey AND a.Userdefine09<>'' AND b.ID<>'' AND a.Userdefine09<>OH.Userdefine09 AND b.ID=PD.ID
                           FOR XML PATH('')),1,2,'') AS NVARCHAR(200))
           , Brand       = RTRIM( LEFT(DIV.UDF01, 3) )
      FROM dbo.ORDERS      OH(NOLOCK)
      JOIN dbo.PICKDETAIL  PD(NOLOCK) ON OH.Orderkey=PD.Orderkey
      JOIN dbo.SKU        SKU(NOLOCK) ON PD.Storerkey=SKU.Storerkey AND PD.Sku=SKU.Sku
      JOIN dbo.LOC        LOC(NOLOCK) ON PD.Loc=LOC.Loc
      JOIN dbo.PUTAWAYZONE PA(NOLOCK) ON LOC.PutawayZone=PA.PutawayZone
      LEFT JOIN dbo.CODELKUP DIV(NOLOCK) ON DIV.Listname='PVHDIV' AND DIV.Storerkey=SKU.Storerkey AND DIV.Code = SKU.BUSR5
      WHERE OH.Userdefine09<>''
        AND OH.Userdefine09=@as_wavekey
        AND LOC.LocationType = 'OTHER'
   ) X
   GROUP BY X.Storerkey, X.Wavekey, X.PutawayZone, X.LogicalLoc,
          X.PA_Descr, X.Loc, X.ID, X.Sku, X.Sku_Descr, X.PikDetUOM,
          X.ToZone, X.Remarks


   IF NOT EXISTS(SELECT TOP 1 1 FROM #TEMP_PICKDETAIL)
   BEGIN
      INSERT INTO #TEMP_PICKDETAIL (
           Storerkey, Wavekey, PutawayZone, PA_Descr, LogicalLoc, Loc, ID,
           Sku, Sku_Descr, Qty, PikDetUOM, ToZone, Remarks, ErrMsg, Brand)
      VALUES(@c_Storerkey, @as_wavekey, '', '', '', '', '', '', '', 0, '', '', '', 'No Replenishment Record', '')
   END


   SELECT Storerkey, Wavekey, PutawayZone, PA_Descr, LogicalLoc
        , Loc, ID, Sku, Sku_Descr, Qty, PikDetUOM
        , ToZone, Remarks, ErrMsg
        , DWName = @cDataWidnow
        , Brand
     FROM #TEMP_PICKDETAIL
    ORDER BY Wavekey, PutawayZone, LogicalLoc, Loc, ID, Sku

QUIT:
   WHILE @@TRANCOUNT > @n_StartTCnt
   BEGIN
      COMMIT TRAN
   END
   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END
END
GO

GRANT EXECUTE ON isp_r_hk_replenishment_report_07 TO NSQL
GO