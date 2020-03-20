IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[isp_r_hk_picking_control_list_07a]') AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
   DROP PROCEDURE [dbo].[isp_r_hk_picking_control_list_07a]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/*************************************************************************/
/* Stored Procedure: isp_r_hk_picking_control_list_07a                   */
/* Creation Date: 04-Sep-2019                                            */
/* Copyright: LFL                                                        */
/* Written by: Michael Lam (HK LIT)                                      */
/*                                                                       */
/* Purpose: PVH Picking Control List                                     */
/*                                                                       */
/* Called By: Report Module. Datawidnow r_hk_picking_control_list_07a    */
/*                                                                       */
/* PVCS Version: 1.0                                                     */
/*                                                                       */
/* Version: 7.0                                                          */
/*                                                                       */
/* Data Modifications:                                                   */
/*                                                                       */
/* Updates:                                                              */
/* Date         Author   Ver  Purposes                                   */
/* 19/09/2019   ML       1.1  1. Include PD.Status = 3                   */
/*                            2. Exclude PD.UOM = 2 (FCP)                */
/*************************************************************************/
CREATE PROCEDURE [dbo].[isp_r_hk_picking_control_list_07a] (
       @as_storerkey NVARCHAR(15)
     , @as_wavekey   NVARCHAR(10)
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_DataWindow       NVARCHAR(40)
         , @n_Ttl_Carton       INT


   SET @c_DataWindow   = 'r_hk_picking_control_list_07a'

   IF OBJECT_ID('tempdb..#TEMP_PICKDETAIL') IS NOT NULL
      DROP TABLE #TEMP_PICKDETAIL


   SELECT Storerkey         = RTRIM(ISNULL(OH.Storerkey,''))
        , CustomerGroupCode = RTRIM(ISNULL(ST.CustomerGroupCode,''))
        , Wavekey           = RTRIM(ISNULL(OH.Userdefine09,''))
        , Wave_AddDate      = WAVE.AddDate
        , CaseID            = RTRIM(ISNULL(PD.CaseID,''))
        , PutawayZone       = RTRIM(ISNULL(LOC.PutawayZone,''))
        , PickZone          = RTRIM(ISNULL(LOC.PickZone,''))
        , Loc               = RTRIM(ISNULL(PD.Loc,''))
        , Qty               = PD.Qty
        , ReqReplen         = IIF(LOC.LocationType='OTHER','Y','N')
     INTO #TEMP_PICKDETAIL
     FROM dbo.ORDERS      OH(NOLOCK)
     JOIN dbo.STORER      ST(NOLOCK) ON OH.Storerkey = ST.Storerkey
     JOIN dbo.WAVE      WAVE(NOLOCK) ON OH.Userdefine09 = WAVE.Wavekey
     JOIN dbo.PICKDETAIL  PD(NOLOCK) ON OH.Orderkey = PD.Orderkey
     JOIN dbo.LOC        LOC(NOLOCK) ON PD.Loc = LOC.Loc
    WHERE OH.Storerkey    = @as_storerkey
      AND OH.Userdefine09 = @as_wavekey
      AND OH.Userdefine09<>''
      AND PD.Status <= '3'
      AND ISNULL(PD.UOM,'') <> '2'
      AND PD.Qty > 0


   SET @n_Ttl_Carton = 0
   SELECT @n_Ttl_Carton = COUNT(DISTINCT CaseID) FROM #TEMP_PICKDETAIL WHERE CaseID <>''


   SELECT Storerkey         = Z.Storerkey
        , CustomerGroupCode = MAX(Z.CustomerGroupCode)
        , Wavekey           = Z.Wavekey
        , Wave_AddDate      = MAX(Z.Wave_AddDate)
        , ReqReplen         = Z.ReqReplen
        , Suggest_PAZone    = Z.Suggest_PAZone
        , PA_PickZone       = 0
        , PA_PickLoc        = 0
        , PA_NoOfCtn        = 0
        , Qty               = 0
        , LineSeq           = FLOOR((Z.SeqNo+5) / 6)
        , CaseID_01         = MAX(CASE WHEN (Z.SeqNo-1)%6=0 THEN Z.CaseID END)
        , CaseID_02         = MAX(CASE WHEN (Z.SeqNo-1)%6=1 THEN Z.CaseID END)
        , CaseID_03         = MAX(CASE WHEN (Z.SeqNo-1)%6=2 THEN Z.CaseID END)
        , CaseID_04         = MAX(CASE WHEN (Z.SeqNo-1)%6=3 THEN Z.CaseID END)
        , CaseID_05         = MAX(CASE WHEN (Z.SeqNo-1)%6=4 THEN Z.CaseID END)
        , CaseID_06         = MAX(CASE WHEN (Z.SeqNo-1)%6=5 THEN Z.CaseID END)
        , Ttl_Carton        = @n_Ttl_Carton
        , Datawindow        = @c_DataWindow
        , Section           = 2
        , PageNo            = ROW_NUMBER() OVER(PARTITION BY Z.Storerkey, Z.Wavekey ORDER BY Z.ReqReplen, Z.Suggest_PAZone, FLOOR((Z.SeqNo+5) / 6))
   FROM (
      SELECT Y.*
           , SeqNo = ROW_NUMBER() OVER(PARTITION BY Y.Storerkey, Y.Wavekey, Y.ReqReplen, Y.Suggest_PAZone  ORDER BY Y.CaseID)
      FROM (
         SELECT Storerkey         = X.Storerkey
              , CustomerGroupCode = MAX(X.CustomerGroupCode)
              , Wavekey           = X.Wavekey
              , Wave_AddDate      = MAX(X.Wave_AddDate)
              , Suggest_PAZone    = ISNULL((SELECT TOP 1 a.PutawayZone FROM #TEMP_PICKDETAIL a
                                             WHERE a.Storerkey=X.Storerkey AND a.Wavekey=X.Wavekey AND a.CaseID=X.CaseID
                                               AND a.CaseID<>'' GROUP BY a.CaseID, a.PutawayZone
                                             ORDER BY SUM(a.Qty) DESC, a.PutawayZone), '')
              , CaseID            = X.CaseID
              , ReqReplen         = MAX(X.ReqReplen)
         FROM #TEMP_PICKDETAIL X
         GROUP BY X.Storerkey
                , X.Wavekey
                , X.CaseID
      ) Y
   ) Z
   GROUP BY Z.Storerkey
          , Z.Wavekey
          , Z.ReqReplen
          , Z.Suggest_PAZone
          , FLOOR((Z.SeqNo+5) / 6)

   UNION ALL

   SELECT Storerkey         = X.Storerkey
        , CustomerGroupCode = MAX(X.CustomerGroupCode)
        , Wavekey           = X.Wavekey
        , Wave_AddDate      = MAX(X.Wave_AddDate)
        , ReqReplen         = ''
        , Suggest_PAZone    = X.PutawayZone
        , PA_PickZone       = COUNT(DISTINCT X.PickZone)
        , PA_PickLoc        = COUNT(DISTINCT X.Loc)
        , PA_NoOfCtn        = COUNT(DISTINCT X.CaseID)
        , Qty               = SUM(X.Qty)
        , LineSeq           = 0
        , CaseID_01         = ''
        , CaseID_02         = ''
        , CaseID_03         = ''
        , CaseID_04         = ''
        , CaseID_05         = ''
        , CaseID_06         = ''
        , Ttl_Carton        = @n_Ttl_Carton
        , Datawindow        = @c_DataWindow
        , Section           = 1
        , PageNo            = 0
   FROM #TEMP_PICKDETAIL X
   GROUP BY X.Storerkey
          , X.Wavekey
          , X.PutawayZone

   ORDER BY Storerkey, Wavekey, Section, ReqReplen, Suggest_PAZone, LineSeq
END
GO
GRANT EXECUTE ON isp_r_hk_picking_control_list_07a TO NSQL
GO