CREATE TABLE [dbo].[MBOLDETAIL]
(
[MbolKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MbolLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ContainerKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOLDETAIL_ContainerKey] DEFAULT (' '),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOLDETAIL_OrderKey] DEFAULT (' '),
[PalletKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOLDETAIL_PalletKey] DEFAULT (' '),
[Description] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOLDETAIL_Description] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_MBOLDETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOLDETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_MBOLDETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MBOLDETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStamp] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GrossWeight] [float] NULL CONSTRAINT [DF_MBOLDETAIL_GROSSWEIGHT] DEFAULT ((0)),
[Capacity] [float] NULL CONSTRAINT [DF_MBOLDETAIL_CAPACITY] DEFAULT ((0)),
[InvoiceNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UPSINum] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCMNum] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternReason] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceAmount] [float] NULL CONSTRAINT [DF_MBOLDETAIL_INVOICEAMOUNT] DEFAULT ((0)),
[DeliveryTime] [datetime] NULL,
[OfficialReceipt] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ITS] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Weight] [float] NULL CONSTRAINT [DF_MBOLDETAIL_Weight] DEFAULT ((0)),
[Cube] [float] NULL CONSTRAINT [DF_MBOLDETAIL_Cube] DEFAULT ((0)),
[OrderDate] [datetime] NULL,
[ExternOrderKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeliveryDate] [datetime] NULL,
[DeliveryStatus] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_DeliveryStatus] DEFAULT ('0'),
[TotalCartons] [float] NULL CONSTRAINT [DF_MBOLDETAIL_TotalCartons] DEFAULT ((0)),
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_UserDefine08] DEFAULT ('N'),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_UserDefine10] DEFAULT (' '),
[CtnCnt1] [int] NULL CONSTRAINT [DF_mboldetail_CtnCnt1] DEFAULT ((0)),
[CtnCnt2] [int] NULL CONSTRAINT [DF_mboldetail_CtnCnt2] DEFAULT ((0)),
[CtnCnt3] [int] NULL CONSTRAINT [DF_mboldetail_CtnCnt3] DEFAULT ((0)),
[CtnCnt4] [int] NULL CONSTRAINT [DF_mboldetail_CtnCnt4] DEFAULT ((0)),
[CtnCnt5] [int] NULL CONSTRAINT [DF_mboldetail_CtnCnt5] DEFAULT ((0)),
[TotCtnCube] [float] NULL CONSTRAINT [DF_MBOLDetail_TotCtnCube] DEFAULT ((0)),
[TotCtnWeight] [float] NULL CONSTRAINT [DF_MBOLDetail_TotCtnWeight] DEFAULT ((0)),
[DriverName] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_DriverName] DEFAULT (''),
[VehicleNo] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_VehicleNo] DEFAULT (''),
[TruckType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_TruckType] DEFAULT (''),
[ServiceProvider] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_MBOLDETAIL_ServiceProvider] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/  
/* Trigger:  ntrMBOLDetailAdd                                              */  
/* Creation Date:                                                          */  
/* Copyright: IDS                                                          */  
/* Written by:                                                             */  
/*                                                                         */  
/* Purpose:  Trigger point upon any insert MBOLDetail                      */  
/*                                                                         */  
/* Input Parameters:                                                       */  
/*                                                                         */  
/* Output Parameters:  None                                                */  
/*                                                                         */  
/* Return Status:  None                                                    */  
/*                                                                         */  
/* Usage:                                                                  */  
/*                                                                         */  
/* Local Variables:                                                        */  
/*                                                                         */  
/* Called By: When records updated                                         */  
/*                                                                         */  
/* PVCS Version: 1.12                                                      */  
/*                                                                         */  
/* Version: 5.4                                                            */  
/*                                                                         */  
/* Data Modifications:                                                     */  
/*                                                                         */  
/* Updates:                                                                */  
/* Date         Author Ver.  Purposes                                      */  
/* 22-Jul-2004  SHONG        Convert SELECT MIN to Cursor Loop             */  
/* 17-Oct-2005  Vicky        SOS#41907 - To Fix the Casecnt so that it's   */  
/*                                       tally with Loadplan               */  
/* 23-Mar-2006  SHONG        Performance Tuning (SWT_Perf_001)             */  
/* 23-Nov-2007  SHONG        Not Allow to populate Order# into more then 1 */  
/*                           MBOL (SOS92506)                               */  
/* 11-May-2009  NJOW01 1.1   SOS#118352                                    */  
/*                           Populate Carton count by order to MBOL detail */  
/* 26-Jun-2009  NJOW02 1.2   Change calculate total carton by using        */  
/*                           distinct count packdetail.cartonno            */  
/* 17-Aug-2009  SHONG  1.3   SOS#140791 Default Loadplan.TotCtnWeight and  */  
/*                           TotCtnCube                                    */  
/* 05-May-2010  NJOW01 1.4   168916 - update total carton to mbol          */  
/*                           depend on mbol.userdefine09                   */  
/* 07-Apr-2011  NJOW03 1.5   Calculate total carton using distinct labelno */  
/*                           to cater for multi ps per order scenario      */  
/* 14-Mar-2012  KHLim011.6   Update EditDate of several tables             */  
/* 06-APR-2012  YTWan  1.7   SOS#238876-ReplaceUSAMBOL. Calculate          */  
/*                           NoofCartonPacked. (Wan01)                     */  
/* 30-Apr-2012  SHONG  1.8   CustCnt Should using Count Distinct Consignee */  
/*                           Cater ConsoOrderKey                           */  
/* 23-May-2012  SHONG  1.8   Do Not Calculate CtnCnt When TrafficCop = '1' */  
/* 24-May-2012  Leong  1.8   SOS# 245519 - Bug Fix                         */  
/* 07-Nov-2012  KHLim  1.9   DM integrity - Update EditDate  (KH01)        */  
/* 20-Nov-2013  TLTING 1.10  Nolock hints (tlting01)                       */  
/* 21-Sep-2015  ChewKP 1.11  Auto Generate MBOLLineDetail.MBOLLineNumber   */  
/*                           when inserted = '00000'  (ChewKP01)           */  
/* 28-JUL-2017  Wan02  1.12   WMS-1916 - WMS Storerconfig for Copy         */  
/*                           totalcarton to ctncnt1 in mboldetail          */  
/* 17-Aug-2017  TLTING 1.13  Bug fix - update archiveCop                   */  
/* 14-Jan-2020  SHONG  1.14  Update OrderDetail With Cursor Loop           */
/* 28-May-2020  Shong  1.15  WMS-13444 Auto Create POD record after MBOL   */  
/*                           creation  (SWT01)                             */  
/* 10-Dec-2020  TLTING02 1.16  Performance tune                            */  
/***************************************************************************/  
CREATE TRIGGER [dbo].[ntrMBOLDetailAdd]  
ON  [dbo].[MBOLDETAIL]  
FOR INSERT  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @b_debug int  
   SELECT @b_debug = 0  
   DECLARE  
             @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?  
   ,         @n_err                int       -- Error number returned by stored procedure or this trigger  
   ,         @n_err2 int              -- For Additional Error Detection  
   ,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger  
   ,         @n_Continue int  
   ,         @n_starttcnt int                -- Holds the current transaction count  
   ,         @c_preprocess NVARCHAR(250)         -- preprocess  
   ,         @c_pstprocess NVARCHAR(250)         -- post process  
   ,         @n_cnt              INT  
   ,         @c_storerkey        NVARCHAR(15)  
   ,         @c_authority        NVARCHAR(1)  
   ,         @c_POD_Authority    NVARCHAR(1) = '0'   -- (SWT01)  
   ,         @c_POD_Option01     NVARCHAR(20) = ''   -- (SWT01)  
   ,         @c_PODXDeliverDate  NVARCHAR(1) = '0'   -- (SWT01)  
   ,         @c_Facility         NVARCHAR(5)         -- (SWT01)  
  
   SELECT @n_Continue=1, @n_starttcnt=@@TRANCOUNT  
   /* #INCLUDE <TRMBODA1.SQL> */  
  
   DECLARE @c_InvoiceStatus NVARCHAR(10),  
           @d_DeliveryDate  datetime,  
           @c_PCM           NVARCHAR(12),  
           @c_Reason        NVARCHAR(60),  
           @c_MBOLKey       NVARCHAR(10),  
           @c_OtherMBOL     NVARCHAR(10),  
           @c_OrderKey      NVARCHAR(10),  
           @c_OrderLineNumber NVARCHAR(5)  
  
   DECLARE  @n_casecnt       int,  
            @n_palletcnt     int,  
            @n_weight        decimal(15, 4),  
            @n_cube          decimal(15, 4),  
            @n_custcnt       int,  
            @c_PrevLoadKey   NVARCHAR(10),  
            @c_VoyageNumber  NVARCHAR(30),  
            @c_LoadKey       NVARCHAR(10),  
            @f_TotCtnWeight  float,  
            @f_TotCtnCube    float,  
            @cLabelLine     NVARCHAR(5)    
  
   DECLARE @n_TtlCnts int --NJOW01 SOS#118352  
  
   IF @n_Continue=1 or @n_Continue=2  
   BEGIN  
      IF EXISTS(SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')  
         SELECT @n_Continue = 4  
   END  
   -- End  
  
   IF @n_Continue=1 or @n_Continue=2  
   BEGIN  
      IF EXISTS (SELECT 1 FROM MBOL with (NOLOCK), INSERTED   -- tlting01  
                 WHERE MBOL.MBOLKey = INSERTED.MBOLKey  
                 AND MBOL.Status = '9')  
      BEGIN  
         SELECT @n_Continue = 3  
         SELECT @n_err=72900  
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': MBOL.Status = ''SHIPPED''. UPDATE rejected. (ntrMBOLDetailAdd)'  
      END  
   END  
  
   --(Wan02) - START  
   IF @n_continue=1 or @n_continue = 2  
   BEGIN  
      IF EXISTS (SELECT 1 FROM INSERTED i  
                 JOIN ORDERS       O WITH (NOLOCK) ON (I.OrderKey = O.OrderKey)  
                 JOIN storerconfig s WITH (NOLOCK) ON (O.storerkey = s.storerkey)  
                 JOIN sys.objects sys ON sys.type = 'P' AND sys.name = s.Svalue  
                 WHERE  s.configkey = 'MBOLDetailTrigger_SP')  
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
  
         EXECUTE dbo.isp_MBOLDetailTrigger_Wrapper  
                   'INSERT'  --@c_Action  
                 , @b_Success  OUTPUT  
                 , @n_Err      OUTPUT  
                 , @c_ErrMsg   OUTPUT  
  
         IF @b_success <> 1  
         BEGIN  
            SELECT @n_continue = 3  
                  ,@c_errmsg = 'ntrMBOLDetailAdd ' + RTRIM(LTRIM(ISNULL(@c_errmsg,'')))  
         END  
  
         IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL  
            DROP TABLE #INSERTED  
  
         IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL  
            DROP TABLE #DELETED  
      END  
   END  
   --(Wan02) - END  
   -- (ChewKP01)   
   IF EXISTS (SELECT 1 FROM INSERTED WITH (NOLOCK) WHERE INSERTED.MBOLLineNumber = '00000')    
   BEGIN             
  
     
       SELECT @cLabelLine = RIGHT( '00000' + CAST( CAST( IsNULL( MAX( MBOLDETAIL.MBOLLineNumber), 0) AS INT) + 1 AS NVARCHAR( 5)), 5)    
       FROM MBOLDETAIL WITH (NOLOCK)    
       JOIN INSERTED WITH (NOLOCK) ON (MBOLDETAIL.MBOLKey = INSERTED.MBOLKey )   
     
       UPDATE MBOLDETAIL    
          SET MBOLLineNumber = @cLabelLine  
              ,TrafficCop = NULL   
       FROM INSERTED WITH (NOLOCK)    
       WHERE MBOLDetail.MBOLKey = INSERTED.MBOLKey    
       AND   MBOLDetail.OrderKey = INSERTED.OrderKey    
       --AND   PACKDETAIL.CartonNo = 0    
     
  
  
      IF EXISTS ( SELECT 1   
         FROM MBOLDetail (NOLOCK)   
         JOIN INSERTED WITH (NOLOCK) ON (MBOLDetail.MBOLKey = INSERTED.MBOLKey)    
         WHERE MBOLDetail.MBOLLineNumber = @cLabelLine  
         HAVING COUNT( DISTINCT MBOLDetail.MBOLLineNumber) > 1)   
      BEGIN  
         SELECT @n_err = 72613    
         SELECT @n_continue = 3    
         SELECT @c_errmsg = 'NSQL'+CONVERT(char(5),@n_err)+ ': MBOLLineNumber repeated (ntrMBOLDetailAdd)'  
      END  
  
   
   END    
  
   -- Added for IDSV5 by June 26.Jun.02, (extract from IDSPH) *** Start  
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN  
      DECLARE C_OrderKey_Cursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
         SELECT LoadKey,      OrderKey, MBOLKey,      InvoiceStatus,  
                DeliveryDate, PCMNum,   ExternReason  
         FROM   INSERTED  
         ORDER BY LoadKey  
  
  
      OPEN C_OrderKey_Cursor  
  
      FETCH NEXT FROM C_OrderKey_Cursor INTO  
            @c_LoadKey, @c_OrderKey, @c_MBOLKey, @c_InvoiceStatus, @d_DeliveryDate,  
            @c_PCM, @c_Reason  
  
      WHILE @@FETCH_STATUS <> -1 AND ( @n_Continue = 1 OR @n_Continue = 2 )  
      BEGIN  
         SET @c_OtherMBOL = ''  
  
         SELECT @c_OtherMBOL = ISNULL(MBOLKey, '')  
         FROM   MBOLDetail WITH (NOLOCK)  
         WHERE  OrderKey = @c_OrderKey  
         AND    MBOLKey <> @c_MBOLKey  
  
         IF ISNULL(RTrim(@c_OtherMBOL), '') <> ''  
         BEGIN  
            SELECT @n_Continue = 3  
            SELECT @n_err=72613  
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+' OrderKey ' + @c_OrderKey + ' Already Populate to MBOL# ' + @c_OtherMBOL  
            GOTO QUIT  
         END  
  
         IF @c_PrevLoadKey <> @c_LoadKey  
         BEGIN  
            SET @c_PrevLoadKey = @c_LoadKey  
  
            IF EXISTS(SELECT 1 FROM LoadPlan WITH (NOLOCK)  
                      WHERE LoadKey = @c_LoadKey AND (MBOLKey = '' OR MBOLKey IS NULL))  
            BEGIN  
               SET @f_TotCtnWeight = 0  
               SET @f_TotCtnCube   = 0  
  
               SELECT @f_TotCtnWeight = TotCtnWeight,  
                      @f_TotCtnCube   = TotCtnCube  
               FROM   LOADPLAN WITH (NOLOCK)  
               WHERE  LoadKey = @c_LoadKey  
  
               IF ISNULL(@f_TotCtnWeight,0) = 0 AND ISNULL(@f_TotCtnCube,0) = 0  
               BEGIN  
                  -- SOS#140791 Default Loadplan.TotCtnWeight  
                  IF NOT EXISTS(SELECT TOP 1 PickSlipNo FROM PACKHEADER WITH (NOLOCK)  
                                WHERE  LOADKEY = @c_LoadKey)  
                  BEGIN  
                     SELECT @f_TotCtnWeight = SUM(P.Qty * ISNULL(SKU.STDNETWGT,0)),  
                            @f_TotCtnCube   = SUM(P.Qty * ISNULL(SKU.STDCUBE,0))  
                     FROM   PICKDETAIL P WITH (NOLOCK)  
                     JOIN   LOADPLANDETAIL LP WITH (NOLOCK) ON (LP.OrderKey = P.OrderKey)  
                     JOIN   SKU WITH (NOLOCK) ON SKU.StorerKey =P.StorerKey AND SKU.SKU = P.SKU  
                     WHERE  LP.LoadKey = @c_LoadKey  
                  END  
               END  
  
               UPDATE LOADPLAN WITH (ROWLOCK)  
               SET MBOLKey = @c_MBOLKey,  
                   EditDate = GETDATE(), -- KHLim01  
                   TrafficCop = NULL,  
                   -- SOS#140791  
                   TotCtnCube = @f_TotCtnCube,  
                   TotCtnWeight = @f_TotCtnWeight  
               WHERE LoadKey = @c_LoadKey  
  
               SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
               IF @n_err <> 0  
               BEGIN  
                  SELECT @n_Continue = 3  
                  SELECT @n_err=72601  
                  SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table LoadPlanDetail. (ntrMBOLDetailAdd)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '  
                  GOTO QUIT  
               END  
            END  
         END -- IF @c_PrevLoadKey <> @c_LoadKey  
  
         SELECT @c_Storerkey = Storerkey  
              , @c_Facility = Facility  
         FROM   ORDERS WITH (NOLOCK)  
         WHERE  ORDERS.Orderkey = @c_OrderKey  
  
         SELECT @b_success = 0  
         Execute nspGetRight  
                 NULL,  -- facility  
                 @c_StorerKey,  -- Storerkey  
                 NULL,          -- Sku  
                 'ACSIE',       -- Configkey  
                 @b_success     output,  
                 @c_authority   output,  
                 @n_err         output,  
                 @c_errmsg      output  
  
         IF @b_success <> 1  
         BEGIN  
            SELECT @n_Continue = 3, @c_errmsg = 'ntrMBOLDetailAdd' + dbo.fnc_RTrim(@c_errmsg)  
         END  
         ELSE IF @c_authority = '1'  
         BEGIN  
            -- for ACSIE  
            -- WALLY 8.may.2001  
            -- mandatory fields based on invoice status  
            IF @c_InvoiceStatus = 'D' AND @d_DeliveryDate IS NULL  
            BEGIN  
               SELECT @n_Continue = 3  
               SELECT @n_err=72611  
               SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+' : ACTUAL DELIVERY DATE REQUIRED...'  
               GOTO QUIT  
            END  
            ELSE IF @c_InvoiceStatus = 'J' AND (@c_PCM IS NULL OR @c_PCM = '') AND (@c_Reason IS NULL OR @c_Reason = '')  
            BEGIN  
               SELECT @n_Continue = 3  
               SELECT @n_err=72611  
               SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+' : PCM NUMBER and REASON CODE REQUIRED...'  
               GOTO QUIT  
            END  
         END -- IF ACSIE @c_authority = '1'  
  
         IF EXISTS(SELECT 1 FROM ORDERS WITH (NOLOCK) WHERE OrderKey = @c_OrderKey  
                   AND (MBOLKey IS NULL OR MBOLKey = ''))  
         BEGIN  
            UPDATE ORDERS WITH (ROWLOCK)  
            SET MBOLKey = @c_MBOLKey,  
                EditDate = GETDATE(), -- KHLim01  
                TrafficCop = NULL  
            WHERE OrderKey = @c_OrderKey  
             AND (MBOLKey IS NULL OR MBOLKey = '')  
            SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
            IF @n_err <> 0  
            BEGIN  
         SELECT @n_Continue = 3  
               SELECT @n_err=72601  
               SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table ORDERS. (ntrMBOLDetailAdd)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '  
            END  
         END  
           
         DECLARE CUR_ORDERLINE CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
         SELECT OrderLineNumber  
         FROM OrderDetail WITH (NOLOCK)   
         WHERE OrderKey = @c_OrderKey  
         AND (MBOLKey IS NULL OR MBOLKey = '')  
           
         OPEN CUR_ORDERLINE  
           
         FETCH FROM CUR_ORDERLINE INTO @c_OrderLineNumber  
           
         WHILE @@FETCH_STATUS = 0  
         BEGIN  
            UPDATE ORDERDETAIL WITH (ROWLOCK)  
                  SET MBOLKey = @c_MBOLKey,  
                      EditDate = GETDATE(),   
                      TrafficCop = NULL  
            WHERE OrderKey = @c_OrderKey   
            AND OrderLineNumber = @c_OrderLineNumber  
  
            SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
            IF @n_err <> 0  
            BEGIN  
               SELECT @n_Continue = 3  
               SELECT @n_err=72601  
               SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table OrderDetail. (ntrMBOLDetailAdd)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '  
            END  
           
          FETCH FROM CUR_ORDERLINE INTO @c_OrderLineNumber  
         END  
           
         CLOSE CUR_ORDERLINE  
         DEALLOCATE CUR_ORDERLINE  
           
         -- NJOW01 SOS#118352-- Start  
          SET @n_TtlCnts = 0  
          SELECT @n_TtlCnts = COUNT(DISTINCT PACKDETAIL.LabelNo)   --NJOW02 / NJOW03  
          FROM PACKHEADER (NOLOCK)  
          JOIN PACKDETAIL (NOLOCK) ON (PACKHEADER.Pickslipno = PACKDETAIL.Pickslipno)  
          WHERE PACKHEADER.Status = '9'  
          AND PACKHEADER.Orderkey = @c_orderkey  
  
          IF @n_TtlCnts > 0  
          BEGIN  
             UPDATE MBOLDETAIL WITH (ROWLOCK)  
                SET TotalCartons = @n_TtlCnts,  
                    EditDate = GETDATE(), -- KHLim01  
                    Trafficcop = NULL  
                WHERE Orderkey = @c_orderkey  
                AND MBOLKey = @c_MBOLKey  
                AND ISNULL(TotalCartons,0) = 0  -- usually using populate load plan / order function to insert  
  
              SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
              IF @n_err <> 0  
              BEGIN  
                 SELECT @n_Continue = 3  
                 SELECT @n_err=72611  
                 SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table MBOLDetail. (ntrMBOLDetailAdd)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '  
              END  
  
              --(Wan01)  - START (open the remark)  
              IF (@n_Continue = 1 OR @n_Continue = 2) AND @n_cnt > 0  
              BEGIN  
                  UPDATE MBOL WITH (ROWLOCK)  
                  SET NoofCartonPacked = ISNULL(NoOfCartonPacked,0) + @n_TtlCnts  
                   , EditWho = SUSER_NAME()  
                   , EditDate = GETDATE()  
                   , Trafficcop = NULL  
                  WHERE MBOLKey = @c_MBOLKey  
  
                  SELECT @n_err = @@ERROR  
                  IF @n_err <> 0  
                  BEGIN  
                     SET @n_Continue = 3  
                     SET @n_err=72612  
                     SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table MBOL. (ntrMBOLDetailAdd)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '  
                  END  
              END  
              --(Wan01)  - END (open the remark)  
           END -- IF @n_TtlCnts > 0  
           -- NJOW01 SOS#118352-- End  
  
            -- Generate POD Records Here................... (SWT01)  
            SET @b_success = 0  
            SET @c_POD_Option01=''  
            SET @c_POD_Authority = ''  
              
            EXECUTE nspGetRight   
                @c_Facility  = @c_Facility -- facility  
               ,@c_StorerKey = @c_StorerKey -- Storerkey -- SOS40271  
               ,@c_sku       = NULL         -- Sku  
               ,@c_ConfigKey = 'POD'        -- Configkey  
               ,@b_Success   = @b_success      OUTPUT  
               ,@c_authority = @c_POD_Authority OUTPUT  
               ,@n_err       = @n_err          OUTPUT  
               ,@c_errmsg    = @c_errmsg       OUTPUT  
               ,@c_Option1   = @c_POD_Option01 OUTPUT -- (SWT01)   
  
            IF @b_success <> 1  
            BEGIN  
               SELECT @n_continue = 3, @c_errmsg = 'ntrMBOLDetailAdd' + RTRIM(@c_errmsg)  
            END  
            ELSE IF @c_POD_Authority = '1' AND @c_POD_Option01 = 'MBOLADD'  
            BEGIN   
               IF @b_debug = 1  
               BEGIN  
                  SELECT 'Insert Details of MBOL into POD Table'  
               END  
                 
               IF NOT EXISTS ( SELECT 1 FROM POD WITH (NOLOCK) WHERE OrderKey = @c_OrderKey AND MBOLKey = @c_MBOLKey)  
               BEGIN  
  
                  SET @c_PODXDeliverDate = '0'  
                  SET @b_success = 0  
                  EXECUTE nspGetRight  
                        @c_facility, -- facility  
                        @c_storerkey, -- Storerkey -- SOS40271  
                        null,         -- Sku  
                        'PODXDeliverDate',  -- Configkey  
                        @b_success           OUTPUT,  
                        @c_PODXDeliverDate   OUTPUT,  
                        @n_err               OUTPUT,  
                        @c_errmsg            OUTPUT  
                                      
                  INSERT INTO POD  
                              (MBOLKey,         MBOLLineNumber,   LoadKey,    ExternLoadKey,       
                               OrderKey,        BuyerPO,          ExternOrderKey,  
                               InvoiceNo,       status,           ActualDeliveryDate,  
                               InvDespatchDate, poddef08,         Storerkey,    
                               SpecialHandling, TrackCol01)       
                  SELECT   MBOLDetail.MBOLKey,  
                           MBOLDetail.MBOLLineNumber,  
                           ORDERS.LoadKey,  
                           ISNULL(LOADPLAN.ExternLoadKey, ''),     
                           ORDERS.OrderKey,  
                           ORDERS.BuyerPO,  
                           ORDERS.ExternOrderKey,  
                           ORDERS.InvoiceNo,     
                           '0',  
                           CASE WHEN @c_PODXDeliverDate = '1' THEN NULL ELSE GETDATE() END,  
                           InvDespatchDate=GETDATE(),  
                           PODDef08=ISNULL(MBOLDetail.its,''),    
                           ORDERS.Storerkey,  
                           ORDERS.SpecialHandling,   
                           TrackCol01 =''              
                    FROM MBOLDetail WITH (NOLOCK)  
                    JOIN ORDERS ON (MBOLDetail.OrderKey = ORDERS.OrderKey)  
                    LEFT JOIN LOADPLAN LOADPLAN WITH (NOLOCK) ON (LOADPLAN.LoadKey = ORDERS.LoadKey)     
                    WHERE ORDERS.OrderKey = @c_OrderKey  
                      AND MBOLDetail.MBOLKey = @c_MBOLKey    
  
                  SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
                  IF @n_err <> 0  
                  BEGIN  
                     SELECT @n_continue = 3  
                     SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72807  
                     SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))  
                                      + ': Insert Failed On Table POD. (ntrMBOLDetailAdd)'  
                                      + ' ( SQLSvr MESSAGE=' + ISNULL(RTrim(@c_errmsg), '') + ' ) '  
                  END  
               END  
            END -- POD Authority = 1 -- (SWT01)  
           
           FETCH NEXT FROM C_OrderKey_Cursor INTO  
               @c_LoadKey, @c_OrderKey, @c_MBOLKey, @c_InvoiceStatus, @d_DeliveryDate,  
               @c_PCM, @c_Reason  
      END -- While Loop  
      CLOSE C_OrderKey_Cursor  
      DEALLOCATE C_OrderKey_Cursor  
   END  
  
  
   /**** To Calculate Weight, Cube, Pallet, Case and Customer Cnt ****/  
   IF @n_Continue = 1 or @n_Continue = 2  
   BEGIN  
      SELECT @c_MBOLKey = ''  
  
      DECLARE C_trMBOLDetail CURSOR FAST_FORWARD READ_ONLY FOR  
         SELECT  INSERTED.MBOLKey,  
                 SUM(INSERTED.Weight),  
                 SUM(INSERTED.Cube),  
                 COUNT(DISTINCT O.ConsigneeKey)  
         FROM  INSERTED  
         JOIN ORDERS O WITH (NOLOCK) ON (O.OrderKey = INSERTED.OrderKey)  
         GROUP BY INSERTED.MBOLKey  
         ORDER BY INSERTED.MBOLKey  
  
      OPEN C_trMBOLDetail  
  
      FETCH NEXT FROM C_trMBOLDetail INTO @c_MBOLKey, @n_weight, @n_cube, @n_custcnt  
      WHILE @@FETCH_STATUS <> -1  
      BEGIN  
         IF dbo.fnc_RTrim(@c_MBOLKey) IS NULL OR dbo.fnc_RTrim(@c_MBOLKey) = ''  
            BREAK  
  
         SET @c_VoyageNumber = ''  

         --tlting02
         SELECT @c_VoyageNumber = IsNULL(MAX(LoadPlan.Route), ' ') -- SOS# 245519  
         FROM  LoadPlan (NOLOCK)  
         WHERE exists  ( SELECT   1 FROM  MBOLDETAIL MD WITH (NOLOCK)   
                        JOIN Orders O (NOLOCK) ON O.Orderkey =  MD.OrderKey
                        WHERE  MD.MBOLKey = @c_MBOLKey 
                        AND O.LoadKey = LoadPlan.LoadKey  )  
                       

         --SELECT @c_VoyageNumber = IsNULL(MAX(LoadPlan.Route), ' ') -- SOS# 245519  
         --FROM  LoadPlan (NOLOCK)  
         --WHERE EXISTS(SELECT 1 FROM LoadPlanDetail lpd WITH (NOLOCK)  
         --            JOIN  MBOLDETAIL MD WITH (NOLOCK) ON MD.OrderKey = lpd.OrderKey  
         --            WHERE lpd.LoadKey = LoadPlan.LoadKey  
         --              AND MD.MBOLKey = @c_MBOLKey)  
   
  
         -- Modified By Vicky on 17th Oct 2005  
         -- SOS #41907 - To fix the casecnt so that tally with loadplan  
         SELECT @n_casecnt = SUM(CASE WHEN PACK.CASECNT = 0 THEN 0  
                                 ELSE (ORDERDETAIL.QtyAllocated + ORDERDETAIL.QtyPicked) / (PACK.CaseCnt)  
                                 END),  
               @n_palletcnt = SUM((ORDERDETAIL.QtyAllocated + ORDERDETAIL.QtyPicked) / (CASE WHEN PACK.Pallet = 0  
                                                                                          THEN 1  
                                                                                          ELSE PACK.Pallet  
                                                                                          END))  
         FROM  ORDERDETAIL (NOLOCK), INSERTED, PACK (NOLOCK)  
         WHERE ORDERDETAIL.OrderKey = INSERTED.OrderKey  
         AND   ORDERDETAIL.Packkey = PACK.Packkey  
         AND   INSERTED.MBOLKey = @c_MBOLKey  
  
         IF @n_casecnt = NULL SELECT @n_casecnt = 0  
         IF @n_palletcnt = NULL SELECT @n_palletcnt = 0  
  
  
         UPDATE MBOL WITH (ROWLOCK)  
         SET [CustCnt]    = CustCnt + @n_custcnt,  
             [Weight]     = MBOL.Weight + @n_weight,  
             [Cube]       = MBOL.Cube + @n_cube,  
             [PalletCnt]  = PalletCnt + @n_palletcnt,  
             [CaseCnt]    = CaseCnt + @n_casecnt,  
             [VoyageNumber] = CASE WHEN VoyageNumber IS NULL OR VoyageNumber = '' THEN  
                                   @c_VoyageNumber  
                              ELSE  
                                  MBOL.VoyageNumber  
                              END,  
             EditDate = GETDATE(), -- KHLim01  
             [TrafficCop] = NULL  
         WHERE MBOL.MBOLKey = @c_MBOLKey  
  
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
         IF @n_err <> 0 OR @n_cnt = 0  
         BEGIN  
            SELECT @n_Continue = 3  
            SELECT @n_err=72601  
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table MBOL. (ntrMBOLDetailAdd)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '  
         END  
  
         FETCH NEXT FROM C_trMBOLDetail INTO @c_MBOLKey, @n_weight, @n_cube, @n_custcnt  
      END -- While  
      CLOSE C_trMBOLDetail  
      DEALLOCATE C_trMBOLDetail  
   END  
  
   /**** To Calculate Weight, Cube, Pallet, Case and Customer Cnt ****/  
  
   --SOS#168916  NJOW01  
   IF (@n_Continue = 1 OR @n_Continue = 2)  
   BEGIN  
        IF EXISTS(SELECT 1  
                FROM   INSERTED I  
                JOIN   Orders O WITH (NOLOCK) ON (O.OrderKey = I.OrderKey)  
                JOIN   StorerConfig S WITH (NOLOCK) ON (S.StorerKey = O.StorerKey)  
                WHERE  S.sValue NOT IN ('0','')  
                AND    S.Configkey = 'MBOLDEFAULT')  
      BEGIN  
          UPDATE MBOL WITH (ROWLOCK)  
          SET NoOfIdsCarton = CASE WHEN MBOL.userdefine09 = 'IDS' THEN  
                                   (SELECT SUM(MD.totalcartons) FROM MBOLDETAIL MD (NOLOCK) WHERE MD.MBOLKey = MBOL.MBOLKey)  
                              ELSE 0 END,  
               NoOfCustomerCarton = CASE WHEN MBOL.userdefine09 = 'CUSTOMER' THEN  
                                        (SELECT SUM(MD.totalcartons) FROM MBOLDETAIL MD (NOLOCK) WHERE MD.MBOLKey = MBOL.MBOLKey)  
                                    ELSE 0 END,  
               EditDate = GETDATE(), -- KHLim01  
               TrafficCop = NULL  
           FROM MBOL  
           WHERE MBOL.MBOLKey IN (SELECT DISTINCT MBOLKey FROM INSERTED)  
          SELECT @n_err = @@ERROR  
          IF @n_err <> 0  
          BEGIN  
             SELECT @n_Continue = 3  
             SELECT @n_err=72621  
             SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table MBOL. (ntrMBOLDetailAdd)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '  
          END  
      END  
   END  
  
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN  
      IF EXISTS (SELECT 1 FROM storerconfig s (NOLOCK)  
                 JOIN orders o (NOLOCK) on s.storerkey = o.storerkey  
                 JOIN INSERTED i (NOLOCK) on i.orderkey = o.orderkey  
                 WHERE s.configkey = 'WTS-ITF'  
                   AND s.svalue = '1')  
      BEGIN  
         UPDATE md  
            SET md.TrafficCop = NULL,  
                md.UserDefine01 = l.UserDefine10  
               ,md.EditDate = GETDATE() -- KHLim01  
         FROM MBOLDetail md  
         JOIN INSERTED i on md.MBOLKey = i.MBOLKey and md.LoadKey = i.LoadKey  
         JOIN LoadPlan l (NOLOCK) on i.LoadKey = l.LoadKey  
      END  
   END  
   -- end: populate UserDefine01  
  
   IF @n_Continue = 1 or @n_Continue = 2  
   BEGIN  
      DECLARE @cTrafficCop NVARCHAR(1)  
  
      DECLARE @tPack TABLE  
         (PickSlipNo NVARCHAR(10),  
          LabelNo    NVARCHAR(20),  
          CartonNo   INT,  
          [WEIGHT]   REAL,  
          [CUBE]     REAL)  
  
  
      DECLARE CUR_DELMBOL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
      SELECT DISTINCT MBOLKey, ISNULL(TrafficCop,'')  
      FROM INSERTED  
  
      OPEN CUR_DELMBOL  
      FETCH NEXT FROM CUR_DELMBOL INTO @c_MBOLKey, @cTrafficCop  
  
      WHILE @@FETCH_STATUS <>  -1  
      BEGIN  
         IF ISNULL(@cTrafficCop,'') = '1'  
            GOTO FETCH_NEXT  
  
         IF EXISTS(SELECT 1 FROM ORDERDETAIL o WITH (NOLOCK) WHERE o.MBOLKey = @c_MBOLKey  
                   AND o.ConsoOrderKey IS NOT NULL AND o.ConsoOrderKey <> '')  
         BEGIN  
  
            INSERT INTO @tPack (PickSlipNo, LabelNo, CartonNo, [WEIGHT], [CUBE])  
            SELECT DISTINCT P.PickSlipNo, PD.LabelNo, PD.CartonNo,0, 0  
            FROM   PICKDETAIL p WITH (NOLOCK)  
            JOIN   PACKDETAIL PD WITH (NOLOCK) ON PD.PickSlipNo = P.PickSlipNo  
                                    AND PD.DropID = P.DropID  
            JOIN  MBOLDETAIL MD WITH (NOLOCK) ON MD.OrderKey = P.OrderKey  
            WHERE MD.MBOLKey = @c_MBOLKey  
  
            UPDATE TP  
               SET [WEIGHT]  = pi1.[Weight],  
                   TP.[CUBE] = CASE WHEN pi1.[CUBE] < 1.00 THEN 1.00 ELSE pi1.[CUBE] END  
            FROM @tPack TP  
            JOIN PackInfo pi1 WITH (NOLOCK) ON pi1.PickSlipNo = TP.PickSlipNo AND pi1.CartonNo = TP.CartonNo  
  
            IF EXISTS(SELECT 1 FROM @tPack WHERE [WEIGHT]=0)  
            BEGIN  
               UPDATE TP  
         SET TP.[WEIGHT]  = TWeight.[WEIGHT],  
                      TP.[CUBE] = CASE WHEN TP.[CUBE] < 1.00 THEN 1.00 ELSE TP.[CUBE] END  
               FROM @tPack TP  
               JOIN (SELECT PD.PickSlipNo, PD.CartonNo, SUM(S.STDGROSSWGT * PD.Qty) AS [WEIGHT]  
                     FROM PACKDETAIL PD WITH (NOLOCK)  
                     JOIN SKU S WITH (NOLOCK) ON S.StorerKey = PD.StorerKey AND S.SKU = PD.SKU  
                     JOIN @tPack TP2 ON TP2.PickSlipNo = PD.PickSlipNo AND TP2.CartonNo = PD.CartonNo  
                     GROUP BY PD.PickSlipNo, PD.CartonNo) AS TWeight ON TP.PickSlipNo = TWeight.PickSlipNo  
                              AND TP.CartonNo = TWeight.CartonNo  
               WHERE TP.[WEIGHT] = 0  
  
            END  
  
            UPDATE MBOL  
               SET [Weight]  =  PK.WEIGHT,  
                   MBOL.[Cube] = PK.Cube,  
                   MBOL.CaseCnt = PK.CaseCnt,  
                   EditDate = GETDATE(), -- KH01  
                   TrafficCop=NULL  
            FROM MBOL  
            JOIN (SELECT @c_MBOLKey AS MBOLKey, SUM(WEIGHT) AS Weight, SUM(CUBE) AS Cube, COUNT(*) AS CaseCnt  
                  FROM @tPack) AS PK ON MBOL.MBOLKey = PK.MBOLKey  
  
         END  
  
FETCH_NEXT:  
         DELETE FROM @tPack  
  
         FETCH NEXT FROM CUR_DELMBOL INTO @c_MBOLKey, @cTrafficCop  
      END -- While CUR_DELMBOL  
      CLOSE CUR_DELMBOL  
      DEALLOCATE CUR_DELMBOL  
  
   END  
  
QUIT:  
  
IF @n_Continue=3  -- Error Occured - Process And Return  
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
   EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrMBOLDetailAdd'  
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
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*************************************************************************/  
/* Trigger: ntrMBOLDetailDelete                                          */  
/* Creation Date:                                                        */  
/* Copyright: IDS                                                        */  
/* Written by:                                                           */  
/*                                                                       */  
/* Purpose:                                                              */  
/*                                                                       */  
/* Input Parameters:                                                     */  
/*                                                                       */  
/* Output Parameters:                                                    */  
/*                                                                       */  
/* Return Status:                                                        */  
/*                                                                       */  
/* Usage:                                                                */  
/*                                                                       */  
/* Local Variables:                                                      */  
/*                                                                       */  
/* Called By: Delete Mboldetail                                          */  
/*                                                                       */  
/* PVCS Version: 2.0                                                     */  
/*                                                                       */  
/* Version: 5.4                                                          */  
/*                                                                       */  
/* Data Modifications:                                                   */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date         Author  Ver  Purposes                                    */  
/* 3 MArch 2005 YTWan        Empty orderdetail's MBOLKey  WHEN           */  
/*                           Orderdetail'sLoadKey is empty               */  
/* 04-Jan-2008  SHONG        Bug Fixing - Wrong Formula for Pallet Cnt   */  
/*                           Calculation SOS#95432                       */  
/* 16-Sep-2009  Leong   1.1  SOS147150 - Update OrderDetail before Orders*/  
/* 05-May-2010  NJOW01  1.2  168916 - update total carton to mbol        */  
/*                           depend on mbol.userdefine09                 */  
/* 07-Jul-2010  TLTING  1.3  SOS147150 - Change orderdetail update       */  
/*  9-Jun-2011  KHLim01 1.4  Insert Delete log                           */  
/* 14-Jul-2011  KHLim02 1.5  GetRight for Delete log                     */  
/* 14-Mar-2012  KHLim03 1.6  Update EditDate                             */  
/* 06-APR-2012  YTWan   1.7  SOS#238876:ReplaceUSAMBOL.                  */  
/*                            Calculate NoofCartonPacked. (Wan01)        */  
/* 30-Apr-2012  SHONG   1.7   CustCnt Should using Count Consignee       */  
/*                            Cater ConsoOrderKey                        */  
/* 02-May-2012  Leong   1.8   SOS# 242479 - Add @n_Continue check        */  
/* 12-Sep-2012  SHONG   1.9   Prevent Splitted Order MBOL Accidentally   */  
/*                            Deleted by someone SOS#256080              */   
/* 10-Dec-2012  KHLim   1.10  SOS#264269:Log OrderKey into DELLOG (KH01) */  
/* 22-APR-2014  YTWan   1.11  SOS#294825 ANF - MBOL Creation.(Wan02)     */  
/* 28-JUL-2017  Wan03   2.0   WMS-1916 - WMS Storerconfig for Copy       */  
/*                            totalcarton toctncnt1 in mboldetail        */  
/* 28-May-2020  Shong   3.1   WMS-13444 Auto Create POD record after     */  
/*                            MBOL creation  (SWT01)                     */  
/*************************************************************************/  
  
CREATE TRIGGER [dbo].[ntrMBOLDetailDelete]  
ON [dbo].[MBOLDETAIL]  
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
  
   DECLARE @b_Success   Int       -- Populated by calls to stored procedures - was the proc successful?  
         , @n_err       Int       -- Error number returned by stored procedure OR this trigger  
         , @c_errmsg    NVARCHAR(250) -- Error message returned by stored procedure OR this trigger  
         , @n_Continue  Int       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing  
         , @n_starttcnt Int       -- Holds the current transaction count  
         , @n_cnt       Int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.  
         , @c_authority NVARCHAR(1)    -- KHLim02  
         , @n_TtlCnts   Int        --(Wan01)  
         , @c_MBOLKey   NVARCHAR(10)   --(Wan01)  
         , @n_CustCnt   Int  
         , @c_Facility  NVARCHAR(5)    --(Wan02)  
         , @c_CreatePopulateChildORD   NVARCHAR(10)   --(Wan02)  
  
   SET @n_TtlCnts = 0  --(Wan01)  
   SET @c_MBOLKey = '' --(Wan01)  
   SET @c_Facility= '' --(Wan02)  
   SET @c_CreatePopulateChildORD = ''  --(Wan02)  
  
   SELECT @n_Continue = 1, @n_starttcnt = @@TRANCOUNT  
  
   /* #INCLUDE <TRMBODD1.SQL> */  
   IF (SELECT COUNT(*) FROM DELETED) = (SELECT COUNT(*) FROM DELETED WHERE DELETED.ArchiveCop = '9')  
   BEGIN  
      SELECT @n_Continue = 4  
   END  
  
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN  
      IF EXISTS (SELECT 1 FROM MBOL WITH (NOLOCK), DELETED  
                  WHERE MBOL.MBOLKey = DELETED.MBOLKey  
                  AND MBOL.Status = '9')  
      BEGIN  
         SELECT @n_Continue = 3  
         SELECT @n_err = 72600  
         SELECT @c_errmsg = 'NSQL'+CONVERT(Char(5), @n_err)+': MBOL.Status = SHIPPED. DELETE rejected. (ntrMBOLDetailDelete)'  
      END  
   END  
  
   -- Added By SHONG on 12-Sep-2012, to Prevent Splitted Order MBOL Accidentally Deleted by someone  
   IF @n_Continue = 1 OR @n_Continue = 2    
   BEGIN    
      IF EXISTS(SELECT 1 FROM RDT.RDTScanToTruck STT WITH (NOLOCK)   
                JOIN DELETED DEL ON STT.MbolKey = DEL.MBOLKey AND STT.Status IN ('3', '9' )  
                JOIN ORDERDETAIL OD WITH (NOLOCK) ON OD.OrderKey = DEL.OrderKey AND OD.UserDefine10 <> '' AND OD.UserDefine10 IS NOT NULL)  
      BEGIN  
         SELECT @n_Continue = 3    
         SELECT @n_err = 72610   
         SELECT @c_errmsg = 'NSQL'+CONVERT(Char(5), @n_err)+': RDTScanToTruck.Status = 9. DELETE rejected. (ntrMBOLDetailDelete)'    
      END   
   END    
  
  --(Wan03) - START  
   IF @n_continue=1 or @n_continue=2            
   BEGIN  
      IF EXISTS (SELECT 1 FROM DELETED d    
                 JOIN ORDERS O WITH (NOLOCK) ON (D.Orderkey = O.Orderkey)  
                 JOIN storerconfig s WITH (NOLOCK) ON (O.storerkey = s.storerkey)  
                 JOIN sys.objects sys ON sys.type = 'P' AND sys.name = s.Svalue  
                 WHERE  s.configkey = 'MBOLDetailTrigger_SP')    
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
     
         EXECUTE dbo.isp_MBOLDetailTrigger_Wrapper  
                   'DELETE'  --@c_Action  
                 , @b_Success  OUTPUT    
                 , @n_Err      OUTPUT     
                 , @c_ErrMsg   OUTPUT    
     
         IF @b_success <> 1    
         BEGIN    
            SELECT @n_continue = 3    
                  ,@c_errmsg = 'ntrMBOLDetailDelete ' + RTRIM(LTRIM(ISNULL(@c_errmsg,'')))  
         END    
           
         IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL  
            DROP TABLE #INSERTED  
     
         IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL  
            DROP TABLE #DELETED  
      END  
   END     
   --(Wan03) - END   
  
   --(Wan02) - START // Prevent delete order from MBOLDETAIL for Created Child Order  
   IF @n_Continue = 1 OR @n_Continue = 2    
   BEGIN  
      SELECT @c_Facility = MBOL.Facility  
      FROM DELETED  
      JOIN MBOL WITH (NOLOCK) ON (DELETED.MBOLKey = MBOL.MBOLKey)  
        
      SET @b_success = 0   
      SET @c_CreatePopulateChildORD = '0'      
      EXECUTE nspGetRight  @c_Facility                -- facility  
                        ,  NULL                       -- Storerkey  
                        ,  NULL                       -- Sku  
                        ,  'CreatePopulateChildORD'   -- Configkey  
                        ,  @b_success                 OUTPUT   
                        ,  @c_CreatePopulateChildORD  OUTPUT   
                        ,  @n_err                     OUTPUT   
                        ,  @c_errmsg                  OUTPUT  
      IF @b_success <> 1  
      BEGIN  
         SET @n_Continue = 3  
         SET @c_errmsg = 'ntrMBOLDETAILDelete' + RTRIM(@c_errmsg)  
      END  
      ELSE  
      IF @c_CreatePopulateChildORD = '1'           
      BEGIN  
         IF EXISTS ( SELECT 1  
                     FROM DELETED  
                     JOIN ORDERS      WITH (NOLOCK) ON (DELETED.Orderkey = ORDERS.Orderkey)  
                     JOIN ORDERDETAIL WITH (NOLOCK) ON (ORDERS.Orderkey  = ORDERDETAIL.Orderkey)  
                     WHERE RDD = 'SplitOrder'  
                     AND ORDERDETAIL.UserDefine09 <> ''  
                     AND ORDERDETAIL.UserDefine09 IS NOT NULL  
                     AND ORDERDETAIL.UserDefine10 <> ''  
                     AND ORDERDETAIL.UserDefine10 IS NOT NULL   
                    )  
         BEGIN  
            SET @n_Continue = 3  
            SET @n_err = 72611  
            SET @c_errmsg = 'NSQL'+CONVERT(Char(5),@n_err)+': Delete Child Order. DELETE rejected (ntrMBOLDETAILDelete)'   
         END  
      END  
   END  
   --(Wan02) - END  
  
   --(Wan01) - START  
   IF @n_Continue = 1 OR @n_Continue = 2 -- SOS# 242479  
   BEGIN  
      SELECT @c_MBOLKey = DELETED.MBOLKey  
            ,@n_TtlCnts = SUM(MBOLDETAIL.TotalCartons)  
            ,@n_CustCnt = COUNT(DISTINCT O.ConsigneeKey)  
      FROM DELETED  
      JOIN MBOLDETAIL WITH (NOLOCK) ON DELETED.MBOLKey = MBOLDETAIL.MBOLKey  
      JOIN ORDERS O WITH (NOLOCK) ON O.OrderKey = MBOLDETAIL.OrderKey  
      GROUP BY DELETED.MBOLKey  
  
      UPDATE MBOL WITH (ROWLOCK)  
      SET NoofCartonPacked = @n_TtlCnts  
         , EditWho = SUSER_SNAME()  
         , EditDate = GETDATE()  
         , Trafficcop = NULL  
         , CustCnt = @n_CustCnt  
      WHERE MBOLKey = @c_MBOLKey  
  
      SELECT @n_err = @@ERROR  
  
      IF @n_err <> 0  
      BEGIN  
         SET @n_Continue = 3  
         SET @n_err = 72601  
         SET @c_errmsg = 'NSQL'+CONVERT(Char(5), @n_err)+': Update Failed On Table MBOL. (ntrMBOLDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '  
      END  
   END  
   --(Wan01) - END  
  
   /**** To Calculate Weight, Cube, Pallet, CASE AND Customer Cnt ****/  
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN  
      DECLARE @n_casecnt   Int  
            , @n_palletcnt Int  
  
      --  Bug Fixed by SHONG SOS#95432  
      --  Original: @n_palletcnt = SUM(((ORDERDETAIL.QtyAllocated + ORDERDETAIL.QtyPicked) * SKU.StdCube) / 1),  
      SELECT @n_palletcnt = SUM((ORDERDETAIL.QtyAllocated + ORDERDETAIL.QtyPicked) / (CASE WHEN PACK.Pallet = 0  
                                                                                           THEN 1  
                                                                                           ELSE PACK.Pallet  
                                                                                      END)),  
             @n_casecnt = SUM((ORDERDETAIL.QtyAllocated + ORDERDETAIL.QtyPicked) / (CASE WHEN PACK.CaseCnt > 0  
                                                                                         THEN pack.casecnt  
                                                                                         ELSE NULL  
                                                                                    END))  
      FROM ORDERDETAIL WITH (NOLOCK)  
      JOIN DELETED ON (ORDERDETAIL.OrderKey = DELETED.OrderKey)  
      JOIN SKU WITH (NOLOCK) ON (ORDERDETAIL.StorerKey = SKU.StorerKey AND ORDERDETAIL.SKU = SKU.SKU)  
      JOIN PACK WITH (NOLOCK) ON (ORDERDETAIL.Packkey = PACK.Packkey)  
  
      IF @n_casecnt = NULL  
         SELECT @n_casecnt = 0  
  
      IF @n_palletcnt = NULL  
         SELECT @n_palletcnt = 0  
  
      UPDATE MBOL  
      SET Weight  = MBOL.Weight - DELETED.Weight,  
          Cube    = MBOL.Cube - DELETED.Cube,  
          PalletCnt = PalletCnt - @n_palletcnt,  
          CaseCnt = CaseCnt - @n_casecnt,  
          MBOL.TrafficCop = NULL  
      FROM MBOL, DELETED  
      WHERE MBOL.MBOLKey = DELETED.MBOLKey  
         AND (DELETED.OrderKey <> '' OR DELETED.OrderKey <> NULL)  
  
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_Continue = 3  
         SELECT @c_errmsg = CONVERT(Char(250), @n_err), @n_err = 72602  
         SELECT @c_errmsg = 'NSQL'+CONVERT(Char(5), @n_err)+': Update Failed On Table MBOL. (ntrMBOLDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' )'  
      END  
   END  
  
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN  
      --SOS147150  
      UPDATE OrderDetail  
      SET MBOLKey = '',  
          EditDate = GETDATE(), -- KHLim03  
          TrafficCop = NULL  
      WHERE Exists ( SELECT 1 FROM DELETED  
                     WHERE  DELETED.OrderKey = OrderDetail.OrderKey )  
  
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_Continue = 3  
         SELECT @c_errmsg = CONVERT(Char(250), @n_err), @n_err = 72603  
         SELECT @c_errmsg = 'NSQL'+CONVERT(Char(5), @n_err)+': Update Failed On Table OrderDetail. (ntrMBOLDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' )'  
      END  
   END  
  
   --SOS147150  
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN  
      UPDATE ORDERS  
      SET MBOLKey = '',  
          EditDate = GETDATE(), -- KHLim03  
          TrafficCop = NULL  
      FROM ORDERS WITH (NOLOCK), DELETED  
      WHERE ORDERS.OrderKey = DELETED.OrderKey  
  
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_Continue = 3  
         SELECT @c_errmsg = CONVERT(Char(250), @n_err), @n_err = 72604  
         SELECT @c_errmsg = 'NSQL'+CONVERT(Char(5), @n_err)+': Update Failed On Table ORDERS. (ntrMBOLDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' )'  
      END  
   END  
  
   --Added By Vicky 17 July 2002  
   --Patch FROM IDSMY SOS 6040  
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN  
      UPDATE LOADPLAN  
      SET MBOLKey = '',  
          EditDate = GETDATE(), -- KHLim03  
          TrafficCop = NULL  
      FROM LOADPLAN WITH (NOLOCK)  
      JOIN DELETED ON LOADPLAN.MBOLKey = DELETED.MBOLKey  
                  AND LOADPLAN.LoadKey = DELETED.LoadKey  
      WHERE NOT EXISTS(SELECT 1 FROM MBOLDETAIL WITH (NOLOCK) WHERE MBOLDETAIL.MBOLKey = DELETED.MBOLKey  
                       AND MBOLDETAIL.LoadKey = DELETED.LoadKey)  
  
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_Continue = 3  
         SELECT @c_errmsg = CONVERT(Char(250), @n_err), @n_err = 72605  
         SELECT @c_errmsg = 'NSQL'+CONVERT(Char(5), @n_err)+': Update Failed On Table LoadPlan. (ntrMBOLDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' )'  
      END  
   END  
   --END Add  
  
   -- wally 8.may.2003  
   -- trigantic control: delete POD record in CASE it was created  
   -- start01  
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN  
      DELETE POD  
      FROM POD P JOIN DELETED D ON P.MBOLKey = D.MBOLKey  
                  AND P.ORDERKEY = D.ORDERKEY  
  
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_Continue = 3  
         SELECT @c_errmsg = CONVERT(Char(250), @n_err), @n_err = 72606  
         SELECT @c_errmsg = 'NSQL'+CONVERT(Char(5), @n_err)+': Delete Failed on Table POD. (ntrMBOLDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' )'  
      END  
   END  
   -- end01  
  
   --SOS#168916  NJOW01  
   IF (@n_Continue = 1 OR @n_Continue = 2)  
   BEGIN  
      IF EXISTS(SELECT 1  
                FROM   DELETED D  
                JOIN   Orders O WITH (NOLOCK) ON (O.OrderKey = D.OrderKey)  
                JOIN   StorerConfig S WITH (NOLOCK) ON (S.StorerKey = O.StorerKey)  
                WHERE  S.sValue NOT IN ('0','')  
                AND    S.Configkey = 'MBOLDEFAULT')  
      BEGIN  
         UPDATE MBOL WITH (ROWLOCK)  
         SET NoOfIDSCarton = CASE WHEN MBOL.userdefine09 = 'IDS'  
                                  THEN NoOfIDSCarton - (SELECT SUM(DELETED.TotalCartons) FROM DELETED WHERE DELETED.MBOLKey = MBOL.MBOLKey)  
                             ELSE 0 END,  
             NoOfCustomerCarton = CASE WHEN MBOL.userdefine09 = 'CUSTOMER'  
                                       THEN NoOfCustomerCarton - (SELECT SUM(DELETED.TotalCartons) FROM DELETED WHERE DELETED.MBOLKey = MBOL.MBOLKey)  
                                  ELSE 0 END,  
             EditDate = GETDATE(), -- KHLim03  
             TrafficCop = NULL  
         FROM MBOL  
         WHERE MBOL.MBOLKey IN (SELECT DISTINCT MBOLKey FROM DELETED)  
  
         SELECT @n_err = @@ERROR  
  
         IF @n_err <> 0  
         BEGIN  
            SELECT @n_Continue = 3  
            SELECT @c_errmsg = CONVERT(Char(250), @n_err), @n_err = 72607  
            SELECT @c_errmsg = 'NSQL'+CONVERT(Char(5), @n_err)+': Update Failed on Table MBOL. (ntrMBOLDetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' )'  
         END  
      END  
   END  
  
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN  
      DECLARE @tPack TABLE  
         (PickSlipNo NVARCHAR(10),  
          LabelNo    NVARCHAR(20),  
          CartonNo   Int,  
          [WEIGHT]   REAL,  
          [CUBE]     REAL)  
  
      DECLARE CUR_DELMBOL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
      SELECT DISTINCT MBOLKey FROM DELETED  
  
      OPEN CUR_DELMBOL  
      FETCH NEXT FROM CUR_DELMBOL INTO @c_MBOLKey  
  
      WHILE @@FETCH_STATUS <>  -1  
      BEGIN  
         IF EXISTS(SELECT 1 FROM ORDERDETAIL O WITH (NOLOCK) WHERE O.MBOLKey = @c_MBOLKey  
                   AND O.ConsoOrderKey IS NOT NULL AND O.ConsoOrderKey <> '')  
         BEGIN  
            INSERT INTO @tPack (PickSlipNo, LabelNo, CartonNo, [WEIGHT], [CUBE])  
            SELECT DISTINCT P.PickSlipNo, PD.LabelNo, PD.CartonNo,0, 0  
            FROM   PICKDETAIL p WITH (NOLOCK)  
            JOIN   PACKDETAIL PD WITH (NOLOCK) ON (PD.PickSlipNo = P.PickSlipNo AND PD.DropID = P.DropID)  
            JOIN  MBOLDETAIL MD WITH (NOLOCK) ON MD.OrderKey = P.OrderKey  
            WHERE MD.MBOLKey = @c_MBOLKey  
  
            UPDATE TP  
               SET [WEIGHT]  = pi1.[Weight],  
                   TP.[CUBE] = CASE WHEN pi1.[CUBE] < 1.00 THEN 1.00 ELSE pi1.[CUBE] END  
            FROM @tPack TP  
            JOIN PackInfo pi1 WITH (NOLOCK) ON pi1.PickSlipNo = TP.PickSlipNo AND pi1.CartonNo = TP.CartonNo  
  
            IF EXISTS(SELECT 1 FROM @tPack WHERE [WEIGHT]=0)  
            BEGIN  
               UPDATE TP  
                  SET TP.[WEIGHT]  = TWeight.[WEIGHT],  
                      TP.[CUBE] = CASE WHEN TP.[CUBE] < 1.00 THEN 1.00 ELSE TP.[CUBE] END  
               FROM @tPack TP  
               JOIN (SELECT PD.PickSlipNo, PD.CartonNo, SUM(S.STDGROSSWGT * PD.Qty) AS [WEIGHT]  
                     FROM PACKDETAIL PD WITH (NOLOCK)  
              JOIN SKU S WITH (NOLOCK) ON S.StorerKey = PD.StorerKey AND S.SKU = PD.SKU  
                     JOIN @tPack TP2 ON TP2.PickSlipNo = PD.PickSlipNo AND TP2.CartonNo = PD.CartonNo  
                     GROUP BY PD.PickSlipNo, PD.CartonNo) AS TWeight ON TP.PickSlipNo = TWeight.PickSlipNo  
                              AND TP.CartonNo = TWeight.CartonNo  
               WHERE TP.[WEIGHT] = 0  
            END  
  
            UPDATE MBOL  
               SET [Weight]  =  PK.WEIGHT, MBOL.[Cube] = PK.Cube, MBOL.CaseCnt = PK.CaseCnt,  
                   TrafficCop=NULL  
            FROM MBOL  
            JOIN (SELECT @c_MBOLKey AS MBOLKey, SUM(WEIGHT) AS Weight, SUM(CUBE) AS Cube, COUNT(*) AS CaseCnt  
                  FROM @tPack) AS PK ON MBOL.MBOLKey = PK.MBOLKey  
         END  
  
         DELETE FROM @tPack  
  
         FETCH NEXT FROM CUR_DELMBOL INTO @c_MBOLKey  
      END -- While CUR_DELMBOL  
      CLOSE CUR_DELMBOL  
      DEALLOCATE CUR_DELMBOL  
  
   END  
  
   -- Start (KHLim01)  
   IF @n_Continue = 1 OR @n_Continue = 2  
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
         SELECT @n_Continue = 3  
              , @c_errmsg = 'ntrMBOLDETAILDelete' + RTRIM(@c_errmsg)  
      END  
      ELSE  
      IF @c_authority = '1'         --    END   (KHLim02)  
      BEGIN  
         INSERT INTO dbo.MBOLDETAIL_DELLOG ( MBOLKey, MbolLineNumber, OrderKey ) --KH01  
         SELECT MBOLKey, MbolLineNumber, OrderKey FROM DELETED --KH01  
  
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
  
         IF @n_err <> 0  
         BEGIN  
            SELECT @n_Continue = 3  
            SELECT @c_errmsg = CONVERT(Char(250),@n_err), @n_err = 72607  
            SELECT @c_errmsg = 'NSQL'+CONVERT(Char(5),@n_err)+': Delete Trigger On Table MBOLDetail Failed. (ntrMBOLDETAILDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' )'  
         END  
      END  
   END  
   -- END (KHLim01)  
     
     
   IF @n_Continue = 1 OR @n_Continue = 2  
   BEGIN  
      DECLARE   
              @c_POD_Authority    NVARCHAR(1)  = '0'   -- (SWT01)  
            , @c_POD_Option01     NVARCHAR(20) = ''   -- (SWT01)   
            , @c_MbolLineNumber   NVARCHAR(5)  = ''  
            , @c_StorerKey        NVARCHAR(15) = ''  
              
        
      DECLARE CUR_DELETE_MBOL_LN CURSOR FAST_FORWARD READ_ONLY FOR  
      SELECT MD.MbolKey, MD.MbolLineNumber, o.StorerKey, o.Facility  
      FROM DELETED MD WITH (NOLOCK)  
      JOIN ORDERS AS o WITH(NOLOCK) ON o.OrderKey = MD.OrderKey  
        
      OPEN CUR_DELETE_MBOL_LN  
        
      FETCH FROM CUR_DELETE_MBOL_LN INTO @c_MbolKey, @c_MbolLineNumber, @c_StorerKey, @c_Facility  
        
      WHILE @@FETCH_STATUS = 0  
      BEGIN  
         SET @b_success = 0  
         SET @c_POD_Option01=''  
         SET @c_POD_Authority = ''  
              
         EXECUTE nspGetRight   
             @c_Facility  = @c_Facility -- facility  
            ,@c_StorerKey = @c_StorerKey -- Storerkey -- SOS40271  
            ,@c_sku       = NULL         -- Sku  
            ,@c_ConfigKey = 'POD'        -- Configkey  
            ,@b_Success   = @b_success       OUTPUT  
            ,@c_authority = @c_POD_Authority OUTPUT  
            ,@n_err       = @n_err          OUTPUT  
            ,@c_errmsg    = @c_errmsg       OUTPUT  
            ,@c_Option1   = @c_POD_Option01 OUTPUT -- (SWT01)   
  
         IF @b_success <> 1  
         BEGIN  
            SELECT @n_continue = 3, @c_errmsg = 'ntrMBOLDetailAdd' + RTRIM(@c_errmsg)  
         END  
         ELSE IF @c_POD_Authority = '1' AND @c_POD_Option01 = 'MBOLADD'  
         BEGIN                  
            IF NOT EXISTS ( SELECT 1 FROM POD WITH (NOLOCK) WHERE MBOLKey = @c_MBOLKey AND Mbollinenumber = @c_MbolLineNumber)  
            BEGIN  
               SET @b_success = 0  
  
               DELETE FROM POD  
               WHERE MBOLKey = @c_MBOLKey   
               AND Mbollinenumber = @c_MbolLineNumber  
                 
               SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
               IF @n_err <> 0  
               BEGIN  
                  SELECT @n_continue = 3  
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72807  
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))  
                                    + ': Delete Failed On Table POD. (ntrMBOLDetailDelete)'  
                                    + ' ( SQLSvr MESSAGE=' + ISNULL(RTrim(@c_errmsg), '') + ' ) '  
               END  
            END  
         END -- POD Authority = 1 -- (SWT01)  
        
        
         FETCH FROM CUR_DELETE_MBOL_LN INTO @c_MbolKey, @c_MbolLineNumber, @c_StorerKey, @c_Facility  
      END  
        
      CLOSE CUR_DELETE_MBOL_LN  
      DEALLOCATE CUR_DELETE_MBOL_LN  
        
        
   END     
  
   /* #INCLUDE <TRMBODD2.SQL> */  
   IF @n_Continue = 3  -- Error Occured - Process AND Return  
   BEGIN  
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrMBOLDetailDelete'  
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

/****************************************************************************/
/* Store Procedure:  ntrMBOLDetailUpdate                                    */
/* Creation Date:                                                           */
/* Copyright: IDS                                                           */
/* Written by:                                                              */
/*                                                                          */
/* Purpose:  MBOLDetailUpdate Trigger                                       */
/*                                                                          */
/* Input Parameters:                                                        */
/*                                                                          */
/* Output Parameters:  None                                                 */
/*                                                                          */
/* Return Status:  None                                                     */
/*                                                                          */
/* Usage:                                                                   */
/*                                                                          */
/* Local Variables:                                                         */
/*                                                                          */
/* Called By:                                                               */
/*                                                                          */
/* PVCS Version: 2.1                                                        */
/*                                                                          */
/* Version: 5.4                                                             */
/*                                                                          */
/* Data Modifications:                                                      */
/*                                                                          */
/* Updates:                                                                 */
/* Date         Author    Ver.  Purposes                                    */
/* 17-Mar-2009  TLTING    1.1   Change user_name() to SUSER_SNAME()         */
/* 05-May-2010  NJOW01    1.2   168916 - update total carton to mbol        */
/*                              depend on mbol.userdefine09                 */
/* 25-May-2011  Ung       1.3   SOS216105 Configurable SP to calc           */
/*                              carton, cube and weight                     */
/* 25-May-2011  Ung       1.4   SOS216105 Configurable SP to calc           */
/*                              carton, cube and weight                     */
/* 09-Apr-2012  TLTING    1.5   Re position Rowcount 0 Return               */
/* 06-APR-2012  YTWan     1.6   SOS#238876:ReplaceUSAMBOL.Calculate         */
/*                              NoofCartonPacked. (Wan01)                   */  
/* 23-Apr-2012  NJOW02    1.7   241032-Calculation by coefficient           */
/* 23 May 2012  TLTING02  1.8   DM integrity - add update editdate B4       */
/*                              TrafficCop for status < '9'                 */ 
/* 28-Oct-2013  TLTING    1.9   Review Editdate column update               */ 
/* 08-Dec-2015  NJOW03    2.0   358632-Skip auto sp calculate for Ecom order*/
/* 28-JUL-2017  Wan02     2.1   WMS-1916 - WMS Storerconfig for Copy        */
/*                              totalcarton to ctncnt1 in mboldetail        */
/****************************************************************************/
CREATE TRIGGER [dbo].[ntrMBOLDetailUpdate] 
ON [dbo].[MBOLDETAIL] FOR UPDATE AS
BEGIN
 
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
 ,         @c_authority NVARCHAR(1) -- Add by June for IDSV5 28.Jun.02
 ,         @n_ttlcnts      INT                                                                     --(Wan01)
 ,         @c_mbolkey      NVARCHAR(10)
 ,         @c_short     NVARCHAR(10) --NJOW03                                                               --(Wan01)

 SET @n_ttlcnts = 0                                                                                --(Wan01)
 SET @c_mbolkey = ''                                                                               --(Wan01)
 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

 IF UPDATE(ArchiveCop)
 BEGIN
    SELECT @n_continue = 4 
 END
 
 -- tlting01
 IF ( @n_continue=1 or @n_continue=2 ) AND NOT UPDATE(EditDate) 
 BEGIN
    UPDATE MBOLDetail with (ROWLOCK)
    SET EditDate = GETDATE(),
        EditWho = SUSER_SNAME(),
        TrafficCop = NULL
    FROM MBOLDetail, INSERTED
    WHERE MBOLDetail.MBOLKey = INSERTED.MBOLKey
    AND MBOLDetail.MBOLLineNumber = INSERTED.MBOLLineNumber
    SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
    IF @n_err <> 0
    BEGIN
       SELECT @n_continue = 3
       SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=73102   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
       SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table MBOLDetail. (ntrMBOLDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
    END
 END
 
 IF UPDATE(TrafficCop)
 BEGIN
    SELECT @n_continue = 4 
 END

 /* #INCLUDE <TRMBODU1.SQL> */     
 /*
 IF @n_continue=1 or @n_continue=2
 BEGIN
 IF EXISTS (SELECT * FROM MBOL, INSERTED
 WHERE MBOL.MBOLKey = INSERTED.MBOLKey
 AND MBOL.Status = "9")
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err=73100
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": MBOL.Status = 'SHIPPED'. UPDATE rejected. (ntrMBOLDetailUpdate)"
 END
 END
 */
   --(Wan02) - START
   IF @n_continue=1 or @n_continue=2
   BEGIN
      IF EXISTS (SELECT 1 FROM DELETED d
                 JOIN ORDERS O WITH (NOLOCK) ON (D.OrderKey = O.OrderKey)
                 JOIN storerconfig s WITH (NOLOCK) ON (O.storerkey = s.storerkey)
                 JOIN sys.objects sys ON sys.type = 'P' AND sys.name = s.Svalue
                 WHERE  s.configkey = 'MBOLDetailTrigger_SP')
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

         EXECUTE dbo.isp_MBOLDetailTrigger_Wrapper
                   'UPDATE'  --@c_Action
                 , @b_Success  OUTPUT
                 , @n_Err      OUTPUT
                 , @c_ErrMsg   OUTPUT

         IF @b_success <> 1
         BEGIN
            SELECT @n_continue = 3
                  ,@c_errmsg = 'ntrMBOLDetailUpdate ' + RTRIM(LTRIM(ISNULL(@c_errmsg,'')))
         END

         IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL
            DROP TABLE #INSERTED

         IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL
            DROP TABLE #DELETED
      END
   END
   --(Wan02) - END

 -- for ACSIE (IDSPH)
 -- WALLY 8.may.2001
 -- mandatory fields based on invoice status
 IF @n_continue = 1 OR @n_continue = 2
 BEGIN
   -- Added for IDSV5 by June 28.Jun.02, (extract from IDSPH) *** Start
   SELECT @b_success = 0
   Execute nspGetRight null,   -- facility
             null,    -- Storerkey
             null,            -- Sku
             'ACSIE',         -- Configkey
             @b_success      output,
             @c_authority   output, 
             @n_err         output,
             @c_errmsg      output
   IF @b_success <> 1
   BEGIN
      SELECT @n_continue = 3, @c_errmsg = 'ntrMBOLDetailUpdate' + dbo.fnc_RTrim(@c_errmsg)
   END
   ELSE IF @c_authority = '1'
   BEGIN    -- Added for IDSV5 by June 28.Jun.02, (extract from IDSPH) *** End
       DECLARE @c_invoicestatus NVARCHAR(10),
          @d_deliverydate datetime,
          @c_pcm NVARCHAR(12),
          @c_reason NVARCHAR(60)
       SELECT @c_invoicestatus = INSERTED.invoicestatus,
          @d_deliverydate = INSERTED.deliverydate,
          @c_pcm = INSERTED.pcmnum,
          @c_reason = INSERTED.externreason
       FROM INSERTED INNER JOIN MBOLDETAIL
         ON (INSERTED.mbolkey = MBOLDETAIL.mbolkey AND INSERTED.mbollinenumber = MBOLDETAIL.mbollinenumber)
       IF @c_invoicestatus = 'D' AND @d_deliverydate IS NULL
       BEGIN
          SELECT @n_continue = 3
          SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72611   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
          SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+" : ACTUAL DELIVERY DATE REQUIRED..."
       END
       ELSE IF @c_invoicestatus = 'J' AND (@c_pcm IS NULL OR @c_pcm = '') AND (@c_reason IS NULL OR @c_reason = '')
       BEGIN
          SELECT @n_continue = 3
          SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72611   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
          SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+" : PCM NUMBER and REASON CODE REQUIRED..."
       END   
   END
 END

--SOS#168916  NJOW01
 IF (@n_continue = 1 OR @n_continue = 2) AND UPDATE(totalcartons)
 BEGIN
      IF EXISTS(SELECT 1
              FROM   INSERTED I 
              JOIN   Orders O WITH (NOLOCK) ON (O.OrderKey = I.OrderKey) 
              JOIN   StorerConfig S WITH (NOLOCK) ON (S.StorerKey = O.StorerKey)
              WHERE  S.sValue NOT IN ('0','') 
              AND    S.Configkey = 'MBOLDEFAULT')
    BEGIN
          UPDATE MBOL WITH (ROWLOCK)
           SET noofidscarton = CASE WHEN MBOL.userdefine09 = 'IDS' THEN
                                 noofidscarton - (SELECT SUM(DELETED.totalcartons) FROM DELETED WHERE DELETED.Mbolkey = MBOL.Mbolkey)
                                 + (SELECT SUM(INSERTED.totalcartons) FROM INSERTED WHERE INSERTED.Mbolkey = MBOL.Mbolkey)
                            ELSE 0 END,
              noofcustomercarton = CASE WHEN MBOL.userdefine09 = 'CUSTOMER' THEN
                                       noofcustomercarton - (SELECT SUM(DELETED.totalcartons) FROM DELETED WHERE DELETED.Mbolkey = MBOL.Mbolkey)
                                       + (SELECT SUM(INSERTED.totalcartons) FROM INSERTED WHERE INSERTED.Mbolkey = MBOL.Mbolkey)
                                   ELSE 0 END,
              TrafficCop = NULL,
              EditDate = GETDATE(),       --tlting
              EditWho = SUSER_SNAME()
           FROM MBOL 
           WHERE MBOL.Mbolkey IN (SELECT DISTINCT Mbolkey FROM DELETED)
        SELECT @n_err = @@ERROR
        IF @n_err <> 0
        BEGIN
           SELECT @n_continue = 3
           SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=73112   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
           SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table MBOL. (ntrMBOLDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
        END          
    END
   --(Wan01) - START

   IF EXISTS ( SELECT 1
               FROM INSERTED
               JOIN DELETED ON (INSERTED.MBOLKey = DELETED.MBolkey) AND (INSERTED.MBolLineNumber = DELETED.MBolLineNumber)
               WHERE INSERTED.TotalCartons <> DELETED.TotalCartons )
   BEGIN

      SELECT @c_MBolkey = MBolkey
      FROM INSERTED

      SELECT @n_ttlcnts = SUM(TotalCartons)
      FROM MBOLDETAIL WITH (NOLOCK)  
      WHERE MBolkey = @c_MBOLKey
          
      UPDATE MBOL WITH (ROWLOCK)
      SET NoofCartonPacked = @n_ttlcnts
       , EditWho = SUSER_NAME() 
       , EditDate = GETDATE()   
       , Trafficcop = NULL
      WHERE Mbolkey = @c_MBOLKey
      
      SELECT @n_err = @@ERROR
      IF @n_err <> 0
      BEGIN
         SET @n_continue = 3
         SET @n_err=72612
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table MBOL. (ntrMBOLDetailAdd)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END
   END
   --(Wan01) - END
 END 
 
-- SOS216105. Configurable SP to calc carton, cube and weight
IF (@n_continue = 1 OR @n_continue = 2) AND (
   UPDATE( TotalCartons) OR 
   UPDATE( CtnCnt1) OR 
   UPDATE( CtnCnt2) OR 
   UPDATE( CtnCnt3) OR 
   UPDATE( CtnCnt4) OR 
   UPDATE( CtnCnt5))
BEGIN
   DECLARE @cSValue     NVARCHAR( 10)
   DECLARE @cSP_Cube    SYSNAME
   DECLARE @cSP_Weight  SYSNAME
   DECLARE @cSQL        NVARCHAR( 400)
   DECLARE @cParam      NVARCHAR( 400)
   DECLARE @cStorerKey  NVARCHAR( 15)
   DECLARE @cPickSlipNo NVARCHAR( 10)
   DECLARE @cOrderKey   NVARCHAR( 10)
   DECLARE @cMBOLKey    NVARCHAR( 10)
   DECLARE @cMBOLLineNumber NVARCHAR( 5)
   DECLARE @nCtnCnt1     INT
   DECLARE @nCtnCnt2     INT
   DECLARE @nCtnCnt3     INT
   DECLARE @nCtnCnt4     INT
   DECLARE @nCtnCnt5     INT
   DECLARE @nTotalCube   FLOAT
   DECLARE @nTotalWeight FLOAT
   DECLARE @nCurrentTotalCube   FLOAT
   DECLARE @nCurrentTotalWeight FLOAT
   DECLARE @n_Coefficient_carton float,  --NJOW02
           @n_Coefficient_cube   float,  --NJOW02
           @n_Coefficient_weight float   --NJOW02


   DECLARE curMD CURSOR FAST_FORWARD READ_ONLY FOR
      SELECT MBOLKey, MBOLLineNumber, OrderKey, Cube, Weight, CtnCnt1, CtnCnt2, CtnCnt3, CtnCnt4, CtnCnt5
      FROM INSERTED
   OPEN curMD
   FETCH NEXT FROM curMD INTO @cMBOLKey, @cMBOLLineNumber, @cOrderKey, @nCurrentTotalCube, @nCurrentTotalWeight, @nCtnCnt1, @nCtnCnt2, @nCtnCnt3, @nCtnCnt4, @nCtnCnt5
   WHILE @@FETCH_STATUS = 0
   BEGIN
      -- Determine if discrete pick list
      IF EXISTS( SELECT 1 FROM PickHeader WITH (NOLOCK) WHERE OrderKey = @cOrderKey)
      BEGIN
         SELECT @cStorerKey = StorerKey FROM Orders WITH (NOLOCK) WHERE OrderKey = @cOrderKey
         
         -- Get pick or pack formula
         IF EXISTS( SELECT 1 FROM PackHeader WITH (NOLOCK) WHERE OrderKey = @cOrderKey)
            SELECT @cSValue = SValue FROM StorerConfig WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ConfigKey = 'CMSPackingFormula'
         ELSE
            SELECT @cSValue = SValue FROM StorerConfig WITH (NOLOCK) WHERE StorerKey = @cStorerKey AND ConfigKey = 'CMSNoPackingFormula'
         
         IF @cSValue <> '' AND @cSValue IS NOT NULL
         BEGIN
            -- Get customize stored procedure
            SELECT 
               @cSP_Cube = Notes, 
               @cSP_Weight = Notes2,
               @n_Coefficient_carton = CASE WHEN ISNUMERIC(UDF01) = 1 THEN
                                            CONVERT(float,UDF01) ELSE 1 END,  --NJOW02
               @n_Coefficient_cube = CASE WHEN ISNUMERIC(UDF02) = 1 THEN
                                            CONVERT(float,UDF02) ELSE 1 END,  --NJOW02
               @n_Coefficient_weight = CASE WHEN ISNUMERIC(UDF03) = 1 THEN
                                            CONVERT(float,UDF03) ELSE 1 END,  --NJOW02
               @c_Short = Short --NJOW03
            FROM CodeLkup WITH (NOLOCK)
            WHERE ListName = 'CMSStrateg'
               AND Code = @cSValue
            
            -- Run cube SP
            IF OBJECT_ID( @cSP_Cube, 'P') IS NOT NULL 
               AND NOT EXISTS (SELECT 1 FROM ORDERS (NOLOCK)  --NJOW03
                               WHERE Orderkey = @cOrderkey
                               AND Doctype = 'E'
                               AND @c_short IN ('1','12','21'))  -- 1=CUBE 2=WEIGHT
            BEGIN
               SET @cSQL = 'EXEC ' + @cSP_Cube + ' @cPickSlipNo, @cOrderKey, @nTotalCube OUTPUT, @nCurrentTotalCube, @nCtnCnt1, @nCtnCnt2, @nCtnCnt3, @nCtnCnt4, @nCtnCnt5'
               SET @cParam = '@cPickSlipNo NVARCHAR( 10), @cOrderKey NVARCHAR( 10), @nTotalCube FLOAT OUTPUT, @nCurrentTotalCube FLOAT , @nCtnCnt1 INT, @nCtnCnt2 INT, @nCtnCnt3 INT, @nCtnCnt4 INT, @nCtnCnt5 INT'
               EXEC sp_executesql @cSQL, @cParam, @cPickSlipNo, @cOrderKey, @nTotalCube OUTPUT, @nCurrentTotalCube, @nCtnCnt1, @nCtnCnt2, @nCtnCnt3, @nCtnCnt4, @nCtnCnt5
               SET @n_err = @@ERROR
               IF @n_err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=73112
                  SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table MBOL. (ntrMBOLDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
                  BREAK
               END 

               --NJOW02
               SET @nTotalCube = ISNULL(@nTotalCube,0) * @n_Coefficient_cube             
               
               UPDATE MBOLDetail SET Cube = @nTotalCube WHERE MBOLKey = @cMBOLKey AND MBOLLineNumber = @cMBOLLineNumber
               SET @n_err = @@ERROR                  
               IF @n_err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=73112
                  SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table MBOL. (ntrMBOLDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
                  BREAK
               END 
            END

            -- Run weight SP
            IF OBJECT_ID( @cSP_Weight, 'P') IS NOT NULL 
               AND NOT EXISTS (SELECT 1 FROM ORDERS (NOLOCK)  --NJOW03
                               WHERE Orderkey = @cOrderkey
                               AND Doctype = 'E'
                               AND @c_short IN ('2','12','21'))  -- 1=CUBE 2=WEIGHT  
            BEGIN
               SET @cSQL = 'EXEC ' + @cSP_Weight + ' @cPickSlipNo, @cOrderKey, @nTotalWeight OUTPUT, @nCurrentTotalWeight'
               SET @cParam = '@cPickSlipNo NVARCHAR( 10), @cOrderKey NVARCHAR( 10), @nTotalWeight FLOAT OUTPUT, @nCurrentTotalWeight FLOAT'
               EXEC sp_executesql @cSQL, @cParam, @cPickSlipNo, @cOrderKey, @nTotalWeight OUTPUT, @nCurrentTotalWeight
               SET @n_err = @@ERROR
               IF @n_err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=73112
                  SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table MBOL. (ntrMBOLDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
                  BREAK
               END 

               --NJOW02
               SET @nTotalWeight = ISNULL(@nTotalWeight,0) * @n_Coefficient_weight             

               UPDATE MBOLDetail SET Weight = @nTotalWeight WHERE MBOLKey = @cMBOLKey AND MBOLLineNumber = @cMBOLLineNumber
               SET @n_err = @@ERROR                  
               IF @n_err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=73112
                  SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table MBOL. (ntrMBOLDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
                  BREAK
               END 
            END
         END
      END
      FETCH NEXT FROM curMD INTO @cMBOLKey, @cMBOLLineNumber, @cOrderKey, @nCurrentTotalCube, @nCurrentTotalWeight, @nCtnCnt1, @nCtnCnt2, @nCtnCnt3, @nCtnCnt4, @nCtnCnt5
   END
   CLOSE curMD
   DEALLOCATE curMD
END
 
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
    execute nsp_logerror @n_err, @c_errmsg, "ntrMBOLDetailUpdate"
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
ALTER TABLE [dbo].[MBOLDETAIL] ADD CONSTRAINT [PKMBOLDETAIL] PRIMARY KEY CLUSTERED ([MbolKey], [MbolLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [MBOLDETAIL5] ON [dbo].[MBOLDETAIL] ([OrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[MBOLDETAIL] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[MBOLDETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[MBOLDETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[MBOLDETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[MBOLDETAIL] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Capacity', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'Capacity'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Item account number', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'ContainerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 1', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'CtnCnt1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 2', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'CtnCnt2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 3', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'CtnCnt3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 4', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'CtnCnt4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton count 5', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'CtnCnt5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Records the maximum cubic size for a Commodity the carton can hold.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of delivery made.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'DeliveryDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Delivery status', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'DeliveryStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Delivery time', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'DeliveryTime'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of Master Bill of Lading Details.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'OTM DriverName', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'DriverName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Seller''s/storer''s external order number', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'ExternOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'External reason', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'ExternReason'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Gross weight', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'GrossWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Invoice amount', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'InvoiceAmount'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shipment Order invoice number', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'InvoiceNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Invoice status', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'InvoiceStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'IT Support', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'ITS'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying loading.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'LoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Master Bill of Lading.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'MbolKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'detail line number in sequence', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'MbolLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Official receipt', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'OfficialReceipt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of order made.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'OrderDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'shipment order number', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pallet Key', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'PalletKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PCM number', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'PCMNum'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Service Provider', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'ServiceProvider'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Timestamp', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'TimeStamp'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total cartons being delivered.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'TotalCartons'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total carton cube', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'TotCtnCube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total carton weight', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'TotCtnWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Truck Type', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'TruckType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'UPS invoice number', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UPSINum'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined column 01', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined column 02', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined column 03', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined column 04', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined column 05', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined column 06', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined column 07', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined column 08', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined column 09', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined column 10', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'UserDefine10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'OTM VehicleNo', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'VehicleNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Weight', 'SCHEMA', N'dbo', 'TABLE', N'MBOLDETAIL', 'COLUMN', N'Weight'
GO
