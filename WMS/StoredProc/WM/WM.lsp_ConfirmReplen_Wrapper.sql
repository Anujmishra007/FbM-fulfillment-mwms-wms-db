SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*************************************************************************/  
/* Stored Procedure: lsp_ConfirmReplen_Wrapper                           */  
/* Creation Date: 28-FEB-2018                                            */  
/* Copyright: LFL                                                        */  
/* Written by:                                                           */  
/*                                                                       */  
/* Purpose:                                                              */  
/*                                                                       */  
/* Called By:                                                            */  
/*                                                                       */  
/*                                                                       */  
/* Version: 1.4                                                          */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date        Author   Ver   Purposes                                   */ 
/* 2021-02-05  mingle01 1.1   Add Big Outer Begin try/Catch              */
/*                            Execute Login if @c_UserName<>SUSER_SNAME()*/
/* 2023-10-11  Wan01    1.2   LFWM-4153 - UAT - CN  All Generating Ecom  */
/*                            Replenishment                              */
/* 2024-03-30  TLTING01 1.3   Infinite loop on trancount commit          */
/* 2023-06-06  Wan02    1.4   LFWM-4671 - CN SCE Generate E-Order        */
/*                            Replenishmenet UI Change For Converse      */     
/*************************************************************************/    
CREATE OR ALTER PROCEDURE [WM].[lsp_ConfirmReplen_Wrapper]  
   @c_Facility             NVARCHAR(10) = ''
,  @c_Zone02               NVARCHAR(10) = ''
,  @c_Zone03               NVARCHAR(10) = ''
,  @c_Zone04               NVARCHAR(10) = ''
,  @c_Zone05               NVARCHAR(10) = ''
,  @c_Zone06               NVARCHAR(10) = ''
,  @c_Zone07               NVARCHAR(10) = ''
,  @c_Zone08               NVARCHAR(10) = ''
,  @c_Zone09               NVARCHAR(10) = ''
,  @c_Zone10               NVARCHAR(10) = ''
,  @c_Zone11               NVARCHAR(10) = ''
,  @c_Zone12               NVARCHAR(10) = ''
,  @c_Storerkey            NVARCHAR(15) = ''
,  @c_ReplGroup            NVARCHAR(10) = 'ALL'
,  @c_ReplenishmentKey     NVARCHAR(10) = ''
,  @b_Success              INT          = 1   OUTPUT   
,  @n_Err                  INT          = 0   OUTPUT
,  @c_Errmsg               NVARCHAR(255)= ''  OUTPUT
,  @n_WarningNo            INT          = 0   OUTPUT
,  @c_ProceedWithWarning   CHAR(1)      = 'N' 
,  @c_UserName             NVARCHAR(128)= ''
,  @c_Wavekey              NVARCHAR(10) = 'ALL'                                     --(Wan02)
AS  
BEGIN  
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue     INT = 1
         , @n_StartTCnt    INT = @@TRANCOUNT 
                 
         , @n_Count        INT = 0 
         , @n_ReplGroupCnt INT = 0                                                  --(Wan02)
         , @CUR_CFMRPL     CURSOR                                                   --(Wan02) 

   DECLARE @t_ReplGroup    TABLE                                                    --(Wan02) 
         ( ReplenishmentGroup    NVARCHAR(10)   NOT NULL DEFAULT 'ALL' )            --(Wan02)  

   SET @b_Success = 1
   SET @c_ErrMsg = ''

   SET @n_Err = 0 

   --(mingle01) - START   
   IF SUSER_SNAME() <> @c_UserName
   BEGIN
      EXEC [WM].[lsp_SetUser] 
               @c_UserName = @c_UserName  OUTPUT
            ,  @n_Err      = @n_Err       OUTPUT
            ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
   
      IF @n_Err <> 0 
      BEGIN
         GOTO EXIT_SP
      END

      EXECUTE AS LOGIN = @c_UserName
   END
   --(mingle01) - END

   --(mingle01) - START
   BEGIN TRY
      IF ISNULL(RTRIM(@c_Facility),'') = ''
      BEGIN
         SET @n_Continue = 3
         SET @n_err = 554901
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + ': Facility cannot be blank. (lsp_ConfirmReplen_Wrapper)'
         GOTO EXIT_SP
      END
    
      IF @c_ProceedWithWarning = 'N' AND @n_WarningNo < 1
      BEGIN
         SET @n_WarningNo = 1
         SET @c_ErrMsg = 'Confirm Replenisment ?'
         GOTO EXIT_SP     
      END  
   
      IF @c_Replenishmentkey = ''
      BEGIN
         BEGIN TRY
            --(Wan02) - START    
            IF @c_Wavekey NOT IN ('','ALL') AND @c_ReplGroup = 'ALL'
            BEGIN
               INSERT INTO @t_ReplGroup (ReplenishmentGroup)
               SELECT rpl.ReplenishmentGroup
               FROM dbo.REPLENISHMENT rpl (NOLOCK)
               JOIN dbo.Loc (NOLOCK) ON loc.loc = rpl.Toloc
               WHERE rpl.Storerkey = @c_Storerkey
               AND   rpl.Wavekey   = @c_Wavekey
               AND   rpl.Confirmed IN ('N', 'L')
               AND   loc.Facility  = @c_Facility
               GROUP BY rpl.ReplenishmentGroup

               SET @n_ReplGroupCnt = @@ROWCOUNT

               IF @n_ReplGroupCnt = 0
               BEGIN
                  INSERT INTO @t_ReplGroup (ReplenishmentGroup)
                  SELECT pt.ReplenishmentGroup
                  FROM dbo.PACKTASK  pt (NOLOCK)
                  JOIN dbo.ORDERS o (NOLOCK) ON o.Orderkey = pt.Orderkey
                  WHERE o.Storerkey = @c_Storerkey
                  AND   o.Facility  = @c_Facility
                  AND   o.UserDefine09 = @c_Wavekey
                  AND   pt.ReplenishmentGroup NOT IN ('', NULL)
                  GROUP BY pt.ReplenishmentGroup
               END
            END
            ELSE
            BEGIN
               INSERT INTO @t_ReplGroup (ReplenishmentGroup)
               VALUES (@c_ReplGroup)
            END
 
            SET @CUR_CFMRPL = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT ReplenishmentGroup
            FROM @t_ReplGroup
            ORDER BY ReplenishmentGroup

            OPEN @CUR_CFMRPL

            FETCH NEXT FROM @CUR_CFMRPL INTO @c_ReplGroup

            WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1,2)
            BEGIN
               EXEC nsp_ConfirmReplenishment
                  @c_Facility = @c_Facility                                            --(Wan01)      
               ,  @c_Zone02   = @c_Zone02       
               ,  @c_Zone03   = @c_Zone03        
               ,  @c_Zone04   = @c_Zone04        
               ,  @c_Zone05   = @c_Zone05        
               ,  @c_Zone06   = @c_Zone06        
               ,  @c_Zone07   = @c_Zone07        
               ,  @c_Zone08   = @c_Zone08        
               ,  @c_Zone09   = @c_Zone09        
               ,  @c_Zone10   = @c_Zone10        
               ,  @c_Zone11   = @c_Zone11        
               ,  @c_Zone12   = @c_Zone12 
               ,  @c_Storerkey= @c_Storerkey 
               ,  @c_replgrp  = @c_ReplGroup                                           --(Wan01)
               ,  @b_Success  = @b_Success   OUTPUT 
               ,  @n_Err      = @n_Err       OUTPUT
               ,  @c_Errmsg   = @c_Errmsg    OUTPUT
               ,  @c_Wavekey  = @c_Wavekey                                             --(Wan03)

               FETCH NEXT FROM @CUR_CFMRPL INTO @c_ReplGroup
            END
            CLOSE @CUR_CFMRPL
            DEALLOCATE @CUR_CFMRPL
            --(Wan02) - END
         END TRY
         BEGIN CATCH
            SET @n_err = 554902
            SET @c_ErrMsg = ERROR_MESSAGE()
            SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_err) 
                          + ': Error Executing nsp_ConfirmReplenishment. (lsp_ConfirmReplen_Wrapper)'
                          + '( ' + @c_ErrMsg + ' )'
         END CATCH

         IF @b_Success = 0 OR @n_Err <> 0 
         BEGIN
            SET @n_continue = 3
            GOTO EXIT_SP 
         END
      END
      ELSE
      BEGIN
         BEGIN TRY
            UPDATE REPLENISHMENT
               SET Confirmed = 'Y'
                  ,EditWho = SUSER_SNAME()
                  ,EditDate= GETDATE()
            WHERE ReplenishmentKey = @c_ReplenishmentKey
         END TRY
         BEGIN CATCH
            SET @n_continue = 3   
            SET @n_err = 554903
            SET @c_ErrMsg = ERROR_MESSAGE()
            SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_err) 
                          + ': Update REPLENISHMENT table fail. (lsp_ConfirmReplen_Wrapper)'
                          + '( ' + @c_ErrMsg + ' )'
            GOTO EXIT_SP 
         END CATCH
  
      END
   END TRY

   BEGIN CATCH
      SET @n_Continue = 3
      SET @c_ErrMsg = ERROR_MESSAGE()
      GOTO EXIT_SP
   END CATCH
   --(mingle01) - END
EXIT_SP:

   IF (XACT_STATE()) = -1                                      
   BEGIN
      SET @n_Continue = 3
      ROLLBACK TRAN
   END 
      
   IF @n_Continue = 3   
   BEGIN
      SET @b_Success = 0
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_ConfirmReplen_Wrapper'
      SET @n_WarningNo = 0
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
   REVERT
END  
GO
GRANT EXECUTE ON [WM].[lsp_ConfirmReplen_Wrapper] TO nSQL 
GO


