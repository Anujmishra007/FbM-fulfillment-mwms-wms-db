SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: mspALUPDORDLN01                                    */
/* Creation Date: 01-Oct-2025                                           */
/* Copyright: MAERSK                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: FCR-8049 LVSUSA - Reallocation SP for Skip and Replace      */
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
/* 01-Oct-2025 WLChooi  1.0   Initial Version                           */
/************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[mspALUPDORDLN01]
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
      --Remove OrderLineNumber from pool if the SKU is not shorted (Pickdetail.Status = 4)
      --RDT will update shorted Pickdetail.Qty to QtyMoved
      WITH ORD AS (
          SELECT WD.OrderKey
          FROM WAVEDETAIL WD (NOLOCK)
          WHERE WD.WaveKey = @c_Wavekey
      )
      DELETE OL
      FROM #OPORDERLINES OL
      WHERE NOT EXISTS (
          SELECT 1
          FROM PICKDETAIL PD (NOLOCK)
          JOIN ORD ON ORD.OrderKey = PD.OrderKey
          WHERE PD.[Status] = '4'
            AND PD.Storerkey = OL.Storerkey
            AND PD.SKU = OL.SKU
            AND PD.QtyMoved > 0   --Not to impact normal allocation
      )
   END

   QUIT_SP:
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
      EXECUTE dbo.nsp_logerror @n_Err, @c_ErrMsg, 'mspALUPDORDLN01'
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
GRANT EXECUTE ON [mspALUPDORDLN01] TO [NSQL]
GO