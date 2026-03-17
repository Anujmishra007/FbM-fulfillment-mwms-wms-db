SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: mspALUPDORDLN02                                    */
/* Creation Date: 12-Mar-2026                                           */
/* Copyright: MAERSK                                                    */
/* Written by: Jih Haur                                                 */
/*                                                                      */
/* Purpose: FCR-11313 DAMIND - Reallocation SP                          */
/*                                                                      */
/* Called By: isp_AllocateUpd_OPORDERLINES_Wrapper                      */
/*                                                                      */
/* GitHub Version: 1.0                                                  */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 12-Mar-2026 JihHaur  1.0   Initial Version                           */
/************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[mspALUPDORDLN02]
   @c_Storerkey  NVARCHAR(15)  = ''
 , @c_Facility   NVARCHAR(5)   = ''
 , @c_Orderkey   NVARCHAR(10)  = ''
 , @c_Loadkey    NVARCHAR(10)  = ''
 , @c_Wavekey    NVARCHAR(10)  = ''
 , @c_SourceType NVARCHAR(30)  = '' --calling sp name
 , @b_Success    INT           = 1 OUTPUT
 , @n_Err        INT           = 0 OUTPUT
 , @c_ErrMsg     NVARCHAR(250) = '' OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue        INT = 1
         , @n_StartTcnt       INT = @@TRANCOUNT

   SELECT @b_Success = 1
        , @n_Err = 0
        , @c_ErrMsg = ''

   IF OBJECT_ID('tempdb..#OPORDERLINES', 'u') IS NULL
   BEGIN
      GOTO QUIT_SP
   END

   IF @c_SourceType <> 'ispWaveProcessing'
   BEGIN
      GOTO QUIT_SP
   END

   IF @n_Continue IN ( 1, 2 )
   BEGIN
      CREATE TABLE #TMP_PD (   Storerkey  NVARCHAR(15)
                             , SKU        NVARCHAR(20)
                             --, DropID     NVARCHAR(20) NULL
                             , Loc        NVARCHAR(10)
                             , Orderkey   NVARCHAR(10)
                             , OrderLnNo  NVARCHAR(5)
                             , Qty        INT 
                           )
      CREATE NONCLUSTERED INDEX IDX_TMP_PD_JoinCols ON #TMP_PD (Storerkey, SKU, Orderkey, OrderLnNo)

      ;WITH WV AS
      (
         SELECT Orderkey
         FROM WAVEDETAIL (NOLOCK)
         WHERE Wavekey = @c_Wavekey
      )
      , RankedPD AS
      (
         SELECT PD.Storerkey, PD.SKU, PD.Loc, QtyMoved = SUM(PD.QtyMoved)
              , PD.Orderkey, PD.OrderLineNumber
         FROM PICKDETAIL PD (NOLOCK)
         JOIN WV ON WV.Orderkey = PD.OrderKey
         JOIN #OPORDERLINES ORD ON ORD.OrderKey = WV.OrderKey
         WHERE PD.[Status] = '4'
           AND PD.Storerkey = ORD.Storerkey
           AND PD.SKU = ORD.SKU
           AND PD.QtyMoved > 0   --Not to impact normal allocation
           AND PD.SourceType = 'msp_ProcessShortPickReAlloc06'
         GROUP BY PD.Storerkey, PD.SKU, PD.Loc, PD.Orderkey, PD.OrderLineNumber
      )

      INSERT INTO #TMP_PD (Storerkey, SKU, Loc, Qty, Orderkey, OrderLnNo)
      SELECT Storerkey, SKU, Loc, QtyMoved, Orderkey, OrderLineNumber
      FROM RankedPD
   END

   IF @n_Continue IN ( 1, 2 )
   BEGIN
      IF EXISTS ( SELECT 1
                  FROM #TMP_PD )
      BEGIN
         --Remove OrderLineNumber from pool if the SKU is not shorted (Pickdetail.Status = 4)
         --RDT will update shorted Pickdetail.Qty to QtyMoved
         DELETE FROM #OPORDERLINES
         WHERE NOT EXISTS ( SELECT 1
                            FROM #TMP_PD TMP
                            WHERE TMP.Storerkey = #OPORDERLINES.Storerkey
                              AND TMP.SKU = #OPORDERLINES.SKU
                              AND TMP.Orderkey = #OPORDERLINES.Orderkey
                              AND TMP.OrderLnNo = #OPORDERLINES.OrderLineNumber )

         --Update #OPORDERLINES.Qty = Latest Pickdetail.QtyMoved
         UPDATE O
         SET O.Qty = IIF(O.Qty <= TMP.Qty, O.Qty, TMP.Qty)
         FROM #OPORDERLINES O
         JOIN #TMP_PD TMP ON TMP.Storerkey = O.Storerkey
                         AND TMP.SKU = O.SKU
                         AND TMP.Orderkey = O.Orderkey
                         AND TMP.OrderLnNo = O.OrderLineNumber
      END
   END

   QUIT_SP:
   IF OBJECT_ID('tempdb..#TMP_PD') IS NOT NULL
      DROP TABLE #TMP_PD

   IF @n_Continue = 3 -- Error Occured - Process AND Return
   BEGIN
      SET @b_Success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTcnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTcnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE dbo.nsp_logerror @n_Err, @c_ErrMsg, 'mspALUPDORDLN02'
      RAISERROR(@c_ErrMsg, 16, 1) WITH SETERROR -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTcnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END -- End Procedure
GO
GRANT EXECUTE ON [mspALUPDORDLN02] TO [NSQL]
GO