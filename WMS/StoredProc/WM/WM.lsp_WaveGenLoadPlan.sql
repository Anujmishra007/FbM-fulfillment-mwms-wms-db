IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_WaveGenLoadPlan]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_WaveGenLoadPlan] 
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO   
/************************************************************************/                                                                                  
/* Store Procedure: lsp_WaveGenLoadPlan                                 */                                                                                  
/* Creation Date: 2019-03-19                                            */                                                                                  
/* Copyright: LFL                                                       */                                                                                  
/* Written by: Wan                                                      */                                                                                  
/*                                                                      */                                                                                  
/* Purpose: LFWM-1651 -  Wave Summary - Wave Control - Generate Loadplan*/
/*                                                                      */                                                                                  
/* Called By: SCE                                                       */                                                                                  
/*          :                                                           */                                                                                  
/* PVCS Version: 1.0                                                    */                                                                                  
/*                                                                      */                                                                                  
/* Version: 8.0                                                         */                                                                                  
/*                                                                      */                                                                                  
/* Data Modifications:                                                  */                                                                                  
/*                                                                      */                                                                                  
/* Updates:                                                             */                                                                                  
/* Date        Author   Ver.  Purposes                                  */  
/************************************************************************/                                                                                  
CREATE PROC [WM].[lsp_WaveGenLoadPlan]                                                                                                                     
      @c_WaveKey           NVARCHAR(10)
   ,  @b_Success           INT = 1           OUTPUT  
   ,  @n_err               INT = 0           OUTPUT                                                                                                             
   ,  @c_ErrMsg            NVARCHAR(255)= '' OUTPUT               
   ,  @c_UserName          NVARCHAR(128)= ''                                                                                                                         

AS  
BEGIN                                                                                                                                                        
   SET NOCOUNT ON                                                                                                                                           
   SET ANSI_NULLS OFF                                                                                                                                       
   SET QUOTED_IDENTIFIER OFF                                                                                                                                
   SET CONCAT_NULL_YIELDS_NULL OFF       

   DECLARE  @n_StartTCnt               INT = @@TRANCOUNT  
         ,  @n_Continue                INT = 1
         ,  @n_Cnt                     INT = 0

         ,  @c_Facility                NVARCHAR(5)  = ''
         ,  @c_Storerkey               NVARCHAR(15) = ''

         ,  @c_SchemaSP                NVARCHAR(10) = ''
         ,  @c_SQL                     NVARCHAR(1000)= ''
         ,  @c_SQLParms                NVARCHAR(1000)=''

         ,  @c_WaveGenLoadPlanSP       NVARCHAR(30) = ''
         ,  @c_BuildParmKey            NVARCHAR(50) = ''

   SET @b_Success = 1
   SET @n_Err     = 0
               
   SET @n_Err = 0 
   EXEC [WM].[lsp_SetUser] 
         @c_UserName = @c_UserName  OUTPUT
      ,  @n_Err      = @n_Err       OUTPUT
      ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
                
   EXECUTE AS LOGIN = @c_UserName

   IF @n_Err <> 0 
   BEGIN
      GOTO EXIT_SP
   END 

   IF NOT EXISTS( SELECT 1 FROM WAVEDETAIL WITH (NOLOCK)
                  WHERE WaveKey = @c_WaveKey )
   BEGIN
      SET @n_continue = 3
      SET @n_err = 555651
      SET @c_errmsg = 'NSQL'+ CONVERT(Char(6),@n_err)
                    + ': No Orders populates to Wave. (lsp_WaveGenLoadPlan)'
      GOTO EXIT_SP
   END

   SET @c_Storerkey= ''
   SET @c_Facility = ''
   SELECT TOP 1 @c_Storerkey = OH.Storerkey
         , @c_Facility = OH.Facility
   FROM WAVEDETAIL WD WITH (NOLOCK)
   JOIN ORDERS OH WITH (NOLOCK) ON (WD.Orderkey = OH.Orderkey)
   WHERE WD.Wavekey = @c_WaveKey    
   ORDER BY WD.WaveDetailKey  

   BEGIN TRY
      EXEC nspGetRight
            @c_Facility   = @c_Facility         
          , @c_StorerKey  = @c_StorerKey        
          , @c_sku        = ''     
          , @c_ConfigKey  = 'WaveGenLoadPlan'       
          , @c_authority  = @c_WaveGenLoadPlanSP      OUTPUT
          , @b_Success    = @b_Success                OUTPUT
          , @n_err        = @n_err                    OUTPUT
          , @c_errmsg     = @c_errmsg                 OUTPUT
   END TRY
   BEGIN CATCH
         SET @n_Continue = 3
         SET @n_Err = 555652
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + ': Error Executing nspGetRight - WaveGenLoadPlan. (lsp_WaveGenLoadPlan)' 
                        + '(' + @c_ErrMsg + ')' 
         GOTO EXIT_SP                         
   END CATCH

   SET @c_BuildParmKey = ''
   IF  @c_WaveGenLoadPlanSP IN ('0','')
   BEGIN 
      SELECT TOP 1  
            @c_BuildParmKey = BP.BuildParmKey
      FROM BUILDPARM BP WITH (NOLOCK)   
      JOIN BUILDPARMGROUPCFG BPCFG WITH (NOLOCK) ON BP.ParmGroup = BPCFG.ParmGroup
                                                AND BPCFG.[Type] = 'WaveBuildLoad'
      WHERE BPCFG.Facility = @c_Facility
      AND   BPCFG.Storerkey= @c_Storerkey
      ORDER BY BP.BuildParmKey
   END

   IF @c_BuildParmKey <> '' 
   BEGIN
      -- Standard SCE Wave Build Load
      EXEC [WM].[lsp_Wave_BuildLoad]  
           @c_WaveKey   = @c_WaveKey
         , @c_Facility  = @c_Facility                                                                                                                            
         , @c_StorerKey = @c_StorerKey           
         , @b_Success   = @b_Success OUTPUT
         , @n_Err       = @n_Err     OUTPUT 
         , @c_ErrMsg    = @c_ErrMsg  OUTPUT
    
      IF @b_Success = 0 OR @n_Err <> 0
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 555653
         SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + ': Error Executing WM.lsp_Wave_BuildLoad. (lsp_WaveGenLoadPlan)' 
                        + '(' + @c_ErrMsg + ')'   
      END
      GOTO EXIT_SP
   END

   BEGIN TRY
      EXEC  [dbo].[isp_WaveGenLoadPlan_Wrapper]  
           @c_WaveKey = @c_WaveKey    
         , @b_Success = @b_Success OUTPUT
         , @n_Err     = @n_Err     OUTPUT 
         , @c_ErrMsg  = @c_ErrMsg  OUTPUT 
   END TRY
   BEGIN CATCH
      SET @n_Err = 555654
      SET @c_ErrMsg = ERROR_MESSAGE()
      SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(6), @n_Err) + ': Error Executing isp_WaveGenLoadPlan_Wrapper. (lsp_WaveGenLoadPlan)'   
                    + '(' + @c_ErrMsg + ')'          
   END CATCH
         
   IF @b_Success = 0 OR @n_Err <> 0
   BEGIN
      SET @n_Continue = 3
      GOTO EXIT_SP   
   END

EXIT_SP:
   IF @n_Continue=3  -- Error Occured - Process And Return
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_WaveGenLoadPlan'
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
GRANT EXECUTE ON [WM].[lsp_WaveGenLoadPlan] TO nSQL 
GO  