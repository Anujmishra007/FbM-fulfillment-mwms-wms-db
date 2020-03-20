IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[ispRLWAV04]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[ispRLWAV04]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*************************************************************************/      
/* Stored Procedure: ispRLWAV04                                          */      
/* Creation Date: 11-Jan-2016                                            */      
/* Copyright: LF                                                         */      
/* Written by:                                                           */      
/*                                                                       */      
/* Purpose: SOS#358768 - Lulu HK Release Pick Task                       */      
/*                                                                       */      
/* Called By: wave                                                       */      
/*                                                                       */      
/* PVCS Version: 1.2                                                     */      
/*                                                                       */      
/* Version: 5.4                                                          */      
/*                                                                       */      
/* Data Modifications:                                                   */      
/*                                                                       */      
/* Updates:                                                              */      
/* Date         Author   Ver  Purposes                                   */  
/* 13-Aug-2016  TLTING01 1.1  Performance tune                           */ 
/* 19-Dec-2016  Wan01    1.2  WMS-821 - HKCPI - lulu- re-release TM Task */
/*                            after pickdetail re-allocate               */
/* 27-Feb-2017  TLTING   1.3  Variable Nvarchar                          */
/*************************************************************************/       

CREATE PROCEDURE [dbo].[ispRLWAV04]          
                 @c_wavekey      NVARCHAR(10)      
                ,@b_Success      int        OUTPUT      
                ,@n_err          int        OUTPUT      
                ,@c_errmsg       NVARCHAR(250)  OUTPUT      
AS      
BEGIN      
   SET NOCOUNT ON       
   SET QUOTED_IDENTIFIER OFF       
   SET ANSI_NULLS OFF       
   SET CONCAT_NULL_YIELDS_NULL OFF      
    
   DECLARE @n_continue int,        
           @n_starttcnt int,         -- Holds the current transaction count      
           @n_debug int,    
           @n_cnt int    
                
   SELECT @n_starttcnt=@@TRANCOUNT , @n_continue=1, @b_success=0,@n_err=0,@c_errmsg='',@n_cnt=0    
   SELECT @n_debug = 1    
    
   DECLARE @c_OrderType             NVARCHAR(10)    
         , @c_Orderkey              NVARCHAR(10)    
         , @c_Storerkey             NVARCHAR(15)    
         , @c_Consigneekey          NVARCHAR(15)    
         , @c_Sku                   NVARCHAR(20)    
         , @c_Lot                   NVARCHAR(10)    
         , @c_FromLoc               NVARCHAR(10)    
         , @c_ID                    NVARCHAR(18)    
         , @n_Qty                   INT        
         , @c_Areakey               NVARCHAR(10)    
         , @c_Facility              NVARCHAR(5)    
         , @c_Packkey               NVARCHAR(10)    
         , @c_UOM                   NVARCHAR(10)       
         , @c_Pickslipno            NVARCHAR(10)    
         , @c_Loadkey               NVARCHAR(10)    
         , @c_PickZone              NVARCHAR(10)        
         , @n_Pickqty               INT    
         , @n_ReplenQty             INT    
         , @c_Pickdetailkey         NVARCHAR(18)    
         , @c_Taskdetailkey         NVARCHAR(10)     
         , @c_TaskType              NVARCHAR(10)     
         , @c_PickMethod            NVARCHAR(10)    
         , @c_Toloc                 NVARCHAR(10)    
         , @c_SourceType            NVARCHAR(30)    
         , @c_Message03             NVARCHAR(20)    
         , @c_LogicalFromLoc        NVARCHAR(18)    
         , @c_LogicalToLoc          NVARCHAR(18)             
         , @c_Priority              NVARCHAR(10)       
         , @c_ListName              NVARCHAR(10)    
         , @c_TableColumnName       NVARCHAR(250)  
         , @c_SQLGroup              NVARCHAR(2000)   
         , @c_SQL                   NVARCHAR(4000)  
         , @n_Found                 INT     
         , @c_curPickdetailkey      NVARCHAR(10)   
         
         , @c_TaskStatus            NVARCHAR(10)                        --(Wan01)
         , @n_TaskShort             INT                                 --(Wan01)

   SET @c_Areakey         = ''    
   SET @c_Orderkey        = ''                  
   SET @c_Priority        = '9'                     
    
   WHILE @@TRANCOUNT > 0     
   BEGIN      
      COMMIT TRAN      
   END      

   -----Determine order type ECOM Or Retail-----    
   
   SELECT TOP 1 @c_Storerkey = OH.Storerkey  
               ,@c_OrderType = CASE WHEN OH.Type = 'LULUECOM' THEN 'ECOM' ELSE 'RETAIL' END    
               ,@c_Facility  = OH.Facility    
   FROM WAVEDETAIL WD WITH (NOLOCK)    
   JOIN ORDERS     OH WITH (NOLOCK) ON (WD.Orderkey = OH.Orderkey)    
   WHERE WD.Wavekey = @c_Wavekey     
       
   IF ISNULL(@c_wavekey,'') = ''      
   BEGIN      
      SET @n_continue = 3      
      SET @n_err = 81000      
      SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Invalid Parameters Passed (ispRLWAV04)'     
      GOTO RETURN_SP     
   END      
    
   -----Wave Validation-----    
   --(Wan01) - START            
   --IF EXISTS ( SELECT 1 FROM TASKDETAIL TD WITH (NOLOCK)     
   --            WHERE TD.Wavekey = @c_Wavekey    
   --            AND TD.Sourcetype IN('ispRLWAV04-RETAIL','ispRLWAV04-ECOM')    
   --            AND TD.Tasktype IN ('SPK', 'PK') )    
   --BEGIN    
   --   SET @n_continue = 3      
   --   SET @n_err = 81001      
   --  SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': This Wave has beed released. (ispRLWAV04)'      
   --   GOTO RETURN_SP         
   --END                   
   --(Wan01) - END 

   IF EXISTS ( SELECT 1         
               FROM WAVEDETAIL WD WITH (NOLOCK)        
               JOIN ORDERS O WITH (NOLOCK) ON WD.Orderkey = O.Orderkey        
               WHERE O.Status > '5'        
               AND WD.Wavekey = @c_Wavekey)        
   BEGIN        
      SET @n_continue = 3          
      SET @n_err = 81002          
      SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Release is not allowed. Some orders of this Wave are started picking (ispRLWAV04)'               
      GOTO RETURN_SP        
   END                   
    
   IF EXISTS ( SELECT 1    
               FROM WAVEDETAIL WD WITH (NOLOCK)    
               JOIN ORDERS     OH WITH (NOLOCK) ON (WD.Orderkey = OH.Orderkey)    
               WHERE WD.Wavekey = @c_Wavekey     
               GROUP BY WD.Wavekey    
               HAVING COUNT( DISTINCT CASE WHEN OH.Type = 'LULUECOM'  THEN 'ECOM' ELSE 'RETAIL' END ) > 1)    
   BEGIN    
      SET @n_continue = 3      
      SET @n_err = 81003      
      SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Release is not allowed. Mix order type in this Wave (ispRLWAV04)'           
      GOTO RETURN_SP    
   END     
  
   -- Make sure loadkey not exists in multiple wave
   /*
   IF EXISTS ( SELECT 1  
               FROM LoadPlanDetail LPD WITH (NOLOCK)   
               JOIN ORDERS O WITH (NOLOCK) ON O.OrderKey = LPD.OrderKey   
               WHERE EXISTS(SELECT 1 FROM WAVEDETAIL W WITH (NOLOCK)  
                            JOIN LoadplanDetail LPD2 WITH (NOLOCK) ON LPD2.OrderKey = W.OrderKey  
                            WHERE LPD2.LoadKey = LPD.LoadKey  
                              AND W.WaveKey = @c_Wavekey)  
               GROUP BY LPD.LoadKey   
               HAVING COUNT(DISTINCT O.UserDefine09) > 1 )  
   BEGIN    
      SET @n_continue = 3      
      SET @n_err = 81014     
      SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Release is not allowed. Found loadkey exists in multiple wave. (ispRLWAV04)'           
      GOTO RETURN_SP    
   END 
   */  
  
    -- Check unique loadplan group  
   SET @c_listname = ''  
   SELECT @c_listname = ISNULL(RTRIM(CODELIST.Listname),'')    
   FROM WAVE     WITH (NOLOCK)     
   JOIN CODELIST WITH (NOLOCK) ON WAVE.LoadPlanGroup = CODELIST.Listname AND CODELIST.ListGroup = 'WAVELPGROUP'    
   WHERE WAVE.Wavekey = @c_WaveKey    
  
   IF @c_listname <> ''  
   BEGIN  
      DECLARE CUR_CODELKUP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR    
      SELECT TOP 10  Long     
      FROM   CODELKUP WITH (NOLOCK)    
      WHERE  ListName = @c_ListName    
      ORDER BY Code    
         
      OPEN CUR_CODELKUP    
         
      FETCH NEXT FROM CUR_CODELKUP INTO @c_TableColumnName    
         
      SET @c_SQLGroup = ''  
      WHILE @@FETCH_STATUS <> -1    
      BEGIN    
         SET @c_SQLGroup = @c_SQLGroup + @c_TableColumnName + ', '           
         FETCH NEXT FROM CUR_CODELKUP INTO @c_TableColumnName    
      END     
      CLOSE CUR_CODELKUP    
      DEALLOCATE CUR_CODELKUP     
         
      IF RIGHT(@c_SQLGroup,2) = ', '  
      BEGIN  
         SET @c_SQLGroup = SUBSTRING(@c_SQLGroup,1 ,LEN(@c_SQLGroup) - 1)  
      END  
  
      IF LEN(@c_SQLGroup) > 0  
      BEGIN  
         SET @n_Found = 0  
         SET @c_SQL = ' SELECT @n_Found = 1'    
                    + ' FROM  WAVEDETAIL WITH (NOLOCK)'    
                    + ' JOIN ORDERS WITH (NOLOCK) ON (WAVEDETAIL.Orderkey = ORDERS.Orderkey)'   
                    + ' WHERE WAVEDETAIL.Wavekey = @c_Wavekey'   
                    + ' GROUP BY ' + @c_SQLGroup   
                    + ' HAVING COUNT(DISTINCT ORDERS.Loadkey) > 1'    
  
            
         EXEC sp_executesql @c_SQL     
                          , N' @c_Wavekey NVARCHAR(10), @n_Found INT OUTPUT'      
                          , @c_Wavekey                          
                          , @n_Found OUTPUT   
  
         IF @n_Found = 1  
         BEGIN    
            SET @n_continue = 3      
            SET @n_err = 81019      
            SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Release is not allowed. Different Loadkey with same Loadplan group Found. (ispRLWAV04)'           
            GOTO RETURN_SP    
         END    
      END  
   END       
  
   BEGIN TRAN      
    
   --Remove taskdetailkey and add wavekey from pickdetail of the wave        
   IF @n_continue = 1 OR @n_continue = 2    
   BEGIN    
      -- tlting01
      SET @c_curPickdetailkey = ''
      DECLARE Orders_Pickdet_cur CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
		   SELECT Pickdetailkey 
               ,TaskDetailKey = ISNULL(RTRIM(TaskDetailKey),'')         --(Wan01)         
         FROM WAVEDETAIL WITH (NOLOCK)      
         JOIN PICKDETAIL WITH (NOLOCK) ON WAVEDETAIL.Orderkey = PICKDETAIL.Orderkey    
         WHERE WAVEDETAIL.Wavekey = @c_Wavekey   
         AND PICKDETAIL.Status = '0'                                    --(Wan01)

	   OPEN Orders_Pickdet_cur 
	   FETCH NEXT FROM Orders_Pickdet_cur INTO @c_curPickdetailkey
                                             ,@c_TaskDetailKey          --(Wan01)
	   WHILE @@FETCH_STATUS = 0  
	   BEGIN 
         --(Wan01) - START
         IF @c_TaskDetailKey <> ''
         BEGIN
            SET @n_cnt = 0
            SET @c_TaskStatus = ''
            SET @n_TaskShort  = 0
            SELECT @n_cnt = 1
               ,   @c_TaskStatus = Status
               ,   @n_TaskShort  = CASE WHEN SystemQty > Qty THEN 1 ELSE 0 END
            FROM TASKDETAIL WITH (NOLOCK)
            WHERE TaskDetailKey = @c_TaskDetailKey

            IF @n_cnt = 0 OR (@c_TaskStatus = '9' AND @n_TaskShort  = 1)
            BEGIN
               SET @c_TaskDetailKey = ''                     -- PickDETAIL.Taskdetailkey not found or TASKDETAIL.Status = '9'
            END 
         END
         --(Wan01) - END
        
         UPDATE PICKDETAIL WITH (ROWLOCK)     
            SET --PICKDETAIL.TaskdetailKey = ''             --(Wan01)
              PICKDETAIL.TaskDetailKey = @c_TaskDetailKey   --(Wan01)    
            , PICKDETAIL.Wavekey = @c_Wavekey      
            , EditWho    = SUSER_SNAME()    
            , EditDate   = GETDATE()    
            , TrafficCop = NULL     
            WHERE PICKDETAIL.Pickdetailkey = @c_curPickdetailkey 
         SET @n_err = @@ERROR    
         IF @n_err <> 0     
         BEGIN    
	         CLOSE Orders_Pickdet_cur 
	         DEALLOCATE Orders_Pickdet_cur
            SET @n_continue = 3      
            SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)    
            SET @n_err = 81004   -- Should Be Set To The SQL Errmessage but I don't know how to do so.      
            SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Pickdetail Table Failed. (ispRLWAV04)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '      
            GOTO RETURN_SP    
         END     
         
         NEXT_REC:                                                      --(Wan01)  	
		   FETCH NEXT FROM Orders_Pickdet_cur INTO @c_curPickdetailkey
                                               , @c_TaskDetailKey       --(Wan01)
	   END
	   CLOSE Orders_Pickdet_cur 
	   DEALLOCATE Orders_Pickdet_cur
   END    
   SET @c_TaskDetailKey = ''                                            --(Wan01)
        
   --Create Temporary Tables   
   IF (@n_continue = 1 OR @n_continue = 2)  AND @c_OrderType = 'ECOM'  
   BEGIN    
      CREATE TABLE  #Orders (  
          RowRef    BIGINT IDENTITY(1,1) Primary Key,  
          OrderKey  NVARCHAR(10)  
         ,SKUCount  INT  
         ,TotalPick INT  
         )                                                   
   END   

   -----Retail Order Initialization and Validation-----     
    
   IF (@n_continue = 1 OR @n_continue = 2) AND @c_OrderType = 'RETAIL'    
   BEGIN         
      -----Generate RETAIL Order Tasks-----    
      IF (@n_continue = 1 OR @n_continue = 2)      
      BEGIN    
         DECLARE cur_Retail CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      
         SELECT PD.Storerkey     
              , PD.Sku     
              , PD.Lot     
              , PD.Loc     
              , PD.ID     
              , SUM(PD.Qty)                              
              --, CASE WHEN OH.TYPE ='LULUSTOR' 
              --       THEN 'STOTE'  
              --       ELSE 'PP' END AS PickMethod     
              , 'PP' AS PickMethod
              , SKU.Packkey    
              , MIN(PD.UOM)    
              , PD.Orderkey 
              , OH.Consigneekey 
         FROM WAVEDETAIL  WD          WITH (NOLOCK)    
         JOIN ORDERS      OH          WITH (NOLOCK) ON WD.Orderkey = OH.Orderkey    
         JOIN ORDERDETAIL OD          WITH (NOLOCK) ON OH.Orderkey = OD.Orderkey    
         JOIN PICKDETAIL  PD          WITH (NOLOCK) ON OD.Orderkey = PD.Orderkey AND OD.OrderLineNumber = PD.OrderLineNumber    
         JOIN LOC                     WITH (NOLOCK) ON PD.Loc = LOC.Loc    
         JOIN SKU                     WITH (NOLOCK) ON PD.Storerkey = SKU.Storerkey AND PD.Sku = SKU.Sku    
         WHERE WD.Wavekey = @c_Wavekey 
         AND PD.Status = '0'                                         --(Wan01)  
         AND ISNULL(PD.TaskDetailKey,'') = ''                        --(Wan01)               
         GROUP BY PD.Storerkey     
                , PD.Sku      
                , PD.Lot     
                , PD.Loc     
                , PD.Id   
                --, CASE WHEN OH.TYPE ='LULUSTOR' 
                --     THEN 'STOTE'  
                --     ELSE 'PP' END      
                , SKU.Packkey    
                , PD.Orderkey
                , OH.Consigneekey
         ORDER BY PD.Storerkey, PD.Sku                              
    
         OPEN cur_Retail      
         FETCH NEXT FROM cur_Retail INTO @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_ID, @n_Qty, @c_PickMethod, @c_Packkey, @c_UOM, @c_Orderkey, @c_Consigneekey
    
         SET @c_SourceType = 'ispRLWAV04-RETAIL'        
         SET @c_ToLoc = ''          
         SET @c_LogicalToLoc = ''      
         SET @c_Priority  = '5'                       
         SET @c_Tasktype = 'SPK'

         -- Create Replenishment tasks    
         WHILE @@FETCH_STATUS = 0     
         BEGIN     
            SET @c_Message03 = @c_Orderkey
            
            GOTO RELEASE_PK_TASKS    
            RETAIL:    
      
            FETCH NEXT FROM cur_Retail INTO @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_ID, @n_Qty, @c_PickMethod, @c_Packkey, @c_UOM, @c_Orderkey, @c_Consigneekey
         END    
         CLOSE cur_Retail    
         DEALLOCATE cur_Retail    
      END
   END    
  
   -----Generate ECOM Order Tasks-----   
   IF (@n_continue = 1 OR @n_continue = 2) AND @c_OrderType = 'ECOM'    
   BEGIN    
      INSERT INTO #ORDERS (PD.Orderkey, SkuCount, TotalPick)  
      SELECT PD.Orderkey  
            ,SkuCount = Count(DISTINCT PD.Sku)  
            ,TotalPick= SUM(PD.Qty)  
      FROM WAVEDETAIL WD WITH (NOLOCK)  
      JOIN ORDERS     OH WITH (NOLOCK) ON (WD.Orderkey = OH.Orderkey)  
      JOIN PICKDETAIL PD WITH (NOLOCK) ON (OH.Orderkey = PD.Orderkey)  
      WHERE WD.Wavekey  = @c_Wavekey  
      AND   OH.Type= 'LULUECOM'  
      GROUP BY PD.Orderkey  
  
      -- Retrieve SINGLES & MULTI  
      DECLARE CUR_ECOM CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      
      SELECT PD.Storerkey     
           , PD.Sku     
           , PD.Lot     
           , PD.Loc     
           , PD.ID     
           , SUM(PD.Qty)                              
           , CASE WHEN TMP.SKUCount = 1 AND TMP.TotalPick = 1 THEN 'SINGLES' ELSE 'MULTIS' END 
           , Orderkey = CASE WHEN TMP.SKUCount = 1 AND TMP.TotalPick = 1 THEN '' ELSE PD.Orderkey END  
      FROM #ORDERS TMP  
      JOIN PICKDETAIL PD  WITH (NOLOCK) ON (TMP.Orderkey = PD.Orderkey)  
      JOIN LOC        LOC WITH (NOLOCK) ON (PD.Loc = LOC.Loc)  
      WHERE PD.Status = '0'  
      AND ISNULL(PD.TaskDetailKey,'') = ''                              --(Wan01) 
      --AND  LOC.LocationType = 'DYNPPICK'          
      GROUP BY CASE WHEN TMP.SKUCount = 1 AND TMP.TotalPick = 1 THEN '' ELSE PD.Orderkey END
              , PD.Storerkey     
              , PD.Sku     
              , PD.Lot     
              , PD.Loc     
              , PD.ID     
              , CASE WHEN TMP.SKUCount = 1 AND TMP.TotalPick = 1 THEN 'SINGLES' ELSE 'MULTIS' END    
      ORDER BY 7, Orderkey  
            ,  PD.Loc   
            ,  PD.Sku  
                
      OPEN CUR_ECOM      
      FETCH NEXT FROM CUR_ECOM INTO @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_ID, @n_Qty   
                                  , @c_PickMethod, @c_Orderkey   
    
      SET @c_SourceType = 'ispRLWAV04-ECOM'        
      WHILE @@FETCH_STATUS = 0      
      BEGIN        
         SET @c_tasktype = 'PK'    
         SET @c_ToLoc = ''          
         SET @c_LogicalToLoc = ''      
         SET @c_UOM = ''  
         IF @c_PickMethod = 'MULTIS'
         BEGIN
            SET @c_Message03 = @c_Orderkey
            SET @c_Priority = '5'
         END
         ELSE
         BEGIN
            SET @c_Message03 = @c_Wavekey
            SET @c_Priority = '4'
         END
            
         GOTO RELEASE_PK_TASKS    
         ECOM:   
         FETCH NEXT FROM CUR_ECOM INTO @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_ID, @n_Qty   
                                     , @c_PickMethod, @c_Orderkey              
      END --Fetch    
      CLOSE CUR_ECOM      
      DEALLOCATE CUR_ECOM                                     
    
   END    

   -----Generate Pickslip No-------    
    
   IF @n_continue = 1 or @n_continue = 2      
   BEGIN    
      DECLARE CUR_PS CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      
      SELECT DISTINCT     
          OrderKey = LPD.Orderkey 
         ,LoadKey  = LPD.LoadKey 
      FROM WAVEDETAIL      WD  WITH (NOLOCK)     
      JOIN LOADPLANDETAIL  LPD WITH (NOLOCK) ON (WD.Orderkey = LPD.Orderkey)    
      WHERE  WD.Wavekey = @c_wavekey       
    
      OPEN CUR_PS      
    
      FETCH NEXT FROM CUR_PS INTO @c_Orderkey, @c_LoadKey           
    
      WHILE @@FETCH_STATUS <> -1      
      BEGIN      
         SET @c_PickZone = CASE WHEN @c_OrderKey = '' THEN 'LP' ELSE '8' END    
    
         SET @c_PickSlipno = ''          
         SELECT @c_PickSlipno = PickheaderKey      
         FROM   PICKHEADER (NOLOCK)      
         WHERE  Wavekey  = @c_Wavekey    
         AND    OrderKey = @c_OrderKey    
         AND    ExternOrderKey = @c_LoadKey    
         AND    Zone =  @c_PickZone               
    
         -- Create Pickheader          
         IF ISNULL(@c_PickSlipno, '') = ''      
         BEGIN      
            EXECUTE nspg_GetKey       
               'PICKSLIP'    
            ,  9    
            ,  @c_Pickslipno OUTPUT    
            ,  @b_Success    OUTPUT    
            ,  @n_err        OUTPUT    
            ,  @c_errmsg     OUTPUT          
                 
            SET @c_Pickslipno = 'P' + @c_Pickslipno          
                         
            INSERT INTO PICKHEADER      
                     (  PickHeaderKey    
                     ,  Wavekey    
                     ,  Orderkey    
                     ,  ExternOrderkey    
                     ,  Loadkey    
                     ,  PickType    
                     ,  Zone    
                     ,  TrafficCop    
                     )      
            VALUES      
                     (  @c_Pickslipno    
                     ,  @c_Wavekey    
                     ,  @c_OrderKey    
                     ,  @c_Loadkey    
                     ,  @c_Loadkey    
                     ,  '0'     
                     ,  @c_PickZone    
                     ,  ''    
                     )          
    
            SET @n_err = @@ERROR      
            IF @n_err <> 0      
            BEGIN      
               SET @n_continue = 3      
               SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)    
               SET @n_err = 81008  -- Should Be Set To The SQL Errmessage but I don't know how to do so.      
               SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert PICKHEADER Failed (ispRLWAV04)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '      
            END      
         END  

         -- IF print from Wave Pickslip, and later release wave, need to make sure refkeylookup record  
         -- is sync with pickdetail record, hence delete and regenerate refkeylookup again  
         IF EXISTS (SELECT 1 FROM REFKEYLOOKUP WITH (NOLOCK)       
                    WHERE PickSlipNo = @c_PickSlipNo    
                    AND   Loadkey    = @c_Loadkey)  
            AND @c_Orderkey = ''                     
         BEGIN     
            DELETE FROM REFKEYLOOKUP WITH (ROWLOCK)  
            WHERE PickSlipNo = @c_PickSlipNo    
            AND   Loadkey    = @c_Loadkey  
  
            SET @n_err = @@ERROR      
            IF @n_err <> 0      
            BEGIN      
               SET @n_continue = 3      
               SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)    
               SET @n_err = 81017 -- Should Be Set To The SQL Errmessage but I don't know how to do so.      
               SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': DELETE REFKEYLOOKUP Failed (ispRLWAV04)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '        
            END    
         END     
  
        -- tlting01
        SET @c_curPickdetailkey = ''

         IF @c_Orderkey <> ''    
         BEGIN    
            DECLARE Orders_Pickdet_cur CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
		         SELECT Pickdetailkey          
               FROM PICKDETAIL WITH (NOLOCK)       
               WHERE  OrderKey = @c_OrderKey   
         END    
         ELSE    
         BEGIN   
		      SELECT PD.Pickdetailkey          
            FROM ORDERS     OH WITH (NOLOCK)    
            JOIN PICKDETAIL PD WITH (NOLOCK) ON (OH.Orderkey = PD.Orderkey)      
            WHERE  OH.Loadkey = @c_Loadkey   
         END   

	      OPEN Orders_Pickdet_cur 
	      FETCH NEXT FROM Orders_Pickdet_cur INTO @c_curPickdetailkey 
	      WHILE @@FETCH_STATUS = 0 AND (@n_continue = 1 or @n_continue = 2)
	      BEGIN 
               UPDATE PICKDETAIL WITH (ROWLOCK)      
               SET  PickSlipNo = @c_PickSlipNo     
                   ,EditWho = SUSER_SNAME()    
                   ,EditDate= GETDATE()     
                   ,TrafficCop = NULL     
               WHERE PICKDETAIL.Pickdetailkey = @c_curPickdetailkey 
               SET @n_err = @@ERROR    
               IF @n_err <> 0     
               BEGIN    
	               CLOSE Orders_Pickdet_cur 
	               DEALLOCATE Orders_Pickdet_cur
                  SET @n_continue = 3      
                  SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)    
                  SET @n_err = 81009 -- Should Be Set To The SQL Errmessage but I don't know how to do so.      
                  SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': UPDATE Pickdetail Failed (ispRLWAV04)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '      
               END       	
		      FETCH NEXT FROM Orders_Pickdet_cur INTO @c_curPickdetailkey
	      END
	      CLOSE Orders_Pickdet_cur 
	      DEALLOCATE Orders_Pickdet_cur             
    
         IF NOT EXISTS (SELECT 1 FROM REFKEYLOOKUP WITH (NOLOCK)       
                        WHERE PickSlipNo = @c_PickSlipNo    
                        AND   Loadkey    = @c_Loadkey)   
            AND @c_OrderKey = ''                    
         BEGIN     
            INSERT INTO REFKEYLOOKUP       
                     (  PickDetailkey      
                     ,  Orderkey      
                     ,  OrderLineNumber      
                     ,  Loadkey      
                     ,  PickSlipNo      
                     )       
            SELECT   PD.PickDetailKey      
                  ,  PD.Orderkey      
                  ,  PD.OrderLineNumber      
                  ,  @c_Loadkey      
                  ,  @c_PickSlipNo       
            FROM ORDERS     OH WITH (NOLOCK)    
            JOIN PICKDETAIL PD WITH (NOLOCK) ON (OH.Orderkey = PD.Orderkey)      
            WHERE  OH.Loadkey = @c_Loadkey    
    
            SET @n_err = @@ERROR      
            IF @n_err <> 0      
            BEGIN      
               SET @n_continue = 3      
               SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)    
               SET @n_err = 81010 -- Should Be Set To The SQL Errmessage but I don't know how to do so.      
               SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert REFKEYLOOKUP Failed (ispRLWAV04)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '        
            END    
         END    
               
         IF NOT EXISTS (SELECT 1 FROM PICKINGINFO WITH (NOLOCK)       
                        WHERE PickSlipNo = @c_PickSlipNo)    
         BEGIN    
            INSERT INTO PICKINGINFO (PickSlipNo, ScanIndate, PickerID)    
            VALUES (@c_PickSlipNo, GETDATE(), SUSER_SNAME())    
    
            SET @n_err = @@ERROR      
            IF @n_err <> 0      
            BEGIN   
               SET @n_continue = 3      
               SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)    
               SET @n_err = 81011 -- Should Be Set To The SQL Errmessage but I don't know how to do so.      
               SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert PICKINGINFO Failed (ispRLWAV04)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '        
            END  
         END    
    
         FETCH NEXT FROM CUR_PS INTO @c_Orderkey, @c_LoadKey           
      END       
      CLOSE CUR_PS      
      DEALLOCATE CUR_PS     
   END    
    
   -----Update Wave Status-----    
   IF @n_continue = 1 or @n_continue = 2      
   BEGIN      
      UPDATE WAVE WITH (ROWLOCK)    
       SET STATUS = '1' -- Released     
         , EditWho = SUSER_SNAME()    
         , EditDate= GETDATE()     
      WHERE WAVEKEY = @c_wavekey      
    
      SET @n_err = @@ERROR      
      IF @n_err <> 0      
      BEGIN      
        SET @n_continue = 3      
         SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)    
         SET @n_err = 81012   -- Should Be Set To The SQL Errmessage but I don't know how to do so.      
         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update on wave Failed (ispRLWAV04)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '      
      END      
   END      
  
   -- Make sure all pickdetail have taskdetailkey stamped (Chee01)  
   IF EXISTS ( SELECT 1   
               FROM WAVEDETAIL WD  WITH (NOLOCK)     
               JOIN PICKDETAIL PD  WITH (NOLOCK) ON (WD.Orderkey = PD.Orderkey)    
               WHERE WD.Wavekey = @c_Wavekey   
                 AND PD.Status < '5'                                    --(Wan01)
                 AND ISNULL(PD.Taskdetailkey,'') = ''    
                 AND PD.Storerkey = @c_Storerkey )    
   BEGIN    
      SET @n_continue = 3      
      SET @n_err = 81018  
      SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': TaskDetailkey not updated to pickdetail. (ispRLWAV04)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '         
      GOTO RETURN_SP    
   END   
    
   RETURN_SP:    
    
   WHILE @@TRANCOUNT < @n_starttcnt    
   BEGIN      
      BEGIN TRAN      
   END      
    
   IF @n_continue=3  -- Error Occured - Process And Return      
   BEGIN      
      SET @b_success = 0      
    
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt      
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
      execute nsp_logerror @n_err, @c_errmsg, 'ispRLWAV04'      
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012    
      RETURN      
   END      
   ELSE      
   BEGIN      
      SET @b_success = 1      
      WHILE @@TRANCOUNT > @n_starttcnt      
      BEGIN      
         COMMIT TRAN      
      END      
      RETURN      
   END    
    
   RELEASE_PK_TASKS:    
       
   --function to insert taskdetail    
   IF (@n_continue = 1 or @n_continue = 2)     
   BEGIN   
      SET @c_LogicalFromLoc = ''  
      SELECT TOP 1 @c_AreaKey = AreaKey    
                 , @c_LogicalFromLoc = ISNULL(RTRIM(LogicalLocation),'')    
      FROM LOC        LOC WITH (NOLOCK)    
      JOIN AREADETAIL ARD WITH (NOLOCK) ON (LOC.PutawayZone = ARD.PutawayZone)    
      WHERE LOC.Loc = @c_FromLoc     
    
      SET @c_LoadKey = ''  
      SELECT Top 1 @c_LoadKey = O.LoadKey   
      FROM dbo.PickDetail PD WITH (NOLOCK)  
      INNER JOIN dbo.Orders O WITH (NOLOCK)  ON O.OrderKEy = PD.OrderKey   
      WHERE PD.WaveKey = @c_WaveKey  
      AND PD.Status = '0'  
      AND PD.SKU = @c_SKU  
      AND PD.Lot = @c_Lot  
      AND PD.Loc = @c_FromLoc  
      AND PD.ID  = @c_ID  
      
      IF ISNULL(@c_Message03,'') = ''
      BEGIN
         SET @n_continue = 3      
         SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)    
         SET @n_err = 81013   -- Should Be Set To The SQL Errmessage but I don't know how to do so.      
         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Empty Message03 is not allowed. (ispRLWAV04)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '               
         GOTO RETURN_SP    
      END

      IF ISNULL(@c_Areakey,'') = ''
      BEGIN
         SET @n_continue = 3      
         SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)    
         SET @n_err = 81014   -- Should Be Set To The SQL Errmessage but I don't know how to do so.      
         SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Empty Areakey is not allowed. (ispRLWAV04)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '               
         GOTO RETURN_SP    
      END
              
      SET @b_success = 1      
      EXECUTE   nspg_getkey      
               'TaskDetailKey'      
              , 10      
              , @c_taskdetailkey OUTPUT      
              , @b_success       OUTPUT      
              , @n_err           OUTPUT      
              , @c_errmsg        OUTPUT      
      IF NOT @b_success = 1      
      BEGIN      
         SET @n_continue = 3      
         GOTO RETURN_SP    
      END      

      IF @b_success = 1      
      BEGIN        
         INSERT TASKDETAIL      
         (      
         TaskDetailKey      
         ,TaskType      
         ,Storerkey      
         ,Sku      
         ,UOM      
         ,UOMQty      
         ,Qty      
         ,SystemQty    
         ,Lot      
         ,FromLoc      
         ,FromID      
         ,ToLoc      
         ,ToID      
         ,SourceType      
         ,SourceKey      
         ,Priority      
         ,SourcePriority      
         ,Status      
         ,LogicalFromLoc      
         ,LogicalToLoc      
         ,PickMethod    
         ,Wavekey    
         ,Listkey      
         ,Areakey    
         ,Message03   
         ,CaseID 
         ,LoadKey    
         ,OrderKey 
         )      
         VALUES      
         (      
         @c_taskdetailkey      
         ,@c_TaskType --Tasktype      
         ,@c_Storerkey      
         ,@c_Sku      
         ,@c_UOM -- UOM,      
         ,0  -- UOMQty,      
         ,@n_Qty      
         ,@n_Qty  --systemqty    
         ,@c_Lot       
         ,@c_fromloc       
         ,@c_ID -- from id      
         ,@c_toloc     
         ,@c_ID -- to id      
         ,@c_SourceType --Sourcetype      
         ,@c_Wavekey    --Sourcekey      
         ,@c_Priority   -- Priority        
         ,'9' -- Sourcepriority      
         ,'N' -- Status      
         ,@c_LogicalFromLoc --Logical from loc      
         ,@c_LogicalToLoc   --Logical to loc      
         ,@c_PickMethod    
         ,@c_Wavekey    
         ,''    
         ,@c_Areakey    
         ,@c_Message03  
         ,'' -- caseid
         ,@c_LoadKey  
         ,@c_Orderkey                                             
         )    
    
         SET @n_err = @@ERROR     
    
         IF @n_err <> 0      
         BEGIN    
    
            SET @n_continue = 3      
            SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)    
            SET @n_err = 81015   -- Should Be Set To The SQL Errmessage but I don't know how to do so.      
            SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insert Taskdetail Failed. (ispRLWAV04)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '      
    
            GOTO RETURN_SP    
         END       
      END    
   END    
    
   --Update taskdetailkey/wavekey to pickdetail    
   IF @n_continue = 1 OR @n_continue = 2    
   BEGIN
      SET @n_ReplenQty = @n_Qty 

      DECLARE CUR_PICKD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR     
      SELECT PD.PickdetailKey    
            ,PD.Qty    
      FROM WAVEDETAIL WD  WITH (NOLOCK)     
      JOIN PICKDETAIL PD  WITH (NOLOCK) ON (WD.Orderkey = PD.Orderkey)    
      JOIN ORDERDETAIL OD WITH (NOLOCK) ON (PD.Orderkey = OD.Orderkey) AND (PD.OrderLineNumber = OD.OrderLineNumber)    
      WHERE WD.Wavekey = @c_Wavekey    
      AND PD.Status = '0'
      AND ISNULL(PD.Taskdetailkey,'') = ''    
      AND PD.Storerkey = @c_Storerkey    
      AND PD.Sku = @c_sku    
      AND PD.Lot = @c_Lot    
      AND PD.Loc = @c_FromLoc    
      AND PD.ID  = @c_ID    
      AND PD.Orderkey = CASE WHEN ISNULL(@c_Orderkey,'') <> '' THEN @c_Orderkey ELSE PD.Orderkey END
      ORDER BY PD.PickDetailKey     
    
      OPEN CUR_PICKD      
    
      FETCH NEXT FROM CUR_PICKD INTO @c_PickdetailKey    
                                    ,@n_PickQty    
         
      WHILE @@FETCH_STATUS <> -1 AND @n_ReplenQty > 0     
      BEGIN    
    
         UPDATE PICKDETAIL WITH (ROWLOCK)    
         SET Taskdetailkey = @c_TaskdetailKey    
            ,EditWho = SUSER_SNAME()    
            ,EditDate= GETDATE()     
            ,TrafficCop = NULL    
         WHERE Pickdetailkey = @c_PickdetailKey    
    
         SET @n_err = @@ERROR    
         IF @n_err <> 0     
         BEGIN    
            SET @n_continue = 3    
            SET @c_errmsg = CONVERT(NVARCHAR(250),@n_err)    
            SET @n_err = 81016      
            SET @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Pickdetail Table Failed. (ispRLWAV04)' + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '    
            BREAK    
         END     
                   
         SET @n_ReplenQty = @n_ReplenQty - @n_PickQty     
         NEXT_PD:              
         FETCH NEXT FROM CUR_PICKD INTO @c_PickdetailKey    
                                       ,@n_PickQty    
      END    
      CLOSE CUR_PICKD    
      DEALLOCATE CUR_PICKD    
   END  
     
   IF @c_OrderType = 'ECOM'       
      GOTO ECOM                  
   IF @c_OrderType = 'RETAIL'    
      GOTO RETAIL    
    
END --sp end
GO
GRANT EXECUTE ON [dbo].[ispRLWAV04] TO nSQL 
GO
