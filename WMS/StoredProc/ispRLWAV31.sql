if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ispRLWAV31]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ispRLWAV31]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/****************************************************************************/  
/* Stored Procedure: ispRLWAV31                                             */  
/* Creation Date: 30-OCT-2019                                               */  
/* Copyright: LFL                                                           */  
/* Written by:                                                              */  
/*                                                                          */  
/* Purpose: WMS-10647 - CN PVH QHW Release Wave update batch to pick        */
/*                                                                          */  
/* Called By: wave                                                          */  
/*                                                                          */  
/* PVCS Version: 1.0                                                        */  
/*                                                                          */  
/* Version: 7.0                                                             */  
/*                                                                          */  
/* Data Modifications:                                                      */  
/*                                                                          */  
/* Updates:                                                                 */  
/* Date         Author   Ver  Purposes                                      */  
/****************************************************************************/   

CREATE PROCEDURE [dbo].[ispRLWAV31]      
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
            
    SELECT  @n_starttcnt=@@TRANCOUNT , @n_continue=1, @b_success=0,@n_err=0,@c_errmsg='',@n_cnt=0
    SELECT  @n_debug = 0

    DECLARE  @c_Storerkey NVARCHAR(15)
            ,@c_Facility NVARCHAR(5)
            ,@c_SourceType NVARCHAR(30)
            ,@c_PickDetailKey NVARCHAR(10)            
            ,@c_OrderGroup NVARCHAR(10)
            ,@c_Short_group NVARCHAR(10)
                              
    SET @c_SourceType = 'ispRLWAV31'    

    -----Wave Validation-----                  
    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
        IF EXISTS (SELECT 1 
                   FROM WAVEDETAIL WD (NOLOCK)
                   JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey            
                   JOIN PICKDETAIL PD (NOLOCK) ON O.Orderkey = PD.Orderkey       
                   WHERE WD.Wavekey = @c_Wavekey    
                   AND ISNULL(PD.notes,'') <> ''
                   ) 
        BEGIN
          SELECT @n_continue = 3  
          SELECT @n_err = 83010    
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': This Wave has beed released. (ispRLWAV31)'       
        END                 
    END

    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
       IF EXISTS (SELECT 1 
                  FROM WAVEDETAIL WD (NOLOCK)
                  JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
                  WHERE WD.Wavekey = @c_Wavekey
                  AND (O.Loadkey = '' OR O.loadkey IS NULL))
       BEGIN
          SELECT @n_continue = 3  
          SELECT @n_err = 83020    
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Not allow to release. Found some order without load planning yet. (ispRLWAV31)'       
       END
    END   
    
    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
       IF EXISTS (SELECT 1 
                  FROM WAVEDETAIL WD (NOLOCK)
                  JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
                  WHERE WD.Wavekey = @c_Wavekey
                  AND O.Status = '0')
       BEGIN
          SELECT @n_continue = 3  
          SELECT @n_err = 83030    
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Not allow to release. Found some order in the wave is not allocated yet. (ispRLWAV31)'       
       END
    END   

    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
       IF EXISTS (SELECT 1 
                  FROM WAVEDETAIL WD (NOLOCK)
                  JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
                  JOIN ORDERDETAIL OD (NOLOCK) ON O.Orderkey = OD.Orderkey
                  JOIN SKU (NOLOCK) ON OD.Storerkey = SKU.Storerkey AND OD.Sku = SKU.Sku
                  LEFT JOIN CODELKUP CL (NOLOCK) ON SKU.Storerkey = CL.Storerkey AND SUBSTRING(SKU.Busr2,15,4) = CL.Code AND CL.Listname = 'PVHITEMGRP'
                  WHERE WD.Wavekey = @c_Wavekey
                  AND CL.Code IS NULL)
       BEGIN
          SELECT @n_continue = 3  
          SELECT @n_err = 83040    
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Not allow to release. Found some sku product group not setup at PVHITEMGRP. (ispRLWAV31)'       
       END
    END   
 
     IF @n_continue = 1 OR @n_continue = 2
    BEGIN
       IF EXISTS (SELECT 1 
                  FROM WAVEDETAIL WD (NOLOCK)
                  JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
                  JOIN STORER S (NOLOCK) ON S.Storerkey = 'PVH-' + O.Billtokey AND S.Consigneefor = O.Storerkey
                  LEFT JOIN CODELKUP CL (NOLOCK) ON S.ISOCntryCode = CL.Code AND CL.Storerkey = O.Storerkey AND CL.Listname = 'PVHCOUNTRY'
                  WHERE WD.Wavekey = @c_Wavekey
                  AND CL.Code IS NULL)
       BEGIN
          SELECT @n_continue = 3  
          SELECT @n_err = 83050    
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Not allow to release. Found some country not setup in PVHCOUNTRY. (ispRLWAV31)'       
       END
    END   
   
    -----Get Storerkey, facility
    IF  (@n_continue = 1 OR @n_continue = 2)
    BEGIN
        SELECT TOP 1 @c_Storerkey = O.Storerkey, 
                     @c_Facility = O.Facility,
                     @c_OrderGroup = CL.Code
        FROM WAVE W (NOLOCK)
        JOIN WAVEDETAIL WD(NOLOCK) ON W.Wavekey = WD.Wavekey
        JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
        JOIN CODELKUP CL (NOLOCK) ON O.OrderGroup = CL.Code AND O.Storerkey = CL.Storerkey AND ListName = 'ORDERGROUP'
        AND W.Wavekey = @c_Wavekey 
    END
            
    --Create pickdetail Work in progress temporary table
    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
       CREATE TABLE #PickDetail_WIP(
          [PickDetailKey] [nvarchar](18) NOT NULL PRIMARY KEY,
          [CaseID] [nvarchar](20) NOT NULL DEFAULT (' '),
          [PickHeaderKey] [nvarchar](18) NOT NULL,
          [OrderKey] [nvarchar](10) NOT NULL,
          [OrderLineNumber] [nvarchar](5) NOT NULL,
          [Lot] [nvarchar](10) NOT NULL,
          [Storerkey] [nvarchar](15) NOT NULL,
          [Sku] [nvarchar](20) NOT NULL,
          [AltSku] [nvarchar](20) NOT NULL DEFAULT (' '),
          [UOM] [nvarchar](10) NOT NULL DEFAULT (' '),
          [UOMQty] [int] NOT NULL DEFAULT ((0)),
          [Qty] [int] NOT NULL DEFAULT ((0)),
          [QtyMoved] [int] NOT NULL DEFAULT ((0)),
          [Status] [nvarchar](10) NOT NULL DEFAULT ('0'),
          [DropID] [nvarchar](20) NOT NULL DEFAULT (''),
          [Loc] [nvarchar](10) NOT NULL DEFAULT ('UNKNOWN'),
          [ID] [nvarchar](18) NOT NULL DEFAULT (' '),
          [PackKey] [nvarchar](10) NULL DEFAULT (' '),
          [UpdateSource] [nvarchar](10) NULL DEFAULT ('0'),
          [CartonGroup] [nvarchar](10) NULL,
          [CartonType] [nvarchar](10) NULL,
          [ToLoc] [nvarchar](10) NULL  DEFAULT (' '),
          [DoReplenish] [nvarchar](1) NULL DEFAULT ('N'),
          [ReplenishZone] [nvarchar](10) NULL DEFAULT (' '),
          [DoCartonize] [nvarchar](1) NULL DEFAULT ('N'),
          [PickMethod] [nvarchar](1) NOT NULL DEFAULT (' '),
          [WaveKey] [nvarchar](10) NOT NULL DEFAULT (' '),
          [EffectiveDate] [datetime] NOT NULL DEFAULT (getdate()),
          [AddDate] [datetime] NOT NULL DEFAULT (getdate()),
          [AddWho] [nvarchar](128) NOT NULL DEFAULT (suser_sname()),
          [EditDate] [datetime] NOT NULL DEFAULT (getdate()),
          [EditWho] [nvarchar](128) NOT NULL DEFAULT (suser_sname()),
          [TrafficCop] [nvarchar](1) NULL,
          [ArchiveCop] [nvarchar](1) NULL,
          [OptimizeCop] [nvarchar](1) NULL,
          [ShipFlag] [nvarchar](1) NULL DEFAULT ('0'),
          [PickSlipNo] [nvarchar](10) NULL,
          [TaskDetailKey] [nvarchar](10) NULL,
          [TaskManagerReasonKey] [nvarchar](10) NULL,
          [Notes] [nvarchar](4000) NULL,
          [MoveRefKey] [nvarchar](10) NULL DEFAULT (''),
          [WIP_Refno] [nvarchar](30) NULL DEFAULT (''),
          [Channel_ID] [bigint] NULL DEFAULT ((0)))    	
    END
    
    --Initialize Pickdetail work in progress staging table
    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
       EXEC isp_CreatePickdetail_WIP
            @c_Loadkey               = ''
           ,@c_Wavekey               = @c_wavekey  
           ,@c_WIP_RefNo             = @c_SourceType 
           ,@c_PickCondition_SQL     = ''
           ,@c_Action                = 'I'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records
           ,@c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization
           ,@b_Success               = @b_Success OUTPUT
           ,@n_Err                   = @n_Err     OUTPUT 
           ,@c_ErrMsg                = @c_ErrMsg  OUTPUT
           
        IF @b_Success <> 1
        BEGIN
           SET @n_continue = 3
        END          
    END
   
    --Get batch number and update to pickdetail for B2B 
    IF (@n_continue = 1 or @n_continue = 2) 
    BEGIN
    	 --Cleare notes
    	 UPDATE #PickDetail_WIP
    	 SET Notes = ''
    	     --Pickslipno = ''
    	     
    	 
       DECLARE CUR_PICK CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      	 
    	    SELECT PD.Pickdetailkey, CL.Short
    	    FROM #PickDetail_WIP PD
    	    JOIN ORDERS O (NOLOCK) ON PD.Orderkey = O.Orderkey
    	    JOIN STORER S (NOLOCK) ON S.Storerkey = 'PVH-' + O.Billtokey AND S.Consigneefor = O.Storerkey
    	    JOIN SKUCONFIG SKC (NOLOCK) ON  PD.Storerkey = SKC.Storerkey AND PD.Sku = SKC.Sku AND SKC.ConfigType = 'HTSCODE-PVH'    	 
    	    JOIN CODELKUP CL (NOLOCK) ON PD.Storerkey = CL.Storerkey AND LEFT(SKC.Data,4) = CL.Long AND CL.Listname = 'PVHHTSCODE' AND S.ISOCntryCode = CL.UDF01

       OPEN CUR_PICK  
         
       FETCH NEXT FROM CUR_PICK INTO @c_Pickdetailkey, @c_Short_group  
         
       WHILE @@FETCH_STATUS <> -1  AND @n_continue IN(1,2)
       BEGIN  
       	  UPDATE #PickDetail_WIP
       	  SET Notes = @c_Short_group
       	  WHERE Pickdetailkey = @c_Pickdetailkey

          FETCH NEXT FROM CUR_PICK INTO @c_Pickdetailkey, @c_Short_group
       END
       CLOSE CUR_PICK
       DEALLOCATE CUR_PICK

       DECLARE CUR_PICK2 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      	 
    	    SELECT PD.Pickdetailkey, CL.Short
    	    FROM #PickDetail_WIP PD
          JOIN SKU (NOLOCK) ON PD.Storerkey = SKU.Storerkey AND PD.Sku = SKU.Sku
          JOIN CODELKUP CL (NOLOCK) ON SKU.Storerkey = CL.Storerkey AND SUBSTRING(SKU.Busr2,15,4) = CL.Code AND CL.Listname = 'PVHITEMGRP'
          AND PD.Notes = ''
             	    
       OPEN CUR_PICK2  
                
       FETCH NEXT FROM CUR_PICK2 INTO @c_Pickdetailkey, @c_Short_group  
         
       WHILE @@FETCH_STATUS <> -1  AND @n_continue IN(1,2)
       BEGIN         	 
       	  UPDATE #PickDetail_WIP
       	  SET Notes = @c_Short_group
       	  WHERE Pickdetailkey = @c_Pickdetailkey

          FETCH NEXT FROM CUR_PICK2 INTO @c_Pickdetailkey, @c_Short_group      	
       END
       CLOSE CUR_PICK2
       DEALLOCATE CUR_PICK2

    END
                                 
    -----Update pickdetail_WIP work in progress staging table back to pickdetail 
    IF @n_continue = 1 or @n_continue = 2
    BEGIN
       EXEC isp_CreatePickdetail_WIP
             @c_Loadkey               = ''
            ,@c_Wavekey               = @c_wavekey  
            ,@c_WIP_RefNo             = @c_SourceType 
            ,@c_PickCondition_SQL     = ''
            ,@c_Action                = 'U'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records
            ,@c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization
            ,@b_Success               = @b_Success OUTPUT
            ,@n_Err                   = @n_Err     OUTPUT 
            ,@c_ErrMsg                = @c_ErrMsg  OUTPUT
           
       IF @b_Success <> 1
       BEGIN
          SET @n_continue = 3
       END             
    END    
                    
    -----Generate Pickslip No------    
    IF @n_continue = 1 or @n_continue = 2 
    BEGIN
    	 IF @c_OrderGroup = 'W'  --Wholesale
       BEGIN    
          EXEC isp_CreatePickSlip
               @c_Wavekey = @c_Wavekey
              ,@c_LinkPickSlipToPick = 'Y'  --Y=Update pickslipno to pickdetail.pickslipno 
              ,@c_ConsolidateByLoad = 'N'
              ,@b_Success = @b_Success OUTPUT
              ,@n_Err = @n_err OUTPUT 
              ,@c_ErrMsg = @c_errmsg OUTPUT       	
          
          IF @b_Success = 0
             SELECT @n_continue = 3
       END       

    	 IF @c_OrderGroup = 'R'  --Retail
       BEGIN    
          EXEC isp_CreatePickSlip
               @c_Wavekey = @c_Wavekey
              ,@c_LinkPickSlipToPick = 'Y'  --Y=Update pickslipno to pickdetail.pickslipno 
              ,@c_ConsolidateByLoad = 'Y'
              ,@b_Success = @b_Success OUTPUT
              ,@n_Err = @n_err OUTPUT 
              ,@c_ErrMsg = @c_errmsg OUTPUT       	
          
          IF @b_Success = 0
             SELECT @n_continue = 3
       END       
    END
            
    -----Update Wave Status-----
    IF @n_continue = 1 or @n_continue = 2  
    BEGIN  
       UPDATE WAVE 
          SET STATUS = '1' -- Released  
       WHERE WAVEKEY = @c_wavekey  
       SELECT @n_err = @@ERROR  
       IF @n_err <> 0  
       BEGIN  
          SELECT @n_continue = 3  
          SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 83160   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update on wave Failed (ispRLWAV31)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '  
       END  
    END  
   
RETURN_SP:

    -----Delete pickdetail_WIP work in progress staging table
    IF @n_continue IN (1,2)
    BEGIN
       EXEC isp_CreatePickdetail_WIP
             @c_Loadkey               = ''
            ,@c_Wavekey               = @c_wavekey  
            ,@c_WIP_RefNo             = @c_SourceType 
            ,@c_PickCondition_SQL     = ''
            ,@c_Action                = 'D'    --I=Initialize pickdetail_wip table. U=Update pickdetail_WIP to pickdetail table and delete. D=Only delete pickdetail_WIP records
            ,@c_RemoveTaskdetailkey   = 'N'    --N=No remove Y=Remove taskdetailkey from pickdetail record when initialization
            ,@b_Success               = @b_Success OUTPUT
            ,@n_Err                   = @n_Err     OUTPUT 
            ,@c_ErrMsg                = @c_ErrMsg  OUTPUT
           
       IF @b_Success <> 1
       BEGIN
          SET @n_continue = 3
       END             
    END
    
    IF OBJECT_ID('tempdb..#PICKDETAIL_WIP') IS NOT NULL
       DROP TABLE #PICKDETAIL_WIP

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
       execute nsp_logerror @n_err, @c_errmsg, "ispRLWAV31"  
       RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012  
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
 END --sp end
GO

GRANT EXECUTE ON ispRLWAV31 TO NSQL
GO

