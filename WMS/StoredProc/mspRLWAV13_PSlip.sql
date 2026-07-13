SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/**************************************************************************/    
/* Stored Procedure: mspRLWAV13_PSlip                                     */    
/* Creation Date: 2026-07-05                                              */    
/* Copyright: Maersk                                                      */    
/* Written by: Wan                                                        */    
/*                                                                        */    
/* Purpose: FCR-12980 - AEOMX Release Wave                                */  
/*          CR v8.5                                                       */  
/* Called By: Wave Release                                                */    
/*          :                                                             */    
/* Version: 1.0                                                           */    
/*                                                                        */    
/* Data Modifications:                                                    */    
/*                                                                        */    
/* Updates:                                                               */    
/* Date        Author   Ver   Purposes                                    */ 
/**************************************************************************/   
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV13_PSlip]        
   @c_Wavekey     NVARCHAR(10)
,  @c_Storerkey   NVARCHAR(15)   = '' 
,  @c_Facility    NVARCHAR(5)    = '' 
,  @b_Success     INT            = 1   OUTPUT
,  @n_Err         INT            = 0   OUTPUT
,  @c_ErrMsg      NVARCHAR(255)  = ''  OUTPUT 
,  @n_debug       INT            = 0                     
AS    
BEGIN    
   SET NOCOUNT ON     
   SET QUOTED_IDENTIFIER OFF     
   SET ANSI_NULLS OFF     
   SET CONCAT_NULL_YIELDS_NULL OFF    
     
   DECLARE
           @n_StartTCnt          INT   = @@TRANCOUNT
         , @n_Continue           INT   = 1

         , @c_SourceType         NVARCHAR(30)= 'mspRLWAV13'
         , @c_UserName           NVARCHAR(128) = ''

         , @c_Orderkey           NVARCHAR(10)= ''
         , @c_Loadkey            NVARCHAR(10)= ''
         , @c_PickHeaderKey      NVARCHAR(10)= ''

         , @cur_ORD              CURSOR

   --@n_Err Start 64010
   SET @b_Success = 1    
   SET @n_Err     = 0    
   SET @c_ErrMsg  = ''   
   SET @c_UserName = dbo.fnc_GetUserName()
   
   IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NULL
   BEGIN
      CREATE TABLE #PickDetail_WIP(
         [PickDetailKey]   [nvarchar](18) NOT NULL PRIMARY KEY
      ,  [CaseID]          [nvarchar](20) NOT NULL DEFAULT (' ')
      ,  [PickHeaderKey]   [nvarchar](18) NOT NULL
      ,  [OrderKey]        [nvarchar](10) NOT NULL
      ,  [OrderLineNumber] [nvarchar](5)  NOT NULL
      ,  [Lot]             [nvarchar](10) NOT NULL
      ,  [Storerkey]       [nvarchar](15) NOT NULL
      ,  [Sku]             [nvarchar](20) NOT NULL
      ,  [AltSku]          [nvarchar](20) NOT NULL DEFAULT (' ')
      ,  [UOM]             [nvarchar](10) NOT NULL DEFAULT (' ')
      ,  [UOMQty]          [int]          NOT NULL DEFAULT (0)
      ,  [Qty]             [int]          NOT NULL DEFAULT (0)
      ,  [QtyMoved]        [int]          NOT NULL DEFAULT (0)
      ,  [Status]          [nvarchar](10) NOT NULL DEFAULT ('0')
      ,  [DropID]          [nvarchar](20) NOT NULL DEFAULT ('')
      ,  [Loc]             [nvarchar](10) NOT NULL DEFAULT ('UNKNOWN')
      ,  [ID]              [nvarchar](18) NOT NULL DEFAULT (' ')
      ,  [PackKey]         [nvarchar](10) NULL     DEFAULT (' ')
      ,  [UpdateSource]    [nvarchar](10) NULL     DEFAULT ('0')
      ,  [CartonGroup]     [nvarchar](10) NULL
      ,  [CartonType]      [nvarchar](10) NULL
      ,  [ToLoc]           [nvarchar](10) NULL     DEFAULT (' ')
      ,  [DoReplenish]     [nvarchar](1)  NULL     DEFAULT ('N')
      ,  [ReplenishZone]   [nvarchar](10) NULL     DEFAULT (' ')
      ,  [DoCartonize]     [nvarchar](1)  NULL     DEFAULT ('N')
      ,  [PickMethod]      [nvarchar](1)  NOT NULL DEFAULT (' ')
      ,  [WaveKey]         [nvarchar](10) NOT NULL DEFAULT (' ')
      ,  [LoadKey]         [nvarchar](10) NOT NULL DEFAULT (' ')
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

      EXEC [dbo].[mspRLWAV13_DATA]        
         @c_Wavekey     = @c_Wavekey 
      ,  @b_Success     = @b_Success   OUTPUT
      ,  @n_Err         = @n_Err       OUTPUT
      ,  @c_ErrMsg      = @c_ErrMsg    OUTPUT 
      ,  @n_debug       = @n_debug  
 
      SET @n_Continue = CASE WHEN @b_Success = 0 THEN 3
                             ELSE 1
                             END
   END

   IF @n_Continue = 1
   BEGIN
      IF @c_Storerkey = ''
      BEGIN
         SELECT TOP 1 @c_Storerkey = pw.Storerkey
         FROM #PICKDETAIL_WIP AS pw
      END
 
      SET @cur_ORD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT  
               Orderkey = ''  
            ,  lpd.Loadkey      
      FROM #PICKDETAIL_WIP AS pw 
      JOIN Loadplandetail lpd (NOLOCK) ON lpd.Orderkey = pw.Orderkey
      WHERE pw.[Status] < '5'
      AND pw.Qty > 0 
      AND pw.WIP_RefNo = @c_SourceType 
      AND pw.Taskdetailkey = '' 
  
      OPEN @cur_ORD

      FETCH NEXT FROM @cur_ORD INTO @c_Orderkey
                                 ,  @c_Loadkey
         
      WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1  
      BEGIN  
          EXEC [dbo].[isp_CreatePickSlip]     
               @c_Orderkey              = ''       
            ,  @c_Loadkey               = @c_Loadkey  --Create discrete or conso load determine by @c_ConsolidateByLoad setting  
            ,  @c_Wavekey               = @c_Wavekey  --Create discrete or conso load of the wave determine by @c_ConsolidateByLoad setting     
            ,  @c_PickslipType          = '5'   --Discrete('8', '3', 'D')  Conso('5','6','7','9','C')  Xdock ('XD','LB','LP')  
            ,  @c_ConsolidateByLoad     = 'Y'   --Y=Create load consolidate pickslip  N=create discrete pickslip  
            ,  @c_Refkeylookup          = 'N'   --Y=Create refkeylookup records  N=Not create  
            ,  @c_LinkPickSlipToPick    = 'N'   --Y=Update pickslipno to pickdetail.pickslipno  N=Not update to pickdetail  
            ,  @c_AutoScanIn            = 'N'   --Y=Auto scan in the pickslip N=Not auto scan in                                              
            ,  @b_Success               = @b_Success  OUTPUT  
            ,  @n_Err                   = @n_Err      OUTPUT   
            ,  @c_ErrMsg                = @c_ErrMsg   OUTPUT
            ,  @c_PickSlipWithWavekey   = 'Y'   --Y=Create Wavekey to PickHeader if not blank    

         IF @b_Success = 0
         BEGIN
            SET @n_Continue = 3
         END

         SET @c_PickHeaderKey = ''
         SELECT @c_PickHeaderKey = ph.PickHeaderkey
         FROM PICKHEADER ph (NOLOCK)
         WHERE ph.Loadkey = @c_Loadkey
         AND   ph.Orderkey= ''
         AND   ph.[Zone]  = '5'

         IF @c_PickHeaderKey > ''
         BEGIN
            UPDATE pw
               SET pw.PickSlipNo = @c_PickHeaderKey
            FROM #PICKDETAIL_WIP AS pw 
            JOIN Loadplandetail lpd (NOLOCK) ON lpd.Orderkey = pw.Orderkey
            WHERE pw.[Status] < '5'
            AND pw.Qty > 0 
            AND pw.WIP_RefNo = @c_SourceType 
            AND pw.Taskdetailkey = ''
         END

         FETCH NEXT FROM @cur_ORD INTO @c_Orderkey
                                    ,  @c_Loadkey
      END  
      CLOSE @cur_ORD  
      DEALLOCATE @cur_ORD         
   END
QUIT_SP:
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'mspRLWAV13_PSlip'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      IF @n_Continue = 4 SET @b_Success = 4

      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END 
GO
GRANT EXECUTE ON mspRLWAV13_PSlip TO NSQL
GO
