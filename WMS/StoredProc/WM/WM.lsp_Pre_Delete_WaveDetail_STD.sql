IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_Pre_Delete_WaveDetail_STD]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_Pre_Delete_WaveDetail_STD]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/    
/* Stored Procedure: lsp_Pre_Delete_WaveDetail_STD                      */    
/* Creation Date: 03-Apr-2018                                           */    
/* Copyright: LFLogistics                                               */    
/* Written by:                                                          */    
/*                                                                      */    
/* Purpose: Orders Pre-delete process / validation                      */    
/*                                                                      */    
/* Called By: Orders delete                                             */    
/*                                                                      */    
/* PVCS Version: 1.0                                                    */    
/*                                                                      */    
/* Version: 8.0                                                         */    
/*                                                                      */    
/* Data Modifications:                                                  */    
/*                                                                      */    
/* Updates:                                                             */    
/* Date         Author   Ver  Purposes                                  */  
/* 19-Nov-2020  LZG      1.1  INC1357497 - Use RefKey2 as               */
/*                            WaveDetailKey (ZG01)                      */  
/************************************************************************/     
CREATE PROCEDURE [WM].[lsp_Pre_Delete_WaveDetail_STD]  
      @c_StorerKey         NVARCHAR(15)  
   ,  @c_RefKey1           NVARCHAR(50)  = ''   
   ,  @c_RefKey2           NVARCHAR(50)  = ''   
   ,  @c_RefKey3           NVARCHAR(50)  = ''   
   ,  @c_RefreshHeader     CHAR(1) = 'N'        OUTPUT  
   ,  @c_RefreshDetail     CHAR(1) = 'N'        OUTPUT   
   ,  @b_Success           INT = 1              OUTPUT     
   ,  @n_Err               INT = 0              OUTPUT  
   ,  @c_Errmsg            NVARCHAR(255) = ''   OUTPUT  
   ,  @c_UserName          NVARCHAR(128) = ''   
   ,  @c_IsSupervisor      CHAR(1) = 'N'   
AS  
BEGIN  
   SET ANSI_NULLS ON  
   SET ANSI_PADDING ON  
   SET ANSI_WARNINGS ON  
   SET QUOTED_IDENTIFIER ON  
   SET CONCAT_NULL_YIELDS_NULL ON  
   SET ARITHABORT ON  
  
   DECLARE @n_Continue                 INT = 1  
         , @n_StartTCnt                INT = @@TRANCOUNT  
  
         , @n_PickSlipCnt              INT = 0  
         , @c_Facility                 NVARCHAR(5)  = ''  
  
         , @c_WaveDetailKey            NVARCHAR(10) = ''   
         , @c_Wavekey                  NVARCHAR(10) = ''  
         , @c_Orderkey                 NVARCHAR(10) = ''   
         , @c_Status                   NVARCHAR(10) = ''  
         , @c_SOStatus                 NVARCHAR(10) = ''  
         
         , @c_DelSOCancCFromWave       NVARCHAR(30) = ''  
         , @c_DelUnProcessSOFromWave   NVARCHAR(30) = ''  
  
   SET @n_err=0  
   SET @b_success=1  
   SET @c_errmsg=''   
   SET @c_RefreshDetail = 'Y'  
     
   SET @c_WaveDetailKey = ISNULL(@c_RefKey2,'')       -- ZG01
  
   SELECT @c_Wavekey  = WD.Wavekey  
         ,@c_Orderkey = WD.Orderkey  
         ,@c_Facility = OH.Facility   
         ,@c_Storerkey= OH.Storerkey  
         ,@c_Status   = OH.[Status]  
         ,@c_SOStatus = OH.SOStatus  
   FROM WAVEDETAIL WD WITH (NOLOCK)  
   JOIN ORDERS OH WITH (NOLOCK) ON WD.Orderkey = OH.Orderkey  
   WHERE WD.WaveDetailKey = @c_WaveDetailKey  
  
   IF @c_WaveKey = ''  
   BEGIN  
      GOTO EXIT_SP    
   END  
           
   IF EXISTS(  SELECT 1   
               FROM WAVE WITH (NOLOCK)  
               WHERE Wavekey = @c_WaveKey  
               AND Status = '9'   
               )  
   BEGIN  
      SET @n_continue = 3  
      SET @n_err = 552351  
      SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(6),@n_err)+': Completed wave may not be deleted. (lsp_Pre_Delete_WaveDetail_STD)'     
      GOTO EXIT_SP               
   END                           
   
   SELECT @c_Status   = OH.[Status]  
         ,@c_SOStatus = OH.SOStatus  
   FROM ORDERS OH WITH (NOLOCK)  
   WHERE OH.Orderkey = @c_Orderkey  
  
   SELECT @c_DelSOCancCFromWave = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'DelSOCancCFromWave')  
  
   IF @c_DelSOCancCFromWave = '1'  
   BEGIN  
      IF @c_Status = '0' AND @c_SOStatus = 'CANC'  -- Delete without other pre-delete validation  
      BEGIN  
         GOTO EXIT_SP    
      END  
   END  
  
   SELECT @c_DelUnProcessSOFromWave = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'DelUnProcessSOFromWave')  
   IF @c_DelUnProcessSOFromWave = 1  
   BEGIN  
      IF @c_Status NOT IN ( '0', '9' )  
      BEGIN  
         SET @n_continue = 3  
         SET @n_err   = 552352  
         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(6),@n_err)  
                        +': ORDERS is not eligible to delete from this wave. (lsp_Pre_Delete_WaveDetail_STD)'   
         GOTO EXIT_SP   
      END  
   END  
  
   IF @c_Status >= '3'  
   BEGIN  
      SET @n_continue = 3  
      SET @n_err   = 552352  
      SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(6),@n_err)  
                     +': Picks are already in progress for Order#. (lsp_Pre_Delete_WaveDetail_STD)'   
      GOTO EXIT_SP                           
   END  
      
   SET @n_PickSlipCnt = 0  
   SELECT @n_PickSlipCnt = ISNULL(SUM(CASE WHEN PH.Orderkey = @c_Orderkey THEN 1 ELSE 0 END),0)  
   FROM WAVEDETAIL WH WITH (NOLOCK)  
   JOIN WAVEDETAIL WD WITH (NOLOCK) ON  WH.Wavekey = WD.Wavekey  
   JOIN PICKHEADER PH WITH (NOLOCK) ON  PH.Wavekey = WD.Wavekey  
                                    AND PH.Orderkey= WD.Orderkey  
   WHERE WH.WaveKey = @c_WaveKey  
                         
   IF @n_PickSlipCnt > 0  
   BEGIN  
      SET @n_continue = 3  
      SET @n_err   = 552352  
      SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(6),@n_err)  
                     +': PickSlip Printed. Delete Not Allowed. (lsp_Pre_Delete_WaveDetail_STD)'                 
      GOTO EXIT_SP   
   END                           
       
   IF EXISTS(  SELECT 1  
               FROM TASKDETAIL TD WITH (NOLOCK)  
               WHERE TD.WaveKey = @c_WaveKey  
               AND TD.[Status] IN ('3','9')  
            )  
   BEGIN  
      SET @n_continue = 3  
      SET @n_err = 552353  
      SET @c_errmsg = 'NSQL'+CONVERT(NVARCHAR(6),@n_err)  
                     + ': Cannot delete this wave. The wave has task details which are In Progress and/or Completed and which may not be deleted'  
                     + '. (lsp_Pre_Delete_WaveDetail_STD)'   
      GOTO EXIT_SP   
   END    
   ELSE  
   BEGIN  
      SET @c_errmsg = 'There are Task Details for this Wave. Delete Anyway?'  
      GOTO EXIT_SP                                                                                                                                                                                                                     
   END                  
     
EXIT_SP:  
  
   IF @n_continue=3  -- Error Occured - Process And Return    
   BEGIN    
      SELECT @b_success = 0    
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_starttcnt    
      BEGIN    
         ROLLBACK TRAN    
      END    
   ELSE    
      BEGIN    
         WHILE @@TRANCOUNT > @n_starttcnt    
         BEGIN    
            COMMIT TRAN    
         END    
      END    
      execute nsp_logerror @n_err, @c_errmsg, 'lsp_Pre_Delete_WaveDetail_STD'  
      RETURN    
   END    
   ELSE    
   BEGIN    
      SELECT @b_success = 1    
      WHILE @@TRANCOUNT > @n_starttcnt    
      BEGIN    
         COMMIT TRAN    
      END    
      RETURN    
   END                
END -- End Procedure
GO
GRANT EXECUTE ON [WM].[lsp_Pre_Delete_WaveDetail_STD] TO nSQL 
GO  