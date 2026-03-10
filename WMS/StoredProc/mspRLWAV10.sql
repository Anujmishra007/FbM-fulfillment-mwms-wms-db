SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/*************************************************************************/    
/* Stored Procedure: mspRLWAV10                                          */    
/* Creation Date: 2026-01-22                                             */    
/* Copyright: Maersk Logistics                                           */    
/* Written by: Wan                                                       */    
/*                                                                       */    
/* Purpose: FCR-10124 - UK Columbia SportWear Release Wave               */    
/*                                                                       */    
/* Called By: Wave                                                       */    
/*                                                                       */    
/* Version: 1.1                                                          */    
/*                                                                       */    
/* Data Modifications:                                                   */    
/*                                                                       */    
/* Updates:                                                              */    
/* Date        Author   Ver   Purposes                                   */
/* 10-Feb-2026 WLChooi  1.0   Initial Version                            */
/* 10-Mar-2026 WLChooi  1.1   FCR-11471 Update Userdefine02 (WL01)       */
/*************************************************************************/     
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV10]        
   @c_Wavekey     NVARCHAR(10)
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
           @n_StartTCnt       INT   = @@TRANCOUNT
         , @n_Continue        INT   = 1
         , @n_RowCount        INT   = 0

         , @c_Facility        NVARCHAR(5) = ''
         , @c_Storerkey       NVARCHAR(15)= ''
         , @c_Orderkey        NVARCHAR(10)= ''
         , @c_Loadkey         NVARCHAR(10)= ''
         , @c_PickSlipNo      NVARCHAR(10)= ''
         , @c_SourceType      NVARCHAR(30)= 'mspRLWAV10'

         , @c_SQL             NVARCHAR(MAX) = ''
         , @c_SQLParms        NVARCHAR(2000)= ''

         , @cur_PCKGRPH       CURSOR
 
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

      CREATE INDEX IDX_Case ON #PickDetail_WIP (Orderkey, CaseID, Lot, Loc, ID)
   END
   
   IF @n_Continue = 1
   BEGIN
      SELECT TOP 1
            @c_Facility  = o.Facility
         ,  @c_Storerkey = o.StorerKey
      FROM WAVEDETAIL wd (NOLOCK)
      JOIN ORDERS o (NOLOCK) ON o.Orderkey = wd.Orderkey
      WHERE wd.Wavekey = @c_Wavekey
      ORDER BY wd.WaveDetailKey
   END

   IF @n_Continue = 1 AND @@TRANCOUNT = 0 
   BEGIN
      BEGIN TRAN
   END
   
   IF @n_Continue = 1
   BEGIN
      -- Generate Validation for mspRLWAV10 include its sub SPs
      -- @n_Err Start 62010
      EXEC [dbo].[mspRLWAV10_DATA]        
         @c_Wavekey     = @c_Wavekey 
      ,  @b_Success     = @b_Success   OUTPUT
      ,  @n_Err         = @n_Err       OUTPUT
      ,  @c_ErrMsg      = @c_ErrMsg    OUTPUT 
      ,  @n_debug       = @n_debug  

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
      -- Generate Validation for mspRLWAV10 include its sub SPs
      -- @n_Err Start 63010
      EXEC [dbo].[mspRLWAV10_VLDN]
         @c_Wavekey  = @c_Wavekey
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
     
   IF @n_Continue = 1 --AND @b_DoCartonize = 1
   BEGIN
      -- B2B, B2C Cartonization
      -- @n_Err Start 64010
      EXEC [dbo].[mspRLWAV10_PACK]
         @c_Wavekey  = @c_Wavekey
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


   IF @n_Continue = 1 
   BEGIN
      -- B2B & B2C ASTCPK task
      -- @n_Err Start 66010
      EXEC [dbo].[mspRLWAV10_CPK]
         @c_Wavekey  = @c_Wavekey
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
      UPDATE WAVE WITH (ROWLOCK)
         SET TMReleaseFlag = 'Y'
          ,  UserDefine02 = 'WaveReleased'   --WL01
          ,  TrafficCop = NULL
          ,  EditWho  = SUSER_SNAME()
          ,  EditDate = GETDATE()
      WHERE WaveKey = @c_Wavekey

      SELECT @n_Err = @@ERROR

      IF @n_Err <> 0
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'mspRLWAV10'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END 
GO
GRANT EXECUTE ON [dbo].[mspRLWAV10] TO [NSQL]
GO