SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
    
/************************************************************************/    
/* Stored Procedure: isp_RCM_WV_Update_OrdersRoute                      */    
/* Creation Date: 12-OCT-2022                                           */    
/* Copyright: LF                                                        */    
/* Written by:CHONGCS                                                   */    
/*                                                                      */    
/* Purpose: WMS-20882 -SG- PMI - Add in Routing logic                   */    
/*                                                                      */    
/* Called By: Wave Dymaic RCM configure at listname 'RCMConfig'         */    
/*                                                                      */    
/* Parameters:                                                          */    
/*                                                                      */    
/* PVCS Version: 1.0                                                    */    
/*                                                                      */    
/* Version: 5.4                                                         */    
/*                                                                      */    
/* Data Modifications:                                                  */    
/*                                                                      */    
/* Updates:                                                             */    
/* Date         Author    Ver.  Purposes                                */    
/* 12-OCT-2022  CHONGCS   1.0   Devops Scripts Combine                  */    
/************************************************************************/    
    
CREATE OR ALTER  PROCEDURE [dbo].[isp_RCM_WV_Update_OrdersRoute]    
   @c_Wavekey NVARCHAR(10),    
   @b_success  int OUTPUT,    
   @n_err      int OUTPUT,    
   @c_errmsg   NVARCHAR(225) OUTPUT,    
   @c_code     NVARCHAR(30)='',  
   @b_debug    NVARCHAR(1) = '0'  
AS    
BEGIN    
   SET NOCOUNT ON    
   SET ANSI_DEFAULTS OFF    
   SET QUOTED_IDENTIFIER OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
    
   DECLARE @n_continue int,    
           @n_cnt int,    
           @n_starttcnt int    
    
   DECLARE @c_Facility        NVARCHAR(5),    
           @c_Getwavekey      NVARCHAR(20),    
           @c_storerkey       NVARCHAR(15),    
           @c_Getstorerkey    NVARCHAR(15),    
           @c_Loadkey         NVARCHAR(10),    
           @c_orderkey        NVARCHAR(20),    
           @c_consigneekey    NVARCHAR(45),    
           @c_OrdRouteType    NVARCHAR(20),    
           @c_CLKRouteType    NVARCHAR(20),    
           @c_CLKMainRoute    NVARCHAR(20),    
           @c_mainroute       NVARCHAR(50),    
           @c_fixroute        NVARCHAR(50),    
           @c_clkshareroute   NVARCHAR(50),    
           @c_fixroverroute   NVARCHAR(50),    
           @c_shareroute      NVARCHAR(50),    
           @c_shareroverroute NVARCHAR(50),    
           @c_roverroute      NVARCHAR(50),    
           @c_clkroverroute   NVARCHAR(50),    
           @c_lastmodify      NVARCHAR(10),    
           @d_OHEditDate      DATETIME,    
           @c_OrdRoute        NVARCHAR(50),    
           @c_RouteUpdateTime NVARCHAR(10),    
           @d_RouteUpdateTime DATE,    
           @n_lastupdateday   INT  = 0,    
           @n_lastsupdateday  INT  = 0,    
           @c_prevorder       NVARCHAR(20),    
           @c_preconsignee    NVARCHAR(45)= '',    
           @c_ohstatus        NVARCHAR(20),    
           @c_prevmainroute   NVARCHAR(50) ='' ,    
           @c_UseRoverroute   NVARCHAR(1) = 'N',    
           @c_UseSharedroute  NVARCHAR(1) = 'N',    
           @c_originalRoute   NVARCHAR(50) = '',    
           @c_recntroute      NVARCHAR(1)  ='N' ,    
           @c_notctn          NVARCHAR(1)  ='N',    
           @n_ctncancelcases  INT = 0,     
           @n_ctncanceldrop   INT = 0,    
           @c_redeliverystatus NVARCHAR(5) ='4',    
           @c_podorderkey      NVARCHAR(20),    
           @c_podstorerkey     NVARCHAR(20),    
           @c_podconsigneekey  NVARCHAR(45),    
           @c_PODroutetype     NVARCHAR(50),    
           @c_PODGetOHroute    NVARCHAR(50),    
           @n_sharedlastupdateday   INT  = 0,    
           @c_SRouteUpdateTime NVARCHAR(10),    
           @d_SRouteUpdateTime DATE,    
           @c_slastmodify      NVARCHAR(10),    
           @c_updateroute      NVARCHAR(50) = '',    
           @c_updatecancelord  NVARCHAR(1) = 'N'      
           --@b_debug            NVARCHAR(1) = '0'       
                       
   DECLARE @n_maxcase           INT,    
           @n_maxdrop           INT,    
           @n_daycase           INT = 0,    
           @n_daycanccase       INT = 0,    
           @n_daydrop           INT = 0,    
           @n_ttldaycase        INT = 0,    
           @n_ttldaydrop        INT = 0,    
           @n_ttlcancel         INT,    
           @c_clkmaxcase        NVARCHAR(10),    
           @c_clkmaxdrop        NVARCHAR(10),    
           @c_clkttldaycase     NVARCHAR(10),    
           @c_clkttldaydrop     NVARCHAR(10),    
           @n_rowno             INT = 1                
    
   SELECT @n_Continue = 1, @b_success = 1, @n_starttcnt=@@TRANCOUNT, @c_errmsg='', @n_err=0      
    
   --Create temp table and populate data  
   IF @n_continue IN(1,2)  
   BEGIN      
      CREATE TABLE #TMPWVORDROUTE (    
            rowref          INT NOT NULL IDENTITY(1,1) PRIMARY KEY,    
            OrderKey        NVARCHAR(20),    
            Storerkey       NVARCHAR(20),    
            Wavekey         NVARCHAR(20),       
            consigneekey    NVARCHAR(45),    
            OHRoute         NVARCHAR(10),    
            Editdate        DATETIME,    
            routetype       NVARCHAR(50),    
            mainroute       NVARCHAR(50),    
            shareroute      NVARCHAR(50),    
            roverroute      NVARCHAR(50),    
            CancelORD       NVARCHAR(10) NULL,    
            --RtnPOD          NVARCHAR(1),    
            UpdateORD       DATETIME NULL,    
            OHStatus        NVARCHAR(20),    
            TTLCases        INT,    
            TTLDrop         INT,    
            ORDCases        INT,    
            ORDDrop         INT               
          
      )    
      CREATE INDEX IDX_TMPWVORDROUTE_Ord ON #TMPWVORDROUTE (wavekey,OrderKey, Storerkey)    
        
        
      CREATE TABLE #TMPWVORDCANC (    
            rowref          INT NOT NULL IDENTITY(1,1) PRIMARY KEY,    
            OrderKey        NVARCHAR(20),    
            Storerkey       NVARCHAR(20),    
            Wavekey         NVARCHAR(20),       
            consigneekey    NVARCHAR(45),    
            OHRoute         NVARCHAR(10),    
            routetype       NVARCHAR(50),    
            mainroute       NVARCHAR(50),    
            shareroute      NVARCHAR(50),    
            roverroute      NVARCHAR(50),    
            UpdateORD       DATETIME NULL,    
            OHStatus        NVARCHAR(20),    
            CancelORD       NVARCHAR(10) NULL,    
            TTLCancCases    INT,    
            TTLCancDrop     INT    
)       
        
      CREATE INDEX IDX_#TMPWVORDCANC_Ordcanc ON #TMPWVORDCANC (wavekey,OrderKey, Storerkey)       
        
      --Pupulate data   
      INSERT INTO #TMPWVORDROUTE    
      (    
          OrderKey,    
          Storerkey,    
          Wavekey,    
          consigneekey,    
          OHRoute,    
          Editdate,    
          routetype,    
          mainroute,    
          shareroute,    
          roverroute,    
          CancelORD,    
          --RtnPOD,    
          UpdateORD,    
          OHStatus,TTLCases,TTLDrop,ORDCases,ORDDrop    
      )    
       SELECT  DISTINCT oh.OrderKey    
               ,oh.StorerKey    
               ,wv.WaveKey AS wavekey    
               ,oh.ConsigneeKey AS consigneekey    
               ,oh.Route    
               ,oh.EditDate    
               ,ST.SUSR1 AS routetype    
               ,ST.SUSR2 AS mainroute    
               ,ST.SUSR3 AS shareroute    
               ,ST.SUSR4 AS roverroute    
               ,ISNULL(OH.UserDefine10,'N')    
               ,oh.UserDefine07,Oh.Status,0,0,ISNULL(oh.ContainerQty,0),1      
      FROM wave wv (NOLOCK)    
      JOIN orders oh (NOLOCK) ON oh.UserDefine09=wv.WaveKey    
      JOIN dbo.STORER ST (NOLOCK) ON ST.StorerKey = oh.ConsigneeKey AND ST.type='2'    
      JOIN dbo.PICKDETAIL PD WITH (NOLOCK) ON PD.OrderKey=oh.OrderKey    
      WHERE wv.WaveKey=@c_Wavekey    
      AND wv.Status <> '0'    
      AND oh.type in ('CCB2B', 'MANUALSO')     
      AND priority <> 'TOPGT'    
      AND pd.DropID <> ''    
      --AND CAST(oh.AddDate AS DATE)= CAST(GETDATE() AS DATE)    
      --AND ST.susr1='Fixed'    
      AND (oh.UserDefine07 IS NULL OR CAST(oh.UserDefine07 AS DATE) = CONVERT(NVARCHAR(10),GETDATE(),23))    
      --AND oh.Status <> 'CANC'    
      ORDER BY wv.WaveKey,oh.OrderKey,oh.ConsigneeKey    
        
      INSERT INTO #TMPWVORDCANC    
      (    
          OrderKey,    
          Storerkey,    
          Wavekey,    
          consigneekey,    
          OHRoute,    
          routetype,    
          mainroute,    
          shareroute,    
          roverroute,    
          UpdateORD,    
          OHStatus,    
          CancelORD,    
          TTLCancCases,    
          TTLCancDrop    
      )    
      SELECT DISTINCT oh.OrderKey    
                 ,oh.StorerKey    
                 ,wv.WaveKey AS wavekey    
                 ,oh.ConsigneeKey AS consigneekey    
                 ,oh.Route    
                 ,ST.SUSR1 AS routetype    
                 ,ST.SUSR2 AS mainroute    
                 ,ST.SUSR3 AS shareroute    
                 ,ST.SUSR4 AS roverroute    
                 ,oh.UserDefine07,oh.SOStatus    
                 ,'C',ISNULL(oh.ContainerQty,0),Cancord.ctndrop    
      FROM wave wv (NOLOCK)    
      JOIN orders oh (NOLOCK) ON oh.UserDefine09=wv.WaveKey    
      JOIN dbo.STORER ST (NOLOCK) ON ST.StorerKey = oh.ConsigneeKey AND ST.type='2'    
      CROSS APPLY (SELECT ord.OrderKey,ord.ConsigneeKey,COUNT(DISTINCT ord.consigneekey) AS ctndrop    
                   FROM dbo.ORDERS ord WITH (NOLOCK)    
                   WHERE ord.OrderKey=oh.OrderKey AND ord.StorerKey=oh.StorerKey    
                   GROUP BY ord.OrderKey,ord.ConsigneeKey) AS Cancord     
      WHERE wv.Status <> '0'    
      AND oh.type in ('CCB2B', 'MANUALSO')    
      AND priority <> 'TOPGT'    
      AND  CAST(oh.UserDefine07 AS DATE) = CONVERT(NVARCHAR(10),GETDATE(),23)    
      AND oh.soStatus = 'CANC' AND ISNULL(OH.UserDefine10,'N') <> 'C'    
      ORDER BY wv.WaveKey,oh.OrderKey,oh.ConsigneeKey    
        
      SELECT @c_redeliverystatus = ISNULL(CLK.Code,'4')    
      From codelkup CLK (nolock)     
      WHERE listname = 'PODSTATUS'     
      AND Description='Redelivery'    
        
      SELECT @c_Getstorerkey= MAX(storerkey)    
      FROM #TMPWVORDROUTE    
      WHERE Wavekey=@c_Wavekey    
        
      IF @b_debug = '5'    
      BEGIN      
          SELECT '#TMPWVORDROUTE',* FROM #TMPWVORDROUTE ORDER BY routetype    
      END     
   END   
     
   --Fix route    
   IF @n_continue IN(1,2)  
   BEGIN  
      --Loop Fixed route    
      DECLARE CUR_FixedRoute CURSOR LOCAL FAST_FORWARD READ_ONLY FOR    
      SELECT WaveKey AS wavekey    
                 ,ConsigneeKey AS consigneekey    
                 ,StorerKey    
                 ,OrderKey    
                 ,OHRoute    
                 ,EditDate    
                 ,routetype AS routetype    
                 ,mainroute AS mainroute    
                 ,shareroute AS shareroute    
                 ,roverroute AS roverroute    
      FROM #TMPWVORDROUTE    
      WHERE routetype = 'Fixed'    
      AND UpdateORD IS NULL    
      AND OHStatus <> 'CANC' AND (CancelORD ='N' OR CancelORD='')    
      ORDER BY WaveKey,OrderKey,ConsigneeKey    
        
      OPEN CUR_FixedRoute    
        
      FETCH NEXT FROM CUR_FixedRoute INTO @c_Getwavekey, @c_consigneekey  ,@c_StorerKey,@c_orderkey,@c_OrdRoute,    
                                         @d_OHEditDate,@c_OrdRouteType,@c_mainroute,@c_shareroute,@c_roverroute    
        
      WHILE @@FETCH_STATUS <> -1    
      BEGIN      
         SET @d_RouteUpdateTime ='1900-01-01'    
         --Check whether today had already trigger orders route update    
         -- IF EXISTS (SELECT 1 FROM ORDERS (NOLOCK) WHERE UserDefine09=@c_Wavekey AND CAST(UserDefine07 AS DATE)= CAST(GETDATE() AS DATE))    
         IF EXISTS (SELECT 1 FROM ORDERS (NOLOCK) WHERE storerkey=@c_storerkey AND CAST(UserDefine07 AS DATE)= CAST(GETDATE() AS DATE))    
         BEGIN    
             SET @c_recntroute ='Y'    
         END    
        
            
         --IF @n_rowno = 0  --1st record row    
         --BEGIN    
              --SET @c_prevmainroute = @c_mainroute    
              --SET @c_preconsignee = @c_consigneekey    
                
         SET @n_ctncancelcases = 0     
         SET @n_ctncanceldrop = 0    
         SET @c_lastmodify = ''    
         SET @c_updatecancelord ='N'    
         SET @c_notctn          ='N'    
         SET @c_originalRoute   = '' --fix  
           
         IF  @c_prevmainroute <> @c_mainroute    
         BEGIN    
            SET @c_UseRoverroute ='N'    
            --SET @b_debug ='1'    
         END    
           
         --Get latest route setup last update. if not today need to reset total day cases and total day drop id to 0    
         SELECT   @c_lastmodify = udf01     
         FROM codelkup (NOLOCK)     
         WHERE LISTNAME='PMIROUTE'    
         AND code = @c_mainroute AND Storerkey = @c_storerkey     
           
         SET @n_lastupdateday = 0    
           
         SET @d_RouteUpdateTime = CAST(@c_lastmodify AS DATE)    
           
         SET @n_lastupdateday = DATEDIFF(DAY,@d_RouteUpdateTime,GETDATE())    
           
         IF @b_debug='5'    
         BEGIN    
            SELECT @n_rowno 'rowno',@n_lastupdateday '@n_lastupdateday'    
         END    
           
         --if codelkup route setup last update not today date reset the total day cases and total day drop id to 0 and update last modify to today    
         IF @n_lastupdateday>= 1    
         BEGIN    
             SET @d_RouteUpdateTime = CAST(GETDATE() AS DATE)    
             --Update last update date if the udf01 not today date    
             UPDATE dbo.CODELKUP    
             SET UDF01 =  CAST(@d_RouteUpdateTime AS NVARCHAR(10))    
                ,udf04 = '0',udf05 ='0'    
             WHERE LISTNAME='PMIROUTE'    
             AND code = @c_mainroute AND Storerkey = @c_storerkey        
           
             IF @b_debug ='5'    
             BEGIN      
                SELECT 'update codelkup last update', @n_rowno 'rowno',@c_mainroute'@c_mainroute',@c_storerkey '@c_storerkey', @d_RouteUpdateTime '@d_RouteUpdateTime'    
             END    
                
             SELECT @n_err = @@ERROR    
               
             IF @n_err <> 0                                                                                                                                                                   
             BEGIN                                                                                                                                                                                      
                SELECT @n_Continue = 3                                                                                                                                                                  
                SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 64020   -- Should Be Set To The SQL Errmessage but I don't know how to do so.                                                
                SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update fixed route Codelkup last update Failed. (isp_RCM_WV_Update_OrdersRoute)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '                 
                GOTO ENDPROC     
             END      
         END      
           
       
         IF @b_debug='5'    
         BEGIN    
            SELECT 'chk original codelkup',@n_rowno 'rowno',* FROM dbo.CODELKUP (NOLOCK) WHERE LISTNAME='PMIROUTE'    
                 AND code = @c_mainroute AND Storerkey = @c_storerkey AND UDF01 = convert(NVARCHAR(10),GETDATE(),23)    
           
         END    
               
         SELECT  @c_CLKRouteType = code2 ,@c_CLKMainRoute = code,    
                 @c_clkshareroute =short ,@c_clkroverroute = long ,    
                 @c_lastmodify = udf01 ,  @c_clkmaxcase = udf02 ,    
                 @c_clkmaxdrop = udf03 ,  @c_clkttldaycase = udf04 ,    
                 @c_clkttldaydrop = udf05    
         FROM codelkup (NOLOCK)     
         WHERE LISTNAME='PMIROUTE'    
         AND code = @c_mainroute AND Storerkey = @c_storerkey AND UDF01 = convert(NVARCHAR(10),GETDATE(),23)    
           
         SET @n_ttldaycase = CAST(@c_clkttldaycase AS INT)    
         SET @n_ttldaydrop =  CAST(@c_clkttldaydrop AS INT)     
           
         IF @b_debug ='5'    
         BEGIN    
             SELECT 'retrieve codelkup ttl ',@n_rowno 'rowno',@c_orderkey '@c_orderkey',@c_lastmodify '@c_lastmodify',@c_CLKRouteType '@c_CLKRouteType',@c_CLKMainRoute '@c_CLKMainRoute',@c_clkmaxcase '@c_clkmaxcase',@c_clkmaxdrop '@c_clkmaxdrop'    
                 , @c_clkttldaycase '@c_clkttldaycase', @c_clkttldaydrop '@c_clkttldaydrop',@n_ttldaycase '@n_ttldaycase',@n_ttldaydrop '@n_ttldaydrop', @c_recntroute '@c_recntroute'    
         END    
           
         IF @c_recntroute ='Y'    
         BEGIN      
             --Check if the consigneekey already update the route or not in same day without consider wave. if the consignee already assign route not need count and update to same consignee route     
             IF EXISTS (SELECT 1 FROM dbo.ORDERS (NOLOCK) WHERE consigneekey =@c_consigneekey AND CAST(UserDefine07 AS DATE)= CAST(GETDATE() AS DATE))    
             BEGIN    
                SELECT TOP 1 @c_originalRoute = OH.route    
                FROM dbo.ORDERS OH (NOLOCK)    
                WHERE consigneekey =@c_consigneekey AND CAST(OH.UserDefine07 AS DATE)= CAST(GETDATE() AS DATE)    
                ORDER BY OH.AddDate DESC    
                  
                SET @c_notctn ='Y'    
             END    
           
             IF @n_rowno =1    
             BEGIN    
                --Check whether there had any orders cancel which already assign route as need to minus out total case and total drop id    
                --Ignoe if the cancel orders had been deduct before with orders userdefine07 = 'C'    
                --SELECT @n_ctncancelord = COUNT(DISTINCT Oh.orderkey)     
                IF EXISTS (SELECT 1 FROM #TMPWVORDCANC WHERE CAST(UpdateORD AS DATE)= CAST(GETDATE() AS DATE) AND OHRoute=@c_mainroute AND OHStatus='CANC')    
                BEGIN                         
                   SET @n_ctncancelcases = 0    
                   SET @n_ctncanceldrop = 0    
                   SET @c_updatecancelord ='Y'    
                     
                   SELECT  @n_ctncancelcases = TTLCancCases    
                   --FROM pickdetail PD (nolock)     
                   FROM #TMPWVORDCANC    
                   --AND TR.Wavekey = oh.UserDefine09     
                   WHERE  OHRoute = @c_mainroute AND CAST(UpdateORD AS DATE)= CAST(GETDATE() AS DATE) AND CancelORD <> 'C'    
                   AND OHStatus='CANC'     
                     
                   SELECT @n_ctncanceldrop = TTLCancDrop    
                   FROM #TMPWVORDCANC    
                   --AND TR.Wavekey = oh.UserDefine09     
                   WHERE OHRoute = @c_mainroute AND CAST(UpdateORD AS DATE)= CAST(GETDATE() AS DATE) AND CancelORD <> 'C'     
                   AND OHStatus='CANC'                        
                END    
             END     
         END    
           
         SET @n_daycase = 0    
           
         IF @b_debug='9'    
         BEGIN    
            SELECT @c_notctn '@c_notctn', @c_recntroute '@c_recntroute',@c_consigneekey '@c_consigneekey' , @n_ttldaycase '@b4_ttldaycase',@n_ttldaydrop '@b4_ttldaydrop',    
            CAST(@c_clkmaxdrop AS INT) 'CAST(@c_clkmaxdrop AS INT)', CAST(@c_clkmaxcase AS INT) 'CAST(@c_clkmaxcase AS INT)'    
         END    
           
         IF  @c_notctn ='N' --get total cases    
         BEGIN    
            SET @n_daycase = 0    
            SET @n_daydrop = 0      
            SELECT @n_daycase = COUNT(DISTINCT DROPID)     
            FROM pickdetail (nolock)     
            WHERE storerkey = @c_storerkey    
            AND orderkey = @c_orderkey    
                      
            IF @c_preconsignee <> @c_consigneekey    
            BEGIN     
               SET @n_daydrop = @n_daydrop + 1    
            END       
           
            SET @n_ttldaycase = @n_ttldaycase + @n_daycase - @n_ctncancelcases    
            SET @n_ttldaydrop = @n_ttldaydrop + @n_daydrop - @n_ctncanceldrop    
         END    
           
         --check if total day cases or day dropid more than maximum days case and day drop allow assign to rover route    
         IF @n_ttldaydrop > CAST(@c_clkmaxdrop AS INT) OR @n_ttldaycase > CAST(@c_clkmaxcase AS INT)    
         BEGIN    
               SET @c_UseRoverroute ='Y'    
               IF @n_ttldaydrop > CAST(@c_clkmaxdrop AS INT)    
               BEGIN     
                   SET @n_ttldaydrop =  @n_daycase     
               END     
           
               IF @n_ttldaycase > CAST(@c_clkmaxcase AS INT)    
               BEGIN     
                   SET @n_ttldaycase =  @n_daydrop     
               END     
         END       
           
         IF @b_debug ='9'    
         BEGIN    
            SELECT 'retrieve orders ttl ',@n_rowno 'rowno',@c_orderkey '@c_orderkey' ,@c_UseRoverroute '@c_UseRoverroute',@c_originalRoute '@c_originalRoute',@c_mainroute '@c_mainroute',@c_roverroute '@c_roverroute'    
                   , @n_ttldaycase '@n_ttldaycase', @n_ttldaydrop '@n_ttldaydrop', @c_UseRoverroute '@c_UseRoverroute',@c_clkmaxdrop '@c_clkmaxdrop',@c_clkmaxcase '@c_clkmaxcase'    
            SELECT @n_ctncancelcases '@n_ctncancelcases',@n_ctncanceldrop '@n_ctncanceldrop'    
         END     
           
         --Update #TM TABLE    
         UPDATE #TMPWVORDROUTE    
         SET OHRoute =   CASE WHEN @c_UseRoverroute = 'N' THEN CASE WHEN @c_originalRoute = '' THEN @c_mainroute ELSE @c_originalRoute END ELSE @c_roverroute END    
             ,UpdateORD = CAST(GETDATE() AS DATE)    
             ,CancelORD = CASE WHEN @c_updatecancelord ='Y' THEN 'C' ELSE 'N' END    
             ,TTLCases = @n_daycase     
             ,TTLDrop = @n_daydrop    
         WHERE OrderKey   = @c_orderkey AND storerkey = @c_storerkey    
             
           
         --Update the route , userdefine10 and containerqty for orders cases    
         UPDATE ORDERS WITH (ROWLOCK)    
         SET Route = CASE WHEN @c_UseRoverroute = 'N' THEN CASE WHEN @c_originalRoute = '' THEN @c_mainroute ELSE @c_originalRoute END ELSE @c_roverroute END    
           ,  userdefine07 = CAST(GETDATE() AS DATE)    
         --  ,  userdefine10 = ''    
           ,  containerqty = @n_daycase    
           , TrafficCop   = NULL    
           , EditDate     = GETDATE()    
           , EditWho      = SUSER_SNAME()    
         WHERE OrderKey   = @c_orderkey AND storerkey = @c_storerkey    
           
         SELECT @n_err = @@ERROR    
             
         IF @n_err <> 0                                                                                                                                                                   
         BEGIN                                                                                                                                                                                      
            SELECT @n_Continue = 3                                                                                                                                                                  
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 64030   -- Should Be Set To The SQL Errmessage but I don't know how to do so.                                                
            SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update fixed route ORDERS Failed. (isp_RCM_WV_Update_OrdersRoute)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '     
            GOTO ENDPROC           
         END    
           
         --Update the orders table cancel route    
         IF @c_updatecancelord='Y'    
         BEGIN    
            UPDATE ORDERS WITH (ROWLOCK)    
            SET userdefine10 = TRC.CancelORD    
              , TrafficCop   = NULL    
              , EditDate     = GETDATE()    
              , EditWho      = SUSER_SNAME()    
            FROM ORDERS OH --WITH (NOLOCK)    
            JOIN #TMPWVORDCANC TRC ON TRC.OrderKey=OH.OrderKey AND TRC.Storerkey=OH.StorerKey    
            WHERE TRC.Wavekey= @c_Getwavekey AND TRC.mainroute= @c_mainroute AND TRC.CancelORD='C'     
            --WHERE OH.OrderKey   = @c_orderkey AND OH.storerkey = @c_storerkey    
             
            SELECT @n_err = @@ERROR    
                
            IF @n_err <> 0                                                                                                                                                                   
            BEGIN                                                                                                                                                                                      
               SELECT @n_Continue = 3                                                                                                                                                                  
               SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 64100  -- Should Be Set To The SQL Errmessage but I don't know how to do so.                                                
               SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update cancel ORDERS Failed. (isp_RCM_WV_Update_OrdersRoute)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '     
               GOTO ENDPROC           
            END    
         END    
           
         --Update total days cases and total day dropid based on route    
         UPDATE dbo.CODELKUP     
         SET udf04 = CASE WHEN @c_UseRoverroute='N'THEN CAST( @n_ttldaycase AS NVARCHAR(10)) ELSE udf04 END    
            ,UDF05 = CASE WHEN @c_UseRoverroute='N'THEN CAST(@n_ttldaydrop AS NVARCHAR(10)) ELSE udf05 END     
         WHERE LISTNAME='PMIROUTE'    
         AND code = @c_mainroute AND Storerkey = @c_storerkey AND UDF01 = convert(NVARCHAR(10),GETDATE(),23)    
           
         SELECT @n_err = @@ERROR    
           
         IF @n_err <> 0                                                                                                                                                                   
         BEGIN                                                                                                                                                                                      
            SELECT @n_Continue = 3                                                                                                                                                                  
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 64040   -- Should Be Set To The SQL Errmessage but I don't know how to do so.                                                
            SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Codelkup fixed route for total day cases Failed. (isp_RCM_WV_Update_OrdersRoute)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '          
            GOTO ENDPROC             
         END    
           
         IF @b_debug='1'    
         BEGIN    
            SELECT 'chk update codelkup',@n_rowno 'rowno',* FROM dbo.CODELKUP (NOLOCK) WHERE LISTNAME='PMIROUTE'    
            AND code = @c_mainroute AND Storerkey = @c_storerkey AND UDF01 = convert(NVARCHAR(10),GETDATE(),23)          
         END    
                 
         SET @n_rowno = @n_rowno + 1    
         SET @c_prevmainroute = @c_mainroute    
         SET @c_preconsignee = @c_consigneekey    
           
         IF @c_UseRoverroute<>'N'    
         BEGIN    
            SET @c_UseRoverroute ='N'    
         END    
        
         FETCH NEXT FROM CUR_FixedRoute INTO @c_Getwavekey, @c_consigneekey  ,@c_StorerKey,@c_orderkey,@c_OrdRoute,    
                                             @d_OHEditDate,@c_OrdRouteType,@c_mainroute,@c_shareroute,@c_roverroute    
      END      
      CLOSE CUR_FixedRoute    
      DEALLOCATE CUR_FixedRoute    
      --End Loop Main Route    
    
   IF @b_debug ='5'    
   BEGIN    
      SELECT 'chk',* FROM #TMPWVORDROUTE ORDER BY routetype     
       
      SELECT 'end fixed route loop'       
   END    
   --GOTO ENDPROC    
   END --end fix route  
  
   --Share route    
   IF @n_continue IN(1,2)  
   BEGIN  
      --Loop share Route      
      IF @b_debug='8'    
      BEGIN    
         SELECT 'start shared route', * FROM #TMPWVORDROUTE         
         SELECT 'canc',* FROM #TMPWVORDCANC    
      end    
        
      SET @c_UseRoverroute='N'    
      SET @c_UseSharedroute ='N'    
      SET @c_prevmainroute = ''    
        
      DECLARE CUR_ShareRoute  CURSOR LOCAL FAST_FORWARD READ_ONLY FOR    
      SELECT WaveKey AS wavekey    
            ,ConsigneeKey AS consigneekey    
            ,StorerKey    
            ,OrderKey    
            ,OHRoute    
            ,EditDate    
            ,routetype AS routetype    
            ,mainroute AS mainroute    
            ,shareroute AS shareroute    
            ,roverroute AS roverroute    
      FROM #TMPWVORDROUTE    
      WHERE routetype = 'Shared'    
      AND UpdateORD IS NULL    
      AND OHStatus <> 'CANC' AND (CancelORD ='N' OR CancelORD='')    
      ORDER BY WaveKey,OrderKey,ConsigneeKey    
        
      OPEN CUR_ShareRoute     
        
      FETCH NEXT FROM CUR_ShareRoute  INTO @c_Getwavekey, @c_consigneekey  ,@c_StorerKey,@c_orderkey,@c_OrdRoute,    
                                           @d_OHEditDate,@c_OrdRouteType,@c_mainroute,@c_shareroute,@c_roverroute    
        
      WHILE @@FETCH_STATUS <> -1    
      BEGIN    
         --SET @b_debug='1'    
           
         SET @c_updateroute =''    
         SET @d_RouteUpdateTime ='1900-01-01'    
         SET @c_updateroute = @c_mainroute    
         SET @c_notctn = 'N'  --Fix  
           
         IF  @c_prevmainroute <> @c_mainroute    
         BEGIN    
              SET @c_UseRoverroute ='N'    
              --SET @b_debug ='1'    
         END    
           
         --Check whether today had already trigger orders route update or not    
         IF EXISTS (SELECT 1 FROM ORDERS (NOLOCK) WHERE storerkey=@c_storerkey AND CAST(UserDefine07 AS DATE)= CAST(GETDATE() AS DATE))    
         BEGIN    
            SET @c_recntroute ='Y'    
         END    
           
         IF @b_debug='2'    
         BEGIN    
            SELECT 'start share route'    
            SELECT 'share route s',* FROM #TMPWVORDROUTE WHERE routetype='shared'    
         END    
               
          --IF @n_rowno = 0  --1st record row    
          --BEGIN    
              --SET @c_prevmainroute = @c_mainroute    
              --SET @c_preconsignee = @c_consigneekey    
           
         SET @n_ctncancelcases = 0     
         SET @n_ctncanceldrop = 0    
         SET @c_lastmodify = ''    
         SET @c_updatecancelord ='N'     
           
         --Get latest route setup last update. if not today need to reset total day cases and total day drop id to 0    
         SELECT   @c_lastmodify = udf01     
         FROM codelkup (NOLOCK)     
         WHERE LISTNAME='PMIROUTE'    
         AND code = @c_mainroute AND Storerkey = @c_storerkey     
           
           
         SET @n_lastupdateday = 0    
           
         SET @d_RouteUpdateTime = CAST(@c_lastmodify AS DATE)    
           
         SET @n_lastupdateday = DATEDIFF(DAY,@d_RouteUpdateTime,GETDATE())    
           
         -- SELECT @n_lastupdateday 'share route @n_lastupdateday'    
           
         --if codelkup route setup last update not today date reset the total day cases and total day drop id to 0 and update last modify to today    
         IF @n_lastupdateday>= 1    
         BEGIN    
            SET @d_RouteUpdateTime = CAST(GETDATE() AS DATE)    
            --Update last update time    
            UPDATE dbo.CODELKUP    
            SET UDF01 =  CAST(@d_RouteUpdateTime AS NVARCHAR(10))    
               ,udf04 = '0',udf05 ='0'    
            WHERE LISTNAME='PMIROUTE'    
            AND code = @c_mainroute AND Storerkey = @c_storerkey      
              
            IF @b_debug='2'    
            BEGIN     
               SELECT 'update share codelkup last update', @c_mainroute'@c_mainroute',@c_storerkey '@c_storerkey', @d_RouteUpdateTime '@d_RouteUpdateTime'    
            END     
              
            SELECT @n_err = @@ERROR    
              
            IF @n_err <> 0                                                                                                                                                                   
            BEGIN                                                                                                                                                                                      
               SELECT @n_Continue = 3                                                                                                                                                                  
               SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 64050   -- Should Be Set To The SQL Errmessage but I don't know how to do so.                                                
               SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update shared route Codelkup last update Failed. (isp_RCM_WV_Update_OrdersRoute)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '                 
               GOTO ENDPROC     
            END      
         END      
           
         SELECT @c_CLKRouteType = code2 ,@c_CLKMainRoute = code,    
                @c_clkshareroute =short ,@c_clkroverroute = long ,    
                @c_lastmodify = udf01 ,  @c_clkmaxcase = udf02 ,    
                @c_clkmaxdrop = udf03 ,  @c_clkttldaycase = udf04 ,    
                @c_clkttldaydrop = udf05              FROM codelkup (NOLOCK)     
         WHERE LISTNAME='PMIROUTE'    
         AND code = @c_mainroute AND Storerkey = @c_storerkey AND UDF01 = convert(NVARCHAR(10),GETDATE(),23)    
           
           
         SET @n_ttldaycase = CAST(@c_clkttldaycase AS INT)    
         SET @n_ttldaydrop =  CAST(@c_clkttldaydrop AS INT)     
           
         IF @b_debug='2'    
         BEGIN    
              SELECT 'shared route',@c_lastmodify '@c_lastmodify',@c_CLKRouteType '@c_CLKRouteType',@c_CLKMainRoute '@c_CLKMainRoute',@c_clkmaxcase '@c_clkmaxcase',@c_clkmaxdrop '@c_clkmaxdrop'    
                     , @c_clkttldaycase '@c_clkttldaycase', @c_clkttldaydrop '@c_clkttldaydrop',@n_ttldaycase '@n_ttldaycase',@n_ttldaydrop '@n_ttldaydrop', @c_consigneekey '@c_consigneekey'    
         END    
           
         IF @b_debug='8'    
         BEGIN    
            SELECT @c_recntroute '@c_recntroute'    
         END    
           
         IF @c_recntroute ='Y'    
         BEGIN      
            --Check if the consigneekey already update the route or not in same day without consider wave. if the consignee already assign route not need count       
            IF EXISTS (SELECT 1 FROM dbo.ORDERS (NOLOCK) WHERE consigneekey =@c_consigneekey AND CAST(UserDefine07 AS DATE)= CAST(GETDATE() AS DATE))    
            BEGIN    
               SELECT TOP 1 @c_originalRoute = OH.route    
               FROM dbo.ORDERS OH (NOLOCK)    
               WHERE consigneekey =@c_consigneekey AND CAST(OH.UserDefine07 AS DATE)= CAST(GETDATE() AS DATE)    
               ORDER BY OH.AddDate DESC    
                 
               SET @c_notctn ='Y'    
               SET @c_updateroute =@c_originalRoute      
            END    
           
            IF @n_rowno =1    
            BEGIN    
              --Check whether there had any orders cancel which already assign route as need to minus out total case and total drop id    
              --Ignoe if the cancel orders had been deduct before with orders userdefine07 = 'C'    
               --SELECT @n_ctncancelord = COUNT(DISTINCT Oh.orderkey)     
               IF EXISTS (SELECT 1 FROM #TMPWVORDCANC WHERE CAST(UpdateORD AS DATE)= CAST(GETDATE() AS DATE) AND OHRoute=@c_mainroute AND OHStatus='CANC')    
               BEGIN      
                  SET @n_ctncancelcases = 0    
                  SET @n_ctncanceldrop = 0    
                  SET @c_updatecancelord ='Y'        
                    
                  IF @b_debug='8'    
                  BEGIN    
                     SELECT 'start chk canc ord' ,@c_mainroute '@c_mainroute' ,@c_OrdRouteType '@c_OrdRouteType'    
                     SELECT  @n_ctncancelcases = TTLCancCases    
                     --FROM pickdetail PD (nolock)     
                     FROM #TMPWVORDCANC    
                     --AND TR.Wavekey = oh.UserDefine09     
                     WHERE  OHRoute = @c_mainroute AND CAST(UpdateORD AS DATE)= CAST(GETDATE() AS DATE) AND CancelORD = 'C'    
                     AND OHStatus='CANC'       
                  END    
                    
                  SELECT  @n_ctncancelcases = TTLCancCases    
                  --FROM pickdetail PD (nolock)     
                  FROM #TMPWVORDCANC    
                  --AND TR.Wavekey = oh.UserDefine09     
                  WHERE OHRoute = @c_mainroute AND CAST(UpdateORD AS DATE)= CAST(GETDATE() AS DATE) AND CancelORD = 'C'    
                  AND OHStatus='CANC'     
                    
                  SELECT @n_ctncanceldrop = TTLCancDrop    
                  FROM #TMPWVORDCANC    
                  --AND TR.Wavekey = oh.UserDefine09     
                  WHERE  OHRoute = @c_mainroute AND CAST(UpdateORD AS DATE)= CAST(GETDATE() AS DATE) AND CancelORD = 'C'     
                  AND OHStatus='CANC'     
               END    
            END     
           
            IF @b_debug='8'    
            BEGIN     
               SELECT 'chk whether is cancel ord or not',@n_ctncancelcases '@n_ctncancelcases',@n_ctncanceldrop '@n_ctncanceldrop',@c_updatecancelord '@c_updatecancelord'    
            END    
         END    
           
         SET @n_daycase = 0    
           
         IF @b_debug='8'    
         BEGIN    
            SELECT @c_notctn '@c_notctn',@c_originalRoute '@c_originalRoute',@c_updateroute '@c_updateroute'    
            SELECT 'cancrote',* FROM #TMPWVORDCANC    
            SELECT 'before shared route chk ttl',@n_ttldaycase '@n_ttldaycase',@n_daycase '@n_daycase',@n_ctncancelcases'@n_ctncancelcases'      
         END     
           
         IF  @c_notctn ='N'     
         BEGIN              
            SET @n_daycase = 0    
            SET @n_daydrop = 0      
            SELECT @n_daycase = COUNT(DISTINCT DROPID)     
            FROM pickdetail (nolock)     
            WHERE storerkey = @c_storerkey --and  status <> '0'     
            AND orderkey = @c_orderkey    
                           
            IF @c_preconsignee <> @c_consigneekey    
            BEGIN     
               SET @n_daydrop = @n_daydrop + 1    
            END       
           
            SET @n_ttldaycase = @n_ttldaycase + @n_daycase - @n_ctncancelcases    
            SET @n_ttldaydrop = @n_ttldaydrop + @n_daydrop - @n_ctncanceldrop    
         END    
           
         IF @b_debug='8'    
         BEGIN    
            SELECT 'after shared route chk ttl',@n_ttldaycase '@n_ttldaycase',@n_ttldaydrop '@n_ttldaydrop',@n_daycase '@n_daycase',@n_daydrop '@n_daydrop',@n_ctncancelcases'@n_ctncancelcases', @n_ctncanceldrop'@n_ctncanceldrop'    
         END       
           
         --check if total day cases or day dropid more than maximum days case and day drop allow assign to share route    
         IF @n_ttldaydrop > CAST(@c_clkmaxdrop AS INT) OR @n_ttldaycase > CAST(@c_clkmaxcase AS INT)    
         BEGIN    
            --SELECT 'share route chk over limit'     
            SET @c_UseSharedroute ='Y'    
            SET @c_UseRoverroute ='N'     
              
            SET @c_updateroute = @c_shareroute    
              
            SET @n_lastsupdateday = 0    
              
              
            IF @n_ttldaydrop > CAST(@c_clkmaxdrop AS INT)    
            BEGIN     
                SET @n_ttldaydrop = - @n_daycase     
            END     
              
            IF @n_ttldaycase > CAST(@c_clkmaxcase AS INT)    
            BEGIN     
                SET @n_ttldaycase = - @n_daydrop     
            END     
              
            SELECT @c_slastmodify = udf01     
            FROM  dbo.CODELKUP (NOLOCK)     
            WHERE LISTNAME='PMIROUTE'    
            AND code = @c_shareroute AND Storerkey = @c_storerkey     
           
           
            SET @n_sharedlastupdateday = 0    
              
            SET @d_SRouteUpdateTime = CAST(@c_slastmodify AS DATE)    
              
            SET @n_lastsupdateday = DATEDIFF(DAY,@d_SRouteUpdateTime,GETDATE())    
              
            --SELECT @n_lastsupdateday 'share route @n_lastsupdateday', @c_slastmodify '@c_slastmodify'    
              
            IF @n_lastsupdateday>= 1    
            BEGIN    
               SET @d_SRouteUpdateTime = CAST(GETDATE() AS DATE)    
              
               UPDATE dbo.CODELKUP    
               SET UDF01 =  CAST(@d_SRouteUpdateTime AS NVARCHAR(10))    
                  ,udf04 = '0',udf05 ='0'    
               WHERE LISTNAME='PMIROUTE'    
               AND code = @c_shareroute AND Storerkey = @c_storerkey     
              
               IF @b_debug='1'    
               BEGIN      
                 SELECT 'update share codelkup last update', @c_shareroute '@c_shareroute',@c_storerkey '@c_storerkey', @d_RouteUpdateTime '@d_RouteUpdateTime'    
               END    
              
               SELECT @n_err = @@ERROR    
               
               IF @n_err <> 0                                                                                                                                                                   
               BEGIN                                                                                                                                                                                      
                  SELECT @n_Continue = 3                                                                                                    
                  SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 64060   -- Should Be Set To The SQL Errmessage but I don't know how to do so.                                                
                  SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update shared route alternate route Codelkup last update Failed. (isp_RCM_WV_Update_OrdersRoute)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '                 
                  GOTO ENDPROC     
               END      
            END      
           
            -- SELECT 'useshareroute',* FROM #TMPPMIORDTBLCLK    
           
            IF @c_UseSharedroute='Y'    
            BEGIN    
               SELECT  @c_CLKRouteType = code2 ,@c_CLKMainRoute = code,    
                       @c_clkshareroute =short ,@c_clkroverroute = long ,    
                       @c_lastmodify = udf01 ,  @c_clkmaxcase = udf02 ,    
                       @c_clkmaxdrop = udf03 ,  @c_clkttldaycase = udf04 ,    
                       @c_clkttldaydrop = udf05    
               FROM dbo.CODELKUP (NOLOCK)      
               WHERE LISTNAME='PMIROUTE'    
               AND code = @c_shareroute AND Storerkey = @c_storerkey AND UDF01 = convert(NVARCHAR(10),GETDATE(),23)    
                 
               SET @n_ttldaycase = CAST(@c_clkttldaycase AS INT)    
               SET @n_ttldaydrop =  CAST(@c_clkttldaydrop AS INT)     
                 
               IF EXISTS (SELECT 1 FROM #TMPWVORDCANC WHERE CAST(UpdateORD AS DATE)= CAST(GETDATE() AS DATE) AND OHRoute=@c_shareroute AND OHStatus='CANC')    
               BEGIN                      
                  SET @n_ctncancelcases = 0    
                  SET @n_ctncanceldrop = 0    
                  SET @c_updatecancelord ='Y'        
                    
                  IF @b_debug='8'    
                  BEGIN    
                     SELECT 'start chk canc ord' ,@c_shareroute '@c_shareroute' ,@c_OrdRouteType '@c_OrdRouteType'    
                     SELECT  @n_ctncancelcases = TTLCancCases    
                     --FROM pickdetail PD (nolock)     
                     FROM #TMPWVORDCANC    
                     --AND TR.Wavekey = oh.UserDefine09     
                     WHERE  OHRoute = @c_shareroute AND CAST(UpdateORD AS DATE)= CAST(GETDATE() AS DATE) AND CancelORD = 'C'    
                     AND OHStatus='CANC'       
                  END    
                    
                  SELECT  @n_ctncancelcases = TTLCancCases    
                  --FROM pickdetail PD (nolock)     
                  FROM #TMPWVORDCANC    
                  --AND TR.Wavekey = oh.UserDefine09     
                  WHERE OHRoute = @c_shareroute AND CAST(UpdateORD AS DATE)= CAST(GETDATE() AS DATE) AND CancelORD = 'C'    
                  AND OHStatus='CANC'     
                    
                  SELECT @n_ctncanceldrop = TTLCancDrop    
                  FROM #TMPWVORDCANC    
                  --AND TR.Wavekey = oh.UserDefine09     
                  WHERE  routetype =  @c_OrdRouteType    
                  AND OHRoute = @c_shareroute AND CAST(UpdateORD AS DATE)= CAST(GETDATE() AS DATE) AND CancelORD = 'C'     
                  AND OHStatus='CANC'                     
               END     
                 
               SET @n_ttldaycase = @n_ttldaycase + @n_daycase - @n_ctncancelcases    
               SET @n_ttldaydrop = @n_ttldaydrop + @n_daydrop - @n_ctncanceldrop    
                 
               --SELECT 'use share route', @n_ttldaycase '@n_ttldaycase', @n_ttldaydrop '@n_ttldaydrop', @n_daycase '@n_daycase',@n_daydrop '@n_daydrop'    
                 
               --check if total day cases or day dropid more than maximum days case and day drop allow assign to rover route    
               IF @n_ttldaydrop > CAST(@c_clkmaxdrop AS INT) OR @n_ttldaycase > CAST(@c_clkmaxcase AS INT)    
               BEGIN    
                  SET @c_UseRoverroute ='Y'    
                  SET @c_UseSharedroute = 'N'    
                    
                  SET @c_updateroute = @c_roverroute    
                  IF @n_ttldaydrop > CAST(@c_clkmaxdrop AS INT)    
                  BEGIN     
                      SET @n_ttldaydrop = @n_daycase     
                  END     
                    
                  IF @n_ttldaycase > CAST(@c_clkmaxcase AS INT)    
                  BEGIN     
                      SET @n_ttldaycase =  @n_daydrop     
                  END                     
               END          
            END    
            ELSE    
            BEGIN    
               SELECT @c_CLKRouteType = code2 ,@c_CLKMainRoute = code,    
                      @c_clkshareroute =short ,@c_clkroverroute = long ,    
                      @c_lastmodify = udf01 ,  @c_clkmaxcase = udf02 ,    
                      @c_clkmaxdrop = udf03 ,  @c_clkttldaycase = udf04 ,    
                      @c_clkttldaydrop = udf05    
               FROM codelkup (NOLOCK)      
               WHERE LISTNAME='PMIROUTE'    
               AND code = @c_mainroute AND Storerkey = @c_storerkey AND UDF01 = convert(NVARCHAR(10),GETDATE(),23)    
                 
               SET @n_ttldaycase = CAST(@c_clkttldaycase AS INT)    
               SET @n_ttldaydrop =  CAST(@c_clkttldaydrop AS INT)     
      
               SET @n_ttldaycase = @n_ttldaycase + @n_daycase - @n_ctncancelcases    
               SET @n_ttldaydrop = @n_ttldaydrop + @n_daydrop - @n_ctncanceldrop    
            END    
              
            IF @b_debug='1'    
            BEGIN    
                      SELECT 'shared alternate route',@c_lastmodify '@c_lastmodify',@c_CLKRouteType '@c_CLKRouteType',@c_CLKMainRoute '@c_CLKMainRoute',@c_clkmaxcase '@c_clkmaxcase',@c_clkmaxdrop '@c_clkmaxdrop'    
                    , @c_clkttldaycase '@c_clkttldaycase', @c_clkttldaydrop '@c_clkttldaydrop',@n_ttldaycase '@n_ttldaycase',@n_ttldaydrop '@n_ttldaydrop'    
            END      
         END    
           
         IF @b_debug ='8'    
         BEGIN    
               SELECT 'shared alternate',@c_orderkey '@c_orderkey' ,@c_UseRoverroute '@c_UseRoverroute',@c_originalRoute '@c_originalRoute',@c_mainroute '@c_mainroute',@c_roverroute '@c_roverroute'    
                      , @n_ttldaycase '@n_ttldaycase', @n_ttldaydrop '@n_ttldaydrop',@c_mainroute '@c_mainroute'    
               SELECT @c_updateroute '@c_updateroute', @n_ctncancelcases '@n_ctncancelcases',@n_ctncanceldrop '@n_ctncanceldrop',@n_ttldaycase '@n_ttldaycase',@n_ttldaydrop '@n_ttldaydrop'      
         END    
         --Update #TM TABLE    
         --UPDATE #TMPWVORDROUTE    
         --SET OHRoute =   @c_updateroute --CASE WHEN @c_UseRoverroute = 'N' THEN CASE WHEN @c_originalRoute = '' THEN @c_mainroute ELSE @c_originalRoute END ELSE @c_roverroute END    
         --    ,UpdateORD = CAST(GETDATE() AS DATE)    
         --    ,CancelORD = CASE WHEN @c_updatecancelord ='Y' THEN 'C' ELSE 'N' END    
         --WHERE OrderKey   = @c_orderkey AND storerkey = @c_storerkey    
           
         UPDATE #TMPWVORDROUTE    
         SET OHRoute =   @c_updateroute--CASE WHEN @c_UseRoverroute = 'N' THEN CASE WHEN @c_originalRoute = '' THEN @c_mainroute ELSE @c_originalRoute END ELSE @c_roverroute END    
             ,UpdateORD = CAST(GETDATE() AS DATE)    
             ,CancelORD = CASE WHEN @c_updatecancelord ='Y' THEN 'C' ELSE 'N' END    
             ,TTLCases = @n_daycase     
             ,TTLDrop = @n_daydrop    
         WHERE OrderKey   = @c_orderkey AND storerkey = @c_storerkey    
             
         --Update the route and userdefine10    
         UPDATE ORDERS WITH (ROWLOCK)    
         SET Route = @c_updateroute    
                    ,  userdefine07 = CAST(GETDATE() AS DATE)    
                 --   ,  userdefine10 = CASE WHEN @c_updatecancelord ='Y' THEN 'C' ELSE userdefine10 END    
                    ,  containerqty = @n_daycase    
                    , TrafficCop   = NULL    
                    , EditDate     = GETDATE()    
                    , EditWho      = SUSER_SNAME()    
         WHERE OrderKey   = @c_orderkey AND storerkey = @c_storerkey    
           
         SELECT @n_err = @@ERROR    
             
         IF @n_err <> 0                                                                                                                                                                   
         BEGIN                                                                                                                                                                                      
            SELECT @n_Continue = 3                                                                                                                                                                  
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 64070   -- Should Be Set To The SQL Errmessage but I don't know how to do so.                                                
            SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update shared route ORDERS Failed. (isp_RCM_WV_Update_OrdersRoute)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '     
            GOTO ENDPROC           
         END    
           
         --Update total days cases and total day deopid based on route    
         IF @c_UseSharedroute ='N'    
         BEGIN    
            UPDATE dbo.CODELKUP     
            SET udf04 = CASE WHEN @c_UseRoverroute='N'THEN CAST( @n_ttldaycase AS NVARCHAR(10)) ELSE udf04 END    
               ,UDF05 = CASE WHEN @c_UseRoverroute='N'THEN CAST(@n_ttldaydrop AS NVARCHAR(10)) ELSE udf05 END     
            WHERE LISTNAME='PMIROUTE'    
            AND code = @c_mainroute AND Storerkey = @c_storerkey AND UDF01 = convert(NVARCHAR(10),GETDATE(),23)    
         END    
         ELSE    
         BEGIN    
            UPDATE dbo.CODELKUP     
            SET udf04 = CASE WHEN @c_UseRoverroute='N'THEN CAST( @n_ttldaycase AS NVARCHAR(10)) ELSE udf04 END    
               ,UDF05 = CASE WHEN @c_UseRoverroute='N'THEN CAST(@n_ttldaydrop AS NVARCHAR(10)) ELSE udf05 END     
            WHERE LISTNAME='PMIROUTE'    
            AND code = @c_shareroute AND Storerkey = @c_storerkey AND UDF01 = convert(NVARCHAR(10),GETDATE(),23)    
         END    
           
         SELECT @n_err = @@ERROR    
           
         IF @n_err <> 0                                                                                                                                                                   
         BEGIN                                                                                                                                                                                      
            SELECT @n_Continue = 3                                                                                                                                                                  
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 64080   -- Should Be Set To The SQL Errmessage but I don't know how to do so.                                                
            SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update Codelkup shared route Failed. (isp_RCM_WV_Update_OrdersRoute)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '          
            GOTO ENDPROC      
         END    
                 
         SET @n_rowno = @n_rowno + 1    
         SET @c_prevmainroute = @c_mainroute    
         SET @c_preconsignee = @c_consigneekey    
           
         IF @c_UseSharedroute<>'N'    
         BEGIN    
            SET @c_UseSharedroute ='N'    
         END    
           
         IF @c_UseRoverroute<>'N'    
         BEGIN    
            SET @c_UseSharedroute ='N'    
         END    
         
         FETCH NEXT FROM CUR_ShareRoute  INTO @c_Getwavekey, @c_consigneekey  ,@c_StorerKey,@c_orderkey,@c_OrdRoute,    
                                              @d_OHEditDate,@c_OrdRouteType,@c_mainroute,@c_shareroute,@c_roverroute    
      END      
      CLOSE CUR_ShareRoute     
      DEALLOCATE CUR_ShareRoute     
      --End Loop Share Route                   
        
      IF @b_debug='8'    
      BEGIN    
           SELECT 'shared route end',* FROM #TMPWVORDROUTE WHERE routetype='shared'    
      END        
      --GOTO ENDPROC    
    
      --End Loop Share Route          
   END --end share route  
     
   --Update cancel orders  
   IF @n_continue IN(1,2)  
   BEGIN       
      --Update the orders table cancel route    
      IF @c_updatecancelord='Y'    
      BEGIN        
         UPDATE ORDERS WITH (ROWLOCK)    
         SET userdefine10 = TRC.CancelORD    
           , TrafficCop   = NULL    
           , EditDate     = GETDATE()    
           , EditWho      = SUSER_SNAME()    
         FROM ORDERS OH --WITH (NOLOCK)    
         JOIN #TMPWVORDCANC TRC ON TRC.OrderKey=OH.OrderKey AND TRC.Storerkey=OH.StorerKey    
         WHERE TRC.mainroute= @c_mainroute AND TRC.CancelORD='C'              
           
         SELECT @n_err = @@ERROR    
             
         IF @n_err <> 0                                                                                                                                                                   
         BEGIN                                                                                                    
            SELECT @n_Continue = 3                                                                                                                                                                  
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 64200   -- Should Be Set To The SQL Errmessage but I don't know how to do so.                                                
            SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update cancel shared ORDERS Failed. (isp_RCM_WV_Update_OrdersRoute)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '     
            GOTO ENDPROC           
         END    
      END      
   END  
    
   --Check Route from redeliver POD  
   IF @n_continue IN(1,2)  
   BEGIN  
      --Loop POD    
      DECLARE Cur_PODORD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR    
      SELECT  POD.orderkey,POD.storerkey,oh.ConsigneeKey,st.susr1    
      FROM POD WITH (NOLOCK)    
      JOIN ORDERS OH WITH (NOLOCK) ON OH.OrderKey=POD.orderkey AND OH.StorerKey=POD.storerkey     
      JOIN dbo.STORER ST (NOLOCK) ON ST.StorerKey = oh.ConsigneeKey AND ST.type='2'    
      WHERE POD.storerkey = @c_Getstorerkey AND POD.status = @c_redeliverystatus    
      AND CAST(POD.editDate AS DATE)>= CAST(GETDATE()-5 AS DATE)    
      ORDER BY  POD.orderkey     
        
      OPEN Cur_PODORD    
    
      FETCH NEXT FROM Cur_PODORD INTO @c_podorderkey, @c_podstorerkey  ,@c_podconsigneekey,@c_PODroutetype    
    
      WHILE @@FETCH_STATUS <> -1    
      BEGIN    
    
         SET @c_PODGetOHroute = ''    
    
         SELECT @c_PODGetOHroute = MAX(OHRoute)    
         FROM #TMPWVORDROUTE     
         WHERE consigneekey = @c_podconsigneekey AND Storerkey = @c_podstorerkey    
    
         IF ISNULL(@c_PODGetOHroute,'') <>''    
         BEGIN      
            UPDATE ORDERS WITH (ROWLOCK)    
            SET Route = @c_PODGetOHroute    
              ,  userdefine07 = CAST(GETDATE() AS DATE)    
              , TrafficCop   = NULL    
              , EditDate     = GETDATE()    
              , EditWho      = SUSER_SNAME()    
            WHERE OrderKey   = @c_podorderkey AND storerkey = @c_podstorerkey    
           
            SELECT @n_err = @@ERROR    
                
            IF @n_err <> 0                              
            BEGIN                                                                                                                                                                                      
               SELECT @n_Continue = 3                                                                                                                                                                  
               SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err = 64090   -- Should Be Set To The SQL Errmessage but I don't know how to do so.                                                
               SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Update POD Failed. (isp_RCM_WV_Update_OrdersRoute)' + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '     
               GOTO ENDPROC           
            END             
         END    
         --ELSE    
         --BEGIN    
           
         --END     
       
         FETCH NEXT FROM Cur_PODORD INTO @c_podorderkey, @c_podstorerkey  ,@c_podconsigneekey,@c_PODroutetype    
      END      
      CLOSE Cur_PODORD    
      DEALLOCATE Cur_PODORD            
   END    
    
ENDPROC:    
      
   IF OBJECT_ID('tempdb..#TMPWVORDROUTE') IS NOT NULL    
      DROP TABLE #TMPWVORDROUTE    
    
  IF CURSOR_STATUS('LOCAL', 'CUR_FixedRoute') IN (0 , 1)    
   BEGIN    
      CLOSE CUR_FixedRoute    
      DEALLOCATE CUR_FixedRoute       
   END     
    
  IF CURSOR_STATUS('LOCAL', 'CUR_ShareRoute') IN (0 , 1)    
   BEGIN    
      CLOSE CUR_ShareRoute    
      DEALLOCATE CUR_ShareRoute       
   END     
    
  IF CURSOR_STATUS('LOCAL', 'Cur_PODORD') IN (0 , 1)    
   BEGIN    
      CLOSE Cur_PODORD    
      DEALLOCATE Cur_PODORD       
   END         
    
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
     execute nsp_logerror @n_err, @c_errmsg, 'isp_RCM_WV_Update_OrdersRoute'    
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
END -- End PROC    
GO
GO
GRANT EXECUTE ON [dbo].[isp_RCM_WV_Update_OrdersRoute] TO nSQL 
GO
