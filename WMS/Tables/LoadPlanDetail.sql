CREATE TABLE [dbo].[LoadPlanDetail]
(
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlanDetail_OrderKey] DEFAULT (' '),
[ExternOrderKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderDate] [datetime] NULL,
[DeliveryDate] [datetime] NULL,
[DeliveryPlace] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Door] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Stop] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Route] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Weight] [float] NULL CONSTRAINT [DF_LoadPlanDetail_Weight] DEFAULT ((0)),
[Cube] [float] NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlanDetail_Status] DEFAULT ('0'),
[CaseCnt] [int] NULL CONSTRAINT [DF_LoadPlanDetail_CaseCnt] DEFAULT ((0)),
[NoOfOrdLines] [int] NULL CONSTRAINT [DF_LoadPlanDetail_NoOfOrdLines] DEFAULT ((0)),
[Rdd] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_LoadPlanDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlanDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_LoadPlanDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlanDetail_EditWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLANDETAIL_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLANDETAIL_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLANDETAIL_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLANDETAIL_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLANDETAIL_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLANDETAIL_UserDefine08] DEFAULT ('N'),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLANDETAIL_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLANDETAIL_UserDefine10] DEFAULT (' '),
[ExternLoadKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlanDetail_ExternLoadKey] DEFAULT (' '),
[ExternLineNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlanDetail_ExternLineNo] DEFAULT (' ')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Trigger:  ntrLoadPlanDetailAdd                                          */
/* Creation Date:                                                          */
/* Copyright: IDS                                                          */
/* Written by:                                                             */
/*                                                                         */
/* Purpose:                                                                */
/*                                                                         */
/* Input Parameters:                                                       */
/*                                                                         */
/* OUTPUT Parameters:  None                                                */
/*                                                                         */
/* Return Status:  None                                                    */
/*                                                                         */
/* Usage:                                                                  */
/*                                                                         */
/* Local Variables:                                                        */
/*                                                                         */
/* Called By: When records updated                                         */
/*                                                                         */
/* PVCS Version: 1.13                                                      */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author Ver   Purposes                                      */
/* 03-03-2006   Shong        Add SetROWCOUNT 1                             */
/* 18-06-2007   Shong        SOS80748, Status Not Update when populate     */
/*                           allocated orders into Loadplan.               */
/* 17-03-2008   Shong        SOS100780 Not Allow to populate Order# already*/
/*                           exists in another Loadplan Detail             */
/* 27-03-2009   NJOW01 1.1 SOS132422 - Control orders populate to Load Plan*/
/*                           cannot mix RoutingTool and SOStatus in one lp */ 
/* 06-08-2010   GTGOH  1.2 SOS180734 - Update MBOLDetail.LoadKey if Orders */
/*                           exist in MBOLDetail (GOH01)                   */
/* 13-04-2012   SHONG  1.3   Only Ship Loadplan When All Orders Shipped    */
/* 11-11-2014   NJOW02 1.4   324900-Auto update load plan default strategy */
/*                           flag by storerconfig                          */
/* 18-Jul-2016  SHONG  1.5   Update LoadKey to Pick & Pack Tables          */
/*                           SOS#373412 (SHONG01)                          */ 
/* 20-Sep-2016  TLTING 1.6   Change SetROWCOUNT 1 to Top 1                 */
/* 05-May-2017  TLTING 1.7   Skip if Update TrafficCop = 9                 */
/* 16-May-2017  NJOW03 1.8   WMS-1798 Allow config to call custom sp       */
/* 28-Sep-2018  TLTING 1.9   remove row lock                               */
/***************************************************************************/

CREATE TRIGGER [dbo].[ntrLoadPlanDetailAdd]
 ON  [dbo].[LoadPlanDetail]
 FOR INSERT
 AS
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
 
 DECLARE
     @b_debug                      INT
,    @b_Success	                 INT	  -- Populated by calls to stored procedures - was the proc successful?
,    @n_err	                       INT	  -- Error number returned by stored procedure or this trigger
,    @n_err2	                    INT       -- For Additional Error Detection
,    @c_errmsg	                    NVARCHAR(250) -- Error message returned by stored procedure or this trigger
,    @n_continue	                 INT                 
,    @n_starttcnt	                 INT       -- Holds the current transaction count
,    @n_cnt	                       INT                  
,	  @c_authority	                 NVARCHAR(1)	 -- Added By Ricky for usage of Configkey
, 	  @c_Facility	                 NVARCHAR(5)	 -- Added By Ricky for usage of Configkey	
,	  @c_StorerKey	                 NVARCHAR(15) -- Added By Ricky for usage of Configkey
,    @c_AutoUpdLoadPlanDefStrategy NVARCHAR(10) --NJOW02
,    @c_PickSlipNo                 NVARCHAR(10) 
,    @c_OrderKey                   NVARCHAR(10)
,    @c_LoadKey                    NVARCHAR(10)
,    @n_RecordsInserted            INT
,    @c_NoMixRoutingTool           NVARCHAR(1)
,    @c_NoMixHoldSOStatus_LP       NVARCHAR(1)
,    @c_DummyRoute                 NVARCHAR(1) 

 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT, @b_debug = 0

 DECLARE @c_SuperOrderFlag NVARCHAR(1)
 SELECT @c_SuperOrderFlag = 'Y' 

 DECLARE @c_RoutingTool NVARCHAR(30), @c_SOStatus NVARCHAR(10), @c_OrderKey2 NVARCHAR(10)  --NJOW01
 
 SET @n_RecordsInserted = 0 
 
 /* #INCLUDE <TRMBODA1.SQL> */
 -- Added By SHONG
 -- 30t Apr 2003 
 -- Do Nothing when ArchiveCop = '9'
 IF @n_continue = 1 OR @n_continue = 2
 BEGIN
    IF EXISTS (SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
    BEGIN  
       SELECT @n_continue = 4 
    END  
 END 
 IF @n_continue = 1 OR @n_continue = 2
 BEGIN
    IF EXISTS (SELECT 1 FROM INSERTED WHERE TrafficCop = '9')
    BEGIN  
       SELECT @n_continue = 4 
    END  
 END    
 -- End 30th Apr 2003
  
IF (SELECT COUNT(1) FROM INSERTED WHERE TrafficCop is not NULL ) > 0
BEGIN
   UPDATE LoadPlanDetail  
   SET TrafficCop = NULL, ArchiveCop = LoadPlanDetail.ArchiveCop
   FROM INSERTED, DELETED
   WHERE LoadPlanDetail.Loadkey = INSERTED.Loadkey
   AND LoadPlanDetail.LoadLineNumber = INSERTED.LoadLineNumber
   AND LoadPlanDetail.TrafficCop is not NULL 
   SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
   IF @n_err <> 0
   BEGIN
       SELECT @n_continue = 3  
       SELECT @n_err=72609  
       SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Insert Trigger On LoadPlanDetail Failed. (ntrLoadPlanDetailADD)'
   END
   ELSE
   BEGIN
      SELECT @n_continue = 4
   END
END

 IF @n_continue = 1 OR @n_continue = 2
 BEGIN
 	SET @c_LoadKey = ''
 	
 	SELECT @n_RecordsInserted = COUNT(*) FROM INSERTED
 	 
   IF @n_RecordsInserted = 1
    BEGIN
 	    SELECT @c_OrderKey2 = ORDERKEY, 
 	           @c_LoadKey   = LoadKey  
 	    FROM   INSERTED  	 
    END
    ELSE
    BEGIN
 	    SELECT TOP 1
 	           @c_OrderKey2 = ORDERKEY, 
 	           @c_LoadKey   = LoadKey 
 	    FROM   INSERTED

    	 IF (SELECT COUNT(DISTINCT LoadKey) FROM INSERTED) > 1 
    	   SET @c_LoadKey = '' 
 	       	 	 
    END
 
    SELECT 
          @c_StorerKey = ORDERS.StorerKey, 
 	       @c_RoutingTool = ORDERS.RoutingTool,
          @c_SOStatus = ORDERS.SOStatus, 
          @c_Facility = ORDERS.Facility 
    FROM ORDERS WITH (NOLOCK) 
    WHERE OrderKey = @c_OrderKey2     
 END -- @n_continue=1 or @n_continue=2

--SOS132422 - Control orders populate to Load Plan. By NJOW01 27/03/2009 -START
IF @n_continue=1 or @n_continue=2
BEGIN   
	Select @b_success = 0

	Execute nspGetRight '', 
		@c_StorerKey,   -- Storer
		'',   		      -- Sku
		'NoMixRoutingTool_LP', -- ConfigKey
		@b_success    		 OUTPUT, 
		@c_NoMixRoutingTool OUTPUT, 
		@n_err        		 OUTPUT, 
		@c_errmsg     		 OUTPUT

	IF @b_success <> 1
	BEGIN
		SELECT @n_continue = 3 
		SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72610   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
		SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err) + ': Retrieve of Right (NoMixRoutingTool_LP) Failed (ntrLoadPlanDetailAdd)' 
		                 + ' ( ' + ' SQLSvr MESSAGE=' + @c_errmsg + ' ) '
	END   
END

IF (@n_continue=1 or @n_continue=2)
BEGIN
	Select @b_success = 0

	Execute nspGetRight '', 
			@c_StorerKey,   -- Storer
			'',   		-- Sku
			'NoMixHoldSOStatus_LP',  -- ConfigKey
			@b_success    		      OUTPUT, 
			@c_NoMixHoldSOStatus_LP	OUTPUT, 
			@n_err        		      OUTPUT, 
			@c_errmsg     		      OUTPUT

	IF @b_success <> 1
	BEGIN
		SELECT @n_continue = 3 
		SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72611   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
		SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Retrieve of Right (NoMixHoldSOStatus_LP) Failed (ntrLoadPlanDetailAdd)' 
		      + ' ( ' + ' SQLSvr MESSAGE=' + @c_errmsg + ' ) '
	End   
END

  
 IF @n_continue = 1 OR @n_continue = 2
 BEGIN
    IF EXISTS(SELECT 1 FROM  LOADPLAN (NOLOCK) 
 	  	      JOIN  INSERTED ON LOADPLAN.LoadKey = INSERTED.LoadKey
 	  	      WHERE LOADPLAN.FinalizeFlag = 'Y')
 	 BEGIN
       SELECT @n_continue = 3  
       SELECT @n_err=73000  
       SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Loadplan has been finalized. ADD rejected. (ntrLoadPlanDetailADD)'    	 	 
       GOTO EXIT_TRIGGER   	
 	 END
 	  	    
    IF EXISTS(SELECT 1 FROM  LOADPLAN (NOLOCK) 
 	  	      JOIN  INSERTED ON LOADPLAN.LoadKey = INSERTED.LoadKey
 	  	      WHERE LOADPLAN.Status = '9') 
    BEGIN
       SELECT @n_continue = 3
       SELECT @n_err=72900
       SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': LoadPlan.Status = SHIPPED. UPDATE rejected. (ntrLoadPlanDetailAdd)'
       GOTO EXIT_TRIGGER 
    END 	 	    
           	  	 
 	 DECLARE CUR_VALIDATION CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
 	 SELECT INSERTED.LoadKey, INSERTED.OrderKey, lp.DummyRoute
 	 FROM INSERTED 
 	 JOIN LoadPlan AS lp WITH(NOLOCK) ON lp.LoadKey = INSERTED.LoadKey 
 	 ORDER BY INSERTED.LoadKey, INSERTED.OrderKey 
 	 
    OPEN CUR_VALIDATION
    FETCH NEXT FROM CUR_VALIDATION INTO @c_LoadKey, @c_OrderKey2, @c_DummyRoute 
    WHILE @@FETCH_STATUS = 0 AND ( @n_continue = 1 OR @n_continue = 2 )
    BEGIN     	 
    	 IF EXISTS( SELECT 1 
    	            FROM LOADPLANDETAIL LPD (NOLOCK) 
    	            WHERE LPD.OrderKey = @c_OrderKey2   
                  AND   LPD.Loadkey <> @c_Loadkey )
        BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72601   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Found Same Order in Different Load Plan Detail. (ntrLoadPlanDetailAdd)'
            BREAK  
        END

        IF @c_NoMixRoutingTool='1'
        BEGIN
           SELECT @c_RoutingTool = ISNULL(ORDERS.RoutingTool, 'Y')  
	        FROM ORDERS (NOLOCK) 
	        WHERE ORDERS.ORDERKEY = @c_OrderKey2 
   
           IF EXISTS(SELECT 1 
               FROM LOADPLANDETAIL WITH (NOLOCK)  
               JOIN ORDERS (NOLOCK) ON LOADPLANDETAIL.OrderKey = ORDERS.OrderKey 
               WHERE LOADPLANDETAIL.Loadkey = @c_Loadkey
               AND LOADPLANDETAIL.OrderKey <> @c_OrderKey2
               AND ISNULL(ORDERS.RoutingTool,'Y') <> @c_RoutingTool)
           BEGIN
              SELECT @n_continue = 3      
              SELECT @n_err=72611
              SELECT @c_errmsg='RoutingTool: Order No '+ @c_OrderKey2 +' has RoutingTool <> exiting Orders in the Load Plan (ntrLoadPlanDetailAdd)'
              BREAK
           END
        END
        
        IF @c_NoMixHoldSOStatus_LP = '1'
        BEGIN
           IF EXISTS(SELECT 1 
               FROM LOADPLANDETAIL WITH (NOLOCK)  
               JOIN ORDERS (NOLOCK) ON LOADPLANDETAIL.OrderKey = ORDERS.OrderKey 
               WHERE LOADPLANDETAIL.Loadkey = @c_Loadkey
               AND LOADPLANDETAIL.OrderKey <> @c_OrderKey2
               AND ORDERS.SOStatus <> @c_SOStatus
               AND (@c_SOStatus = 'HOLD' OR ORDERS.SOStatus ='HOLD'))     
           BEGIN
              SELECT @n_continue = 3
              SELECT @n_err=72612
              SELECT @c_errmsg='SOStatus: Order No '+ @c_OrderKey2 +' has Extern Order Status <> existing Orders in the Load Plan (ntrLoadPlanDetailAdd)'
              BREAK
           END                  	
        END
    	 
       UPDATE ORDERS  
          SET LoadKey = @c_LoadKey, 
              Route   = CASE @c_DummyRoute WHEN 'Y' THEN 'XX' ELSE Orders.Route END,
              TrafficCop = NULL, 
              EditDate = GETDATE(),
              EditWho = SUSER_SNAME() 
       WHERE OrderKey = @c_OrderKey2 
       SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
       IF @n_err <> 0
       BEGIN
           SELECT @n_continue = 3
           SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72601   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
           SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table ORDERS. (ntrLoadPlanDetailAdd)' + ' ( ' + ' SQLSvr MESSAGE=' + @c_errmsg + ' ) '
           BREAK
       END

      IF EXISTS (SELECT 1 FROM MBOLDETAIL WITH (NOLOCK)  
                 WHERE MBOLDETAIL.OrderKey = @c_OrderKey2
                   AND (LoadKey = '' OR LoadKey IS NULL) )
      BEGIN  
        UPDATE MBOLDETAIL WITH (ROWLOCK) 
        SET LoadKey = @c_LoadKey, 
            TrafficCop = NULL 
        WHERE MBOLDETAIL.OrderKey = @c_OrderKey2 
        
        SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
        IF @n_err <> 0
        BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72601   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table MBOLDETAIL. (ntrLoadPlanDetailAdd)' + ' ( ' + ' SQLSvr MESSAGE=' + @c_errmsg + ' ) '
            BREAK 
        END
     END
          
    	 FETCH NEXT FROM CUR_VALIDATION INTO @c_LoadKey, @c_OrderKey2, @c_DummyRoute  
    END 	  
 	 CLOSE CUR_VALIDATION 
 	 DEALLOCATE CUR_VALIDATION 	 
 END

--NJOW03
IF @n_continue=1 or @n_continue=2          
BEGIN   	  
   IF EXISTS (SELECT 1 FROM INSERTED d   ----->Put INSERTED if INSERT action
            JOIN ORDERS o WITH (NOLOCK) ON d.Orderkey = o.Orderkey
            JOIN storerconfig s WITH (NOLOCK) ON  o.storerkey = s.storerkey    
            JOIN sys.objects sys ON sys.type = 'P' AND sys.name = s.Svalue
            WHERE  s.configkey = 'LoadPlanDetailTrigger_SP')   -----> Current table trigger storerconfig
   BEGIN        	  
      IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL
         DROP TABLE #INSERTED
       
      SELECT * 
      INTO #INSERTED
      FROM INSERTED
              
      IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL
         DROP TABLE #DELETED
       
      SELECT * 
      INTO #DELETED
      FROM DELETED
       
      EXECUTE dbo.isp_LoadPlanDetailTrigger_Wrapper ----->wrapper for current table trigger
               'INSERT'  -----> @c_Action can be INSERT, UPDATE, DELETE
            , @b_Success  OUTPUT  
            , @n_Err      OUTPUT   
            , @c_ErrMsg   OUTPUT  
       
      IF @b_success <> 1  
      BEGIN  
         SELECT @n_continue = 3  
               ,@c_errmsg = 'ntrLoadPlanDetailAdd ' + RTRIM(LTRIM(ISNULL(@c_errmsg,'')))  -----> Put current trigger name
      END  
             
      IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL
         DROP TABLE #INSERTED
       
      IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL
         DROP TABLE #DELETED
   END
END       

-- Check the Configkey for updating of the superorderflag --> Start by Ricky Yee
IF @n_continue = 1 or @n_continue = 2
BEGIN
	 If @n_continue = 1 or @n_continue = 2  
	 Begin
	 	 Select @b_success = 0
	 	
       SET @c_authority = '0'
       
	 	  Execute nspGetRight 	@c_Facility, 
	 	  			  @c_StorerKey, -- Storer
	 	  			  NULL,			 -- Sku
	 	  			  'AutoUpdSupOrdflag',	-- ConfigKey
	 	  			  @b_success    OUTPUT, 
	 	  			  @c_authority  OUTPUT, 
	 	  			  @n_err        OUTPUT, 
	 	  			  @c_errmsg     OUTPUT
	 	  If @b_success <> 1
	 	  Begin
	 	  	 Select @n_continue = 3, @c_errmsg = 'ntrLoadPlanDetailAdd:' + dbo.fnc_rtrim(@c_errmsg)
	 	  End
	 End
	 
	 --NJOW02
	 If @n_continue = 1 or @n_continue = 2  
	 Begin
	 	  Select @b_success = 0
	 	
        SET @c_AutoUpdLoadPlanDefStrategy = '0'
       
	 	  Execute nspGetRight 	@c_Facility, 
	 	  			  @c_StorerKey, 	        -- Storer
	 	  			  NULL,			-- Sku
	 	  			  'AutoUpdLoadPlanDefStrategy',	-- ConfigKey
	 	  			  @b_success    OUTPUT, 
	 	  			  @c_AutoUpdLoadPlanDefStrategy  OUTPUT, 
	 	  			  @n_err        OUTPUT, 
	 	  			  @c_errmsg     OUTPUT
	 	  If @b_success <> 1
	 	  Begin
	 	  	 Select @n_continue = 3, @c_errmsg = 'ntrLoadPlanDetailAdd:' + dbo.fnc_rtrim(@c_errmsg)
	 	  End
	 End	 
	 
	 -- SHONG01
	 If @n_continue = 1 or @n_continue = 2  
	 BEGIN	 

      DECLARE @cKeepPickHDWhenLpdDelete NVARCHAR(10) 	 	
      
	   SET @cKeepPickHDWhenLpdDelete = ''  
      
      SELECT @cKeepPickHDWhenLpdDelete = ISNULL(sValue, '0')   
      FROM  STORERCONFIG WITH (NOLOCK)   
      WHERE StorerKey = @c_StorerKey   
      AND   ConfigKey = 'KeepPickHDWhenLpdDelete'   
      AND   sVAlue = '1' 
	 END	                   
END

-- Check the Configkey for updating of the superorderflag --> End by Ricky Yee
-- SOS 8113 wally 30.sep.02
-- un-commented out: instead of handling it in loadplan trigger, do the updates in here
IF @n_continue = 1 or @n_continue = 2
BEGIN
   DECLARE @n_casecnt 	           INT,
   		  @n_palletcnt 	        INT,
   		  @n_weight	              FLOAT,
   		  @n_cube		           FLOAT,
   		  @n_custcnt	           INT,
   		  @n_ordercnt	           INT,
           -- SOS80748, Status Not Update when populate allocated orders into Loadplan 
           @n_OrdFullyAllocated    INT,
           @n_OrdPartialAllocated  INT,
           @n_OrdPicked            INT,
           @n_OrdShipped           INT,  
           @n_OrdNormal            INT,  
           @c_Status               NVARCHAR(10)
   

   DECLARE C_InsertLoad CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT LoadKey, OrderKey, Weight, [Cube]
      FROM  INSERTED 
      ORDER BY LoadKey, OrderKey 
 
  OPEN C_InsertLoad

   FETCH NEXT FROM C_InsertLoad INTO @c_LoadKey, @c_OrderKey, @n_weight, @n_cube  

   WHILE @@FETCH_STATUS <> -1 AND (@n_continue = 1 OR @n_continue = 2) 
   BEGIN
      SELECT @n_palletcnt = CONVERT(Integer, SUM(CASE WHEN PACK.Pallet = 0 THEN 0
                		                                 ELSE (ORDERDETAIL.OpenQty / PACK.Pallet) END)), 
             @n_casecnt = CONVERT(Integer, SUM(CASE WHEN PACK.CaseCnt = 0 THEN 0
   				                                     ELSE (ORDERDETAIL.OpenQty / PACK.CaseCnt) END)) 
      FROM ORDERDETAIL (NOLOCK) 
      JOIN SKU (NOLOCK) ON (ORDERDETAIL.SKU = SKU.SKU AND ORDERDETAIL.StorerKey = SKU.StorerKey) 
      JOIN PACK (NOLOCK) ON (SKU.Packkey = PACK.Packkey) 
      WHERE ORDERDETAIL.OrderKey = @c_OrderKey 

      SELECT @n_custcnt = COUNT(DISTINCT CustomerName)
        -- SOS80748, Status Not Update when populate allocated orders into Loadplan 
        ,@n_OrdFullyAllocated    = SUM(CASE When STATUS = '2' THEN 1 ELSE 0 END)
        ,@n_OrdPartialAllocated  = SUM(CASE When STATUS = '1' THEN 1 ELSE 0 END)
        ,@n_OrdPicked            = SUM(CASE When STATUS = '5' THEN 1 ELSE 0 END)
        ,@n_OrdShipped           = SUM(CASE When STATUS = '9' THEN 1 ELSE 0 END) 
        ,@n_OrdNormal            = SUM(CASE When STATUS = '0' THEN 1 ELSE 0 END) 
      FROM  LOADPLANDETAIL (NOLOCK) 
      WHERE LOADPLANDETAIL.LoadKey = @c_LoadKey 
   
      IF @n_OrdShipped > 0 
         AND (@n_OrdFullyAllocated + @n_OrdPartialAllocated + @n_OrdPicked + @n_OrdNormal) = 0 -- Shong 
         SET @c_Status = '9'
      ELSE IF @n_OrdPicked > 0 
         SET @c_Status = '5'
      ELSE IF @n_OrdPartialAllocated > 0 OR (@n_OrdFullyAllocated > 0 AND @n_OrdNormal > 0 )
         SET @c_Status = '1'
      ELSE IF @n_OrdFullyAllocated > 0 AND @n_OrdNormal = 0 
         SET @c_Status = '2'
      ELSE  
         SET @c_Status = '0'

      -- SOS80748, Status Not Update when populate allocated orders into Loadplan 
      IF @n_casecnt IS NULL SELECT @n_casecnt = 0 
      IF @n_weight IS NULL SELECT @n_weight = 0 
      IF @n_cube IS NULL SELECT @n_cube = 0 
      IF @n_ordercnt IS NULL SELECT @n_ordercnt = 0 
      IF @n_palletcnt IS NULL SELECT @n_palletcnt = 0 
      IF @n_custcnt IS NULL SELECT @n_custcnt = 0 

      IF @c_authority = '1' 
      BEGIN  
         IF EXISTS (SELECT 1 FROM ORDERS (NOLOCK) WHERE ORDERS.OrderKey = @c_OrderKey AND ORDERS.Rds = 'Y') 
            SELECT @c_SuperOrderFlag = 'N' 
      END 

      UPDATE LoadPlan  
      SET LoadPlan.CustCnt   = @n_custcnt, 
          LoadPlan.OrderCnt  = LoadPlan.OrderCnt + 1,
          LoadPlan.Weight    = LoadPlan.Weight + @n_weight,
          LoadPlan.Cube      = LoadPlan.Cube + @n_cube,
          LoadPlan.PalletCnt = LoadPlan.PalletCnt + @n_palletcnt,
          LoadPlan.CaseCnt   = LoadPlan.CaseCnt + @n_casecnt,
          SuperOrderFlag     = CASE WHEN @c_authority = '1' THEN @c_SuperOrderFlag
                               ELSE SuperOrderFlag END, 
          Status             = @c_Status, -- SOS80748
          Trafficcop         = null, 
          LoadPlan.DefaultStrategykey = CASE WHEN @c_AutoUpdLoadPlanDefStrategy = '1' THEN 'Y' ELSE 'N' END --NJOW02
      WHERE LoadPlan.LoadKey = @c_LoadKey
         
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72601   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table LoadPlan. (ntrLoadPlanDetailAdd)' + ' ( ' + ' SQLSvr MESSAGE=' + @c_errmsg + ' ) '
      END
      
      -- SHONG01
      IF @cKeepPickHDWhenLpdDelete='1'
      BEGIN
         IF EXISTS(SELECT 1 FROM PICKHEADER WITH (NOLOCK) 
      	          WHERE OrderKey = @c_OrderKey 
      	          AND   ExternOrderKey = @c_LoadKey)
         BEGIN
            DECLARE CUR_Added_PickSlipNo CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT p.PickHeaderKey 
            FROM PICKHEADER AS p WITH (NOLOCK)
            WHERE p.ExternOrderKey = '' 
            AND   p.OrderKey = @c_OrderKey
               	
            OPEN CUR_Added_PickSlipNo 
            FETCH NEXT FROM CUR_Added_PickSlipNo INTO @c_PickSlipNo 
            WHILE @@FETCH_STATUS = 0
            BEGIN
               UPDATE PICKHEADER 
            	   SET ExternOrderKey = @c_LoadKey, 
            	      TrafficCop = NULL, 
            	      EditDate = GETDATE(), 
            	      EditWho = SUSER_SNAME() 
               WHERE ExternOrderKey = '' 
            	   AND OrderKey = @c_OrderKey  
            	   AND PickHeaderKey = @c_PickSlipNo  
            	   
               IF EXISTS(SELECT 1 FROM PackHeader AS ph WITH (NOLOCK)
            	            WHERE ph.PickSlipNo = @c_PickSlipNo 
            	            AND   ph.LoadKey = '' 
            	            AND   ph.OrderKey = @c_OrderKey)
               BEGIN
            	   UPDATE PackHeader WITH (ROWLOCK) 
            	      SET LoadKey = @c_LoadKey
            	   WHERE PickSlipNo = @c_PickSlipNo
            	   	            	   	
               END -- PackHeader 
               IF EXISTS(SELECT 1 FROM RefKeyLookup AS rkl WITH (NOLOCK)
            	            WHERE rkl.Pickslipno = @c_PickSlipNo 
            	            AND rkl.OrderKey = @c_OrderKey 
            	            AND rkl.Loadkey = '')
               BEGIN
            	   UPDATE RefKeyLookup
            	      SET Loadkey = @c_LoadKey
            	   WHERE Pickslipno = @c_PickSlipNo 
            	   AND OrderKey = @c_OrderKey 
            	   AND Loadkey = ''
               END -- RefKeyLookup     
                   
               FETCH NEXT FROM CUR_Added_PickSlipNo INTO @c_PickSlipNo      	
            END    
            CLOSE CUR_Added_PickSlipNo 
            DEALLOCATE CUR_Added_PickSlipNo           	         	      
         END -- PICKHEADER
      END -- @cKeepPickHDWhenLpdDelete = 1

      FETCH NEXT FROM C_InsertLoad INTO @c_LoadKey, @c_OrderKey, @n_weight, @n_cube  
   END -- WHILE
   CLOSE C_InsertLoad
   DEALLOCATE C_InsertLoad
END

EXIT_TRIGGER:

 /* #INCLUDE <TRMBODA2.SQL> */
 IF @n_continue=3  -- Error Occured - Process And Return
 BEGIN
    IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
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
    execute nsp_logerror @n_err, @c_errmsg, 'ntrLoadPlanDetailAdd'
    RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
    RETURN
 END
 ELSE
 BEGIN
    WHILE @@TRANCOUNT > @n_starttcnt
    BEGIN
       COMMIT TRAN
    END
    RETURN
 END

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Trigger:  ntrLoadPlanDetailDelete                                    */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Return Status:  None                                                 */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When records updated                                      */
/*                                                                      */
/* PVCS Version: 1.2                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver.  Purposes                                */
/* 02-Mar-2006  Shong     1.0   Set OrderDetail.Loadkey to NULL instead */
/*                              of Blank.                               */
/* 27-Aug-2008  RickyYee  1.0   Update RDSORders.Loadkey when Orders    */
/*                              remove from the LoadplanDetail          */
/*                              (RY_082708)                             */
/* 22-Sep-2008  Shong     1.1   Reverse Loadplan Status When all Lines  */
/*                              Deleted                                 */
/* 11-Mar-2009  YokeBeen  1.2   Added Trigger Point for CMS Project.    */
/*                              - SOS#170510 - (YokeBeen01)             */
/* 19-Mar-2010  Shong     1.3   Delete PickHeader When Loadplan Detail  */
/*                              Deleted.                                */
/*  9-Jun-2011  KHLim01   1.4   Insert Delete log                       */
/* 14-Jul-2011  KHLim02   1.5   GetRight for Delete log                 */
/* 04-May-2016  tlting    1.6   performance tune - DoNotCalcLPAllocInfo */
/* 18-Jul-2016  SHONG01   1.7   Update LoadKey to Pick & Pack Tables    */
/*                              SOS#373412                              */
/* 20-Sep-2016  TLTING    1.7   Change SetROWCOUNT 1 to Top 1           */
/* 20-Oct-2016  SHONG     1.8   Update Loadplan Status                  */
/* 16-May-2017  NJOW01    1.9   WMS-1798 Allow config to call custom sp */
/* 28-Sep-2018  TLTING    1.10  remove row lock                         */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrLoadPlanDetailDelete]
ON [dbo].[LoadPlanDetail]
FOR DELETE
AS
BEGIN
   IF @@ROWCOUNT = 0
   BEGIN
      RETURN
   END

   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Success       int       -- Populated by calls to stored procedures - was the proc successful?
         , @n_err           int       -- Error number returned by stored procedure or this trigger
         , @c_errmsg        NVARCHAR(250) -- Error message returned by stored procedure or this trigger
         , @n_continue      int       -- continuation flag: 1=Continue, 2=failed but continue processsing, 
                                      -- 3=failed do not continue processing, 4=successful but skip further processing
         , @n_starttcnt     int       -- Holds the current transaction count
         , @n_cnt           int       -- Holds the number of rows affected by the DELETE statement that fired this trigger.
         , @c_authority     NVARCHAR(1)
         , @c_storerkey     NVARCHAR(10)
         , @c_LPCANCCMS     NVARCHAR(1)   -- (YokeBeen01) 

   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   /* #INCLUDE <TRMBODD1.SQL> */

   IF (select count(*) from DELETED) =
      (select count(*) from DELETED where DELETED.ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
   END

   -- SOS32395 : Move from BATCHPICK
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      SELECT TOP 1 @c_Storerkey = ORDERS.Storerkey
      FROM   DELETED 
      JOIN   ORDERS WITH (NOLOCK) ON (DELETED.Orderkey = ORDERS.Orderkey) 
   END

   -- Added for IDSV5 by June 26.Jun.02, (extract from IDSHK) *** Start
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      SELECT @b_success = 0
      Execute nspGetRight null,  -- facility
               @c_storerkey,  -- Storerkey : SOS32395
               null,          -- Sku
               'FinalizeLP',     -- Configkey
               @b_success     output,
               @c_authority   output,
               @n_err         output,
               @c_errmsg      output

      IF @b_success <> 1
      BEGIN
         SELECT @n_continue = 3, @c_errmsg = 'ntrLoadplanDetailDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE IF @c_authority = '1'
      BEGIN
         -- Once finalized, no more deletion allowed, requested by KO, 5th Jan 2002
         IF EXISTS (SELECT 1 FROM LOADPLAN WITH (NOLOCK)
                      JOIN DELETED ON (LOADPLAN.Loadkey = DELETED.Loadkey) 
                       AND LOADPLAN.FinalizeFlag = 'Y' ) -- AND LOADPLAN.Status IN ('5', '6', '7', '8','9')))
         BEGIN
            SELECT @n_continue = 3
            SELECT @n_err=72001
            SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0)) 
                             + ': Loadplan has been finalized. DELETE rejected. (ntrLoadPlanDetailDelete)'
         END
      END
   END   -- Added for IDSV5 by June 26.Jun.02, (extract from IDSHK) *** End

   -- Added for IDSV5 by June 26.Jun.02, (extract from IDSHK) *** Start
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      SELECT @b_success = 0
      Execute nspGetRight null,  -- facility
               @c_StorerKey,  -- Storerkey
               null,          -- Sku
               'BATCHPICK',      -- Configkey
               @b_success     output,
               @c_authority   output,
               @n_err         output,
               @c_errmsg      output

      IF @b_success <> 1
      BEGIN
         SELECT @n_continue = 3, @c_errmsg = 'ntrLoadplanDetailDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE IF @c_authority = '1'
      BEGIN
         -- Customized for Batch Pick
         IF EXISTS (SELECT 1 FROM TASKDETAIL WITH (NOLOCK)
                      JOIN DELETED ON (Taskdetail.Sourcekey = DELETED.LOADKEY) 
                      JOIN ORDERS WITH (NOLOCK) ON (DELETED.Orderkey = ORDERS.Orderkey) 
                     WHERE ORDERS.Type NOT IN ('M', 'I')
                       AND ORDERS.UserDefine08 = 'N' -- These orders are allocated in LoadpLan, and thus, batch picked.
                       AND TASKDETAIL.Sourcetype = 'BATCHPICK' )
         BEGIN
            SELECT @n_continue = 3
            SELECT @n_err=72002
            SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0)) 
                   + ': Batch Pick Tasks has been released. Unable to delete Load Detail(ntrLoadPlanDetailDelete)'
         END
         -- batch pick
      END
   END  -- Added for IDSV5 by June 26.Jun.02, (extract from IDSHK) *** End

   --NJOW01
   IF @n_continue=1 or @n_continue=2          
   BEGIN   	  
      IF EXISTS (SELECT 1 FROM DELETED d   ----->Put INSERTED if INSERT action
                 JOIN ORDERS o WITH (NOLOCK) ON d.Orderkey = o.Orderkey
                 JOIN storerconfig s WITH (NOLOCK) ON  o.storerkey = s.storerkey    
                 JOIN sys.objects sys ON sys.type = 'P' AND sys.name = s.Svalue
                 WHERE  s.configkey = 'LoadPlanDetailTrigger_SP')   -----> Current table trigger storerconfig
      BEGIN        	  
         IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL
            DROP TABLE #INSERTED
   
      	 SELECT * 
      	 INTO #INSERTED
      	 FROM INSERTED
          
         IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL
            DROP TABLE #DELETED
   
      	 SELECT * 
      	 INTO #DELETED
      	 FROM DELETED
   
         EXECUTE dbo.isp_LoadPlanDetailTrigger_Wrapper ----->wrapper for current table trigger
                   'DELETE'  -----> @c_Action can be INSERT, UPDATE, DELETE
                 , @b_Success  OUTPUT  
                 , @n_Err      OUTPUT   
                 , @c_ErrMsg   OUTPUT  
   
         IF @b_success <> 1  
         BEGIN  
            SELECT @n_continue = 3  
                  ,@c_errmsg = 'ntrLoadPlanDetailDelete ' + RTRIM(LTRIM(ISNULL(@c_errmsg,'')))  -----> Put current trigger name
         END  
         
         IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL
            DROP TABLE #INSERTED
   
         IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL
            DROP TABLE #DELETED
      END
   END      

   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      UPDATE ORDERS  
    SET LoadKey = '',
             Editdate = GETDATE(),
             Trafficcop = NULL
         --      rdd = '' -- use as loadsheetno for MANILA  :SOS 11354 - no need to re-initialize
        FROM ORDERS 
        JOIN DELETED ON (ORDERS.OrderKey = DELETED.OrderKey AND ORDERS.Loadkey = DELETED.Loadkey) 

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72003  
         SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0)) 
                          + ': Update Failed On Table ORDERS. (ntrLoadPlanDetailAdd)' 
                          + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END
   END

   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      UPDATE ORDERDETAIL  
          -- Change By Shong on 03-Mar-2006, Instead of BLANK, Set it to NULL.
         SET LoadKey = NULL,
             EditDate = GETDATE(),
             Trafficcop = NULL
        FROM ORDERDETAIL 
        JOIN DELETED ON (ORDERDETAIL.OrderKey = DELETED.OrderKey AND ORDERDETAIL.Loadkey = DELETED.Loadkey) 

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72004  
         SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0)) 
                          + ': Update Failed On Table ORDERDETAIL. (ntrLoadPlanDetailAdd)'
                          + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END
   END

	-- Added By Ricky on 28th Aug 2008 Begin (RY_082708)
	-- Update RDSORDERS When Delete from Load Plan Detail
	IF @n_continue = 1 or @n_continue = 2
	BEGIN
      UPDATE rdsORDERS  
         SET LoadKey = '',
             TrafficCop = NULL
        FROM rdsORDERS 
        JOIN DELETED ON (rdsORDERS.OrderKey = DELETED.OrderKey) 

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72005   
         SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0)) 
                          + ': Update Failed On Table rdsORDERS. (ntrLoadPlanDetaildelete)' 
                          + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END
	END 
	-- Added By Ricky on 28th Aug 2008 End (RY_082708)
	
   -- SOS 7261
   -- wally 19.aug.2002
   -- delete the record from orderscan table
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      DELETE ORDERSCAN
      FROM ORDERSCAN O 
      JOIN DELETED D ON O.LOADKEY = D.LOADKEY AND O.ORDERKEY = D.ORDERKEY

      SELECT @n_err = @@error, @n_cnt = @@rowcount

      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72006   
         SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0)) 
                          + ': Delete Failed On Table ORDERSCAN. (ntrLoadPlanDetailAdd)' 
                          + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END
   END

   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      DECLARE @n_casecnt int,
              @n_palletcnt int,
              @n_weight decimal(15, 4),
              @n_cube decimal(15, 4),
              @n_custcnt int,
              @n_ordercnt int,
              @c_DeleteLoadKey NVARCHAR(10)
      DECLARE @cDoNotCalcLPAllocInfo VARCHAR(10)  

      DECLARE @c_LP_Min_Status NVARCHAR(10),
	           @c_LP_Max_Status NVARCHAR(10), 
	           @c_LP_Cur_Status NVARCHAR(10) , 
	           @c_LP_New_Status NVARCHAR(10)  
  
      SET @n_casecnt = 0
      SET @n_palletcnt = 0
      SET @n_weight = 0
      SET @n_cube = 0
      SET @n_custcnt = 0
      SET @n_ordercnt = 0
      SET @c_DeleteLoadKey = ''
              
      SET @cDoNotCalcLPAllocInfo = ''  

      SELECT @cDoNotCalcLPAllocInfo = ISNULL(sValue, '0')   
      FROM  STORERCONFIG WITH (NOLOCK)   
      WHERE StorerKey = @c_StorerKey   
      AND   ConfigKey = 'DoNotCalcLPAllocInfo'   
      AND   sVAlue = '1' 
        
      DECLARE CUR_DELETED_LOADKEY CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DISTINCT LoadKey FROM DELETED
   
      OPEN CUR_DELETED_LOADKEY
   
      FETCH NEXT FROM CUR_DELETED_LOADKEY INTO @c_DeleteLoadKey 
   
      WHILE @@FETCH_STATUS <> -1 AND (@n_continue = 1 or @n_continue = 2) 
      BEGIN 
         IF NOT EXISTS (SELECT 1 FROM LoadPlanDetail WITH (NOLOCK) WHERE LoadKey = @c_DeleteLoadKey)
         BEGIN
            UPDATE LoadPlan  
               SET CustCnt   = 0,
                     OrderCnt  = 0,
                     Weight    = 0,
                     Cube      = 0,
                     PalletCnt = 0,
                     CaseCnt   = 0, 
                     Status    = '0', 
                     editdate  = getdate(),
                     TrafficCop = NULL 
               WHERE LoadPlan.LoadKey = @c_DeleteLoadKey 
               AND Status <= '5'
               AND FinalizeFlag = 'N'
   
            SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
            IF @n_err <> 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72007  
               SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0)) 
                                 + ': Update Failed On Table LoadPlan. (ntrLoadPlanDetailAdd)' 
                                 + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
            END
   
            -- (YokeBeen01) - Start 
            -- Trigger record into CMSLOG with normal Status upon the last LoadplanDetail line is to be purged.
            -- This record will be updated from CMSLOG.TransmitFlag from "0" to "2" in the Loadplan Header Trigger, 
            -- when the Loadplan Header record is to be purged.
            IF @n_continue = 1 or @n_continue = 2  
            BEGIN  
               SELECT @c_LPCANCCMS = 0
               SELECT @b_success = 0
   
               EXECUTE nspGetRight
                        NULL,          -- Facility
                        @c_StorerKey,  -- Storerkey
                        NULL,          -- Sku
                        'LPCANCCMS',   -- Configkey
                        @b_success    output,
                        @c_LPCANCCMS  output,
                        @n_err        output,
                        @c_errmsg     output
   
               IF @b_success <> 1
               BEGIN
                  SELECT @n_continue = 3, @c_errmsg = 'ntrLoadPlandELETE' + dbo.fnc_RTrim(@c_errmsg)
               END
   
               IF @b_success = 1 AND @c_LPCANCCMS = '1'
               BEGIN
                  EXEC ispGenCMSLog 'LPCANCCMS', @c_DeleteLoadKey, 'L', @c_StorerKey, ''
                                    , @b_success OUTPUT
                                    , @n_err OUTPUT
                                    , @c_errmsg OUTPUT
   
                  IF @b_success <> 1
                  BEGIN
                     SELECT @n_continue = 3
                     SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72008   
                     SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0)) 
                           + ': Unable to Generate CMSLog Record, TableName = LPCANCCMS (ntrLoadPlanDetailDelete)' 
                           + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
                  END
               END -- IF @b_success = 1 AND @c_LPCANCCMS = '1'
            END -- IF @n_continue = 1 or @n_continue = 2  
         -- (YokeBeen01) - End 
         END -- No More Loadplan Detail 
         ELSE
         BEGIN 
         	IF @cDoNotCalcLPAllocInfo <> '1' 
            BEGIN
               SELECT @n_palletcnt = CONVERT(Integer, SUM(CASE WHEN PACK.Pallet = 0 THEN 0
                                                            ELSE (ORDERDETAIL.OpenQty / PACK.Pallet) END)),
                      @n_casecnt = CONVERT(Integer, SUM(CASE WHEN PACK.CaseCnt = 0 THEN 0
                                                         ELSE (ORDERDETAIL.OpenQty / PACK.CaseCnt) END))
               FROM ORDERDETAIL WITH (NOLOCK)
               JOIN LoadPlanDetail WITH (NOLOCK) ON ORDERDETAIL.OrderKey = LoadPlanDetail.OrderKey 
               JOIN SKU WITH (NOLOCK) ON ORDERDETAIL.SKU = SKU.SKU AND ORDERDETAIL.Storerkey = SKU.Storerkey
               JOIN PACK WITH (NOLOCK) ON ORDERDETAIL.Packkey = PACK.Packkey
               WHERE LoadPlanDetail.LoadKey = @c_DeleteLoadKey 
         
               SELECT @n_weight = SUM(Weight),
                      @n_cube = SUM(Cube),
                      @n_ordercnt = COUNT(OrderKey)
               FROM LoadPlanDetail WITH (NOLOCK) 
               WHERE LoadKey = @c_DeleteLoadKey
         
               SELECT @n_custcnt = COUNT(DISTINCT ORDERS.ConsigneeKey)
               FROM LoadPlanDetail WITH (NOLOCK)
               JOIN ORDERS WITH (NOLOCK) ON  LoadPlanDetail.OrderKey = ORDERS.OrderKey
               WHERE LoadPlanDetail.LoadKey = @c_DeleteLoadKey

               SET  @n_casecnt   = ISNULL(@n_casecnt,0) 
               SET  @n_weight    = ISNULL(@n_weight,0)
               SET  @n_cube      = ISNULL(@n_cube,0)
               SET  @n_ordercnt  = ISNULL(@n_ordercnt,0)
               SET  @n_palletcnt = ISNULL(@n_palletcnt,0)
               SET  @n_custcnt   = ISNULL(@n_custcnt,0)               
            END 
            ELSE 
            BEGIN 
               SET  @n_casecnt   =  0
               SET  @n_weight    =  0
               SET  @n_cube      =  0
               SET  @n_ordercnt  =  0
               SET  @n_palletcnt =  0
               SET  @n_custcnt   =  0
            END 

      	   SELECT @c_LP_Min_Status = MIN(STATUS), 
      	          @c_LP_Max_Status = MAX(STATUS) 
      	   FROM   LoadPlanDetail AS lpd WITH (NOLOCK)
      	   WHERE  lpd.LoadKey = @c_DeleteLoadKey 
      	   AND    lpd.[Status] NOT IN ('CANC') 
      	
      	   SELECT @c_LP_Cur_Status = [Status]
      	   FROM   LoadPlan AS lp WITH (NOLOCK)
      	   WHERE  lp.LoadKey = @c_DeleteLoadKey
      	
            SET @c_LP_New_Status = CASE
                                      WHEN @c_LP_Max_Status = '0' THEN '0'
                                      WHEN @c_LP_Min_Status = '0' and @c_LP_Max_Status IN ('1','2')
                                         THEN '1'
                                      WHEN @c_LP_Min_Status IN ('0','1','2') AND @c_LP_Max_Status IN ('3','5')
                                         THEN '3'
                                      ELSE @c_LP_Min_Status
                                   END     
            
            IF @cDoNotCalcLPAllocInfo <> '1'
            BEGIN
               UPDATE LoadPlan  
                  SET CustCnt   = @n_custcnt,
                        OrderCnt  = @n_ordercnt,
                        [Weight]  = @n_weight,
                        [Cube]    = @n_cube,
                        PalletCnt = @n_palletcnt,
                        CaseCnt   = @n_casecnt, 
                        [Status]  = @c_LP_New_Status 
                  WHERE LoadPlan.LoadKey = @c_DeleteLoadKey
         
               SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
               IF @n_err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72009  
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0)) 
                                    + ': Update Failed On Table LoadPlan. (ntrLoadPlanDetailAdd)' 
                                    + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
               END             	
            END    
            ELSE 
            BEGIN
            	IF @c_LP_Cur_Status < '5' AND @c_LP_Cur_Status <> @c_LP_New_Status
            	BEGIN
                  UPDATE LoadPlan  
                     SET [Status]  = @c_LP_New_Status, 
                         EditDate  = GETDATE(), 
                         EditWho = SUSER_SNAME(), 
                         TrafficCop = NULL  
                     WHERE LoadPlan.LoadKey = @c_DeleteLoadKey
         
                  SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
                  IF @n_err <> 0
                  BEGIN
                     SELECT @n_continue = 3
                     SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72009  
                     SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0)) 
                                       + ': Update Failed On Table LoadPlan. (ntrLoadPlanDetailAdd)' 
                                       + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
                  END             		
            	END            	
            END                                     
         END -- If Loadplan Detail Exists
   
         FETCH NEXT FROM CUR_DELETED_LOADKEY INTO @c_DeleteLoadKey 
      END -- WHILE 
      CLOSE CUR_DELETED_LOADKEY
      DEALLOCATE CUR_DELETED_LOADKEY
   END -- IF @n_continue = 1 or @n_continue = 2
   
   /* Added By SHONG ON 19th Mar 2010 */
   /* Delete PickHeader Record When Loadplan Detail Deleted */
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      DECLARE @c_DelLoadKey             NVARCHAR(10),
              @c_DelOrderKey            NVARCHAR(10), 
              @cKeepPickHDWhenLpdDelete NVARCHAR(10),  -- SHONG01 
              @c_PickSlipNo             NVARCHAR(10)  
              
      DECLARE CUR_DELETED_LP_LINE CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT DEL.LOADKEY, DEL.ORDERKEY, ORD.StorerKey  
      FROM DELETED DEL  
      JOIN ORDERS AS ORD WITH (NOLOCK) ON ORD.OrderKey = DEL.OrderKey  
      
      OPEN CUR_DELETED_LP_LINE
      
      FETCH NEXT FROM CUR_DELETED_LP_LINE INTO @c_DelLoadKey, @c_DelOrderKey, @c_StorerKey 
      
      WHILE @@FETCH_STATUS <> -1
      BEGIN
         IF EXISTS(SELECT 1 FROM PICKHEADER WITH (NOLOCK) 
                   WHERE ExternOrderKey = @c_DelLoadKey 
                   AND OrderKey = @c_DelOrderKey)
         BEGIN
         	-- SHONG01
         	SET @cKeepPickHDWhenLpdDelete = ''  

            SELECT @cKeepPickHDWhenLpdDelete = ISNULL(sValue, '0')   
            FROM  STORERCONFIG WITH (NOLOCK)   
            WHERE StorerKey = @c_StorerKey   
            AND   ConfigKey = 'KeepPickHDWhenLpdDelete'   
            AND   sVAlue = '1' 
      
            IF @cKeepPickHDWhenLpdDelete <> '1'
            BEGIN
               DELETE FROM PICKHEADER 
               WHERE ExternOrderKey = @c_DelLoadKey 
                 AND OrderKey = @c_DelOrderKey             	
            END
            ELSE 
            BEGIN
            	IF EXISTS(SELECT 1 FROM PICKHEADER WITH (NOLOCK) 
      	          WHERE OrderKey = @c_DelOrderKey 
      	          AND   ExternOrderKey = @c_DelLoadKey)
               BEGIN
               	DECLARE DEL_PickSlipNo CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               	SELECT p.PickHeaderKey 
               	FROM PICKHEADER AS p WITH (NOLOCK)
               	WHERE p.ExternOrderKey = @c_DelLoadKey 
               	AND   p.OrderKey = @c_DelOrderKey
               	
               	OPEN DEL_PickSlipNo 
               	FETCH NEXT FROM DEL_PickSlipNo INTO @c_PickSlipNo 
               	WHILE @@FETCH_STATUS = 0 
               	BEGIN
            	      UPDATE PICKHEADER 
            	       SET ExternOrderKey = '', 
            	           TrafficCop = NULL, 
            	           EditDate = GETDATE(), 
            	           EditWho = SUSER_SNAME() 
            	      WHERE ExternOrderKey = @c_DelLoadKey 
            	        AND OrderKey = @c_DelOrderKey  
            	        AND PickHeaderKey = @c_PickSlipNo  
            	   
            	      IF EXISTS(SELECT 1 FROM PackHeader AS ph WITH (NOLOCK)
            	                WHERE ph.PickSlipNo = @c_PickSlipNo 
            	                AND   ph.LoadKey = @c_DelLoadKey 
            	                AND   ph.OrderKey = @c_DelOrderKey)
            	      BEGIN
            	   	   UPDATE PackHeader  
            	   	      SET LoadKey = ''
            	   	   WHERE PickSlipNo = @c_PickSlipNo
            	   	            	   	
            	      END -- PackHeader 
            	      IF EXISTS(SELECT 1 FROM RefKeyLookup AS rkl WITH (NOLOCK)
            	                WHERE rkl.Pickslipno = @c_PickSlipNo 
            	                AND rkl.OrderKey = @c_DelOrderKey 
            	                AND rkl.Loadkey = @c_DelLoadKey)
            	      BEGIN
            	   	   UPDATE RefKeyLookup
            	   	      SET Loadkey = ''
            	   	   WHERE Pickslipno = @c_PickSlipNo 
            	         AND OrderKey = @c_DelOrderKey 
            	         AND Loadkey = @c_DelLoadKey
            	      END -- RefKeyLookup               		
               		
               	   FETCH NEXT FROM DEL_PickSlipNo INTO @c_PickSlipNo 
               	END      	      
               	CLOSE DEL_PickSlipNo
               	DEALLOCATE DEL_PickSlipNo               	        	      
               END -- PICKHEADER
            END -- @cKeepPickHDWhenLpdDelete = 1
         END 
         
         FETCH NEXT FROM CUR_DELETED_LP_LINE INTO @c_DelLoadKey, @c_DelOrderKey, @c_StorerKey  
      END -- WHILE
      CLOSE CUR_DELETED_LP_LINE
      DEALLOCATE CUR_DELETED_LP_LINE
   END    

   -- Start (KHLim01)
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      SELECT @b_success = 0         --    Start (KHLim02)
      EXECUTE nspGetRight  NULL,             -- facility  
                           NULL,             -- Storerkey  
                           NULL,             -- Sku  
                           'DataMartDELLOG', -- Configkey  
                           @b_success     OUTPUT, 
                           @c_authority   OUTPUT, 
                           @n_err         OUTPUT, 
                           @c_errmsg      OUTPUT  
      IF @b_success <> 1
      BEGIN
         SELECT @n_continue = 3
               ,@c_errmsg = 'ntrLoadPlanDetailDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.LoadPlanDetail_DELLOG ( LoadKey, LoadLineNumber )
         SELECT LoadKey, LoadLineNumber FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table ORDERS Failed. (ntrLoadPlanDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END
   -- End (KHLim01)

   /* #INCLUDE <TRMBODD2.SQL> */
   IF @n_continue=3  -- Error Occured - Process And Return
   BEGIN
      IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrLoadPlanDetailDelete'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END


GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrLoadPlanDetailUpdate                           */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: LOADPLANDETAIL UPDATE TRIGGER                               */
/*                                                                      */
/* Called By: LOADPLANDETAIL TABLE                                      */ 
/*                                                                      */
/* Parameters:                                                          */
/*                                                                      */
/* PVCS Version: 1.4	                                                  */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver.  Purposes                                */
/* 17-Mar-2009  TLTING    1.1   Change user_name() to SUSER_SNAME()     */
/* 30-Jun-2009  NJOW01    1.2   Disable field in loadplan detail screen */
/*                              SOS#138667                              */
/* 10-Sep-2009  NJOW02    1.3   SOS#142570 - update userdefine01 to     */
/*                              orders.issued                           */
/* 22-May-2012  TLTING01  1.4   DM integrity - add update editdate B4   */
/*                              TrafficCop for status < '9'             */ 
/* 28-Oct-2013  TLTING    1.5   Review Editdate column update           */  
/* 16-May-2017  NJOW03    1.6   WMS-1798 Allow config to call custom sp */
/* 28-Sep-2018  TLTING    1.7   remove row lock                         */  
/************************************************************************/

CREATE TRIGGER [dbo].[ntrLoadPlanDetailUpdate]
 ON  [dbo].[LoadPlanDetail]
 FOR UPDATE
 AS
 IF @@ROWCOUNT = 0
 BEGIN
     RETURN
 END
 SET NOCOUNT ON
 SET ANSI_NULLS OFF
 SET QUOTED_IDENTIFIER OFF
 SET CONCAT_NULL_YIELDS_NULL OFF

 DECLARE
 @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?
 ,         @n_err                int       -- Error number returned by stored procedure or this trigger
 ,         @n_err2 int              -- For Additional Error Detection
 ,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
 ,         @n_continue int                 
 ,         @n_starttcnt int                -- Holds the current transaction count
 ,         @c_preprocess NVARCHAR(250)         -- preprocess
 ,         @c_pstprocess NVARCHAR(250)         -- post process
 ,         @n_cnt int                  
 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

 IF UPDATE(ArchiveCop)
 BEGIN
    SELECT @n_continue = 4 
 END
 
 -- TLTING01
 IF EXISTS ( SELECT 1 FROM INSERTED, DELETED 
               WHERE INSERTED.LoadKey = DELETED.LoadKey AND INSERTED.LoadLineNumber = DELETED.LoadLineNumber
               AND ( INSERTED.[status] < '9' OR DELETED.[status] < '9' ) ) 
       AND (@n_continue = 1 or @n_continue = 2)
       AND NOT UPDATE(EditDate)
 BEGIN
    UPDATE LoadPlanDetail  
    SET EditDate = GETDATE(), EditWho = SUSER_SNAME(), Trafficcop = NULL
    FROM LoadPlanDetail, INSERTED
    WHERE LoadPlanDetail.LoadKey = INSERTED.LoadKey AND LoadPlanDetail.LoadLineNumber = INSERTED.LoadLineNumber
    AND LoadPlanDetail.[status] < '9'
    SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
    IF @n_err <> 0
    BEGIN
       SELECT @n_continue = 3
       SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=73102   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
       SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table LoadPlanDetail. (ntrLoadPlanDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
    END
 END


 IF UPDATE(TrafficCop)
 BEGIN
    SELECT @n_continue = 4 
 END
      /* #INCLUDE <TRMBODU1.SQL> */     
 
 --SOS#138667 remove the loadplandetail update blocking. By NJOW 08JUN09
 /*IF @n_continue = 1 or @n_continue = 2
 BEGIN
     SELECT @n_continue = 3
     SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=73102   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
     SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update of LoadPlanDetail is illegal. (ntrLoadPlanDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
 END*/

 IF ( @n_continue = 1 or @n_continue = 2 ) AND NOT UPDATE(EditDate)
 BEGIN
    UPDATE LoadPlanDetail  
    SET EditDate = GETDATE(), EditWho = SUSER_SNAME(), Trafficcop = NULL
    FROM LoadPlanDetail, INSERTED
    WHERE LoadPlanDetail.LoadKey = INSERTED.LoadKey AND LoadPlanDetail.LoadLineNumber = INSERTED.LoadLineNumber
    AND INSERTED.[status] in ( '9', 'C', 'CANC' )   -- tlting01
    SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
    IF @n_err <> 0
    BEGIN
       SELECT @n_continue = 3
       SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=73102   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
       SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table LoadPlanDetail. (ntrLoadPlanDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
    END
 END
 
 --NJOW03
 IF @n_continue=1 or @n_continue=2          
 BEGIN   	  
    IF EXISTS (SELECT 1 FROM DELETED d   ----->Put INSERTED if INSERT action
               JOIN ORDERS o WITH (NOLOCK) ON d.Orderkey = o.Orderkey
               JOIN storerconfig s WITH (NOLOCK) ON  o.storerkey = s.storerkey    
               JOIN sys.objects sys ON sys.type = 'P' AND sys.name = s.Svalue
               WHERE  s.configkey = 'LoadPlanDetailTrigger_SP')   -----> Current table trigger storerconfig
    BEGIN        	  
       IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL
          DROP TABLE #INSERTED
 
    	 SELECT * 
    	 INTO #INSERTED
    	 FROM INSERTED
        
       IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL
          DROP TABLE #DELETED
 
    	 SELECT * 
    	 INTO #DELETED
    	 FROM DELETED
 
       EXECUTE dbo.isp_LoadPlanDetailTrigger_Wrapper ----->wrapper for current table trigger
                 'UPDATE'  -----> @c_Action can be INSERT, UPDATE, DELETE
               , @b_Success  OUTPUT  
               , @n_Err      OUTPUT   
               , @c_ErrMsg   OUTPUT  
 
       IF @b_success <> 1  
       BEGIN  
          SELECT @n_continue = 3  
                ,@c_errmsg = 'ntrLoadPlanDetailUpdate ' + RTRIM(LTRIM(ISNULL(@c_errmsg,'')))  -----> Put current trigger name
       END  
       
       IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL
          DROP TABLE #INSERTED
 
       IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL
          DROP TABLE #DELETED
    END
 END    
 
/*
 -- Add for IDSV5, Extract from IDSPH
 /* Modified by June (FBR018) 20010920 */
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
    IF UPDATE(Weight) OR UPDATE(CUBE) OR UPDATE(ORDERKEY)
    BEGIN
       SELECT @c_insertloadkey = INSERTED.LoadKey
       FROM INSERTED
       SELECT  @n_weight = SUM(Weight), 
             @n_cube = SUM(Cube),
             @n_ordercnt = COUNT(OrderKey)
       FROM  LoadPlanDetail (NOLOCK)
       WHERE LoadKey = @c_insertloadkey
       SELECT @n_custcnt = COUNT(DISTINCT ORDERS.ConsigneeKey),
              @n_casecnt = SUM(LoadPlanDetail.casecnt)
       FROM  LoadPlanDetail (NOLOCK), ORDERS (NOLOCK)
       WHERE LoadPlanDetail.LoadKey = @c_insertloadkey
       AND   LoadPlanDetail.OrderKey = ORDERS.OrderKey
       AND   LoadPlanDetail.Loadkey = ORDERS.Loadkey
       SELECT @n_palletcnt = CONVERT(Integer, SUM(CASE WHEN PACK.Pallet = 0 THEN 0
          ELSE (ORDERDETAIL.OpenQty / PACK.Pallet) END))
       FROM  ORDERDETAIL (NOLOCK), LoadPlanDetail (NOLOCK), PACK (NOLOCK), SKU (NOLOCK)
       WHERE ORDERDETAIL.OrderKey = LoadPlanDetail.OrderKey
       AND ORDERDETAIL.Loadkey = LoadPlanDetail.Loadkey
       AND LoadPlanDetail.LoadKey = @c_insertloadkey
       AND ORDERDETAIL.Packkey = PACK.Packkey
       AND ORDERDETAIL.SKU = SKU.SKU
       IF @n_casecnt IS NULL SELECT @n_casecnt = 0
       IF @n_weight IS NULL SELECT @n_weight = 0
       IF @n_cube IS NULL SELECT @n_cube = 0
       IF @n_ordercnt IS NULL SELECT @n_ordercnt = 0
       IF @n_palletcnt IS NULL SELECT @n_palletcnt = 0
       IF @n_custcnt IS NULL SELECT @n_custcnt = 0
       UPDATE LoadPlan
       SET CustCnt = @n_custcnt,
          OrderCnt = @n_ordercnt,
          Weight = @n_weight,
          Cube = @n_cube,
          PalletCnt = @n_palletcnt,
          LoadPlan.CaseCnt = @n_casecnt,
          EditDate = GETDATE(),        --tlting
          EditWho = SUSER_SNAME()
       WHERE LoadPlan.LoadKey = @c_insertloadkey
       SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
       IF @n_err <> 0
       BEGIN
          SELECT @n_continue = 3
          SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72601   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
          SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table LoadPlan. (ntrLoadPlanDetailAdd)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
       END
    END 
 END /* End of Modified by June (FBR018) 20010920 */
*/

--NJOW02 Start
IF @n_continue = 1 or @n_continue = 2
BEGIN
	IF UPDATE(userdefine01)
	BEGIN		 
		 UPDATE ORDERS 
		 SET ORDERS.Issued = LEFT(ISNULL(INSERTED.Userdefine01,''),1),
		     ORDERS.Trafficcop = NULL,
		     EditDate = GETDATE(),    --tlting
           EditWho = SUSER_SNAME()
		 FROM ORDERS (NOLOCK) 
		 JOIN INSERTED ON (ORDERS.Orderkey = INSERTED.Orderkey)
		 JOIN STORERCONFIG SC (NOLOCK) ON (SC.Storerkey = ORDERS.Storerkey)
		 WHERE SC.svalue = '1' AND SC.Configkey = 'LPMapUdf01ToOrdIssued'		

     SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
     IF @n_err <> 0
     BEGIN
        SELECT @n_continue = 3
        SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72602   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
        SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table LoadPlanDetail. (ntrLoadPlanDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
     END
  END
END
--NJOW02 End

/* -- Remark for IDSV5 by June 28.Jun.02, Extract from IDSMY
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
    UPDATE ORDERS
    SET ORDERS.LoadKey = INSERTED.LoadKey,
        Trafficcop = NULL
    FROM ORDERS, INSERTED
    WHERE ORDERS.OrderKey = INSERTED.OrderKey
    SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
    IF @n_err <> 0
    BEGIN
       SELECT @n_continue = 3
       SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=73114   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
       SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table ORDERS. (ntrLoadPlanDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
    END
 END
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
    UPDATE ORDERDETAIL
    SET ORDERDETAIL.LoadKey = INSERTED.LoadKey,
        Trafficcop = NULL
    FROM ORDERDETAIL, INSERTED
    WHERE ORDERDETAIL.OrderKey = INSERTED.OrderKey
    SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
    IF @n_err <> 0
    BEGIN
       SELECT @n_continue = 3
       SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=73114   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
       SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table ORDERDETAIL. (ntrLoadPlanDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
    END
 END
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
    UPDATE ORDERS
    SET Status = '5'
    FROM ORDERS, INSERTED
    WHERE ORDERS.OrderKey = INSERTED.OrderKey
    AND INSERTED.Status = '5'
    SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
    IF @n_err <> 0
    BEGIN
       SELECT @n_continue = 3
       SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=73104   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
       SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table ORDERS. (ntrLoadPlanDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
    END
 END
*/
      /* #INCLUDE <TRMBODU2.SQL> */
 IF @n_continue=3  -- Error Occured - Process And Return
 BEGIN
    IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
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
    execute nsp_logerror @n_err, @c_errmsg, 'ntrLoadPlanDetailUpdate'
    RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012 
    RETURN
 END
 ELSE
 BEGIN
    WHILE @@TRANCOUNT > @n_starttcnt
    BEGIN
       COMMIT TRAN
    END
    RETURN
 END


GO
ALTER TABLE [dbo].[LoadPlanDetail] ADD CONSTRAINT [PK_LoadPlanDetail] PRIMARY KEY CLUSTERED ([LoadKey], [LoadLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_loadplandetail_Orderkey] ON [dbo].[LoadPlanDetail] ([OrderKey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LoadPlanDetail] WITH NOCHECK ADD CONSTRAINT [FK_LoadPlanDetail_LoadPlan] FOREIGN KEY ([LoadKey]) REFERENCES [dbo].[LoadPlan] ([LoadKey])
GO
GRANT SELECT ON  [dbo].[LoadPlanDetail] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[LoadPlanDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[LoadPlanDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[LoadPlanDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[LoadPlanDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Load Plan Detail consists of all the orders in a load that will be delivered together in one truck to specific drops (stops)', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total case count for the order', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'CaseCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Consignee in which the order will be delivered to', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'ConsigneeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total order cubic', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer company name', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'CustomerName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Cancel Date', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'DeliveryDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Ship to address - province', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'DeliveryPlace'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Loading door for the order', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'Door'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Load used by the Storer. ', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'ExternLoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller/storer external order number', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'ExternOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Load plan other reference number - if any', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'LoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Load detail line number', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'LoadLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total line numbers for the order', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'NoOfOrdLines'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date in which the orders were allocated', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'OrderDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipment Order number. It''s used to identify a specific shipment order record', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Priority:', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'Priority'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Delivery route under the order', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'Route'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Load plan status', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The sequence in which the order will be dropped off during the delivery round', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'Stop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of customer order', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'Type'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total order weight', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlanDetail', 'COLUMN', N'Weight'
GO
