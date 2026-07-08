SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/**************************************************************************/    
/* Stored Procedure: mspRLWAV13_FCP                                       */    
/* Creation Date: 2026-06-22                                              */    
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
/* 2026-07-07  Wan      1.0   FCR-12980: CR v8.5 - v8.7                   */
/**************************************************************************/   
CREATE OR ALTER PROCEDURE [dbo].[mspRLWAV13_FCP]        
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
         , @c_TaskdetailKey      NVARCHAR(10)= ''
         , @c_Taskdetail_RPF     NVARCHAR(10)= ''
         , @c_TaskType           NVARCHAR(10)= ''
         , @c_Sku                NVARCHAR(15)= ''
         , @c_Lot                NVARCHAR(10)= ''
         , @c_FromLoc            NVARCHAR(10)= ''
         , @c_FromID             NVARCHAR(18)= ''
         , @c_UCCNo              NVARCHAR(20)= ''
         , @c_UCCNo_P            NVARCHAR(20)= ''
         , @c_ToLoc              NVARCHAR(10)= ''
         , @c_ToLoc_P            NVARCHAR(10)= ''
         , @c_ToID               NVARCHAR(18)= ''
         , @c_FinalLoc           NVARCHAR(10)= ''
         , @c_FinalID            NVARCHAR(18)= ''
         , @c_UOM                NVARCHAR(10)= ''
         , @c_UOM_P              NVARCHAR(10)= ''
         , @c_PickMethod         NVARCHAR(10)= ''
         , @c_TransitLoc         NVARCHAR(10)= ''
         , @c_RefTaskkey         NVARCHAR(10)= ''
         , @c_Priority           NVARCHAR(10)= '9'
         , @c_Priority_Wave      NVARCHAR(10)= ''
         , @c_Priority_Area      NVARCHAR(10)= ''
         , @c_TaskStatus         NVARCHAR(10)= '0'
         , @c_GroupKey           NVARCHAR(10)= ''
         , @c_SectionKey         NVARCHAR(10)= ''
         , @c_SectionKey_P       NVARCHAR(10)= ''
         , @c_PutawayZone        NVARCHAR(10)= '' 
         , @c_AreaKey_P          NVARCHAR(10)= '' 
         , @c_AreaKey            NVARCHAR(10)= '' 
         , @c_LinkTaskToPick_SQL NVARCHAR(1000)= '' 
         , @c_PickDetailKey      NVARCHAR(10)= ''
         , @c_PickDetailKey_New  NVARCHAR(10)= ''         

         , @n_TransitCount       INT         = 0  
         , @n_LocLevel           INT         = 0
         , @n_LocLevel_P         INT         = 0
         , @n_Qty                INT         = 0
         , @n_QtyLeftToFill      INT         = 0
         , @n_QtyToFill          INT         = 0
         , @n_QtyToTake          INT         = 0
         , @n_QtyPick            INT         = 0
         , @n_QtyTask            INT         = 0         
         , @n_UOMQty             INT         = 0
         , @n_Vol                FLOAT       = 0.00
         , @n_VolDropID          FLOAT       = 0.00
         , @n_VolLeftToFill      FLOAT       = 0.00
         , @n_VolTotal           FLOAT       = 0.00
         , @n_Cube               FLOAT       = 0.00
         , @n_CubeUOM3           FLOAT       = 0.00
         , @n_MaxCapaci_LPN      FLOAT       = 0.00
         , @n_MaxCapaci_Tote     FLOAT       = 0.00

         , @c_SQL                NVARCHAR(MAX) = ''
         , @c_SQLParms           NVARCHAR(2000)= ''                                   
  
         , @cur_FCP              CURSOR
         , @CUR_UPD              CURSOR         

   DECLARE @t_CL                 TABLE
         (  [RowID]              INT               IDENTITY(1,1) PRIMARY KEY                   
         ,  [LISTNAME]           [nvarchar](10)    NULL     
         ,  [Code]               [nvarchar](30)    NULL  
         ,  [Description]        [nvarchar](250)   NULL  
         ,  [Short]              [nvarchar](10)    NULL  
         ,  [Long]               [nvarchar](250)   NULL  
         ,  [Notes]              [nvarchar](4000)  NULL  
         ,  [Notes2]             [nvarchar](4000)  NULL  
         ,  [Storerkey]          [nvarchar](50)    NOT NULL  
         ,  [UDF01]              [nvarchar](60)    NOT NULL  
         ,  [UDF02]              [nvarchar](60)    NOT NULL  
         ,  [UDF03]              [nvarchar](60)    NOT NULL  
         ,  [UDF04]              [nvarchar](60)    NOT NULL  
         ,  [UDF05]              [nvarchar](60)    NOT NULL  
         ,  [code2]              [nvarchar](30)    NOT NULL 
         ) 

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
      
      SELECT @c_Priority_Wave = w.Userdefine04
      FROM WAVE AS w (NOLOCK)
      WHERE w.Wavekey = @c_Wavekey

      IF @c_Priority_Wave NOT BETWEEN '0' AND '9'
      BEGIN
         SET @c_Priority_Wave = @c_Priority
      END

      INSERT INTO @t_CL ( Listname, Code, Description, Short, Long                
                     ,  Notes, Notes2, Storerkey
                     ,  UDF01, UDF02, UDF03, UDF04, UDF05, Code2
                     )  
      SELECT CL.Listname   
         ,   CL.Code   
         ,   [Description] = ISNULL(CL.[Description],'')   
         ,   Short = ISNULL(CL.Short,'')      
         ,   Long  = ISNULL(CL.Long ,'')     
         ,   Notes = ISNULL(CL.Notes,'')      
         ,   Notes2= ISNULL(CL.Notes2,'')           
         ,   CL.Storerkey  
         ,   CASE WHEN IsNumeric(CL.UDF01) = 1 THEN cl.UDF01 ELSE '0' END  
         ,   CASE WHEN IsNumeric(CL.UDF02) = 1 THEN cl.UDF02 ELSE '0.00' END    
         ,   CL.UDF03   
         ,   CL.UDF04   
         ,   CL.UDF05   
         ,   CL.Code2  
      FROM CODELKUP CL (NOLOCK)  
      WHERE CL.Listname = 'MAX_CAPACI'
      AND   CL.Storerkey= @c_Storerkey
      
      INSERT INTO @t_CL ( Listname, Code, Description, Short, Long                
                     ,  Notes, Notes2, Storerkey
                     ,  UDF01, UDF02, UDF03, UDF04, UDF05, Code2
                     )  
      SELECT cl.Listname   
         ,   cl.Code   
         ,   [Description] = ISNULL(cl.[Description],'')   
         ,   Short = ISNULL(cl.Short,'')      
         ,   Long  = ISNULL(cl.Long ,'')     
         ,   Notes = ISNULL(cl.Notes,'')      
         ,   Notes2= ISNULL(cl.Notes2,'')           
         ,   cl.Storerkey  
         ,   cl.UDF01 
         ,   cl.UDF02     
         ,   cl.UDF03   
         ,   cl.UDF04   
         ,   cl.UDF05   
         ,   cl.Code2  
      FROM CODELKUP cl (NOLOCK)  
      WHERE cl.Listname = 'AREA_MEZZA'
      AND   cl.Storerkey= @c_Storerkey

      SELECT @n_MaxCapaci_LPN = cl.UDF01
            ,@n_MaxCapaci_Tote= cl.UDF02
      FROM @t_CL cl
      WHERE cl.Listname = 'MAX_CAPACI'
      AND   cl.Code = 'FULL_UCC'
      AND   cl.Storerkey= @c_Storerkey
   END
   
   IF @n_Continue = 1
   BEGIN
      SET @cur_FCP = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT pw.Storerkey
            ,pw.Sku 
            ,pw.Lot                                                                  
            ,FromLoc = CASE WHEN rpf.TaskDetailKey IS NULL THEN pw.Loc ELSE rpf.FinalLoc END
            ,FromID  = CASE WHEN rpf.TaskDetailKey IS NULL THEN pw.ID ELSE rpf.FinalID END
            ,pw.UOM
            ,UCCNo   = CASE WHEN rpf.TaskDetailKey IS NULL THEN pw.DropID ELSE '' END  
            ,Qty     = SUM(pw.Qty)     
            ,UOMQty  = SUM(pw.UOMQty) 
            ,rpf.TaskDetailKey
            ,l.LocLevel
            ,ad.Areakey
            ,p.CubeUOM3 
      FROM #PICKDETAIL_WIP AS pw      
      JOIN LOC l (NOLOCK) ON l.Loc = pw.ToLoc  
      JOIN AreaDetail AD (NOLOCK) ON ad.PutawayZone = l.PutawayZone   
      JOIN SKU S (NOLOCK) ON s.StorerKey = pw.Storerkey AND s.SKU = pw.Sku 
      JOIN PACK P (NOLOCK) ON p.PackKey = s.PACKKey  
      LEFT OUTER JOIN TaskDetail rpf (NOLOCK) ON rpf.TaskDetailKey = pw.ReplenishZone
      WHERE pw.[Status] < '5'
      AND pw.Qty > 0 
      AND pw.WIP_RefNo = @c_SourceType 
      AND pw.Taskdetailkey = '' 
      GROUP BY pw.Storerkey
            ,  pw.Sku 
            ,  pw.Lot                                                                  
            ,  CASE WHEN rpf.TaskDetailKey IS NULL THEN pw.Loc ELSE rpf.FinalLoc END
            ,  CASE WHEN rpf.TaskDetailKey IS NULL THEN pw.ID ELSE rpf.FinalID END
            ,  pw.UOM
            ,  CASE WHEN rpf.TaskDetailKey IS NULL THEN pw.DropID ELSE '' END  
            ,  rpf.TaskDetailKey
            ,  l.LogicalLocation            
            ,  l.LocLevel
            ,  ad.Areakey
            ,  p.CubeUOM3 
      ORDER BY pw.UOM
            ,  l.LogicalLocation
            ,  ad.Areakey                                                           --(Wan)
  
      OPEN @cur_FCP

      FETCH NEXT FROM @cur_FCP INTO @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_FromID
                                 ,  @c_UOM, @c_UCCNo, @n_Qty, @n_UOMQty
                                 ,  @c_Taskdetail_RPF 
                                 ,  @n_LocLevel 
                                 ,  @c_Areakey, @n_CubeUOM3

         
      WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1 
      BEGIN  
         SET @c_TaskType   = 'FCP'
         SET @c_PickMethod = 'PP'
         SET @c_ToID = @c_FromID
         SET @c_Priority = @c_Priority_Wave
         SET @c_TaskStatus = '0'
         SET @c_RefTaskkey = ''
         SET @c_LinkTaskToPick_SQL = ' PICKDETAIL.UOM = @c_UOM AND ORDERS.Userdefine09 = @c_Wavekey' 
                                   + ' ORDER BY PICKDETAIL.QTY'

         IF @c_Taskdetail_RPF > ''
         BEGIN
            SET @c_RefTaskkey = @c_Taskdetail_RPF
            SET @c_TaskStatus = 'H'
         END

         SELECT @c_ToLoc = cl.UDF01
               ,@c_Priority_Area = cl.UDF02
         FROM @t_CL cl
         WHERE cl.ListName = 'AREA_MEZZA'
         AND   cl.Code = @c_AreaKey
         AND   cl.Storerkey = @c_Storerkey

         --IF @c_UOM = '2'                                                          --(Wan)                     
         --BEGIN
         --   SET @c_ToLoc = 'AEOSTGPICK'
         --END
                                
         IF ISNULL(@c_Toloc,'') = ''  
         BEGIN           
            SET @n_Continue = 3    
            SET @n_err = 68010  -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
            SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Invalid To Loc setup. (mspRLWAV13)' 
         END    

         IF @c_UOM IN ('2', '6') AND @n_Continue = 1
         BEGIN
            IF @c_UOM = '2' AND @c_UCCNo > ''
            BEGIN
               SET @c_Priority = '9'
               SET @n_Vol      = 1.00           
               SET @n_Cube     = 1.00 
               SET @n_VolDropID= @n_MaxCapaci_LPN
            END
            ELSE IF @c_UOM = '6'
            BEGIN
               SET @n_Vol      = @n_CubeUOM3 * @n_Qty      
               SET @n_Cube     = @n_CubeUOM3                                      
               SET @n_VolDropID= @n_MaxCapaci_Tote                        
            END

            IF @c_UOM_P <> @c_UOM
            BEGIN
               SET @c_Groupkey = ''
            END

            IF @c_Areakey_P <> @c_Areakey                                           --(Wan)
            BEGIN
               SET @c_Groupkey = ''
            END

            IF @c_ToLoc_P <> @c_ToLoc
            BEGIN
               SET @c_Groupkey = ''
            END

            IF @c_Groupkey > '' AND @n_VolDropID > 0.00 AND @n_VolLeftToFill > 0     
            BEGIN
               IF @n_VolLeftToFill < @n_Cube                                        
               BEGIN
                  SET @c_Groupkey = ''
               END              
            END                                                                           
                 
            SET @n_QtyLeftToFill = @n_Qty                                              
            
            IF @c_UOM = '2' AND @c_UCCNo > '' 
            BEGIN
               SET @n_QtyLeftToFill = 1                                                
            END   
                     
            WHILE @n_QtyLeftToFill > 0 AND @n_Continue IN (1,2)                       
            BEGIN
               IF @c_Groupkey = ''
               BEGIN
                  SET @n_VolLeftToFill = @n_VolDropID                               
               END
                                          
               SET @n_QtyToTake = 0
               SET @n_QtyToFill = 0

               IF @n_Cube > 0
               BEGIN
                  SET @n_QtyToFill = FLOOR(@n_VolLeftToFill/@n_Cube)
               END
                            
               IF @n_QtyToFill > 0
               BEGIN
                  IF @n_QtyLeftToFill > @n_QtyToFill
                  BEGIN
                     SET @n_QtyToTake = @n_QtyToFill
                  END
                  ELSE
                  BEGIN
                     SET @n_QtyToTake = @n_QtyLeftToFill
                  END
               END
                  
               IF @c_UCCNo = ''
               BEGIN
                  SET @n_UOMQty = @n_QtyToTake
                  SET @n_Qty    = @n_QtyToTake                                              
               END
                  
               SET @b_success = 1                                                
               SET @c_Taskdetailkey = ''
               EXECUTE nspg_getkey   
                     @KeyName    = 'TaskDetailKey'             
                  ,  @fieldlength= 10    
                  ,  @keystring  = @c_Taskdetailkey   OUTPUT  
                  ,  @b_Success  = @b_Success         OUTPUT  
                  ,  @n_err      = @n_err             OUTPUT  
                  ,  @c_errmsg   = @c_errmsg          OUTPUT  

               IF @b_Success <> 1    
               BEGIN    
                  SET @n_Continue = 3    
               END  

               IF @n_Continue = 1
               BEGIN
                  IF @c_GroupKey = ''
                  BEGIN
                     SET @c_GroupKey = @c_Taskdetailkey 
                  END

                  EXEC isp_InsertTaskDetail  
                      @c_TaskdetailKey         = @c_Taskdetailkey 
                     ,@c_TaskType              = @c_TaskType               
                     ,@c_Storerkey             = @c_Storerkey  
                     ,@c_Sku                   = @c_Sku  
                     ,@c_Lot                   = @c_Lot   
                     ,@c_UOM                   = @c_UOM        
                     ,@n_UOMQty                = @n_UOMQty       
                     ,@n_Qty                   = @n_Qty     
                     ,@c_FromLoc               = @c_Fromloc        
                     ,@c_LogicalFromLoc        = @c_FromLoc   
                     ,@c_FromID                = @c_FromID       
                     ,@c_ToLoc                 = @c_ToLoc         
                     ,@c_LogicalToLoc          = @c_ToLoc   
                     ,@c_ToID                  = @c_ToID   
                     ,@c_CaseID                = @c_UCCNo
                     ,@c_PickMethod            = @c_PickMethod  
                     ,@c_Priority              = @c_Priority_Wave        
                     ,@c_SourcePriority        = '9'        
                     ,@c_SourceType            = @c_SourceType        
                     ,@c_SourceKey             = @c_Wavekey        
                     ,@c_OrderKey              = @c_Orderkey  
                     ,@c_Wavekey               = @c_Wavekey 
                     ,@c_Message01             = '' 
                     ,@c_Message02             = '' 
                     ,@c_Message03             = @c_Priority_Area 
                     ,@c_RefTaskkey            = @c_RefTaskkey -- if FCP need RPF Qty from other wave, reftaskkey  =''
                     ,@c_Loadkey               = @c_Loadkey   
                     ,@c_AreaKey               = @c_AreaKey    -- ?F=Get from location areakey                        
                     ,@c_TransitLoc            = @c_ToLoc
                     ,@c_Groupkey              = @c_Groupkey
                     ,@c_LinkTaskToPick        = 'WIP' -- WIP=Update taskdetailkey to pickdetail_wip  
                     ,@c_LinkTaskToPick_SQL    = @c_LinkTaskToPick_SQL    
                     ,@c_SplitTaskByCase       ='N'   -- N=No slip Y=Split TASK by carton. Only apply if @n_casecnt > 0. include last partial carton.  
                     ,@c_WIP_RefNo             = @c_SourceType  
                     ,@b_Success               = @b_Success OUTPUT  
                     ,@n_Err                   = @n_err OUTPUT   
                     ,@c_ErrMsg                = @c_errmsg OUTPUT 
                     ,@c_Status                = @c_TaskStatus         
                      
                  IF @b_Success <> 1   
                  BEGIN  
                     SET @n_Continue = 3  
                  END  

                  IF @n_Continue = 1 AND @c_Taskdetail_RPF > '' AND @n_Qty > 0
                  BEGIN
                     SET @n_QtyTask = @n_Qty
 
                     SET @CUR_UPD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                     SELECT pw.PickDetailKey
                           ,pw.Qty
                     FROM #PICKDETAIL_WIP AS pw
                     WHERE pw.ReplenishZone = @c_Taskdetail_RPF
                     AND   pw.TaskDetailKey= ''
                     ORDER BY pw.Qty                      

                     OPEN @CUR_UPD

                     FETCH NEXT FROM @CUR_UPD INTO @c_PickdetailKey
                                                ,  @n_QtyPick

                     WHILE @@FETCH_STATUS = 0 AND @n_Continue = 1 AND @n_QtyTask > 0
                     BEGIN
                        IF @n_QtyPick < @n_QtyTask
                        BEGIN 
                           SET @n_Qty = @n_QtyPick
                        END
                        ELSE
                        BEGIN
                           SET @n_Qty = @n_QtyTask
                        END

                        UPDATE pw
                           SET pw.Qty = @n_Qty
                              ,pw.TaskDetailkey = @c_Taskdetailkey
                              ,pw.EditWho  = @c_UserName
                              ,pw.EditDate = GETDATE()                               
                        FROM #PICKDETAIL_WIP AS pw 
                        WHERE pw.PickdetailKey = @c_PickdetailKey 

                        SET @n_QtyPick = @n_QtyPick - @n_Qty
                        SET @n_QtyTask = @n_QtyTask - @n_Qty                        

                        IF @n_QtyPick > 0
                        BEGIN
                           SET @b_Success = 1    
                           EXECUTE nspg_getkey   
                                 @KeyName    = 'PickDetailKey'             
                              ,  @fieldlength= 10    
                              ,  @keystring  = @c_PickDetailKey_New  OUTPUT  
                              ,  @b_Success  = @b_Success            OUTPUT  
                              ,  @n_err      = @n_err                OUTPUT  
                              ,  @c_errmsg   = @c_errmsg             OUTPUT  

                           IF @b_Success <> 1    
                           BEGIN    
                              SET @n_Continue = 3    
                           END 
                  
                           IF @n_Continue = 1
                           BEGIN
                              INSERT INTO #PickDetail_WIP 
                                 (
                                    [PickDetailKey]   
                                 ,  [CaseID]          
                                 ,  [PickHeaderKey]   
                                 ,  [OrderKey]        
                                 ,  [OrderLineNumber] 
                                 ,  [Lot]             
                                 ,  [Storerkey]       
                                 ,  [Sku]             
                                 ,  [AltSku]          
                                 ,  [UOM]             
                                 ,  [UOMQty]          
                                 ,  [Qty]             
                                 ,  [QtyMoved]        
                                 ,  [Status]          
                                 ,  [DropID]          
                                 ,  [Loc]             
                                 ,  [ID]              
                                 ,  [PackKey]         
                                 ,  [UpdateSource]    
                                 ,  [CartonGroup]     
                                 ,  [CartonType]      
                                 ,  [ToLoc]           
                                 ,  [DoReplenish]     
                                 ,  [ReplenishZone]   
                                 ,  [DoCartonize]     
                                 ,  [PickMethod]      
                                 ,  [WaveKey]         
                                 ,  [LoadKey]         
                                 ,  [EffectiveDate]   
                                 ,  [OptimizeCop]
                                 ,  [ShipFlag]        
                                 ,  [PickSlipNo]      
                                 ,  [TaskDetailKey]   
                                 ,  [TaskManagerReasonKey] 
                                 ,  [Notes]           
                                 ,  [MoveRefKey]      
                                 ,  [WIP_Refno]       
                                 ,  [Channel_ID]
                                 )
                              SELECT 
                                    PickdetailKey = @c_PickDetailKey_New   
                                 ,  pw.CaseID         
                                 ,  pw.PickHeaderKey   
                                 ,  pw.OrderKey        
                                 ,  pw.OrderLineNumber 
                                 ,  pw.Lot            
                                 ,  pw.Storerkey      
                                 ,  pw.Sku             
                                 ,  pw.AltSku          
                                 ,  pw.UOM            
                                 ,  pw.UOMQty         
                                 ,  Qty = @n_QtyPick        
                                 ,  pw.QtyMoved        
                                 ,  pw.[Status]          
                                 ,  pw.DropID           
                                 ,  pw.Loc              
                                 ,  pw.ID              
                                 ,  pw.PackKey         
                                 ,  pw.UpdateSource     
                                 ,  pw.CartonGroup      
                                 ,  pw.CartonType        
                                 ,  pw.ToLoc          
                                 ,  pw.DoReplenish      
                                 ,  pw.ReplenishZone    
                                 ,  pw.DoCartonize      
                                 ,  pw.PickMethod       
                                 ,  WaveKey = @c_WaveKey         
                                 ,  pw.LoadKey         
                                 ,  pw.EffectiveDate    
                                 ,  OptimizeCop = '9'
                                 ,  pw.ShipFlag         
                                 ,  pw.PickSlipNo       
                                 ,  TaskDetailKey = ''   
                                 ,  pw.TaskManagerReasonKey  
                                 ,  Notes = 'Ref Pickdetailkey: ' + @c_PickdetailKey
                                          + ', Qty: ' + CONVERT(NVARCHAR(10), @n_QtyPick)        
                                 ,  pw.MoveRefKey    
                                 ,  pw.WIP_Refno        
                                 ,  pw.Channel_ID       
                              FROM #PICKDETAIL_WIP AS pw
                              WHERE pw.PickdetailKey = @c_PickdetailKey
                           END 
                        END

                        FETCH NEXT FROM @CUR_UPD INTO @c_PickdetailKey
                                                   ,  @n_QtyPick
                     END
                     CLOSE @CUR_UPD
                     DEALLOCATE @CUR_UPD
                  END
                  
                  IF @n_Continue = 1
                  BEGIN
                     IF @n_QtyToTake < @n_QtyToFill                         
                     BEGIN
                        SET @n_VolTotal = @n_QtyToTake * @n_Cube
                        SET @n_VolLeftToFill = @n_VolLeftToFill - @n_VolTotal
                     END
                     ELSE 
                     BEGIN
                        SET @n_VolTotal = 0.00
                        SET @n_VolLeftToFill = 0.00
                        SET @c_Groupkey  = ''
                     END
                  
                     SET @n_QtyLeftToFill = @n_QtyLeftToFill - @n_QtyToTake 
                     -- Exceptional Handling if qtytotake = 0 with infinity loop
                     IF @n_QtyToTake = 0                                               
                     BEGIN
                        SET @n_QtyLeftToFill = 0
                     END
                  END
               END                                                              
            END
         END

         IF @c_UOM = '1' AND @n_Continue IN (1,2)
         BEGIN   
            SET @c_Taskdetailkey = ''  
            SET @c_TaskType   = 'FPK'  
            SET @c_PickMethod = 'FP' 
            SET @c_GroupKey = @c_Wavekey
            SET @c_Priority_Area = ''
              
            SET @b_Success = 1    
            EXECUTE nspg_getkey   
                  @KeyName    = 'TaskDetailKey'             
               ,  @fieldlength= 10    
               ,  @keystring  = @c_Taskdetailkey   OUTPUT  
               ,  @b_Success  = @b_Success         OUTPUT  
               ,  @n_err      = @n_err             OUTPUT  
               ,  @c_errmsg   = @c_errmsg          OUTPUT  

            IF @b_Success <> 1    
            BEGIN    
               SET @n_Continue = 3    
            END  

            IF @n_Continue = 1
            BEGIN
               SET @c_Groupkey = @c_Taskdetailkey
               EXEC isp_InsertTaskDetail     
                   @c_Taskdetailkey         = @c_Taskdetailkey --OUTPUT  
                  ,@c_TaskType              = @c_TaskType               
                  ,@c_Storerkey             = @c_Storerkey  
                  ,@c_Sku                   = @c_Sku  
                  ,@c_Lot                   = @c_Lot   
                  ,@c_UOM                   = @c_UOM        
                  ,@n_UOMQty                = @n_UOMQty       
                  ,@n_Qty                   = @n_Qty        
                  ,@c_FromLoc               = @c_Fromloc        
                  ,@c_LogicalFromLoc        = @c_FromLoc   
                  ,@c_FromID                = @c_FromID       
                  ,@c_ToLoc                 = @c_ToLoc         
                  ,@c_LogicalToLoc          = @c_ToLoc   
                  ,@c_ToID                  = @c_ToID         
                  ,@c_PickMethod            = @c_PickMethod  
                  ,@c_Priority              = @c_Priority_Wave     
                  ,@c_SourcePriority        = '9'        
                  ,@c_SourceType            = @c_SourceType        
                  ,@c_SourceKey             = @c_Wavekey        
                  ,@c_OrderKey              = @c_Orderkey
                  ,@c_Wavekey               = @c_Wavekey  
                  ,@c_Message01             = '' 
                  ,@c_Message02             = ''                   
                  ,@c_Message03             = @c_Priority_Area  
                  ,@c_Loadkey               = @c_Loadkey                    
                  ,@c_AreaKey               = @c_AreaKey -- ?F=Get from location areakey   
                  ,@c_TransitLoc            = ''
                  ,@c_Groupkey              = @c_Groupkey 
                  ,@c_LinkTaskToPick        = 'WIP' -- WIP=Update taskdetailkey to pickdetail_wip  
                  ,@c_LinkTaskToPick_SQL    = @c_LinkTaskToPick_SQL    
                  ,@c_WIP_RefNo             = @c_SourceType  
                  ,@b_Success               = @b_Success OUTPUT  
                  ,@n_Err                   = @n_err OUTPUT   
                  ,@c_ErrMsg                = @c_errmsg OUTPUT          
                
               IF @b_Success <> 1   
               BEGIN  
                  SET @n_Continue = 3    
               END               
            END
         END  

         SET @c_UOM_P      = @c_UOM      
         SET @c_Areakey_P  = @c_Areakey
         SET @n_LocLevel_P = @n_LocLevel         
         SET @c_ToLoc_P    = @c_ToLoc
         SET @c_SectionKey_P= @c_SectionKey
 
         FETCH NEXT FROM @cur_FCP INTO @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_FromID
                                    ,  @c_UOM, @c_UCCNo, @n_Qty, @n_UOMQty
                                    ,  @c_Taskdetail_RPF 
                                    ,  @n_LocLevel 
                                    ,  @c_Areakey, @n_CubeUOM3 
      END  
      CLOSE @cur_FCP  
      DEALLOCATE @cur_FCP         
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'mspRLWAV13_FCP'
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
GRANT EXECUTE ON mspRLWAV13_FCP TO NSQL
GO
