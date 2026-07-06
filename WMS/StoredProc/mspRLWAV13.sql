SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO
/**************************************************************************/    
/* Stored Procedure: mspRLWAV13                                           */    
/* Creation Date: 2026-06-16                                              */    
/* Copyright: Maersk                                                      */    
/* Written by: Wan                                                        */    
/*                                                                        */    
/* Purpose: FCR-12980 - AEOMX Release Wave                                */  
/*                                                                        */  
/* Called By: Wave Release                                                */    
/*          :                                                             */    
/* Version: 1.0                                                           */    
/*                                                                        */    
/* Data Modifications:                                                    */    
/*                                                                        */    
/* Updates:                                                               */    
/* Date        Author   Ver   Purposes                                    */ 
/* 2026-07-01  Wan      1.0   Remove Delete #Pickdetail_WIP record        */
/**************************************************************************/     
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV13]        
   @c_Wavekey     NVARCHAR(10)    
,  @b_Success     INT            = 1   OUTPUT    
,  @n_err         INT            = 0   OUTPUT    
,  @c_errmsg      NVARCHAR(250)  = ''  OUTPUT    
AS    
BEGIN    
   SET NOCOUNT ON     
   SET QUOTED_IDENTIFIER OFF     
   SET ANSI_NULLS OFF     
   SET CONCAT_NULL_YIELDS_NULL OFF    
      
   DECLARE @n_Continue           INT = 1     
         , @n_StartTCnt          INT = @@TRANCOUNT         -- Holds the current transaction count    
         , @n_debug              INT = 0 
         , @n_cnt                INT = 0

         , @c_Facility           NVARCHAR(5) = ''
         , @c_Storerkey          NVARCHAR(15)= ''
         , @c_Orderkey           NVARCHAR(10)= ''
         , @c_Loadkey            NVARCHAR(10)= ''
         , @c_PickSlipNo         NVARCHAR(10)= ''
         , @c_SourceType         NVARCHAR(30)= 'mspRLWAV13'
         , @c_Channel_b          NVARCHAR(20)= ''
         , @c_Client             NVARCHAR(20)= ''

         , @c_SQL                NVARCHAR(MAX) = ''
         , @c_SQLParms           NVARCHAR(2000)= ''
         , @c_Option5            NVARCHAR(MAX) = ''       
 
   IF @n_Continue = 1
   BEGIN
      IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NOT NULL
      BEGIN
         DROP TABLE #PICKDETAIL_WIP
      END

      CREATE TABLE #PickDetail_WIP(
         [PickDetailKey]   [nvarchar](18) NOT NULL PRIMARY KEY
      ,  [CaseID]          [nvarchar](20) NOT NULL DEFAULT ('')
      ,  [PickHeaderKey]   [nvarchar](18) NOT NULL
      ,  [OrderKey]        [nvarchar](10) NOT NULL
      ,  [OrderLineNumber] [nvarchar](5)  NOT NULL
      ,  [Lot]             [nvarchar](10) NOT NULL
      ,  [Storerkey]       [nvarchar](15) NOT NULL
      ,  [Sku]             [nvarchar](20) NOT NULL
      ,  [AltSku]          [nvarchar](20) NOT NULL DEFAULT ('')
      ,  [UOM]             [nvarchar](10) NOT NULL DEFAULT ('')
      ,  [UOMQty]          [int]          NOT NULL DEFAULT (0)
      ,  [Qty]             [int]          NOT NULL DEFAULT (0)
      ,  [QtyMoved]        [int]          NOT NULL DEFAULT (0)
      ,  [Status]          [nvarchar](10) NOT NULL DEFAULT ('0')
      ,  [DropID]          [nvarchar](20) NOT NULL DEFAULT ('')
      ,  [Loc]             [nvarchar](10) NOT NULL DEFAULT ('UNKNOWN')
      ,  [ID]              [nvarchar](18) NOT NULL DEFAULT ('')
      ,  [PackKey]         [nvarchar](10) NULL     DEFAULT ('')
      ,  [UpdateSource]    [nvarchar](10) NULL     DEFAULT ('0')
      ,  [CartonGroup]     [nvarchar](10) NULL
      ,  [CartonType]      [nvarchar](10) NULL
      ,  [ToLoc]           [nvarchar](10) NULL     DEFAULT ('')
      ,  [DoReplenish]     [nvarchar](1)  NULL     DEFAULT ('N')
      ,  [ReplenishZone]   [nvarchar](10) NULL     DEFAULT ('')
      ,  [DoCartonize]     [nvarchar](1)  NULL     DEFAULT ('N')
      ,  [PickMethod]      [nvarchar](1)  NOT NULL DEFAULT ('')
      ,  [WaveKey]         [nvarchar](10) NOT NULL DEFAULT ('')
      ,  [LoadKey]         [nvarchar](10) NOT NULL DEFAULT ('')
      ,  [EffectiveDate]   [datetime]     NOT NULL DEFAULT (getdate())
      ,  [AddDate]         [datetime]     NOT NULL DEFAULT (getdate())
      ,  [AddWho]          [nvarchar](128)NOT NULL DEFAULT (suser_sname())
      ,  [EditDate]        [datetime]     NOT NULL DEFAULT (getdate())
      ,  [EditWho]         [nvarchar](128)NOT NULL DEFAULT (suser_sname())
      ,  [TrafficCop]      [nvarchar](1)  NULL
      ,  [ArchiveCop]      [nvarchar](1)  NULL
      ,  [OptimizeCop]     [nvarchar](1)  NULL
      ,  [ShipFlag]        [nvarchar](1)  NULL     DEFAULT ('0')
      ,  [PickSlipNo]      [nvarchar](10) NULL
      ,  [TaskDetailKey]   [nvarchar](10) NULL
      ,  [TaskManagerReasonKey] [nvarchar](10) NULL
      ,  [Notes]           [nvarchar](4000)NULL
      ,  [MoveRefKey]      [nvarchar](10) NULL     DEFAULT ('')
      ,  [WIP_Refno]       [nvarchar](30) NULL     DEFAULT ('')
      ,  [Channel_ID]      [bigint]       NULL     DEFAULT (0)
      )
      CREATE INDEX IDX_Case ON #PickDetail_WIP (CaseID, Lot, Loc, ID)
      CREATE INDEX IDX_RPF ON #PickDetail_WIP (ReplenishZone)
   END
   
   IF @n_Continue = 1
   BEGIN
      SELECT 
            @c_Channel_b = w.UserDefine03
         ,  @c_Client = w.UserDefine05
      FROM WAVE w (NOLOCK) 
      WHERE w.Wavekey = @c_Wavekey

      SELECT TOP 1
            @c_Facility  = o.Facility
         ,  @c_Storerkey = o.StorerKey
      FROM WAVEDETAIL wd (NOLOCK) 
      JOIN ORDERS o (NOLOCK) ON o.Orderkey = wd.Orderkey
      WHERE wd.Wavekey = @c_Wavekey
   END

   IF @n_Continue = 1 AND @@TRANCOUNT = 0 
   BEGIN
      BEGIN TRAN
   END
   
   IF @n_Continue = 1
   BEGIN
      -- Generate Validation for mspRLWAV13 include its sub SPs
      -- @n_Err Start 62010
      EXEC [dbo].[mspRLWAV13_DATA]        
         @c_Wavekey  = @c_Wavekey
      ,  @c_Storerkey= @c_Storerkey
      ,  @c_Facility = @c_Facility 
      ,  @b_Success  = @b_Success   OUTPUT
      ,  @n_Err      = @n_Err       OUTPUT
      ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
      ,  @n_debug    = @n_debug  

      IF @b_Success = 0
      BEGIN
         SET @n_Continue = 3
      END

      IF @n_debug >= 1
      BEGIN
         select 'DATA',* from #PickDetail_WIP
         print 'DATA'
      END      
   END

   IF @n_Continue = 1
   BEGIN
      -- Generate Validation for mspRLWAV13 include its sub SPs
      -- @n_Err Start 63010
      EXEC [dbo].[mspRLWAV13_VLDN]
         @c_Wavekey  = @c_Wavekey
      ,  @c_Storerkey= @c_Storerkey
      ,  @c_Facility = @c_Facility 
      ,  @b_Success  = @b_Success   OUTPUT
      ,  @n_Err      = @n_Err       OUTPUT
      ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
      ,  @n_debug    = @n_debug  

      IF @b_Success = 0
      BEGIN
         SET @n_Continue = 3
      END
      
      IF @n_debug = 1
      BEGIN
         select 'VLDN', DoCartonize,pickslipno,* from #PickDetail_WIP
         print 'VLDN'
      END      
   END
 
   IF @n_Continue = 1 AND @c_Channel_b  = 'ECOM'
   BEGIN
      -- B2C Cartonization
      -- @n_Err Start 65010
      EXEC [dbo].[mspRLWAV13_ePACK]
         @c_Wavekey  = @c_Wavekey
      ,  @c_Storerkey= @c_Storerkey
      ,  @c_Facility = @c_Facility 
      ,  @b_Success  = @b_Success   OUTPUT
      ,  @n_Err      = @n_Err       OUTPUT
      ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
      ,  @n_debug    = @n_debug  

      IF @b_Success = 0
      BEGIN
         SET @n_Continue = 3
      END

      IF @n_debug = 1
      BEGIN
         select 'pack', DoCartonize, pickslipno,* from #PickDetail_WIP
         print 'PACK'
      END
   END

   IF @n_Continue = 1 AND @c_Channel_b IN ('WHSLE', 'RTL')
   BEGIN
      -- None B2C
      -- @n_Err Start 66010
      EXEC [dbo].[mspRLWAV13_SLOT]
         @c_Wavekey  = @c_Wavekey
      ,  @c_Storerkey= @c_Storerkey
      ,  @c_Facility = @c_Facility 
      ,  @b_Success  = @b_Success   OUTPUT
      ,  @n_Err      = @n_Err       OUTPUT
      ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
      ,  @n_debug    = @n_debug  

      IF @b_Success = 0
      BEGIN
         SET @n_Continue = 3
      END
   END
   
   IF @n_Continue = 1 
   BEGIN
      -- B2B & B2C ASTCPK task
      -- @n_Err Start 67010
      EXEC [dbo].[mspRLWAV13_RPF]
         @c_Wavekey  = @c_Wavekey
      ,  @c_Storerkey= @c_Storerkey
      ,  @c_Facility = @c_Facility 
      ,  @b_Success  = @b_Success   OUTPUT
      ,  @n_Err      = @n_Err       OUTPUT
      ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
      ,  @n_debug    = @n_debug  

      IF @b_Success = 0
      BEGIN
         SET @n_Continue = 3
      END
      
      IF @n_debug = 1
      BEGIN
         Select 'pick', DoCartonize, pickslipno,* from #PickDetail_WIP
         print 'PICK'
      END
   END

   IF @n_Continue = 1 
   BEGIN
      -- B2B & B2C ASTCPK task
      -- @n_Err Start 68010
      EXEC [dbo].[mspRLWAV13_FCP]
         @c_Wavekey  = @c_Wavekey
      ,  @c_Storerkey= @c_Storerkey
      ,  @c_Facility = @c_Facility 
      ,  @b_Success  = @b_Success   OUTPUT
      ,  @n_Err      = @n_Err       OUTPUT
      ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
      ,  @n_debug    = @n_debug  

      IF @b_Success = 0
      BEGIN
         SET @n_Continue = 3
      END
      
      IF @n_debug = 1
      BEGIN
         Select 'pick', DoCartonize, pickslipno,* from #PickDetail_WIP
         print 'PICK'
      END
   END

   IF @n_Continue = 1   
   BEGIN 
      --Reset Fields that not to update back to Pickdetail
      UPDATE #pickdetail_WIP SET ToLoc = '', ReplenishZone = '' 
      --Update pickdetail_WIP work in progress staging table back to pickdetail 
      EXEC isp_CreatePickdetail_WIP  
               @c_Loadkey               = ''                                
            ,  @c_Wavekey               = @c_Wavekey    
            ,  @c_WIP_RefNo             = @c_SourceType   
            ,  @c_PickCondition_SQL     = ''  
            ,  @c_Action                = 'U'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records  
            ,  @c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization  
            ,  @b_Success               = @b_Success OUTPUT  
            ,  @n_Err                   = @n_Err     OUTPUT   
            ,  @c_ErrMsg                = @c_ErrMsg  OUTPUT  

      IF @b_Success <> 1                                                             
      BEGIN  
         SET @n_Continue = 3  
      END     
   END
QUIT_SP: 
   IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NOT NULL
   BEGIN
      DROP TABLE #PICKDETAIL_WIP  
   END

   IF @n_Continue=3  -- Error Occured - Process And Return    
   BEGIN    
      SET @b_success = 0    
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_StartTCnt    
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
      execute nsp_logerror @n_err, @c_errmsg, "mspRLWAV13"    
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012    
   END    
   ELSE    
   BEGIN    
      SET @b_success = 1    
      WHILE @@TRANCOUNT > @n_StartTCnt    
      BEGIN    
         COMMIT TRAN    
      END    
   END        
END
GO


