if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ispRLWAV32]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ispRLWAV32]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/****************************************************************************/  
/* Stored Procedure: ispRLWAV32                                             */  
/* Creation Date: 30-OCT-2019                                               */  
/* Copyright: LFL                                                           */  
/* Written by:                                                              */  
/*                                                                          */  
/* Purpose: WMS-11399 - CN Puma Release wave                                */
/*                                                                          */  
/* Called By: wave                                                          */  
/*                                                                          */  
/* PVCS Version: 1.1                                                        */  
/*                                                                          */  
/* Version: 7.0                                                             */  
/*                                                                          */  
/* Data Modifications:                                                      */  
/*                                                                          */  
/* Updates:                                                                 */  
/* Date        Author   Ver  Purposes                                       */  
/* 17-Jun-2020 NJOW01   1.0  Fix filter by facility                         */
/* 02-Jul-2020 Wan01    1.1  Sync Exceed & SCE                              */
/* 29-Jul-2020 NJOW02   1.2  Fix loc required calculation                   */ 
/****************************************************************************/   

CREATE PROCEDURE [dbo].[ispRLWAV32]      
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

    DECLARE  @c_Storerkey          NVARCHAR(15)
            ,@c_Sku                NVARCHAR(20)
            ,@c_Facility           NVARCHAR(5)
            ,@c_SourceType         NVARCHAR(30)
            ,@c_PickDetailKey      NVARCHAR(10)
            ,@c_NewPickDetailkey   NVARCHAR(10)            
            ,@c_Userdefine01       NVARCHAR(20)
            ,@c_Userdefine02       NVARCHAR(20)
            ,@c_Userdefine03       NVARCHAR(20)
            ,@c_WaveType           NVARCHAR(10)
            ,@c_WaveTypeLong       NVARCHAR(10)
            ,@n_DPPAvailable       INT
            ,@n_DPPCartonPerLoc    INT
            ,@n_DPPCartonAvai      INT
            ,@n_DPPCartonRequire   INT
            ,@c_Lot                NVARCHAR(10)
            ,@c_FromLoc            NVARCHAR(10)
            ,@c_ToLoc              NVARCHAR(10)
            ,@c_ID                 NVARCHAR(18)
            ,@c_ToID               NVARCHAR(18)
            ,@n_CaseCnt            INT
            ,@c_LocationRoom       NVARCHAR(18)
            ,@c_Packkey            NVARCHAR(10) 
            ,@c_UOM                NVARCHAR(10)
            ,@n_Qty                INT 
            ,@n_cartonReq          INT
            ,@c_ReplenishmentKey   NVARCHAR(10)    
            ,@c_ReplenishmentGroup NVARCHAR(10)
            ,@n_ReplenQty          INT
            ,@n_ReplenQtyFinal     INT
            ,@n_QtyAvailable       INT
            ,@n_DPPCartonCanFit    INT
            ,@n_RowID              INT
            ,@n_CartonAssign       INT
            ,@n_PickQty            INT
            ,@n_SplitQty           INT
            ,@n_QtyShort           INT 
            ,@c_UDF01              NVARCHAR(50)
            ,@c_LocationType       NVARCHAR(10)
            ,@n_LLIQty             INT
            ,@n_DPPLocRequire      INT
                                         
    SET @c_SourceType = 'ispRLWAV32'    

    -----Get Storerkey, facility
    IF  (@n_continue = 1 OR @n_continue = 2)
    BEGIN
        SELECT TOP 1 @c_Storerkey     = O.Storerkey, 
                     @c_Facility      = O.Facility,
                     @c_WaveType      = W.WaveType,
                     @c_Userdefine01  = W.Userdefine01,  --DPP Area - location group
                     @c_Userdefine02  = W.Userdefine02,  --DPP location available
                     @c_Userdefine03  = W.Userdefine03,  --No of carton per DPP location. 1 sku per loc
                     @c_WaveTypeLong  = ISNULL(CL.Long, '0'),  --0=Monkey picking 1=DPP picking 2=pick face picking    
                     @c_UDF01         = ISNULL(CL.UDF01,'')    --1=Keep original location of pickdetail in pickface for DPP picking
        FROM WAVE W (NOLOCK)
        JOIN WAVEDETAIL WD(NOLOCK) ON W.Wavekey = WD.Wavekey
        JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
        JOIN CODELKUP CL (NOLOCK) ON W.Wavetype = CL.Code AND CL.Listname = 'WAVETYPE'  
        AND W.Wavekey = @c_Wavekey 
         
        --Get default value if user not key-in from wave 
        SELECT TOP 1 @c_Userdefine02 = CASE WHEN ISNULL(@c_Userdefine02,'') = '' THEN ISNULL(UDF01,'') ELSE @c_Userdefine02 END,
                     @c_Userdefine03 = CASE WHEN ISNULL(@c_Userdefine03,'') = '' THEN ISNULL(UDF02,'') ELSE @c_Userdefine03 END               
        FROM CODELKUP (NOLOCK)
        WHERE Listname = 'PUMAWAVDEF'
        AND Storerkey = @c_Storerkey        

      	SET @n_DPPAvailable = 0
       	SET @n_DPPCartonPerLoc = 0
       	SET @n_DPPCartonAvai = 0
        
        IF ISNUMERIC(@c_Userdefine02) = 1
        BEGIN
           SELECT @n_DPPAvailable = CAST(@c_Userdefine02 AS INT)   --available DPP loc
        END

        IF ISNUMERIC(@c_Userdefine03) = 1
        BEGIN
           SELECT @n_DPPCartonPerLoc = CAST(@c_Userdefine03 AS INT)   --no of carton per DPP loc
        END
        
        SET @n_DPPCartonAvai = @n_DPPAvailable * @n_DPPCartonPerLoc   --total available DPP carton
    END

    -----Wave Validation-----            
    IF @n_continue = 1 OR @n_continue = 2 
    BEGIN
        IF NOT EXISTS (SELECT 1
                       FROM WAVE W (NOLOCK)
                       JOIN WAVEDETAIL WD(NOLOCK) ON W.Wavekey = WD.Wavekey
                       JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
                       JOIN CODELKUP CL (NOLOCK) ON W.Wavetype = CL.Code AND CL.Listname = 'WAVETYPE'  AND O.Storerkey = CL.Storerkey
                       AND W.Wavekey = @c_Wavekey)
        BEGIN
          SELECT @n_continue = 3  
          SELECT @n_err = 83000    
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Invalid Wave Type for the storer. (ispRLWAV32)'       
        END                                                                   
    END
          
    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
        IF @c_WaveTypeLong = '0'  --Monkey pick
        BEGIN
          SELECT @n_continue = 3  
          SELECT @n_err = 83010    
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': This Wave Type not require replenishment. (ispRLWAV32)'       
        END                 
    END

    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
        IF EXISTS (SELECT 1 
                   FROM REPLENISHMENT RP (NOLOCK)
                   WHERE RP.Wavekey = @c_Wavekey    
                   ) 
        BEGIN
          SELECT @n_continue = 3  
          SELECT @n_err = 83020    
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': This Wave has beed released. (ispRLWAV32)'       
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
          SELECT @n_err = 83030    
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Not allow to release. Found some order without load planning yet. (ispRLWAV32)'       
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
          SELECT @n_err = 83040    
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Not allow to release. Found some order in the wave is not allocated yet. (ispRLWAV32)'         
       END
    END   
    
    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
       IF NOT EXISTS (SELECT 1 
                      FROM CODELKUP (NOLOCK)
                      WHERE Listname = 'PUMALOCGRP'
                      AND Long = @c_Userdefine01)
       BEGIN
          SELECT @n_continue = 3  
          SELECT @n_err = 83050    
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Invalid Wave DPP location group defined in Userdefine01. (ispRLWAV32)'       
       END
    END      

    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
       IF EXISTS (SELECT 1
                  FROM LOTXLOCXID LLI (NOLOCK)
                  JOIN LOC (NOLOCK) ON LLI.Loc = LOC.Loc
                  WHERE LOC.Facility = @c_Facility
                  AND LOC.LocationGroup = @c_Userdefine01
                  AND LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked  > 0) 
       BEGIN
          SELECT @n_continue = 3  
          SELECT @n_err = 83060    
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Release Failed. Found available stock in DPP location group defiend in Wave userdefine01. (ispRLWAV32)'       
       END
    END      
        
    IF @n_continue = 1 OR @n_continue = 2
    BEGIN
    	 SET @c_Sku = ''
       
       SELECT TOP 1 @c_Sku = OD.Sku 
       FROM WAVEDETAIL WD (NOLOCK)
       JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
       JOIN ORDERDETAIL OD (NOLOCK) ON O.Orderkey = OD.Orderkey  
       LEFT JOIN SKUXLOC SL (NOLOCK) ON OD.Storerkey = SL.Storerkey AND OD.Sku = SL.Sku  AND SL.LocationType IN('PICK','CASE')
       WHERE WD.Wavekey = @c_Wavekey
       GROUP BY OD.Sku
       HAVING COUNT(DISTINCT SL.Loc) > 1 OR MAX(SL.LocationType) IS NULL
       ORDER BY OD.Sku
                  
       IF ISNULL(@c_Sku,'') <> ''           
       BEGIN
          SELECT @n_continue = 3  
          SELECT @n_err = 83070    
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Found Sku: ' + RTRIM(@c_Sku) + ' has none or multiple pick locations. Every Sku must has one pick location only. (ispRLWAV32)'       
       END
    END      
    
    IF (@n_continue = 1 OR @n_continue = 2) AND @c_WaveTypeLong = '1'  --DPP Picking 
    BEGIN
    	 /*SELECT @n_DPPCartonRequire = SUM(P.CartonReq)
    	 FROM (
    	     SELECT PD.Sku, PD.Loc,  CEILING(SUM(PD.Qty) / PACK.CaseCnt) AS CartonReq
             FROM WAVEDETAIL WD (NOLOCK)
             JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
             JOIN PICKDETAIL PD (NOLOCK) ON O.Orderkey = PD.Orderkey
             JOIN LOC (NOLOCK) ON PD.Loc = LOC.Loc
             JOIN SKU (NOLOCK) ON PD.Storerkey = SKU.Storerkey AND PD.Sku = SKU.Sku
             JOIN PACK (NOLOCK) ON SKU.Packkey = PACK.Packkey
             WHERE WD.Wavekey = @c_Wavekey
             AND PD.UOM <> '2'
             AND 1 = CASE WHEN @c_UDF01 = '1' AND LOC.LocationType = 'PICK' THEN 2 ELSE 1 END
             GROUP BY PD.Sku, PD.Loc, PACK.CaseCnt
            ) AS P
       
       IF @n_DPPCartonRequire > @n_DPPCartonAvai
       BEGIN
          SELECT @n_continue = 3  
          SELECT @n_err = 83080    
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insufficient DPP Location. Require ' + RTRIM(CAST(@n_DPPCartonRequire AS NVARCHAR)) + ' Carton.  Available ' + RTRIM(CAST(@n_DPPCartonAvai AS NVARCHAR))  + ' Carton. (ispRLWAV32)'       
       END*/             
       
       SELECT PD.Sku, PD.Loc,  CEILING(SUM(PD.Qty) / (PACK.CaseCnt * 1.0)) AS CartonReq, ISNULL(PLOC.LocationRoom,'') AS LocationRoom
       INTO #TMP_SKULOCREQCTN
       FROM WAVEDETAIL WD (NOLOCK)
       JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
       JOIN PICKDETAIL PD (NOLOCK) ON O.Orderkey = PD.Orderkey
       OUTER APPLY (SELECT TOP 1 SXL.Loc, L.LocationRoom
                    FROM SKUXLOC SXL (NOLOCK) 
                    JOIN LOC L (NOLOCK) ON SXL.Loc = L.Loc
                    WHERE PD.Storerkey = SXL.Storerkey AND PD.Sku = SXL.Sku AND SXL.LocationType IN('PICK','CASE')
                    ORDER BY L.LocationRoom) PLOC
       JOIN LOC (NOLOCK) ON PD.Loc = LOC.Loc
       JOIN SKU (NOLOCK) ON PD.Storerkey = SKU.Storerkey AND PD.Sku = SKU.Sku
       JOIN PACK (NOLOCK) ON SKU.Packkey = PACK.Packkey
       WHERE WD.Wavekey = @c_Wavekey
       AND PD.UOM <> '2'
       AND 1 = CASE WHEN @c_UDF01 = '1' AND LOC.LocationType = 'PICK' THEN 2 ELSE 1 END
       GROUP BY PD.Sku, PD.Loc, PACK.CaseCnt, ISNULL(PLOC.LocationRoom,'')             
              

       /*
       SELECT SKU, CEILING(CartonReq / (@n_DPPCartonPerLoc * 1.00)) LocNeed, LocationRoom
       INTO #TMP_SKUREQLOC 
       FROM #TMP_SKULOCREQCTN
       */

       --NJOW02
       SELECT SKU, CEILING(SUM(CartonReq) / (@n_DPPCartonPerLoc * 1.00)) LocNeed, LocationRoom
       INTO #TMP_SKUREQLOC 
       FROM #TMP_SKULOCREQCTN
       GROUP BY SKU, LocationRoom
       
       SELECT @n_DPPLocRequire = SUM(LocNeed) 
       FROM #TMP_SKUREQLOC
       
       IF @n_DPPLocRequire > @n_DPPAvailable
       BEGIN
          SELECT @n_continue = 3  
          SELECT @n_err = 83080    
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insufficient DPP Location. Require ' + RTRIM(CAST(@n_DPPLocRequire AS NVARCHAR)) + ' DPP Loc.  Available ' + RTRIM(CAST(@n_DPPAvailable AS NVARCHAR))  + ' DPP Loc. (ispRLWAV32)'       
       END               
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
          
       CREATE TABLE #TMP_DPP (
           ROWID INT IDENTITY(1,1),
           LOC NVARCHAR(10) NULL,
           LogicalLocation NVARCHAR(18) NULL,
           LocationRoom NVARCHAR(30) NULL,
           Maxcarton INT NULL DEFAULT(0),
           Noofcarton INT NULL DEFAULT(0),
           Sku NVARCHAR(20) NULL)                                  
    END

 	  BEGIN TRAN
    
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
       
       UPDATE #PickDetail_WIP SET Toloc = '', PickHeaderkey = ''       
    END
    
    --DPP loc Picking replen From BULK'
    IF (@n_continue = 1 OR @n_continue = 2) AND @c_WaveTypeLong = '1'  
    BEGIN
    	 --Get DPP of the specific locationgroup (userdefine01)
       INSERT INTO #TMP_DPP (Loc, LogicalLocation, LocationRoom, MaxCarton, Noofcarton, sku)       
          SELECT Loc, LogicalLocation, LocationRoom, @n_DPPCartonPerLoc, 0, ''
          FROM Loc (NOLOCK) 
          WHERE Facility = @c_Facility
          AND LocationGroup = @c_Userdefine01
          AND LocationType = 'DYNPPICK'
          
       --Preassign DPP for sku
       DECLARE CUR_ASSIDPP CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
          SELECT SKU, LocNeed, LocationRoom
          FROM #TMP_SKUREQLOC
          ORDER BY Sku
           
       OPEN CUR_ASSIDPP  
         
       FETCH NEXT FROM CUR_ASSIDPP INTO @c_Sku, @n_DPPLocRequire, @c_LocationRoom  

       WHILE @@FETCH_STATUS <> -1  AND @n_continue IN(1,2)
       BEGIN       	  
       	  WHILE @n_DPPLocRequire > 0
       	  BEGIN
       	  	 SET @n_RowID = 0
       	  	 
       	     SELECT @n_RowID = RowID
       	     FROM #TMP_DPP
       	     WHERE LocationRoom = @c_LocationRoom
       	     AND Sku = ''
       	     ORDER BY LogicalLocation, Loc
       	     
       	     IF @@ROWCOUNT = 0
       	        BREAK
       	     
    	       UPDATE #TMP_DPP
       	     SET Sku = @c_Sku
    	       WHERE RowID = @n_RowID       
    	       
    	       SET @n_DPPLocRequire = @n_DPPLocRequire - 1
    	    END	            	  
       	  
          FETCH NEXT FROM CUR_ASSIDPP INTO @c_Sku, @n_DPPLocRequire, @c_LocationRoom         	
       END
       CLOSE CUR_ASSIDPP
       DEALLOCATE CUR_ASSIDPP                          
          
       DECLARE CUR_PICK CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
    	  SELECT PD.Storerkey, PD.Sku, PD.Lot, PD.Loc, PD.ID, PACK.Casecnt, PLOC.LocationRoom,
    	           PACK.Packkey, PACK.PackUOM3,       
    	           SUM(PD.Qty), CEILING(SUM(PD.Qty) / PACK.CaseCnt) AS CartonReq, 
    	           INV.QtyAvailable,
    	           LOC.LocationType 
          FROM WAVEDETAIL WD (NOLOCK)
          JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
          JOIN #PickDetail_WIP PD (NOLOCK) ON O.Orderkey = PD.Orderkey
          JOIN LOC (NOLOCK) ON PD.Loc = LOC.Loc
          JOIN SKU (NOLOCK) ON PD.Storerkey = SKU.Storerkey AND PD.Sku = SKU.Sku
          JOIN PACK (NOLOCK) ON SKU.Packkey = PACK.Packkey
          CROSS APPLY (SELECT TOP 1 SXL.Loc, L.LocationRoom
                       FROM SKUXLOC SXL (NOLOCK) 
                       JOIN LOC L (NOLOCK) ON SXL.Loc = L.Loc
                       WHERE PD.Storerkey = SXL.Storerkey AND PD.Sku = SXL.Sku AND SXL.LocationType IN('PICK','CASE')
                       ORDER BY L.LocationRoom) PLOC
          --JOIN SKUXLOC SL (NOLOCK) ON PD.Storerkey = SL.Storerkey AND PD.Sku = SL.Sku AND SL.LocationType IN('PICK','CASE')   --every sku should setup one pick face
          --JOIN LOC PLOC (NOLOCK) ON SL.Loc = PLOC.Loc  --pick face
          CROSS APPLY (SELECT LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked  AS QtyAvailable FROM LOTXLOCXID LLI (NOLOCK) WHERE LLI.Lot = PD.Lot AND LLI.Loc = PD.Loc AND LLI.ID = PD.ID) AS INV           
          WHERE WD.Wavekey = @c_Wavekey
          AND PD.UOM <> '2'
          AND LOC.LocationType <> 'PICK'
          AND LOC.LocationGroup <> @c_Userdefine01
          AND ISNULL(PD.Pickheaderkey,'') <> '1'
          GROUP BY PD.Storerkey, PD.Sku, PD.Lot, PD.Loc, PD.ID, PACK.Casecnt, PLOC.LocationRoom, PACK.Packkey, PACK.PackUOM3, INV.QtyAvailable, LOC.LocationType
          ORDER BY PD.SKU, PD.Loc, PD.Lot 
           
       OPEN CUR_PICK  
         
       FETCH NEXT FROM CUR_PICK INTO @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_ID, @n_CaseCnt, @c_LocationRoom, @c_Packkey, @c_UOM, @n_Qty, @n_cartonReq, @n_QtyAvailable, @c_LocationType  

       WHILE @@FETCH_STATUS <> -1  AND @n_continue IN(1,2)
       BEGIN         	  
       	  --IF @c_UDF01 = '1' AND @c_LocationType = 'PICK'  --skip replenish pick face to DPP
       	  --   GOTO NEXT_PICK
       	     
       	  --Calculate replenish qty
       	  IF (@n_cartonReq * @n_CaseCnt) - @n_Qty <= @n_QtyAvailable  --check whether can get all full carton
       	  BEGIN
       	     SET @n_ReplenQty = @n_cartonReq * @n_CaseCnt  --Replenish full carton
       	  END        	  
       	  ELSE
       	  BEGIN
       	     SET @n_ReplenQty = @n_Qty   --Replenish with loose qty 
       	  END
       	         	  
       	  WHILE @n_cartonReq > 0 AND @n_ReplenQty > 0 AND @n_continue IN(1,2)
       	  BEGIN
          	 SELECT @c_Replenishmentkey= '', @c_replenishmentGroup = '', @c_Toloc = '', @n_DPPCartonCanFit = 0, @n_ReplenQtyFinal = 0, @n_RowID = 0
       	  	
       	     --find DPP location with same sku of same locationroom
       	     SELECT @n_RowID = RowID, 
       	            @c_Toloc = Loc, 
       	            @n_DPPCartonCanFit = MaxCarton - Noofcarton   
       	     FROM #TMP_DPP
       	     WHERE LocationRoom = @c_LocationRoom
       	     AND MaxCarton - Noofcarton > 0
       	     AND Sku = @c_Sku
       	     ORDER BY LogicalLocation, Loc
       	            	     
       	     --find empty DPP of same locationroom
       	     IF @c_ToLoc = ''
       	     BEGIN
       	        SELECT @n_RowID = RowID,
       	               @c_Toloc = Loc, 
       	               @n_DPPCartonCanFit = MaxCarton - Noofcarton   
       	        FROM #TMP_DPP
       	        WHERE LocationRoom = @c_LocationRoom
       	        AND MaxCarton - Noofcarton > 0
       	        AND Sku = ''
       	        ORDER BY LogicalLocation, Loc
       	     END
       	     
       	     IF @c_ToLoc = ''
       	     BEGIN
                SELECT @n_continue = 3  
                SELECT @n_err = 83090    
                SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insufficent DPP Location at locationRoom ' + RTRIM(@c_LocationRoom) + ' for Sku ' + RTRIM(@c_Sku)  + '. (ispRLWAV32)'        
                BREAK      	     	
       	     END       	            	     

       	     IF @n_DPPCartonCanFit >= @n_cartonReq
       	     BEGIN
       	     	  --replenish all
       	     	  SET @n_ReplenQtyFinal = @n_ReplenQty
       	     	  SET @n_CartonAssign = @n_cartonReq
       	     	  SET @n_cartonReq = 0
       	     	  SET @n_ReplenQty = 0
       	     END
       	     ELSE
       	     BEGIN
       	     	  --replenish carton can fit only
       	        SET @n_ReplenQtyFinal = @n_DPPCartonCanFit * @n_CaseCnt
       	        
       	        IF @n_ReplenQtyfinal > @n_ReplenQty   --if partial carton found
       	           SET @n_ReplenQtyFinal = @n_ReplenQty
       	     	  
       	     	  SET @n_CartonAssign = @n_DPPCartonCanFit       	        
       	        SET @n_CartonReq = @n_CartonReq - @n_DPPCartonCanFit
       	        SET @n_ReplenQty = @n_ReplenQty - @n_ReplenQtyFinal
       	     END       	     
       	     
       	     UPDATE #TMP_DPP
       	     SET Sku = @c_Sku,
       	         Noofcarton = Noofcarton + @n_CartonAssign
       	     WHERE RowID = @n_RowID       	     
       	     
             EXECUTE nspg_getkey
                'REPLENISHKEY'
                , 10
                , @c_ReplenishmentKey OUTPUT
                , @b_success OUTPUT
                , @n_err OUTPUT
                , @c_errmsg OUTPUT
                
             IF NOT @b_success = 1
             BEGIN
                SET @c_ErrMsg = 'Get replenish Key'
                SELECT @n_continue = 3
                BREAK
             END

             INSERT INTO REPLENISHMENT (ReplenishmentKey, ReplenishmentGroup,
                            StorerKey,      SKU,         FromLOC,         ToLOC,
                            Lot,            Id,          Qty,             UOM,
                            PackKey,        Priority,    QtyMoved,        QtyInPickLOC,
                            RefNo,          Confirmed,   ReplenNo,        Wavekey,
                            Remark,         OriginalQty, OriginalFromLoc, ToID,
                            QtyReplen, pendingmovein)
                        VALUES (
                            @c_ReplenishmentKey,         @c_ReplenishmentGroup,
                            @c_StorerKey,   @c_Sku,      @c_FromLoc,      @c_ToLoc,
                            @c_Lot,         @c_Id,       @n_ReplenQtyFinal, @c_UOM,
                            @c_Packkey,     '5',					0,               0,
                            '', 				     'N',          '',   					 @c_WaveKey,
                            '',      			 @n_Qty,      @c_SourceType,    '',
                            @n_ReplenQtyFinal, @n_ReplenQtyFinal)
             
             SET @n_err = @@ERROR
             
             IF @n_err <> 0
             BEGIN
                SELECT @n_continue = 3  
                SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 83100     -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
                SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Error Insert Replenishment Table. (ispRLWAV32)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '  
                BREAK
             END                                

             --Move pickdetail to DPP
             DECLARE CUR_MOVEPick CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                    SELECT P.Pickdetailkey, P.Qty 
                    FROM #PICKDETAIL_WIP AS p WITH (NOLOCK) 
                    WHERE P.[Status] = '0'                
                    AND P.UOM <> '2'
                    AND P.Lot = @c_Lot
                    AND P.Loc = @c_FromLoc
                    AND P.Id = @c_ID         	   
                    AND ISNULL(P.Pickheaderkey,'') <> '1'  	   
                    ORDER BY P.Pickdetailkey
              	  
             OPEN CUR_MOVEPick
             
             FETCH NEXT FROM CUR_MOVEPick INTO @c_Pickdetailkey, @n_PickQty         
             
             WHILE @@FETCH_STATUS = 0 AND @n_ReplenQtyFinal > 0 AND @n_continue IN(1,2)
             BEGIN            	  
             	  IF @n_ReplenQtyFinal >= @n_PickQty
             	  BEGIN
             	  	  UPDATE #PICKDETAIL_WIP 
             	  	  SET ReplenishZone = @c_ReplenishmentKey, 
             	  	      ToLoc = @c_Toloc,
             	  	      PickHeaderkey = '1'
             	  	  WHERE Pickdetailkey = @c_Pickdetailkey
                
                   IF @@ERROR <> 0 
                   BEGIN
                      SELECT @n_continue = 3
                      SELECT @n_err = 83110
                      SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),@n_err)+': Update PickDetail Failed! (ispRLWAV16)'
                   END 
             	  	  
                	  SET @n_ReplenQtyFinal =  @n_ReplenQtyFinal - @n_PickQty 
             	  END
             	  ELSE
             	  BEGIN
                    SET @c_NewPickDetailKey = ''
                                         
                    EXECUTE dbo.nspg_GetKey  
                       'PICKDETAILKEY',   
                       10 ,  
                       @c_NewPickDetailKey  OUTPUT,  
                       @b_success        OUTPUT,  
                       @n_err            OUTPUT,  
                       @c_errmsg         OUTPUT  
                    
                    IF @b_success <> 1  
                    BEGIN  
                       SET @n_Err = 83120  
                       SET @c_ErrMsg = 'Get Pickdetail Key'
                       SET @n_Continue = 3
                    END 
                                      
                    SET @n_SplitQty = @n_PickQty - @n_ReplenQtyFinal
                
                    INSERT INTO #PICKDETAIL_WIP
                    (
                        PickDetailKey    ,CaseID           ,PickHeaderKey
                       ,OrderKey         ,OrderLineNumber  ,Lot
                       ,Storerkey        ,Sku              ,AltSku
                       ,UOM              ,UOMQty           ,Qty
                       ,QtyMoved         ,STATUS           ,DropID
                       ,Loc              ,ID               ,PackKey
                       ,UpdateSource     ,CartonGroup      ,CartonType
                       ,ToLoc            ,DoReplenish      ,ReplenishZone
                       ,DoCartonize      ,PickMethod       ,WaveKey
                       ,EffectiveDate    ,TrafficCop       ,ArchiveCop
                       ,OptimizeCop      ,ShipFlag         ,PickSlipNo
                       ,WIP_Refno
                       )
                    SELECT @c_NewPickDetailKey  AS PickDetailKey
                          ,CaseID           ,PickHeaderKey    ,OrderKey
                          ,OrderLineNumber  ,Lot             ,Storerkey
                          ,Sku              ,AltSku           ,UOM
                          ,UOMQty           ,@n_SplitQty
                          ,QtyMoved         ,[STATUS]         ,DropID       
                          ,Loc   		        ,ID               ,PackKey      
                          ,UpdateSource		  ,CartonGroup      ,@c_PickDetailKey      
                          ,ToLoc						 ,DoReplenish	     ,ReplenishZone='SplitToDPP'      
                          ,DoCartonize      ,PickMethod       ,WaveKey      
                          ,EffectiveDate    ,TrafficCop   		,ArchiveCop      
                          ,'9'              ,ShipFlag         ,PickSlipNo
                          ,@c_SourceType  
                    FROM   #PICKDETAIL_WIP WITH (NOLOCK)  
                    WHERE  PickDetailKey = @c_PickDetailKey 
                
                    IF @@ERROR <> 0 
                    BEGIN
                       SELECT @n_continue = 3
                       SELECT @n_err = 83130
                       SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),@n_err)+': INSERT PickDetail Failed! (ispRLWAV32)'
                    END                   
                                      
                    UPDATE #PICKDETAIL_WIP WITH (ROWLOCK)
                    SET Qty = @n_ReplenQtyFinal, 
                        ReplenishZone=@c_ReplenishmentKey,
                        ToLoc = @c_ToLoc,
                        TrafficCop = NULL,
             	  	      PickHeaderkey = '1'                        
                    WHERE PickDetailKey = @c_PickDetailKey
                
                    IF @@ERROR <> 0 
                    BEGIN
                       SELECT @n_continue = 3
                       SELECT @n_err = 83140
                       SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),@n_err)+': Update PickDetail Failed! (ispRLWAV32)'
                    END 
                     
                    SET @n_ReplenQtyFinal = 0                   
             	  END
           	 
                FETCH NEXT FROM CUR_MOVEPick INTO @c_Pickdetailkey, @n_PickQty         
             END
             CLOSE CUR_MOVEPick
             DEALLOCATE CUR_MOVEPick             
          END
          
          NEXT_PICK:

          FETCH NEXT FROM CUR_PICK INTO @c_Storerkey, @c_Sku, @c_Lot, @c_FromLoc, @c_ID, @n_CaseCnt, @c_LocationRoom, @c_Packkey, @c_UOM, @n_Qty, @n_cartonReq, @n_QtyAvailable, @c_LocationType  
       END       
       CLOSE CUR_PICK
       DEALLOCATE CUR_PICK                    	 
    END

    --DPP loc Picking Replen From PICK'
    IF (@n_continue = 1 OR @n_continue = 2) AND @c_WaveTypeLong = '1'  AND ISNULL(@c_UDF01,'') <> '1'
    BEGIN          
       DECLARE CUR_PICK CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
    	  SELECT PD.Storerkey, PD.Sku, PD.Loc, PACK.Casecnt, PLOC.LocationRoom,
    	           PACK.Packkey, PACK.PackUOM3,       
    	           SUM(PD.Qty), CEILING(SUM(PD.Qty) / PACK.CaseCnt) AS CartonReq, 
    	           SUM(INV.QtyAvailable),
    	           LOC.LocationType 
          FROM WAVEDETAIL WD (NOLOCK)
          JOIN ORDERS O (NOLOCK) ON WD.Orderkey = O.Orderkey
          JOIN #PickDetail_WIP PD (NOLOCK) ON O.Orderkey = PD.Orderkey
          JOIN LOC (NOLOCK) ON PD.Loc = LOC.Loc
          JOIN SKU (NOLOCK) ON PD.Storerkey = SKU.Storerkey AND PD.Sku = SKU.Sku
          JOIN PACK (NOLOCK) ON SKU.Packkey = PACK.Packkey
          CROSS APPLY (SELECT TOP 1 SXL.Loc, L.LocationRoom
                       FROM SKUXLOC SXL (NOLOCK) 
                       JOIN LOC L (NOLOCK) ON SXL.Loc = L.Loc
                       WHERE PD.Storerkey = SXL.Storerkey AND PD.Sku = SXL.Sku AND SXL.LocationType IN('PICK','CASE')
                       ORDER BY L.LocationRoom) PLOC
          --JOIN SKUXLOC SL (NOLOCK) ON PD.Storerkey = SL.Storerkey AND PD.Sku = SL.Sku AND SL.LocationType IN('PICK','CASE')   --every sku should setup one pick face
          --JOIN LOC PLOC (NOLOCK) ON SL.Loc = PLOC.Loc  --pick face
          CROSS APPLY (SELECT LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked  AS QtyAvailable FROM LOTXLOCXID LLI (NOLOCK) WHERE LLI.Lot = PD.Lot AND LLI.Loc = PD.Loc AND LLI.ID = PD.ID) AS INV           
          WHERE WD.Wavekey = @c_Wavekey          
          AND PD.UOM <> '2'
          AND LOC.LocationType = 'PICK'
          AND ISNULL(PD.Pickheaderkey,'') <> '1'
          GROUP BY PD.Storerkey, PD.Sku, PD.Loc, PACK.Casecnt, PLOC.LocationRoom, PACK.Packkey, PACK.PackUOM3, LOC.LocationType
          ORDER BY PD.SKU, PD.Loc
       
       OPEN CUR_PICK  
         
       FETCH NEXT FROM CUR_PICK INTO @c_Storerkey, @c_Sku, @c_FromLoc, @n_CaseCnt, @c_LocationRoom, @c_Packkey, @c_UOM, @n_Qty, @n_cartonReq, @n_QtyAvailable, @c_LocationType  

       WHILE @@FETCH_STATUS <> -1  AND @n_continue IN(1,2)
       BEGIN         	  
       	  --IF @c_UDF01 = '1' AND @c_LocationType = 'PICK'  --skip replenish pick face to DPP
       	  --   GOTO NEXT_PICK2
       	     
       	  --Calculate replenish qty
       	  --IF (@n_cartonReq * @n_CaseCnt) - @n_Qty <= @n_QtyAvailable  --check whether can get all full carton
       	  --BEGIN
       	  --   SET @n_ReplenQty = @n_cartonReq * @n_CaseCnt  --Replenish full carton
       	  --END        	  
       	  --ELSE
       	  --BEGIN
       	     SET @n_ReplenQty = @n_Qty   --Replenish with loose qty 
       	  --END
       	         	  
       	  WHILE @n_cartonReq > 0 AND @n_ReplenQty > 0 AND @n_continue IN(1,2)
       	  BEGIN
          	 SELECT @c_Replenishmentkey= '', @c_replenishmentGroup = '', @c_Toloc = '', @n_DPPCartonCanFit = 0, @n_ReplenQtyFinal = 0, @n_RowID = 0
       	  	
       	     --find DPP location with same sku of same locationroom
       	     SELECT @n_RowID = RowID, 
       	            @c_Toloc = Loc, 
       	            @n_DPPCartonCanFit = MaxCarton - Noofcarton   
       	     FROM #TMP_DPP
       	     WHERE LocationRoom = @c_LocationRoom
       	     AND MaxCarton - Noofcarton > 0
       	     AND Sku = @c_Sku
       	     ORDER BY LogicalLocation, Loc
       	            	     
       	     --find empty DPP of same locationroom
       	     IF @c_ToLoc = ''
       	     BEGIN
       	        SELECT @n_RowID = RowID,
       	               @c_Toloc = Loc, 
       	               @n_DPPCartonCanFit = MaxCarton - Noofcarton   
       	        FROM #TMP_DPP
       	        WHERE LocationRoom = @c_LocationRoom
       	        AND MaxCarton - Noofcarton > 0
       	        AND Sku = ''
       	        ORDER BY LogicalLocation, Loc
       	     END
       	     
       	     IF @c_ToLoc = ''
       	     BEGIN
                SELECT @n_continue = 3  
                SELECT @n_err = 83150    
                SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Insufficent DPP Location at locationRoom ' + RTRIM(@c_LocationRoom) + ' for Sku ' + RTRIM(@c_Sku)  + '. (ispRLWAV32)'        
                BREAK      	     	
       	     END       	            	     

       	     IF @n_DPPCartonCanFit >= @n_cartonReq
       	     BEGIN
       	     	  --replenish all
       	     	  SET @n_ReplenQtyFinal = @n_ReplenQty
       	     	  SET @n_CartonAssign = @n_cartonReq
       	     	  SET @n_cartonReq = 0
       	     	  SET @n_ReplenQty = 0
       	     END
       	     ELSE
       	     BEGIN
       	     	  --replenish carton can fit only
       	        SET @n_ReplenQtyFinal = @n_DPPCartonCanFit * @n_CaseCnt
       	        
       	        IF @n_ReplenQtyfinal > @n_ReplenQty   --if partial carton found
       	           SET @n_ReplenQtyFinal = @n_ReplenQty
       	     	  
       	     	  SET @n_CartonAssign = @n_DPPCartonCanFit       	        
       	        SET @n_CartonReq = @n_CartonReq - @n_DPPCartonCanFit
       	        SET @n_ReplenQty = @n_ReplenQty - @n_ReplenQtyFinal
       	     END       	     
       	     
       	     UPDATE #TMP_DPP
       	     SET Sku = @c_Sku,
       	         Noofcarton = Noofcarton + @n_CartonAssign
       	     WHERE RowID = @n_RowID       	     
             
             --Get LOT,ID to replenish
             DECLARE CUR_MOVEGETLOT CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                    SELECT P.LOT, P.ID, SUM(P.Qty) AS PickQty
                    FROM #PICKDETAIL_WIP AS p WITH (NOLOCK) 
                    WHERE P.[Status] = '0'                
                    AND P.UOM <> '2'
                    AND P.Storerkey = @c_Storerkey
                    AND P.Sku = @c_Sku
                    AND P.Loc = @c_FromLoc
                    AND ISNULL(P.Pickheaderkey,'') <> '1'
                    GROUP BY P.Lot, P.ID                    
                    ORDER BY PickQty 

             OPEN CUR_MOVEGETLOT
             
             FETCH NEXT FROM CUR_MOVEGETLOT INTO @c_Lot, @c_ID, @n_LLIQty         
             
             WHILE @@FETCH_STATUS = 0 AND @n_ReplenQtyFinal > 0 AND @n_continue IN(1,2)
             BEGIN            	   
             	  IF @n_LLIQty > @n_ReplenQtyFinal
             	     SET @n_LLIQty = @n_ReplenQtyFinal
             	     
                EXECUTE nspg_getkey
                   'REPLENISHKEY'
                   , 10
                   , @c_ReplenishmentKey OUTPUT
                   , @b_success OUTPUT
                   , @n_err OUTPUT
                   , @c_errmsg OUTPUT
                   
                IF NOT @b_success = 1
                BEGIN
                   SET @c_ErrMsg = 'Get replenish Key'
                   SELECT @n_continue = 3
                   BREAK
                END
                
                INSERT INTO REPLENISHMENT (ReplenishmentKey, ReplenishmentGroup,
                               StorerKey,      SKU,         FromLOC,         ToLOC,
                               Lot,            Id,          Qty,             UOM,
                               PackKey,        Priority,    QtyMoved,        QtyInPickLOC,
                               RefNo,          Confirmed,   ReplenNo,        Wavekey,
                               Remark,         OriginalQty, OriginalFromLoc, ToID,
                               QtyReplen, pendingmovein)
                           VALUES (
                               @c_ReplenishmentKey,         @c_ReplenishmentGroup,
                               @c_StorerKey,   @c_Sku,      @c_FromLoc,      @c_ToLoc,
                               @c_Lot,         @c_Id,       @n_LLIQty, @c_UOM,
                               @c_Packkey,     '5',					0,               0,
                               '', 				     'N',          '',   					 @c_WaveKey,
                               '',      			 @n_Qty,      @c_SourceType,    '',
                               @n_LLIQty, @n_LLIQty)
                
                SET @n_err = @@ERROR
                
                IF @n_err <> 0
                BEGIN
                   SELECT @n_continue = 3  
                   SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 83160     -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
                   SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Error Insert Replenishment Table. (ispRLWAV32)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '  
                   BREAK
                END                                
                
                --Move pickdetail to DPP            
                DECLARE CUR_MOVEPick CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                       SELECT P.Pickdetailkey, P.Qty 
                       FROM #PICKDETAIL_WIP AS p WITH (NOLOCK) 
                       WHERE P.[Status] = '0'                
                       AND P.UOM <> '2'
                       AND P.Lot = @c_Lot
                       AND P.Loc = @c_FromLoc
                       AND P.Id = @c_ID       
                       AND ISNULL(P.Pickheaderkey,'') <> '1'  	   
                       ORDER BY P.Pickdetailkey
                 	  
                OPEN CUR_MOVEPick
                
                FETCH NEXT FROM CUR_MOVEPick INTO @c_Pickdetailkey, @n_PickQty         
                
                WHILE @@FETCH_STATUS = 0 AND @n_ReplenQtyFinal > 0 AND @n_continue IN(1,2)
                BEGIN            	  
                	  IF @n_ReplenQtyFinal >= @n_PickQty
                	  BEGIN
                	  	  UPDATE #PICKDETAIL_WIP 
                	  	  SET ReplenishZone = @c_ReplenishmentKey, 
                	  	      ToLoc = @c_Toloc,
                	  	      PickHeaderkey = '1'
                	  	  WHERE Pickdetailkey = @c_Pickdetailkey
                   
                      IF @@ERROR <> 0 
                      BEGIN
                         SELECT @n_continue = 3
                         SELECT @n_err = 83170
                         SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),@n_err)+': Update PickDetail Failed! (ispRLWAV16)'
                      END 
                	  	  
                   	  SET @n_ReplenQtyFinal = @n_ReplenQtyFinal - @n_PickQty 
                	  END
                	  ELSE
                	  BEGIN
                       SET @c_NewPickDetailKey = ''
                                            
                       EXECUTE dbo.nspg_GetKey  
                          'PICKDETAILKEY',   
                          10 ,  
                          @c_NewPickDetailKey  OUTPUT,  
                          @b_success        OUTPUT,  
                          @n_err            OUTPUT,  
                          @c_errmsg         OUTPUT  
                       
                       IF @b_success <> 1  
                       BEGIN  
                          SET @n_Err = 83180  
                          SET @c_ErrMsg = 'Get Pickdetail Key'
                          SET @n_Continue = 3
                       END 
                                         
                       SET @n_SplitQty = @n_PickQty - @n_ReplenQtyFinal
                   
                       INSERT INTO #PICKDETAIL_WIP
                       (
                           PickDetailKey    ,CaseID           ,PickHeaderKey
                          ,OrderKey         ,OrderLineNumber  ,Lot
                          ,Storerkey        ,Sku              ,AltSku
                          ,UOM              ,UOMQty           ,Qty
                          ,QtyMoved         ,STATUS           ,DropID
                          ,Loc              ,ID               ,PackKey
                          ,UpdateSource     ,CartonGroup      ,CartonType
                          ,ToLoc            ,DoReplenish      ,ReplenishZone
                          ,DoCartonize      ,PickMethod       ,WaveKey
                          ,EffectiveDate    ,TrafficCop       ,ArchiveCop
                          ,OptimizeCop      ,ShipFlag         ,PickSlipNo
                          ,WIP_Refno
                          )
                       SELECT @c_NewPickDetailKey  AS PickDetailKey
                             ,CaseID           ,PickHeaderKey    ,OrderKey
                             ,OrderLineNumber  ,Lot             ,Storerkey
                             ,Sku              ,AltSku           ,UOM
                             ,UOMQty           ,@n_SplitQty
                             ,QtyMoved         ,[STATUS]         ,DropID       
                             ,Loc   		        ,ID               ,PackKey      
                             ,UpdateSource		 ,CartonGroup      ,@c_PickDetailKey      
                             ,ToLoc						 ,DoReplenish	     ,ReplenishZone='SplitToDPP2'      
                             ,DoCartonize      ,PickMethod       ,WaveKey      
                             ,EffectiveDate    ,TrafficCop   		,ArchiveCop      
                             ,'9'              ,ShipFlag         ,PickSlipNo
                             ,@c_SourceType  
                       FROM   #PICKDETAIL_WIP WITH (NOLOCK)  
                       WHERE  PickDetailKey = @c_PickDetailKey 
                   
                       IF @@ERROR <> 0 
                       BEGIN
                          SELECT @n_continue = 3
                          SELECT @n_err = 83190
                          SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),@n_err)+': INSERT PickDetail Failed! (ispRLWAV32)'
                       END                   
                                         
                       UPDATE #PICKDETAIL_WIP WITH (ROWLOCK)
                       SET Qty = @n_ReplenQtyFinal, 
                           ReplenishZone=@c_ReplenishmentKey,
                           ToLoc = @c_ToLoc,
                           TrafficCop = NULL,
                           PickHeaderkey = '1'
                       WHERE PickDetailKey = @c_PickDetailKey
                   
                       IF @@ERROR <> 0 
                       BEGIN
                          SELECT @n_continue = 3
                          SELECT @n_err = 83200
                          SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),@n_err)+': Update PickDetail Failed! (ispRLWAV32)'
                       END 
                        
                       SET @n_ReplenQtyFinal = 0                   
                	  END
           	    
                   FETCH NEXT FROM CUR_MOVEPick INTO @c_Pickdetailkey, @n_PickQty         
                END
                CLOSE CUR_MOVEPick
                DEALLOCATE CUR_MOVEPick       
                
                FETCH NEXT FROM CUR_MOVEGETLOT INTO @c_Lot, @c_ID, @n_LLIQty                        
             END
             CLOSE CUR_MOVEGETLOT
             DEALLOCATE CUR_MOVEGETLOT
             
          END
          
          --NEXT_PICK2:

          FETCH NEXT FROM CUR_PICK INTO @c_Storerkey, @c_Sku, @c_FromLoc, @n_CaseCnt, @c_LocationRoom, @c_Packkey, @c_UOM, @n_Qty, @n_cartonReq, @n_QtyAvailable, @c_LocationType  
       END       
       CLOSE CUR_PICK
       DEALLOCATE CUR_PICK                    	 
    END

    -----Create replenishment task for pick face picking
    IF (@n_continue = 1 OR @n_continue = 2) AND @c_WaveTypeLong = '2'  
    BEGIN    	 
    	 --Retrieve all lot of the wave from pick loc
       SELECT DISTINCT LLI.Lot             
       INTO #TMP_WAVEPICKLOT
       FROM PICKDETAIL PD (NOLOCK)
       JOIN SKUXLOC SXL (NOLOCK) ON PD.Storerkey = SXL.Storerkey AND PD.Sku = SXL.Sku AND PD.Loc = SXL.Loc
       JOIN LOTXLOCXID LLI (NOLOCK) ON PD.Storerkey = LLI.Storerkey AND PD.Sku = LLI.Sku AND PD.Lot = LLI.Lot AND PD.Loc = LLI.Loc AND PD.ID = LLI.ID
       JOIN ORDERS O (NOLOCK) ON PD.Orderkey = O.Orderkey
       JOIN WAVEDETAIL WD (NOLOCK) ON O.Orderkey = WD.Orderkey
       WHERE WD.Wavekey = @c_Wavekey
       AND SXL.LocationType IN('PICK','CASE')    	 
       AND LLI.QtyExpected > 0
       --AND PD.Uom = '7'
                       
    	 --Retreive pick loc with overallocated
       DECLARE cur_PickLoc CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
          SELECT LLI.Storerkey, LLI.Sku, LLI.Lot, LLI.Loc, LLI.Id, SUM(LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked + LLI.PendingMoveIn) AS Qty,
                 PACK.CaseCnt, PACK.Packkey, PACK.PACKUOM3, LOC.LocationRoom
          FROM LOTXLOCXID LLI (NOLOCK)          
          JOIN SKUXLOC SL (NOLOCK) ON LLI.Storerkey = SL.Storerkey AND LLI.Sku = SL.Sku AND LLI.Loc = SL.Loc
          JOIN SKU (NOLOCK) ON LLI.Storerkey = SKU.Storerkey AND LLI.Sku = SKU.Sku
          JOIN PACK (NOLOCK) ON SKU.Packkey = PACK.Packkey
          JOIN LOC (NOLOCK) ON LLI.Loc = LOC.Loc
          JOIN #TMP_WAVEPICKLOT ON LLI.Lot = #TMP_WAVEPICKLOT.Lot 
          WHERE SL.LocationType IN('PICK','CASE')
          AND LLI.Storerkey = @c_Storerkey
          AND LOC.Facility = @c_Facility       
          GROUP BY LLI.Storerkey, LLI.Sku, LLI.Lot, LLI.Loc, LLI.Id, PACK.CaseCnt, PACK.Packkey, PACK.PACKUOM3, LOC.LocationRoom 
          HAVING SUM((LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked) + LLI.PendingMoveIn) < 0  --overallocate

       OPEN cur_PickLoc
       
       FETCH FROM cur_PickLoc INTO @c_Storerkey, @c_Sku, @c_Lot, @c_ToLoc, @c_ToID, @n_QtyShort, @n_CaseCnt, @c_Packkey, @c_UOM, @c_LocationRoom
       
       WHILE @@FETCH_STATUS = 0 AND @n_continue IN(1,2)
       BEGIN       	  
       	  IF @n_QtyShort < 0
       	     SET @n_QtyShort = @n_QtyShort * -1
       	     
       	  SET @n_ReplenQty = @n_QtyShort   
         
       	  --retrieve stock from bulk 
          DECLARE cur_Bulk CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
             SELECT LLI.Lot, LLI.Loc, LLI.Id, (LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.QtyReplen) AS QtyAvailable
             FROM LOTXLOCXID LLI (NOLOCK)          
             JOIN SKUXLOC SL (NOLOCK) ON LLI.Storerkey = SL.Storerkey AND LLI.Sku = SL.Sku AND LLI.Loc = SL.Loc
             JOIN LOT (NOLOCK) ON LLI.Lot = LOT.Lot
             JOIN LOC (NOLOCK) ON LLI.Loc = LOC.Loc
             JOIN ID (NOLOCK) ON LLI.Id = ID.Id
             WHERE SL.LocationType NOT IN('PICK','CASE')
             AND LOT.STATUS = 'OK' 
             AND LOC.STATUS = 'OK' 
             AND ID.STATUS = 'OK'  
             AND LOC.LocationFlag = 'NONE' 
             AND LOC.LocationType = 'OTHER' 
             AND (LLI.Qty - LLI.QtyAllocated - LLI.QtyPicked - LLI.QtyReplen) > 0
             AND LLI.Storerkey = @c_Storerkey
             AND LLI.Sku = @c_Sku
             AND LLI.Lot = @c_Lot         
             AND LOC.Facility = @c_Facility  --NJOW01
             ORDER BY CASE WHEN LOC.LocationRoom = @c_LocationRoom THEN 1 ELSE 2 END,  --get the locatioroom of the pick face first.
                      LOC.LocationRoom, LOC.Logicallocation, LOC.Loc
             
          OPEN cur_Bulk
          
          FETCH FROM cur_Bulk INTO @c_Lot, @c_FromLoc, @c_ID, @n_QtyAvailable
          
          WHILE @@FETCH_STATUS = 0 AND @n_continue IN(1,2) AND @n_ReplenQty > 0          	 
          BEGIN          
          	 SELECT @c_Replenishmentkey= '', @c_replenishmentGroup = ''
          	 
             IF @n_QtyAvailable >= @n_ReplenQty       
             BEGIN  
                SET @n_ReplenQtyFinal = CEILING(@n_ReplenQty / (@n_CaseCnt * 1.00)) * @n_CaseCnt  --Try to replenish full case
                
                IF @n_ReplenQtyFinal > @n_QtyAvailable  --take all of available if less than full case
                   SET @n_ReplenQtyFinal = @n_QtyAvailable
             END
             ELSE
                SET @n_ReplenQtyFinal = @n_QtyAvailable
                    	     	 	         	  	 	     
       	  	 	SET @n_ReplenQty = @n_ReplenQty - @n_ReplenQtyFinal
       	  	 	
             EXECUTE nspg_getkey
                'REPLENISHKEY'
                , 10
                , @c_ReplenishmentKey OUTPUT
                , @b_success OUTPUT
                , @n_err OUTPUT
                , @c_errmsg OUTPUT
                
             IF NOT @b_success = 1
             BEGIN
                SELECT @n_continue = 3
             END

             INSERT INTO REPLENISHMENT(
                   Replenishmentgroup, ReplenishmentKey, StorerKey,
                   Sku,                FromLoc,          ToLoc,
                   Lot,                Id,               Qty,
                   UOM,                PackKey,          Confirmed, 
                   MoveRefKey,         ToID,             PendingMoveIn, 
                   QtyReplen,          QtyInPickLoc,     RefNo, 
                   Wavekey,						Remark,						ReplenNo,
                   OriginalQty,				OriginalFromLoc)
             VALUES (@c_ReplenishmentGroup, @c_ReplenishmentKey, @c_StorerKey, 
                      @c_SKU,                 @c_FromLOC,          @c_ToLOC, 
                      @c_LOT,           		  @c_ID,               @n_ReplenQtyFinal, 
                      @c_UOM,                 @c_PackKey,          'N', 
                      '',     						    @c_ToID,             @n_ReplenQtyFinal, 
                      @n_ReplenQtyFinal,      0, 							     '',
                      @c_Wavekey,						  '',									 '', 
                      0,										  @c_SourceType)  

             IF @@ERROR <> 0
             BEGIN
                SELECT @n_continue = 3  
                SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 83210     -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
                SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Error Insert Replenishment Table. (ispRLWAV32)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '  
             END                                
                                                                                    
             FETCH FROM cur_Bulk INTO @c_Lot, @c_FromLoc, @c_ID, @n_QtyAvailable
          END
          CLOSE cur_Bulk
          DEALLOCATE cur_Bulk
          
          FETCH FROM cur_PickLoc INTO @c_Storerkey, @c_Sku, @c_Lot, @c_ToLoc, @c_ToID, @n_QtyShort, @n_CaseCnt, @c_Packkey, @c_UOM, @c_LocationRoom
       END
       CLOSE cur_PickLoc
       DEALLOCATE cur_PickLoc          
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
       ELSE
       BEGIN       
       	   --Move pickdetail to DPP
          UPDATE #PickDetail_WIP
          SET Loc = ToLoc,
              ID = '',
              TrafficCop = 'T'  --enable trigger when update
          WHERE Toloc <> ''
          AND ToLoc IS NOT NULL
          
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
    END    

    -----Generate Pickslip No------    
    IF @n_continue = 1 or @n_continue = 2 
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

    -----Update Wave Status-----
    IF @n_continue = 1 or @n_continue = 2  
    BEGIN  
      -- (Wan01) - START
       --UPDATE WAVE 
       --   SET STATUS = '1' -- Released  
       --WHERE WAVEKEY = @c_wavekey  
       
      
      UPDATE WAVE   
          SET TMReleaseFlag = 'Y'
           ,  TrafficCop = NULL  
           ,  EditWho = SUSER_SNAME() 
           ,  EditDate= GETDATE()     
       WHERE WAVEKEY = @c_wavekey    
      -- (Wan01) - END       
              
       SELECT @n_err = @@ERROR  
       IF @n_err <> 0  
       BEGIN  
          SELECT @n_continue = 3  
          SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 83220   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
          SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update on wave Failed (ispRLWAV32)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '  
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
       execute nsp_logerror @n_err, @c_errmsg, "ispRLWAV32"  
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

GRANT EXECUTE ON ispRLWAV32 TO NSQL
GO

