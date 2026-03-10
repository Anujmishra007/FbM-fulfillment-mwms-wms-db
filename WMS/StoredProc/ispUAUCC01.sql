SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Trigger: ispUAUCC01                                                  */
/* Creation Date: 20-Apr-2015                                           */
/* Copyright: LF Logistics                                              */
/* Written by: YTWan                                                    */
/*                                                                      */
/* Purpose: SOS#337957 - ANF - CR on unallocation logic (for handling   */
/*          shared UCC in multiple orders)                              */
/* Called By: ntrPickdetaildelete Trigger when StorerConfig             */
/*            UnAllocUCCPickCode is setup                               */
/*                                                                      */
/* PVCS Version: 1.3                                                    */
/*                                                                      */
/* Version: 6.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/* 06/10/2016   TLTING    1.1 ADD NOLOCK                                */
/* 07/09/2017   Leong     1.2 IN00459369 - Add StorerKey.               */
/* 04-Dec-2025  WL01      1.3 UWP-44797 Support update by Pickdetailkey */
/* 13-Feb-2026  TK01      1.4 UWP-48857 Restructure Update using Loop   */
/* 25-Feb-2026  TK02      1.5 UWP-48857 Add TraceInfo Logging           */
/* 03-Mar-2026  TK03      1.5 UWP-48857 Add Qty > 0 filtering           */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[ispUAUCC01]
(   @c_Storerkey        NVARCHAR(15)
  , @b_Success          INT           OUTPUT
  , @n_Err              INT           OUTPUT
  , @c_ErrMsg           NVARCHAR(255) OUTPUT
  , @c_Pickdetailkey    NVARCHAR(10) = ''   --WL01
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Debug              INT
         , @n_Cnt                INT
         , @n_Continue           INT
         , @n_StartTCount        INT

   DECLARE @n_UCC_RowRef         INT            --(TK01)
         , @c_LogTraceInfo       NVARCHAR(10)   --(TK02)
         , @n_TtlCount           INT            --(TK02)
         , @n_UpdCount           INT            --(TK02)
         , @n_RowCount           INT            --(TK02)
         , @d_Trace_StartTime    DATETIME       --(TK02)
         , @d_Trace_EndTime      DATETIME       --(TK02)
         , @c_Step               NVARCHAR(20)   --(TK02)
         , @c_ZeroQtyCheck       NVARCHAR(1)    --(TK03)
         , @c_SQL_UCC            NVARCHAR(MAX)  --(TK03)
         , @c_Condition          NVARCHAR(MAX)  --(TK03)
         , @c_ExecStatement      NVARCHAR(MAX)  --(TK03) 
         , @c_ExecArguments      NVARCHAR(MAX)  --(TK03)    
         , @c_Facility           NVARCHAR(5)    --(TK03)    

   SET @b_Success             = 1
   SET @n_Err                 = 0
   SET @c_ErrMsg              = ''
   SET @b_Debug               = '0'
   SET @n_Continue            = 1
   SET @n_StartTCount         = @@TRANCOUNT
   SET @c_LogTraceInfo        = ''           --(TK02)
   SET @n_TtlCount            = -1           --(TK02)
   SET @n_UpdCount            = 0            --(TK02)
   SET @n_RowCount            = 0            --(TK02)
   SET @d_Trace_StartTime     = GETDATE()    --(TK02)
   SET @d_Trace_EndTime       = GETDATE()    --(TK02)
   SET @c_Step                = ''           --(TK02)
   SET @c_ZeroQtyCheck        = ''           --(TK03)
   SET @c_Condition           = ''           --(TK03)
   SET @c_ExecStatement       = ''           --(TK03) 
   SET @c_ExecArguments       = ''           --(TK03)    
   SET @c_Facility            = ''           --(TK03)

   --(TK02)
   SELECT @c_LogTraceInfo = Short 
   FROM Codelkup (NOLOCK)
   WHERE Listname  = 'TraceInfo'
   AND Code = 'UAUCC'
   AND StorerKey = @c_Storerkey

   --(TK03)
   SELECT @c_Facility = Facility 
   FROM Storer (NOLOCK)
   WHERE StorerKey = @c_Storerkey

   --(TK03)
   SELECT @c_ZeroQtyCheck = '1'
   FROM dbo.fnc_GetRight2(@c_Facility, @c_Storerkey, '', 'UnAllocUCCPickCode') AS SC
   WHERE Option1 = 'UpdZeroQtyToUnalloc'

   BEGIN TRAN

   --(TK01) - Start - Commented for restructure using Loop
   --WL01 S
   -- If @c_Pickdetailkey is provided (from ntrPickDetailUpdate), use PickDetailKey path
   -- If @c_Pickdetailkey is blank (from ntrPickDetailDelete), use #D_PICKDETAIL path
   --IF ISNULL(TRIM(@c_Pickdetailkey), '') <> ''
   --BEGIN
   --   UPDATE U 
   --   SET U.STATUS = '1'
   --     , U.PickdetailKey = ''
   --     , U.OrderKey = ''
   --     , U.OrderLineNumber = ''
   --     , U.WaveKey = ''
   --   FROM UCC U
   --   WHERE  U.Storerkey = @c_Storerkey
   --   AND    U.Status > '2' AND U.Status < '6'
   --   AND    EXISTS ( SELECT 1 
   --                   FROM PICKDETAIL PD (NOLOCK) 
   --                   WHERE PD.PickDetailKey = @c_Pickdetailkey
   --                   AND PD.Storerkey = @c_Storerkey
   --                   AND PD.DropID = U.UCCNo
   --                   AND PD.Status < '9' )
   --   AND NOT EXISTS ( SELECT 1 
   --                    FROM PICKDETAIL PD (NOLOCK) 
   --                    WHERE PD.Storerkey = @c_Storerkey
   --                    AND PD.DropID = U.UCCNo
   --                    AND PD.Status < '9'
   --                    AND PD.Qty > 0 )   --1 UCC Shares multiple pickdetail - ensure ALL have Qty = 0
   --END
   --ELSE IF OBJECT_ID('tempdb..#D_PICKDETAIL') IS NOT NULL
   --BEGIN   --WL01 E
   --   UPDATE UCC SET STATUS = '1'
   --      ,UCC.PickdetailKey = ''
   --      ,UCC.OrderKey = ''
   --      ,UCC.OrderLineNumber = ''
   --      ,UCC.WaveKey = ''
   --   FROM UCC U
   --   WHERE  U.Storerkey = @c_Storerkey
   --   AND    U.Status > '2' AND U.Status < '6'
   --   AND    EXISTS (SELECT 1 FROM #D_PICKDETAIL d WHERE d.DropID = U.UCCNo AND d.Storerkey = @c_Storerkey AND d.Status < '9') -- IN00459369
   --   AND    NOT EXISTS (SELECT 1 FROM PICKDETAIL PD (NOLOCK) WHERE PD.DropID = U.UCCNo AND PD.Storerkey = @c_Storerkey AND PD.Status < '9') -- IN00459369
   --END   --WL01   


   --(TK03) - Start
   --WL01 S
   -- If @c_Pickdetailkey is provided (from ntrPickDetailUpdate), use PickDetailKey path
   -- If @c_Pickdetailkey is blank (from ntrPickDetailDelete), use #D_PICKDETAIL path
   IF ISNULL(TRIM(@c_Pickdetailkey), '') <> ''
   BEGIN

      SET @c_SQL_UCC = N'DECLARE CUR_UCC CURSOR FAST_FORWARD READ_ONLY FOR'
                     + N' SELECT U.UCC_RowRef'
                     + N' FROM   UCC U (NOLOCK)'
                     + N' WHERE  U.Storerkey = @c_Storerkey'
                     + N' AND    U.Status > ''2'' AND U.Status < ''6'''
                     + N' AND    EXISTS     (SELECT 1 FROM PICKDETAIL PD1 (NOLOCK) WHERE PD1.PickDetailKey = @c_Pickdetailkey AND PD1.Storerkey = @c_Storerkey AND PD1.DropID = U.UCCNo AND PD1.Status < ''9'' )'
                     + N' AND    NOT EXISTS (SELECT 1 FROM PICKDETAIL PD2 (NOLOCK) WHERE PD2.Storerkey = @c_Storerkey AND PD2.DropID = U.UCCNo AND PD2.Status < ''9'' AND PD2.Qty > 0 )'   --1 UCC Shares multiple pickdetail - ensure ALL have Qty = 0

      --(TK02)
      IF @c_LogTraceInfo = '1'
      BEGIN

         SELECT @n_TtlCount = COUNT(U.UCC_RowRef), @d_Trace_StartTime = GETDATE(), @c_Step = 'With_PDKey'
         FROM   UCC U (NOLOCK)
         WHERE  U.Storerkey = @c_Storerkey
         AND    U.Status > '2' AND U.Status < '6'
         AND    EXISTS     (SELECT 1 FROM PICKDETAIL PD1 (NOLOCK) WHERE PD1.PickDetailKey = @c_Pickdetailkey AND PD1.Storerkey = @c_Storerkey AND PD1.DropID = U.UCCNo AND PD1.Status < '9' )
         AND    NOT EXISTS (SELECT 1 FROM PICKDETAIL PD2 (NOLOCK) WHERE PD2.Storerkey = @c_Storerkey AND PD2.DropID = U.UCCNo AND PD2.Status < '9' AND PD2.Qty > 0 )   --1 UCC Shares multiple pickdetail - ensure ALL have Qty = 0

      END

   END
   ELSE IF OBJECT_ID('tempdb..#D_PICKDETAIL') IS NOT NULL
   BEGIN
      
      SET @c_Condition = N' AND NOT EXISTS (SELECT 1 FROM PICKDETAIL PD (NOLOCK) WHERE PD.DropID = U.UCCNo AND PD.Storerkey = @c_Storerkey AND PD.Status < ''9'')'

      IF @c_ZeroQtyCheck = '1'
         SET @c_Condition = N' AND NOT EXISTS (SELECT 1 FROM PICKDETAIL PD (NOLOCK) WHERE PD.DropID = U.UCCNo AND PD.Storerkey = @c_Storerkey AND PD.Status < ''9'' AND PD.Qty > 0)'

      SET @c_SQL_UCC = N'DECLARE CUR_UCC CURSOR FAST_FORWARD READ_ONLY FOR'
                     + N' SELECT U.UCC_RowRef'
                     + N' FROM   UCC U (NOLOCK)'
                     + N' WHERE  U.Storerkey = @c_Storerkey'
                     + N' AND    U.Status > ''2'' AND U.Status < ''6'''
                     + N' AND    EXISTS (SELECT 1 FROM #D_PICKDETAIL d WHERE d.DropID = U.UCCNo AND d.Storerkey = @c_Storerkey AND d.Status < ''9'')' -- IN00459369
                     + @c_Condition

      --(TK02)
      IF @c_LogTraceInfo = '1'
      BEGIN
         
         SET @c_ExecStatement = N'SELECT @n_TtlCount = COUNT(U.UCC_RowRef), @d_Trace_StartTime = GETDATE(), @c_Step = ''With_#D_PICKDETAIL'''
                              + N' FROM   UCC U (NOLOCK)'
                              + N' WHERE  U.Storerkey = @c_Storerkey'
                              + N' AND    U.Status > ''2'' AND U.Status < ''6'''
                              + N' AND    EXISTS (SELECT 1 FROM #D_PICKDETAIL d WHERE d.DropID = U.UCCNo AND d.Storerkey = @c_Storerkey AND d.Status < ''9'')'
                              + @c_Condition

         SET @c_ExecArguments  = N'  @n_TtlCount         INT '
                               + N', @d_Trace_StartTime  DATETIME '
                               + N', @c_Step             NVARCHAR(20) '
                               + N', @c_Storerkey        NVARCHAR(15) '
                               + N', @c_Pickdetailkey    NVARCHAR(10) '
      
         EXEC sp_ExecuteSql @c_ExecStatement
                          , @c_ExecArguments
                          , @n_TtlCount      
                          , @d_Trace_StartTime
                          , @c_Step
                          , @c_Storerkey
                          , @c_Pickdetailkey
      END

   END

   --(TK03) - Execute UCC Cursor
   SET @c_ExecStatement = @c_SQL_UCC
   SET @c_ExecArguments = N'  @c_Storerkey        NVARCHAR(15) '
                        + N', @c_Pickdetailkey    NVARCHAR(10) '
   
   EXEC sp_ExecuteSql @c_ExecStatement
                    , @c_ExecArguments
                    , @c_Storerkey
                    , @c_Pickdetailkey

   
   OPEN CUR_UCC
   FETCH NEXT FROM CUR_UCC INTO @n_UCC_RowRef

   WHILE @@FETCH_STATUS = 0 and @n_Continue = 1
   BEGIN

      UPDATE UCC WITH (ROWLOCK)
      SET STATUS = '1'
        , PickdetailKey = ''
        , OrderKey = ''
        , OrderLineNumber = ''
        , WaveKey = ''
      WHERE  UCC_RowRef = @n_UCC_RowRef

      SET @n_RowCount = @@ROWCOUNT

      IF @@ERROR <> 0
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 80010
         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_Err)
                      +': Update UCC Table Failed. (ispUAUCC01)'
                      +'(' + ERROR_MESSAGE() + ')' 
      END
      ELSE IF @n_RowCount > 0
      BEGIN
         SET @n_UpdCount = @n_UpdCount + 1
      END

      FETCH NEXT FROM CUR_UCC INTO @n_UCC_RowRef
   END
   CLOSE CUR_UCC
   DEALLOCATE CUR_UCC
   --(TK01) - End
   --(TK03) - End

   --(TK02) - Start
   IF @c_LogTraceInfo = '1'
   BEGIN

      SET @d_Trace_EndTime = GETDATE()

      EXEC isp_InsertTraceInfo
           @c_TraceCode = 'UAUCC'
         , @c_TraceName = 'ispUAUCC01'  
         , @c_StartTime = @d_Trace_StartTime  
         , @c_EndTime   = @d_Trace_EndTime
         , @c_Step1     = @c_Storerkey 
         , @c_Step2     = @c_Pickdetailkey  
         , @c_Step3     = @c_Step 
         , @c_Step4     = @n_TtlCount
         , @c_Step5     = @n_UpdCount
         , @c_Col1      = ''
         , @c_Col2      = ''  
         , @c_Col3      = ''  
         , @c_Col4      = ''  
         , @c_Col5      = ''  
         , @b_Success   = 1  
         , @n_Err       = 0
         , @c_ErrMsg    = '' 

   END
   --(TK02) - END

   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0

      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCount
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCount
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ispUAUCC01'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTCount
      BEGIN
         COMMIT TRAN
      END

      RETURN
   END
END
GO
GRANT EXECUTE ON [dbo].[ispUAUCC01] TO nSQL
GO