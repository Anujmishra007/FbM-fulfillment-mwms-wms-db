IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[isp_r_hk_picking_control_list_07b]') AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
   DROP PROCEDURE [dbo].[isp_r_hk_picking_control_list_07b]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/*************************************************************************/
/* Stored Procedure: isp_r_hk_picking_control_list_07b                   */
/* Creation Date: 04-Sep-2019                                            */
/* Copyright: LFL                                                        */
/* Written by: Michael Lam (HK LIT)                                      */
/*                                                                       */
/* Purpose: PVH Picking Slip                                             */
/*                                                                       */
/* Called By: Report Module. Datawidnow r_hk_picking_control_list_07b    */
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
CREATE PROCEDURE [dbo].[isp_r_hk_picking_control_list_07b] (
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


   SET @c_DataWindow   = 'r_hk_picking_control_list_07b'

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


   SELECT Storerkey         = Q.Storerkey
        , CustomerGroupCode = MAX(Q.CustomerGroupCode)
        , Wavekey           = Q.Wavekey
        , ReqReplen         = Q.ReqReplen
        , Suggest_PAZone    = Q.Suggest_PAZone
        , LineSeq           = FLOOR((Q.SeqNo2+1) / 2)

        , CaseID_1          = MAX(CASE WHEN (Q.SeqNo2-1)%2=0 THEN Q.CaseID END)
        , PAZone_101        = MAX(CASE WHEN (Q.SeqNo2-1)%2=0 THEN Q.PAZone_01 END)
        , PAZone_102        = MAX(CASE WHEN (Q.SeqNo2-1)%2=0 THEN Q.PAZone_02 END)
        , PAZone_103        = MAX(CASE WHEN (Q.SeqNo2-1)%2=0 THEN Q.PAZone_03 END)
        , PAZone_104        = MAX(CASE WHEN (Q.SeqNo2-1)%2=0 THEN Q.PAZone_04 END)
        , PAZone_105        = MAX(CASE WHEN (Q.SeqNo2-1)%2=0 THEN Q.PAZone_05 END)
        , PAZone_106        = MAX(CASE WHEN (Q.SeqNo2-1)%2=0 THEN Q.PAZone_06 END)
        , PAZone_107        = MAX(CASE WHEN (Q.SeqNo2-1)%2=0 THEN Q.PAZone_07 END)
        , PAZone_108        = MAX(CASE WHEN (Q.SeqNo2-1)%2=0 THEN Q.PAZone_08 END)
        , PAZone_109        = MAX(CASE WHEN (Q.SeqNo2-1)%2=0 THEN Q.PAZone_09 END)
        , PAZone_110        = MAX(CASE WHEN (Q.SeqNo2-1)%2=0 THEN Q.PAZone_10 END)
        , Qty_101           = MAX(CASE WHEN (Q.SeqNo2-1)%2=0 THEN Q.Qty_01 END)
        , Qty_102           = MAX(CASE WHEN (Q.SeqNo2-1)%2=0 THEN Q.Qty_02 END)
        , Qty_103           = MAX(CASE WHEN (Q.SeqNo2-1)%2=0 THEN Q.Qty_03 END)
        , Qty_104           = MAX(CASE WHEN (Q.SeqNo2-1)%2=0 THEN Q.Qty_04 END)
        , Qty_105           = MAX(CASE WHEN (Q.SeqNo2-1)%2=0 THEN Q.Qty_05 END)
        , Qty_106           = MAX(CASE WHEN (Q.SeqNo2-1)%2=0 THEN Q.Qty_06 END)
        , Qty_107           = MAX(CASE WHEN (Q.SeqNo2-1)%2=0 THEN Q.Qty_07 END)
        , Qty_108           = MAX(CASE WHEN (Q.SeqNo2-1)%2=0 THEN Q.Qty_08 END)
        , Qty_109           = MAX(CASE WHEN (Q.SeqNo2-1)%2=0 THEN Q.Qty_09 END)
        , Qty_110           = MAX(CASE WHEN (Q.SeqNo2-1)%2=0 THEN Q.Qty_10 END)

        , CaseID_2          = MAX(CASE WHEN (Q.SeqNo2-1)%2=1 THEN Q.CaseID END)
        , PAZone_201        = MAX(CASE WHEN (Q.SeqNo2-1)%2=1 THEN Q.PAZone_01 END)
        , PAZone_202        = MAX(CASE WHEN (Q.SeqNo2-1)%2=1 THEN Q.PAZone_02 END)
        , PAZone_203        = MAX(CASE WHEN (Q.SeqNo2-1)%2=1 THEN Q.PAZone_03 END)
        , PAZone_204        = MAX(CASE WHEN (Q.SeqNo2-1)%2=1 THEN Q.PAZone_04 END)
        , PAZone_205        = MAX(CASE WHEN (Q.SeqNo2-1)%2=1 THEN Q.PAZone_05 END)
        , PAZone_206        = MAX(CASE WHEN (Q.SeqNo2-1)%2=1 THEN Q.PAZone_06 END)
        , PAZone_207        = MAX(CASE WHEN (Q.SeqNo2-1)%2=1 THEN Q.PAZone_07 END)
        , PAZone_208        = MAX(CASE WHEN (Q.SeqNo2-1)%2=1 THEN Q.PAZone_08 END)
        , PAZone_209        = MAX(CASE WHEN (Q.SeqNo2-1)%2=1 THEN Q.PAZone_09 END)
        , PAZone_210        = MAX(CASE WHEN (Q.SeqNo2-1)%2=1 THEN Q.PAZone_10 END)
        , Qty_201           = MAX(CASE WHEN (Q.SeqNo2-1)%2=1 THEN Q.Qty_01 END)
        , Qty_202           = MAX(CASE WHEN (Q.SeqNo2-1)%2=1 THEN Q.Qty_02 END)
        , Qty_203           = MAX(CASE WHEN (Q.SeqNo2-1)%2=1 THEN Q.Qty_03 END)
        , Qty_204           = MAX(CASE WHEN (Q.SeqNo2-1)%2=1 THEN Q.Qty_04 END)
        , Qty_205           = MAX(CASE WHEN (Q.SeqNo2-1)%2=1 THEN Q.Qty_05 END)
        , Qty_206           = MAX(CASE WHEN (Q.SeqNo2-1)%2=1 THEN Q.Qty_06 END)
        , Qty_207           = MAX(CASE WHEN (Q.SeqNo2-1)%2=1 THEN Q.Qty_07 END)
        , Qty_208           = MAX(CASE WHEN (Q.SeqNo2-1)%2=1 THEN Q.Qty_08 END)
        , Qty_209           = MAX(CASE WHEN (Q.SeqNo2-1)%2=1 THEN Q.Qty_09 END)
        , Qty_210           = MAX(CASE WHEN (Q.SeqNo2-1)%2=1 THEN Q.Qty_10 END)

        , Ttl_Carton        = @n_Ttl_Carton
        , Datawindow        = @c_DataWindow

   FROM (
      SELECT Storerkey         = Z.Storerkey
           , CustomerGroupCode = MAX(Z.CustomerGroupCode)
           , Wavekey           = Z.Wavekey
           , ReqReplen         = Z.ReqReplen
           , Suggest_PAZone    = Z.Suggest_PAZone
           , CaseID            = Z.CaseID
           , PAZone_01         = MAX(CASE WHEN (Z.SeqNo-1)%10=0 THEN Z.PutawayZone END)
           , PAZone_02         = MAX(CASE WHEN (Z.SeqNo-1)%10=1 THEN Z.PutawayZone END)
           , PAZone_03         = MAX(CASE WHEN (Z.SeqNo-1)%10=2 THEN Z.PutawayZone END)
           , PAZone_04         = MAX(CASE WHEN (Z.SeqNo-1)%10=3 THEN Z.PutawayZone END)
           , PAZone_05         = MAX(CASE WHEN (Z.SeqNo-1)%10=4 THEN Z.PutawayZone END)
           , PAZone_06         = MAX(CASE WHEN (Z.SeqNo-1)%10=5 THEN Z.PutawayZone END)
           , PAZone_07         = MAX(CASE WHEN (Z.SeqNo-1)%10=6 THEN Z.PutawayZone END)
           , PAZone_08         = MAX(CASE WHEN (Z.SeqNo-1)%10=7 THEN Z.PutawayZone END)
           , PAZone_09         = MAX(CASE WHEN (Z.SeqNo-1)%10=8 THEN Z.PutawayZone END)
           , PAZone_10         = MAX(CASE WHEN (Z.SeqNo-1)%10=9 THEN Z.PutawayZone END)
           , Qty_01            = SUM(CASE WHEN (Z.SeqNo-1)%10=0 THEN Z.Qty END)
           , Qty_02            = SUM(CASE WHEN (Z.SeqNo-1)%10=1 THEN Z.Qty END)
           , Qty_03            = SUM(CASE WHEN (Z.SeqNo-1)%10=2 THEN Z.Qty END)
           , Qty_04            = SUM(CASE WHEN (Z.SeqNo-1)%10=3 THEN Z.Qty END)
           , Qty_05            = SUM(CASE WHEN (Z.SeqNo-1)%10=4 THEN Z.Qty END)
           , Qty_06            = SUM(CASE WHEN (Z.SeqNo-1)%10=5 THEN Z.Qty END)
           , Qty_07            = SUM(CASE WHEN (Z.SeqNo-1)%10=6 THEN Z.Qty END)
           , Qty_08            = SUM(CASE WHEN (Z.SeqNo-1)%10=7 THEN Z.Qty END)
           , Qty_09            = SUM(CASE WHEN (Z.SeqNo-1)%10=8 THEN Z.Qty END)
           , Qty_10            = SUM(CASE WHEN (Z.SeqNo-1)%10=9 THEN Z.Qty END)
           , SeqNo2            = ROW_NUMBER() OVER(PARTITION BY Z.Storerkey, Z.Wavekey, Z.ReqReplen, Z.Suggest_PAZone ORDER BY Z.CaseID)
      FROM (
         SELECT Storerkey         = Y.Storerkey
              , CustomerGroupCode = Y.CustomerGroupCode
              , Wavekey           = Y.Wavekey
              , Suggest_PAZone    = Y.Suggest_PAZone
              , CaseID            = Y.CaseID
              , PutawayZone       = Y.PutawayZone
              , Qty               = Y.Qty
              , ReqReplen         = MAX(Y.ReqReplen)  OVER(PARTITION BY Y.Storerkey, Y.Wavekey, Y.CaseID)
              , SeqNo = ROW_NUMBER() OVER(PARTITION BY Y.Storerkey, Y.Wavekey, Y.CaseID ORDER BY Y.PutawayZone)
         FROM (
            SELECT Storerkey         = X.Storerkey
                 , CustomerGroupCode = MAX(X.CustomerGroupCode)
                 , Wavekey           = X.Wavekey
                 , Suggest_PAZone    = ISNULL((SELECT TOP 1 a.PutawayZone FROM #TEMP_PICKDETAIL a
                                                WHERE a.Storerkey=X.Storerkey AND a.Wavekey=X.Wavekey AND a.CaseID=X.CaseID
                                                  AND a.CaseID<>'' GROUP BY a.CaseID, a.PutawayZone
                                                ORDER BY SUM(a.Qty) DESC, a.PutawayZone), '')
                 , CaseID            = X.CaseID
                 , PutawayZone       = X.PutawayZone
                 , Qty               = SUM(X.Qty)
                 , ReqReplen         = MAX(X.ReqReplen)
            FROM #TEMP_PICKDETAIL X
            GROUP BY X.Storerkey
                   , X.Wavekey
                   , X.CaseID
                   , X.PutawayZone
         ) Y
      ) Z
      WHERE Z.SeqNo <= 10
      GROUP BY Z.Storerkey
             , Z.Wavekey
             , Z.ReqReplen
             , Z.Suggest_PAZone
             , Z.CaseID
   ) Q
   GROUP BY Q.Storerkey
          , Q.Wavekey
          , Q.ReqReplen
          , Q.Suggest_PAZone
          , FLOOR((Q.SeqNo2+1) / 2)


   ORDER BY Storerkey, Wavekey, ReqReplen, Suggest_PAZone, LineSeq
END
GO
GRANT EXECUTE ON isp_r_hk_picking_control_list_07b TO NSQL
GO
