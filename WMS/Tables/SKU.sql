CREATE TABLE [dbo].[SKU]
(
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DESCR] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUSR1] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUSR2] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUSR3] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_SUSR3] DEFAULT (' '),
[SUSR4] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUSR5] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MANUFACTURERSKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_MANUFACTURERSKU] DEFAULT (''),
[RETAILSKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_RETAILSKU] DEFAULT (''),
[ALTSKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_ALTSKU] DEFAULT (''),
[PACKKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_Packkey] DEFAULT ('STD'),
[STDGROSSWGT] [float] NOT NULL CONSTRAINT [DF_SKU_StdGrossWgt] DEFAULT ((0)),
[STDNETWGT] [float] NOT NULL CONSTRAINT [DF_SKU_StdNetWgt] DEFAULT ((0)),
[STDCUBE] [float] NOT NULL CONSTRAINT [DF_SKU_StdCube] DEFAULT ((0)),
[TARE] [float] NOT NULL CONSTRAINT [DF_SKU_Tare] DEFAULT ((0)),
[CLASS] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_Class] DEFAULT ('STD'),
[ACTIVE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_ACTIVE] DEFAULT ('1'),
[SKUGROUP] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_SKUGROUP] DEFAULT ('STD'),
[Tariffkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_Tariffkey] DEFAULT ('XXXXXXXXXX'),
[BUSR1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSR2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSR3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSR4] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSR5] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOTTABLE01LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE01LABEL] DEFAULT (' '),
[LOTTABLE02LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE02LABEL] DEFAULT (' '),
[LOTTABLE03LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE03LABEL] DEFAULT (' '),
[LOTTABLE04LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE04LABEL] DEFAULT (' '),
[LOTTABLE05LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE05LABEL] DEFAULT (' '),
[NOTES1] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NOTES2] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PickCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_PickCode] DEFAULT ('NSPRPFIFO'),
[StrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_StrategyKey] DEFAULT ('STD'),
[CartonGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_CartonGroup] DEFAULT ('STD'),
[PutCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_PutCode] DEFAULT ('NSPPASTD'),
[PutawayLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_PutawayLoc] DEFAULT ('UNKNOWN'),
[PutawayZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_Putawayzone] DEFAULT ('BULK'),
[InnerPack] [int] NOT NULL CONSTRAINT [DF_SKU_InnerPack] DEFAULT ((0)),
[Cube] [float] NOT NULL CONSTRAINT [DF_SKU_Cube] DEFAULT ((0)),
[GrossWgt] [float] NOT NULL CONSTRAINT [DF_SKU_GrossWgt] DEFAULT ((0)),
[NetWgt] [float] NOT NULL CONSTRAINT [DF_SKU_NetWgt] DEFAULT ((0)),
[ABC] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_ABC] DEFAULT ('B'),
[CycleCountFrequency] [int] NULL,
[LastCycleCount] [datetime] NULL,
[ReorderPoint] [int] NULL,
[ReorderQty] [int] NULL,
[StdOrderCost] [float] NULL,
[CarryCost] [float] NULL,
[Price] [money] NULL,
[Cost] [money] NULL,
[ReceiptHoldCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_ReceiptHoldCode] DEFAULT (' '),
[ReceiptInspectionLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_ReceiptInspectionLoc] DEFAULT ('QC'),
[OnReceiptCopyPackkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_OnReceiptCopyPackkey] DEFAULT ('0'),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IOFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TareWeight] [float] NULL CONSTRAINT [DF_SKU_TareWeight] DEFAULT ((0)),
[LotxIdDetailOtherlabel1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_LotxIdDetailOtherlabel1] DEFAULT ('Ser#'),
[LotxIdDetailOtherlabel2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_LotxIdDetailOtherlabel2] DEFAULT ('CSID'),
[LotxIdDetailOtherlabel3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_LotxIdDetailOtherlabel3] DEFAULT ('Other'),
[AvgCaseWeight] [float] NULL CONSTRAINT [DF_SKU_AvgCaseWeight] DEFAULT ((0)),
[TolerancePct] [float] NULL CONSTRAINT [DF_SKU_TolerancePct] DEFAULT ((0)),
[SkuStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_SkuStatus] DEFAULT ('ACTIVE'),
[Length] [float] NULL CONSTRAINT [DF_SKU_Length] DEFAULT ((0.00)),
[Width] [float] NULL CONSTRAINT [DF_SKU_Width] DEFAULT ((0.00)),
[Height] [float] NULL CONSTRAINT [DF_SKU_Height] DEFAULT ((0.00)),
[weight] [real] NULL,
[itemclass] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_itemclass] DEFAULT (' '),
[ShelfLife] [int] NULL CONSTRAINT [DF_Sku_ShelfLife] DEFAULT ((0)),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSR6] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_BUSR6] DEFAULT (' '),
[BUSR7] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_BUSR7] DEFAULT (' '),
[BUSR8] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_BUSR8] DEFAULT (' '),
[BUSR9] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_BUSR9] DEFAULT (' '),
[BUSR10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_BUSR10] DEFAULT (' '),
[ReturnLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReceiptLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_SKU_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_SKU_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_EditWho] DEFAULT (suser_sname()),
[archiveqty] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_archiveqty] DEFAULT ((0)),
[XDockReceiptLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrePackIndicator] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_PrePackIndicator] DEFAULT (' '),
[PackQtyIndicator] [int] NULL CONSTRAINT [DF_SKU_PackQtyIndicator] DEFAULT ((0)),
[StackFactor] [int] NULL CONSTRAINT [DF_SKU_StackFactor] DEFAULT ((0)),
[IVAS] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OVAS] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Style] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_Style] DEFAULT (' '),
[Color] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_Color] DEFAULT (''),
[Size] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Measurement] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HazardousFlag] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_HazardousFlag] DEFAULT (''),
[TemperatureFlag] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_TemperatureFlag] DEFAULT (''),
[ProductModel] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_ProductModel] DEFAULT (''),
[CtnPickQty] [int] NOT NULL CONSTRAINT [DF_SKU_CtnPickQty] DEFAULT ((0)),
[CountryOfOrigin] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_CountryOfOrigin] DEFAULT (''),
[IB_UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_IB_UOM] DEFAULT (' '),
[IB_RPT_UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_IB_RPT_UOM] DEFAULT (' '),
[OB_UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_OB_UOM] DEFAULT (' '),
[OB_RPT_UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_OB_RPT_UOM] DEFAULT (' '),
[ABCPL] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_ABCPL] DEFAULT ('B'),
[ABCCS] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_ABCCS] DEFAULT ('B'),
[ABCEA] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_ABCEA] DEFAULT ('B'),
[DisableABCCalc] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_DisableABCCalc] DEFAULT ('N'),
[ABCPeriod] [int] NOT NULL CONSTRAINT [DF_SKU_ABCPeriod] DEFAULT ((0)),
[ABCStorerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_ABCStorerkey] DEFAULT (' '),
[ABCSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_ABCSku] DEFAULT (' '),
[OldStorerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_OldStorerkey] DEFAULT (' '),
[OldSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_OldSku] DEFAULT (' '),
[ImageFolder] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOTTABLE06LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE06LABEL] DEFAULT (''),
[LOTTABLE07LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE07LABEL] DEFAULT (''),
[LOTTABLE08LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE08LABEL] DEFAULT (''),
[LOTTABLE09LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE09LABEL] DEFAULT (''),
[LOTTABLE10LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE10LABEL] DEFAULT (''),
[LOTTABLE11LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE11LABEL] DEFAULT (''),
[LOTTABLE12LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE12LABEL] DEFAULT (''),
[LOTTABLE13LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE13LABEL] DEFAULT (''),
[LOTTABLE14LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE14LABEL] DEFAULT (''),
[LOTTABLE15LABEL] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_LOTTABLE15LABEL] DEFAULT (''),
[LottableCode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_LottableCode] DEFAULT ('STD'),
[OTM_SKUGroup] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_OTM_SKUGroup] DEFAULT (''),
[Pressure] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_Pressure] DEFAULT ('0'),
[SerialNoCapture] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_SerialNoCapture] DEFAULT (''),
[DataCapture] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SKU_DataCapture] DEFAULT (''),
[EcomCartonType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKU_EcomCartonType] DEFAULT ('')
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[SKU] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[SKU] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[SKU] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[SKU] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[SKU] TO [NSQL]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Trigger: ntrSKUAdd                                                      */
/* Creation Date:                                                          */
/* Copyright: IDS                                                          */
/* Written by:                                                             */
/*                                                                         */
/* Purpose:  Update other transactions while SKU line is to be Added.      */
/*                                                                         */
/* Return Status:                                                          */
/*                                                                         */
/* Usage:                                                                  */
/*                                                                         */
/* Called By: When records Updated                                         */
/*                                                                         */
/* PVCS Version: 1.2                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Modifications:                                                          */
/* Date         Author    Ver.  Purposes                                   */
/* 12-Mar-2007  Shong     1.0   Only replace the ` to ' In Non English     */
/*                              Env System Flag had turn ON                */
/* 15-Jun-2009  YokeBeen  1.1   Added new trigger point for interface      */
/*                              with Configkey = "ADDSKULOG".              */
/*                              - (YokeBeen01)                             */
/* 03-Nov-2010  YokeBeen  1.2   FBR#193606 - Added new trigger point       */
/*                              for WITRON interface with                  */
/*                              Configkey = "WTNSKULOG". - (YokeBeen02)    */
/* 22-Dec-2010	 YokeBeen  1.2   SOS#198768 - Blocked interface on process  */
/*                              of re-allocation with Configkey = 'GDSITF' */
/*                              - (YokeBeen03)                             */
/* 28-Mar-2016  Shong     1.3   SOS#366725 Default OTM SKU Group (Shong02) */
/* 30-Jun-2017  KHChan    1.4   FBR#WMS-1455 Add trigger point for         */
/*                              WSSKUADDLOG (KH01)                         */
/* 23-NOV-2017  TLTING    1.5   Skip trigger with archiveCop               */
/* 06-Jul-2020  WLChooi   1.6   WMS-13990 - New Storerconfig               */
/*                              DefaultSkuLottableCode (WL01)              */
/* 11-Nov-2020  WLChooi   1.7   WMS-15671 - SKUTrigger_SP - call custom SP */
/*                              when INSERT record (WL02)                  */
/***************************************************************************/
CREATE TRIGGER [dbo].[ntrSKUAdd] ON [dbo].[SKU] 
FOR INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
  	
   DECLARE @b_debug int    
   SELECT @b_debug = 0    
   IF @b_debug = 2    
   BEGIN    
      DECLARE @profiler NVARCHAR(80)    
      SELECT @profiler = 'PROFILER,637,00,0,ntrSKUAdd Trigger' + CONVERT(char(12), getdate(), 114)    
      PRINT @profiler    
   END    

   DECLARE @b_Success                int       -- Populated by calls to stored procedures - was the proc successful?    
         , @n_err                    int       -- Error number returned by stored procedure or this trigger    
         , @n_err2                   int       -- For Additional Error Detection    
         , @c_errmsg                 NVARCHAR(250) -- Error message returned by stored procedure or this trigger    
         , @n_continue               int                     
         , @n_starttcnt              int       -- Holds the current transaction count    
         , @c_preprocess             NVARCHAR(250) -- preprocess    
         , @c_pstprocess             NVARCHAR(250) -- post process    
         , @n_cnt                    int 
         , @c_StorerKey              NVARCHAR(15)  -- (YokeBeen01) 
         , @c_Sku                    NVARCHAR(20)  -- (YokeBeen01) 
         , @c_authority_skuitf       NVARCHAR(1)   -- (YokeBeen01) 
         , @c_transmitlog3key        NVARCHAR(10)  -- (YokeBeen01) 
         , @c_authority_wtnskuitf    NVARCHAR(1)   -- (YokeBeen02) 
         , @c_default_otm_skugroup   NVARCHAR(20)  -- (Shong02)
         , @c_DefaultSkuLottableCode NVARCHAR(30)  -- (WL01)

   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT     

   -- (YokeBeen01) - Start - Remarked on obsolete Configkey = 'GDSITF'
   /*
   -- Added By SHONG
   -- GDS Interfcae -- BUSR10 Cannot be blank
   -- Otherwise Receipt Interface will having problem
   IF @n_continue=1 OR @n_continue=2
   BEGIN
      IF EXISTS (SELECT 1 
                   FROM INSERTED 
                   JOIN StorerConfig (NOLOCK) ON (StorerConfig.StorerKey = INSERTED.StorerKey AND
                        StorerConfig.ConfigKey = 'GDSITF' AND StorerConfig.sValue = '1')
                  WHERE dbo.fnc_RTrim(BUSR10) IS NULL)
      BEGIN
         SELECT @n_continue = 3    
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=63800   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
         SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0)) 
                          + ': Insert Failed On Table SKU. (ntrSKUAdd), BUSR10 Cannot be BLANK ( SQLSvr MESSAGE= ' 
                          + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '    
      END
   END
   */
   -- (YokeBeen01) - End - Remarked on obsolete Configkey = 'GDSITF'

   -- Added By Shong
   -- 02 May 2002
   -- To replace [`] with ['], RF cannot accept [`] in the description is due to the [`]
   -- use as delimited
   IF @n_continue=1 OR @n_continue=2
   BEGIN
      IF NOT EXISTS(SELECT 1 FROM nSqlConfig WITH (NOLOCK) WHERE ConfigKey = 'NonEnglishEnv' AND NSQLValue = '1')
      BEGIN 
         IF EXISTS( SELECT 1 FROM INSERTED WHERE DESCR LIKE '%`%')
         BEGIN
            UPDATE SKU 
               SET DESCR = REPLACE(SKU.DESCR, '`', "'")
              FROM INSERTED
             WHERE SKU.StorerKey = INSERTED.StorerKey
               AND SKU.SKU = INSERTED.SKU
               AND INSERTED.DESCR LIKE '%`%'
         END
      END 
   END

   IF (SELECT COUNT(*) FROM Inserted) = (SELECT COUNT(*) FROM Inserted WHERE Inserted.ArchiveCop = '9') -- KHLim03
   BEGIN
	   SELECT @n_continue = 4
   END

   --WL02 START
   IF @n_continue=1 or @n_continue = 2
   BEGIN
      IF EXISTS (SELECT 1 FROM INSERTED i
                 JOIN storerconfig s WITH (NOLOCK) ON  i.StorerKey = s.StorerKey
                 JOIN sys.objects sys ON sys.type = 'P' AND sys.name = s.Svalue
                 WHERE  s.configkey = 'SKUTrigger_SP')
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

         EXECUTE dbo.isp_SKUTrigger_Wrapper
                   'INSERT'  --@c_Action
                 , @b_Success  OUTPUT
                 , @n_Err      OUTPUT
                 , @c_ErrMsg   OUTPUT

         IF @b_success <> 1
         BEGIN
            SELECT @n_continue = 3
                  ,@c_errmsg = 'ntrSKUAdd ' + RTRIM(LTRIM(ISNULL(@c_errmsg,'')))
         END

         IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL
            DROP TABLE #INSERTED

         IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL
            DROP TABLE #DELETED
      END
   END
   --WL02 END
   
   -- (YokeBeen01) - Start
   IF @n_continue=1 OR @n_continue=2
   BEGIN
   	DECLARE CUR_SKU_INSERTED CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   	SELECT StorerKey, Sku
      FROM INSERTED 
   	
   	OPEN CUR_SKU_INSERTED
   	
   	FETCH FROM CUR_SKU_INSERTED INTO @c_StorerKey, @c_Sku
   	
   	WHILE @@FETCH_STATUS = 0
   	BEGIN

         SELECT @b_success = 0
         EXECUTE dbo.nspGetRight  '',   -- Facility
                  @c_StorerKey,         -- Storer
                  '',                   -- Sku
                  'ADDSKULOG',          -- ConfigKey
                  @b_success            OUTPUT,
                  @c_authority_skuitf   OUTPUT,
                  @n_err                OUTPUT,
                  @c_errmsg             OUTPUT

         IF @b_success <> 1 
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=63801  
            SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0)) 
                             + ': Retrieve of Right (ADDSKULOG) Failed (ntrSKUAdd) ( SQLSvr MESSAGE=' 
                             + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
         END
         ELSE 
         BEGIN 
            IF @c_authority_skuitf = '1' 
            BEGIN
               EXEC dbo.ispGenTransmitLog3 'ADDSKULOG', @c_StorerKey, '', @c_Sku, ''
                              , @b_success OUTPUT
                              , @n_err OUTPUT
                              , @c_errmsg OUTPUT

               IF @b_success <> 1
               BEGIN
                  SELECT @n_continue = 3
               END
            END -- @c_authority_skuitf = '1' 
         END -- IF @b_success = 1 

         -- (YokeBeen02) - Start 
         SELECT @b_success = 0
         EXECUTE dbo.nspGetRight  '',   -- Facility
                  @c_StorerKey,         -- Storer
                  '',                   -- Sku
                  'WTNSKULOG',          -- ConfigKey
                  @b_success            OUTPUT,
                  @c_authority_skuitf   OUTPUT,
                  @n_err                OUTPUT,
                  @c_errmsg             OUTPUT

         IF @b_success <> 1 
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=63801  
            SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0)) 
                             + ': Retrieve of Right (WTNSKULOG) Failed (ntrSKUAdd) ( SQLSvr MESSAGE=' 
                             + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
         END
         ELSE 
         BEGIN 
            IF @c_authority_skuitf = '1' 
            BEGIN
               EXEC dbo.ispGenWitronLog 'WTNSKULOG', @c_StorerKey, '', @c_Sku, ''
                              , @b_success OUTPUT
                              , @n_err OUTPUT
                              , @c_errmsg OUTPUT

               IF @b_success <> 1
               BEGIN
                  SELECT @n_continue = 3
               END
            END -- @c_authority_skuitf = '1' 
         END -- IF @b_success = 1 
         -- (YokeBeen02) - End 
         
         -- (YokeBeen01) - End          
         
         --(KH01) - Start
         SET @c_authority_skuitf = ''
         SELECT @b_success = 0
         EXECUTE dbo.nspGetRight  '',   -- Facility
                  @c_StorerKey,         -- Storer
                  '',                   -- Sku
                  'WSSKUADDLOG',          -- ConfigKey
                  @b_success            OUTPUT,
                  @c_authority_skuitf   OUTPUT,
                  @n_err                OUTPUT,
                  @c_errmsg             OUTPUT

         IF @b_success <> 1 
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=63801  
            SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0)) 
                             + ': Retrieve of Right (ADDSKULOG) Failed (ntrSKUAdd) ( SQLSvr MESSAGE=' 
                             + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
         END
         ELSE 
         BEGIN 
            IF @c_authority_skuitf = '1' 
            BEGIN
               EXEC dbo.ispGenTransmitLog2 'WSSKUADDLOG', @c_StorerKey, '', @c_Sku, ''
                              , @b_success OUTPUT
                              , @n_err OUTPUT
                              , @c_errmsg OUTPUT

               IF @b_success <> 1
               BEGIN
                  SELECT @n_continue = 3
               END
            END -- @c_authority_skuitf = '1' 
         END -- IF @b_success = 1 
         --(KH01) - End

         -- (Shong02) - Start
         SET @c_default_otm_skugroup = ''
         
         EXECUTE dbo.nspGetRight 
            @c_Facility  = '',               
            @c_StorerKey = @c_StorerKey,     
            @c_sku       = '',               
            @c_ConfigKey = 'OTMCommodity',   
            @b_Success   = @b_success              OUTPUT,
            @c_authority = @c_default_otm_skugroup OUTPUT,
            @n_err       = @n_err                  OUTPUT,
            @c_errmsg    = @c_errmsg               OUTPUT
         
         IF @c_default_otm_skugroup <> '0' AND @c_default_otm_skugroup <> ''
         BEGIN
         	UPDATE SKU WITH (ROWLOCK)
         	   SET OTM_SKUGroup = @c_default_otm_skugroup, 
         	       TrafficCop = NULL, 
         	       EditDate = GETDATE(),
         	       EditWho = SUSER_SNAME()  
         	WHERE StorerKey = @c_StorerKey 
         	AND   Sku = @c_Sku
         END                           
         -- (Shong02) - End

         --WL01 START
         SET @b_success = 0
         SET @c_DefaultSkuLottableCode = ''

         EXECUTE dbo.nspGetRight  '',         -- Facility
                  @c_StorerKey,               -- Storer
                  '',                         -- Sku
                  'DefaultSkuLottableCode',   -- ConfigKey
                  @b_success                  OUTPUT,
                  @c_DefaultSkuLottableCode   OUTPUT,
                  @n_err                      OUTPUT,
                  @c_errmsg                   OUTPUT

         IF @b_success <> 1 
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=63802  
            SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0)) 
                             + ': Retrieve of Right (DefaultSkuLottableCode) Failed (ntrSKUAdd) ( SQLSvr MESSAGE=' 
                             + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
         END

         IF @c_DefaultSkuLottableCode <> '0' AND @c_DefaultSkuLottableCode <> ''
         BEGIN
            UPDATE SKU WITH (ROWLOCK)
            SET LottableCode = @c_DefaultSkuLottableCode, 
                TrafficCop = NULL, 
                EditDate = GETDATE(),
                EditWho = SUSER_SNAME()  
            WHERE StorerKey = @c_StorerKey 
            AND   Sku = @c_Sku
         END
         --WL01 END
   	
   		FETCH FROM CUR_SKU_INSERTED INTO @c_StorerKey, @c_Sku
   	END
   	
   	CLOSE CUR_SKU_INSERTED
   	DEALLOCATE CUR_SKU_INSERTED
   END

   /* #INCLUDE <TRRDA2.SQL> */    
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

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrSKUAdd'    
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012    

      IF @b_debug = 2    
      BEGIN   
         SELECT @profiler = 'PROFILER,637,00,9,ntrSKUAdd Tigger, ' + CONVERT(char(12), getdate(), 114)    
         PRINT @profiler    
      END    
      RETURN    
   END    
   ELSE    
   BEGIN    
      WHILE @@TRANCOUNT > @n_starttcnt    
      BEGIN    
         COMMIT TRAN    
      END    

      IF @b_debug = 2    
      BEGIN    
         SELECT @profiler = 'PROFILER,637,00,9,ntrSKUAdd Trigger, ' + CONVERT(char(12), getdate(), 114) PRINT @profiler    
      END    
      RETURN    
   END    	
END -- End Trigger
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/***************************************************************************/
/* Trigger: ntrSKUDelete                                                   */
/* Creation Date:                                                          */
/* Copyright: IDS                                                          */
/* Written by:                                                             */
/*                                                                         */
/* Purpose: Update/Delete other records while SKU line is being deleted.   */
/*                                                                         */
/* Return Status:                                                          */
/*                                                                         */
/* Usage:                                                                  */
/*                                                                         */
/* Called By: When records Deleted                                         */
/*                                                                         */
/* PVCS Version: 1.4                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Modifications:                                                          */
/* Date         Author   Ver  Purposes                                     */
/* 17-Mar-2009  TLTING        Change user_name() to SUSER_SNAME()          */
/* 28-Apr-2011  KHLim01  1.2  Insert Delete log                            */
/* 14-Jul-2011  KHLim02  1.3  GetRight for Delete log                      */
/* 18-Jan-2012  KHLim03  1.4  check ArchiveCop                             */
/* 22-May-2012  YTWan    1.5  SOS#244027: SkuInfo (Wan01)                  */
/* 11-Nov-2020  WLChooi  1.6  WMS-15671 - SKUTrigger_SP - call custom SP   */
/*                            when DELETE record (WL02)                    */
/***************************************************************************/

CREATE TRIGGER [dbo].[ntrSKUDelete]
 ON  [dbo].[SKU]
 FOR DELETE
 AS
 BEGIN
   IF @@ROWCOUNT = 0 -- KHLim03
   BEGIN
	   RETURN
   END
    SET NOCOUNT ON
    SET ANSI_NULLS OFF 
    SET QUOTED_IDENTIFIER OFF
 	 SET CONCAT_NULL_YIELDS_NULL OFF
 	 
    DECLARE @b_Success       int,
            @n_err           int,       
            @c_errmsg        NVARCHAR(250),
	         @n_cnt           int, 
            @c_Action        NVARCHAR(100)
           ,@c_authority     NVARCHAR(1)  -- KHLim02
           ,@n_continue      int  -- KHLim03
           ,@n_starttcnt     int  -- KHLim03
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  -- KHLim03

   IF (SELECT COUNT(*) FROM DELETED) = (SELECT COUNT(*) FROM DELETED WHERE DELETED.ArchiveCop = '9') -- KHLim03
   BEGIN
	   SELECT @n_continue = 4
   END

   --(Wan01) - START
   IF EXISTS (SELECT 1
              FROM SKUInfo WITH (NOLOCK)
              JOIN DELETED
              ON  ( SKUInfo.Storerkey = DELETED.Storerkey )
              AND ( SKUInfo.Sku = DELETED.Sku ))
   BEGIN
      DELETE FROM SKUInfo WITH (ROWLOCK)  
      FROM SkuInfo
      JOIN DELETED ON  ( SKUInfo.Storerkey = DELETED.Storerkey )
                   AND ( SKUInfo.Sku = DELETED.Sku )
       SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
       IF @n_err <> 0
       BEGIN
          SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68103   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
          SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger Failed on SkuInfo table update. (ntrSKUDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
       END                   
   END
   --(Wan01) - END
   
   IF @n_continue = 1 or @n_continue = 2   -- KHLim03
   BEGIN
       SELECT @c_Action = 'Delete '
       INSERT INTO SKULog
             (Person, ActionTime, ActionDescr)
       SELECT SUSER_SNAME(), GetDate(), 'Deleting ' + dbo.fnc_RTrim(SKU) + dbo.fnc_RTrim(DESCR)
       FROM  DELETED

       DELETE SKUCONFIG FROM DELETED 
        WHERE SKUCONFIG.STORERKEY = DELETED.STORERKEY 
          AND SKUCONFIG.SKU = DELETED.SKU

       SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
       IF @n_err <> 0
       BEGIN
          SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63750   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
          SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On Table SKU Failed. (ntrSKUDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
       END
   END


   IF @n_continue = 1 or @n_continue = 2   -- KHLim03
   BEGIN
   -- Start (KHLim01) 
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
         SELECT @c_errmsg = 'ntrSKUDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.SKU_DELLOG ( StorerKey, Sku )
         SELECT StorerKey, Sku FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table SKU Failed. (ntrSKUDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   -- End (KHLim01) 
   END
   
   --WL01 START
   IF @n_continue=1 or @n_continue=2          
   BEGIN
      IF EXISTS (SELECT 1 FROM DELETED d  
                 JOIN storerconfig s WITH (NOLOCK) ON  d.storerkey = s.storerkey    
                 JOIN sys.objects sys ON sys.type = 'P' AND sys.name = s.Svalue
                 WHERE  s.configkey = 'SKUTrigger_SP')  
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
   
         EXECUTE dbo.isp_SKUTrigger_Wrapper
                   'DELETE'  --@c_Action
                 , @b_Success  OUTPUT  
                 , @n_Err      OUTPUT   
                 , @c_ErrMsg   OUTPUT  
   
         IF @b_success <> 1  
         BEGIN  
            SELECT @n_continue = 3  
                  ,@c_errmsg = 'ntrSKUDelete ' + RTRIM(LTRIM(ISNULL(@c_errmsg,'')))
         END  
         
         IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL
            DROP TABLE #INSERTED
   
         IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL
            DROP TABLE #DELETED
      END
   END  
   --WL01 END
 END

GO

/***************************************************************************/
/* Trigger: ntrSkuUpdate                                                   */
/* Creation Date:                                                          */
/* Copyright: IDS                                                          */
/* Written by:                                                             */
/*                                                                         */
/* Purpose:  Update other transactions while SKU line is to be updated.    */
/*                                                                         */
/* Return Status:                                                          */
/*                                                                         */
/* Usage:                                                                  */
/*                                                                         */
/* Called By: When records Updated                                         */
/*                                                                         */
/* PVCS Version: 1.2                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Modifications:                                                          */
/* Date         Author   Ver  Purposes                                     */
/* 14-Jun-2007  YokeBeen      FBR#78500 - CBM Outbound - (YokeBeen01)      */
/*                            Trigger records into TransmitLog when update */
/*                            on fields - StdCube/StdGrossWgt.             */
/*                            - SQL2005 Changes.                           */
/* 12-Mar-2007  Shong         Only replace the ` to ' In Non English Env   */
/*                            System Flag had turn ON                      */
/* 17-Mar-2009  TLTING   1.1  Change user_name() to SUSER_SNAME()          */
/* 15-Apr-2010  TLTING   1.2  New Sku_log trace FBR145609                  */
/* 26-Jan-2011  MCTang   1.3  FBR#186349 - Added new trigger point for     */
/*                            POSM upon update StdNetWgt & StdCube to      */
/*                            interface Configkey = "VSKULOG" (MC01)       */
/* 13-Apr-2011  AQSKC    1.4  SOS#211893 Do not allow SKU update if inv    */
/*                            found with lottable01 not blank (KC01)       */
/* 25 May 2012  TLTING02 1.5  DM integrity - add update editdate B4        */
/*                            TrafficCop                                   */
/* 04-Dec-2012  Leong    1.6  SOS# 263375 - Log Style, Color, Size and     */
/*                            Measurement when Config SKULOG is turn on.   */
/* 16-May-2012  MCTang   1.6  SOS#244028 - Add UPDSKULOG (MC02)            */
/* *********************************************************************** */
/* 23-Sep-2013  YokeBeen 1.2  Base on PVCS SQL2005_Unicode version 1.1.    */
/*                            FBR#290176 - Insert TransmitLog3.Key2 = "0"  */
/*                            for trigger point "UPDSKULOG" - (YokeBeen02) */
/* 28-Oct-2013  TLTING   1.3  Review Editdate column update                */
/* 12-May-2015  TLTING   1.4  ArchiveCop Update Skip trigger               */
/* 04-Jul-2018  MCTang   1.5  Change UPDSKULOG Key2 value (MC03)           */
/* 11-Nov-2020  WLChooi  1.6  WMS-15671 - SKUTrigger_SP - call custom SP   */
/*                            when UPDATE record (WL01)                    */
/* 15-Mar-2021  KHChan   1.7  LFI-1646 - Trigger for Webservice (KH01)     */
/***************************************************************************/

CREATE TRIGGER [dbo].[ntrSKUUpdate] ON [dbo].[SKU]
FOR UPDATE
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
   DECLARE @b_debug int
   SELECT @b_debug = 0

   IF @b_debug = 2
   BEGIN
      DECLARE @profiler NVARCHAR(80)
      SELECT @profiler = 'PROFILER,637,00,0,ntrSKUUpdate Trigger' + CONVERT(NVARCHAR(12), GETDATE(), 114)
      PRINT @profiler
   END

   DECLARE @b_Success int           -- Populated by calls to stored procedures - was the proc successful?
         , @n_err int               -- Error number returned by stored procedure or this trigger
         , @n_err2 int              -- For Additional Error Detection
         , @c_errmsg NVARCHAR(250)      -- Error message returned by stored procedure or this trigger
         , @n_continue int
         , @n_starttcnt int         -- Holds the current transaction count
         , @c_preprocess NVARCHAR(250)  -- preprocess
         , @c_pstprocess NVARCHAR(250)  -- post process
         , @n_cnt int
         , @c_Key2  NVARCHAR(14)        --MC03

   -- (YokeBeen01) - Start
   DECLARE @c_Storerkey NVARCHAR(15)
         , @c_Sku NVARCHAR(20)
         , @c_PackKey NVARCHAR(10)
         , @c_authority_owitf NVARCHAR(1)
         , @c_transmitlogkey NVARCHAR(10)
         , @c_authority_vskuitf NVARCHAR(1)  -- MC01
         , @c_authority_ValidateSKUChange NVARCHAR(1)     --(KC01)
         , @c_TrafficCopAllowTriggerSP NVARCHAR(10) --WL01

   SELECT  @c_Storerkey  = ''
         , @c_Sku        = ''
         , @c_PackKey    = ''
         , @c_authority_owitf = ''
   -- (YokeBeen01) - End


   DECLARE @c_FieldName             NVARCHAR(25)
         , @c_OldValue              NVARCHAR(60)
         , @c_NewValue              NVARCHAR(60)
         , @c_authority_skulog      NVARCHAR(1)
         , @c_Authority_UpdSkuLog   NVARCHAR(1)        --(MC02)
         , @c_UpdateColumn          NVARCHAR(4000)     --(MC02)
         , @c_Found                 NVARCHAR(1)        --(MC02)
         , @c_ListName_UpdSkuLog    NVARCHAR(10)       --(MC02)
         , @c_ConfigKey_UpdSkuLog   NVARCHAR(30)       --(MC02)
         , @c_Authority_WSUpdSku    NVARCHAR(1)        --(KH01)
         , @c_ListName_WSUpdSku     NVARCHAR(10)       --(KH01)
         , @c_ConfigKey_WSUpdSku    NVARCHAR(30)       --(KH01)

   SET @c_ListName_UpdSkuLog  = 'TRTL3SKU'             --(MC02)
   SET @c_ConfigKey_UpdSkuLog = 'UPDSKULOG'            --(MC02)
   SET @c_ListName_WSUpdSku  = 'WSTRTL2SKU'            --(KH01)
   SET @c_ConfigKey_WSUpdSku = 'WSUPDSKU'              --(KH01)

   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
      
   -- Added By Shong
   -- 02 May 2002
   -- To replace [`] with ['], RF cannot accept [`] in the description is due to the [`]
   -- use as delimited
   IF @n_continue=1 OR @n_continue=2
   BEGIN
      IF NOT EXISTS(SELECT 1 FROM nSqlConfig WITH (NOLOCK) WHERE ConfigKey = 'NonEnglishEnv' AND NSQLValue = '1')
      BEGIN
         IF EXISTS( SELECT 1 FROM INSERTED WHERE DESCR LIKE '%`%')
         BEGIN
            UPDATE SKU
            SET DESCR = REPLACE(SKU.DESCR, '`', "'")
            FROM INSERTED
            WHERE SKU.StorerKey = INSERTED.StorerKey
            AND SKU.SKU = INSERTED.SKU
            AND INSERTED.DESCR LIKE '%`%'
         END
      END
   END

   
   IF UPDATE(ArchiveCop)
   BEGIN
      SELECT @n_continue = 4
   END
   
   -- Added BY SHONG 01 JUL 2002
   IF ( @n_continue=1 OR @n_continue=2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE SKU
         SET EditDate = GetDate(),
             EditWho  = SUSER_SNAME(),
             TrafficCop = NULL
        FROM INSERTED
       WHERE SKU.StorerKey = INSERTED.StorerKey
         AND SKU.SKU = INSERTED.SKU
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err=63703   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),ISNULL(@n_err,0))+': Update Failed On Table SKU. (ntrSkuUpdate)' + ' ( '
                        + ' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '
      END
   END
   -- End Add

   IF UPDATE(TrafficCop)
   BEGIN
   	--WL01 START
      IF EXISTS (SELECT 1 FROM INSERTED i   
                 JOIN storerconfig s WITH (NOLOCK) ON  i.storerkey = s.storerkey    
                 JOIN sys.objects sys ON sys.type = 'P' AND sys.name = s.Svalue
                 WHERE  s.configkey = 'SKUTrigger_SP' AND i.TrafficCop IS NULL) 
      BEGIN
         SELECT @c_TrafficCopAllowTriggerSP = 'Y'
      END
      --WL01 END
   
      SELECT @n_continue = 4
   END

   --(Kc01) - Start
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      IF UPDATE(BUSR5) OR UPDATE(ITEMCLASS) OR UPDATE(SKUGROUP) OR UPDATE(STYLE)
         OR UPDATE(COLOR) OR UPDATE(SIZE) OR UPDATE(MEASUREMENT)
      BEGIN
         SELECT @c_Storerkey = Storerkey
               ,@c_SKU = SKU
         FROM INSERTED

         SELECT @b_success = 0
         SELECT @c_authority_ValidateSKUChange = '0'
         EXECUTE nspGetRight NULL,
                             @c_Storerkey,            -- Storer
                             NULL,                    -- Sku
                             'ValidateSKUChange',     -- ConfigKey
                             @b_success                           OUTPUT,
                             @c_authority_ValidateSKUChange       OUTPUT,
                             @n_err                               OUTPUT,
                             @c_errmsg                            OUTPUT

         IF @b_Success = 1 and @c_authority_ValidateSKUChange = '1'
         BEGIN
            IF EXISTS (SELECT 1 FROM LOT WITH (NOLOCK)
                        JOIN LOTATTRIBUTE WITH (NOLOCK) ON (LOT.Lot = LOTATTRIBUTE.Lot)
                        WHERE LOT.SKU = @c_Sku
                          AND LOT.STORERKEY = @c_Storerkey
                          AND LOT.Qty > 0
                          AND ISNULL(RTRIM(LOTATTRIBUTE.Lottable01),'') <> ''
                      )
            BEGIN
            --SELECT @n_continue = 3
            --SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err=63703   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            --SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),ISNULL(@n_err,0))+': Update Failed On Table SKU. (ntrSkuUpdate)' + ' ( '
            --               + ' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '

               SELECT @n_continue = 3
               SELECT @n_err=60001
               SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),@n_err)+': Not Allowed To Update SKU Because Inventory With Lottable01 Value exists. (ntrSKUUpdate)'
               GOTO QUIT
            END
         END --@b_Success = 1 and @c_authority_ValidateSKUChange = '1'
      END --UPDATE
   END --@n_continue = 1 or @n_continue = 2
   --(Kc01) - End

   /* Added By Vicky 18 July 2002 Patch from IDSHK */

   -- (YokeBeen01) - Start
   -- IF @n_continue = 1 OR @n_continue = 2   -- tlting01
   -- BEGIN
      -- Retrieve related info from INSERTED table into a cursor for TransmitLog Insertion
      DECLARE C_TransmitLogUpdate CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
       SELECT DISTINCT
              INSERTED.Storerkey,
              INSERTED.Sku,
              INSERTED.Packkey
         FROM INSERTED

      OPEN C_TransmitLogUpdate
      FETCH NEXT FROM C_TransmitLogUpdate INTO @c_Storerkey, @c_Sku, @c_PackKey

      WHILE @@FETCH_STATUS <> -1
      BEGIN

         SELECT @b_success = 0
         SELECT @c_authority_skulog = '0'
         EXECUTE nspGetRight NULL,
                             @c_Storerkey,       -- Storer
                             NULL,               -- Sku
                             'SkuLOG',            -- ConfigKey
                             @b_success          output,
                             @c_authority_skulog  output,
                             @n_err              output,
                             @c_errmsg           output

         IF @b_success <> 1
         BEGIN
            SELECT @n_continue = 3, @n_err = 63700, @c_errmsg = 'ntrSkuUpdate: ' + ISNULL(dbo.fnc_RTrim(@c_errmsg),'')
         END

         IF (@c_authority_skulog = '1')
         BEGIN
            IF UPDATE(DESCR)
            BEGIN
               SELECT @c_FieldName = 'DESCR', @c_OldValue = '', @c_NewValue = ''
               SELECT @c_OldValue = DESCR FROM DELETED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU
               SELECT @c_NewValue = DESCR FROM INSERTED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU

               IF @c_OldValue <> @c_NewValue
               BEGIN
                  EXEC isp_Sku_log
                  @cStorerKey     = @c_Storerkey,
                  @cSKU     = @c_SKU,
                  @cFieldName   = @c_FieldName,
                  @cOldValue = @c_OldValue,
                  @cNewValue = @c_NewValue
               END
            END

            IF UPDATE(SUSR3)
            BEGIN
               SELECT @c_FieldName = 'SUSR3', @c_OldValue = '', @c_NewValue = ''
               SELECT @c_OldValue = SUSR3 FROM DELETED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU
               SELECT @c_NewValue = SUSR3 FROM INSERTED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU

               IF @c_OldValue <> @c_NewValue
               BEGIN
                  EXEC isp_Sku_log
                  @cStorerKey     = @c_Storerkey,
                  @cSKU     = @c_SKU,
                  @cFieldName   = @c_FieldName,
                  @cOldValue = @c_OldValue,
                  @cNewValue = @c_NewValue
               END
            END

            IF UPDATE(ALTSKU)
            BEGIN
               SELECT @c_FieldName = 'ALTSKU', @c_OldValue = '', @c_NewValue = ''
               SELECT @c_OldValue = ALTSKU FROM DELETED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU
               SELECT @c_NewValue = ALTSKU FROM INSERTED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU

               IF @c_OldValue <> @c_NewValue
               BEGIN
                  EXEC isp_Sku_log
                  @cStorerKey     = @c_Storerkey,
                  @cSKU     = @c_SKU,
                  @cFieldName   = @c_FieldName,
                  @cOldValue = @c_OldValue,
                  @cNewValue = @c_NewValue
               END
            END
            IF UPDATE(PACKKey)
            BEGIN
               SELECT @c_FieldName = 'PACKKey', @c_OldValue = '', @c_NewValue = ''
               SELECT @c_OldValue = PACKKey FROM DELETED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU
               SELECT @c_NewValue = PACKKey FROM INSERTED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU

               IF @c_OldValue <> @c_NewValue
               BEGIN
                  EXEC isp_Sku_log
                  @cStorerKey     = @c_Storerkey,
                  @cSKU     = @c_SKU,
                  @cFieldName   = @c_FieldName,
                  @cOldValue = @c_OldValue,
                  @cNewValue = @c_NewValue
               END
            END
            IF UPDATE(STDGROSSWGT)
            BEGIN
               SELECT @c_FieldName = 'STDGROSSWGT', @c_OldValue = '', @c_NewValue = ''
               SELECT @c_OldValue = Convert(NVARCHAR(60), STDGROSSWGT) FROM DELETED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU
               SELECT @c_NewValue = Convert(NVARCHAR(60), STDGROSSWGT) FROM INSERTED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU

               IF @c_OldValue <> @c_NewValue
               BEGIN
                  EXEC isp_Sku_log
                  @cStorerKey     = @c_Storerkey,
                  @cSKU     = @c_SKU,
                  @cFieldName   = @c_FieldName,
                  @cOldValue = @c_OldValue,
                  @cNewValue = @c_NewValue
               END
            END
            IF UPDATE(STDCUBE)
            BEGIN
               SELECT @c_FieldName = 'STDCUBE', @c_OldValue = '', @c_NewValue = ''
               SELECT @c_OldValue = Convert(NVARCHAR(60), STDCUBE) FROM DELETED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU
               SELECT @c_NewValue = Convert(NVARCHAR(60), STDCUBE) FROM INSERTED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU

               IF @c_OldValue <> @c_NewValue
               BEGIN
                  EXEC isp_Sku_log
                  @cStorerKey     = @c_Storerkey,
                  @cSKU     = @c_SKU,
                  @cFieldName   = @c_FieldName,
                  @cOldValue = @c_OldValue,
                  @cNewValue = @c_NewValue
               END
            END
            IF UPDATE(BUSR2)
            BEGIN
               SELECT @c_FieldName = 'BUSR2', @c_OldValue = '', @c_NewValue = ''
               SELECT @c_OldValue = BUSR2 FROM DELETED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU
               SELECT @c_NewValue = BUSR2 FROM INSERTED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU

               IF @c_OldValue <> @c_NewValue
               BEGIN
                  EXEC isp_Sku_log
                  @cStorerKey     = @c_Storerkey,
                  @cSKU     = @c_SKU,
                  @cFieldName   = @c_FieldName,
                  @cOldValue = @c_OldValue,
                  @cNewValue = @c_NewValue
               END
            END
            IF UPDATE(BUSR6)
            BEGIN
               SELECT @c_FieldName = 'BUSR6', @c_OldValue = '', @c_NewValue = ''
               SELECT @c_OldValue = BUSR6 FROM DELETED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU
               SELECT @c_NewValue = BUSR6 FROM INSERTED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU

               IF @c_OldValue <> @c_NewValue
               BEGIN
                  EXEC isp_Sku_log
                  @cStorerKey     = @c_Storerkey,
                  @cSKU     = @c_SKU,
                  @cFieldName   = @c_FieldName,
                  @cOldValue = @c_OldValue,
                  @cNewValue = @c_NewValue
               END
            END
            IF UPDATE(LOTTABLE02LABEL)
            BEGIN
               SELECT @c_FieldName = 'LOTTABLE02LABEL', @c_OldValue = '', @c_NewValue = ''
               SELECT @c_OldValue = LOTTABLE02LABEL FROM DELETED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU
               SELECT @c_NewValue = LOTTABLE02LABEL FROM INSERTED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU

               IF @c_OldValue <> @c_NewValue
               BEGIN
                  EXEC isp_Sku_log
                  @cStorerKey     = @c_Storerkey,
                  @cSKU     = @c_SKU,
                  @cFieldName   = @c_FieldName,
                  @cOldValue = @c_OldValue,
                  @cNewValue = @c_NewValue
               END
            END
            IF UPDATE(LOTTABLE04LABEL)
            BEGIN
               SELECT @c_FieldName = 'LOTTABLE04LABEL', @c_OldValue = '', @c_NewValue = ''
               SELECT @c_OldValue = LOTTABLE04LABEL FROM DELETED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU
               SELECT @c_NewValue = LOTTABLE04LABEL FROM INSERTED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU

               IF @c_OldValue <> @c_NewValue
               BEGIN
                  EXEC isp_Sku_log
                  @cStorerKey     = @c_Storerkey,
                  @cSKU     = @c_SKU,
                  @cFieldName   = @c_FieldName,
                  @cOldValue = @c_OldValue,
                  @cNewValue = @c_NewValue
               END
            END
            IF UPDATE(StrategyKey)
            BEGIN
               SELECT @c_FieldName = 'StrategyKey', @c_OldValue = '', @c_NewValue = ''
               SELECT @c_OldValue = StrategyKey FROM DELETED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU
               SELECT @c_NewValue = StrategyKey FROM INSERTED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU

               IF @c_OldValue <> @c_NewValue
               BEGIN
                  EXEC isp_Sku_log
                  @cStorerKey     = @c_Storerkey,
                  @cSKU     = @c_SKU,
                  @cFieldName   = @c_FieldName,
                  @cOldValue = @c_OldValue,
                  @cNewValue = @c_NewValue
               END
            END
            IF UPDATE(ShelfLife)
            BEGIN
               SELECT @c_FieldName = 'ShelfLife', @c_OldValue = '', @c_NewValue = ''
               SELECT @c_OldValue = ShelfLife FROM DELETED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU
               SELECT @c_NewValue = ShelfLife FROM INSERTED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU

               IF @c_OldValue <> @c_NewValue
               BEGIN
                  EXEC isp_Sku_log
                  @cStorerKey     = @c_Storerkey,
                  @cSKU     = @c_SKU,
                  @cFieldName   = @c_FieldName,
                  @cOldValue = @c_OldValue,
                  @cNewValue = @c_NewValue
               END
            END

            -- SOS# 263375 (Start)
            IF UPDATE(Style)
            BEGIN
               SELECT @c_FieldName = 'Style', @c_OldValue = '', @c_NewValue = ''
               SELECT @c_OldValue = Style FROM DELETED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU
               SELECT @c_NewValue = Style FROM INSERTED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU

               IF ISNULL(RTRIM(@c_OldValue),'') <> ISNULL(RTRIM(@c_NewValue),'')
               BEGIN
                  EXEC isp_Sku_log
                        @cStorerKey = @c_Storerkey,
                        @cSKU       = @c_SKU,
                        @cFieldName = @c_FieldName,
                        @cOldValue  = @c_OldValue,
                        @cNewValue  = @c_NewValue
               END
            END

            IF UPDATE(Color)
            BEGIN
               SELECT @c_FieldName = 'Color', @c_OldValue = '', @c_NewValue = ''
               SELECT @c_OldValue = Color FROM DELETED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU
               SELECT @c_NewValue = Color FROM INSERTED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU

               IF ISNULL(RTRIM(@c_OldValue),'') <> ISNULL(RTRIM(@c_NewValue),'')
               BEGIN
                  EXEC isp_Sku_log
                        @cStorerKey = @c_Storerkey,
                        @cSKU       = @c_SKU,
                        @cFieldName = @c_FieldName,
                        @cOldValue  = @c_OldValue,
                        @cNewValue  = @c_NewValue
               END
            END

            IF UPDATE(Size)
            BEGIN
               SELECT @c_FieldName = 'Size', @c_OldValue = '', @c_NewValue = ''
               SELECT @c_OldValue = Size FROM DELETED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU
               SELECT @c_NewValue = Size FROM INSERTED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU

               IF ISNULL(RTRIM(@c_OldValue),'') <> ISNULL(RTRIM(@c_NewValue),'')
               BEGIN
                  EXEC isp_Sku_log
                        @cStorerKey = @c_Storerkey,
                        @cSKU       = @c_SKU,
                        @cFieldName = @c_FieldName,
                        @cOldValue  = @c_OldValue,
                        @cNewValue  = @c_NewValue
               END
            END

            IF UPDATE(Measurement)
            BEGIN
               SELECT @c_FieldName = 'Measurement', @c_OldValue = '', @c_NewValue = ''
               SELECT @c_OldValue = Measurement FROM DELETED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU
               SELECT @c_NewValue = Measurement FROM INSERTED WHERE Storerkey = @c_Storerkey AND SKU = @c_SKU

               IF ISNULL(RTRIM(@c_OldValue),'') <> ISNULL(RTRIM(@c_NewValue),'')
               BEGIN
                  EXEC isp_Sku_log
                        @cStorerKey = @c_Storerkey,
                        @cSKU       = @c_SKU,
                        @cFieldName = @c_FieldName,
                        @cOldValue  = @c_OldValue,
                        @cNewValue  = @c_NewValue
               END
            END
            -- SOS# 263375 (End)
         END

         -- (MC01) - Start
         IF UPDATE(StdNetWgt) OR UPDATE(StdCube)
         BEGIN
            SELECT @b_success = 0
            SELECT @c_authority_vskuitf = '0'
            EXECUTE dbo.nspGetRight  '',   -- Facility
                     @c_StorerKey,         -- Storer
                     '',                   -- Sku
                     'VSKULOG',            -- ConfigKey
                     @b_success            OUTPUT,
                     @c_authority_vskuitf  OUTPUT,
                     @n_err                OUTPUT,
                     @c_errmsg             OUTPUT

            IF @b_success <> 1
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err=63801
               SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5),ISNULL(@n_err,0))
                                + ': Retrieve of Right (VSKULOG) Failed (ntrSkuUpdate) ( SQLSvr MESSAGE='
                                + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
            END
            ELSE
            BEGIN
               IF @c_authority_vskuitf = '1'
               BEGIN

                  --Can't use ispGenVitalLog because need to check again transmitflag
                  --EXEC dbo.ispGenVitalLog  'VSKULOG', @c_StorerKey, '', @c_Sku, ''
                  --   , @b_success OUTPUT
                  --   , @n_err OUTPUT
                  --   , @c_errmsg OUTPUT

                  IF NOT EXISTS ( SELECT 1 FROM VITALLOG WITH (NOLOCK) WHERE TableName = 'VSKULOG'
                                  AND Key1 = @c_StorerKey AND Key3 = @c_Sku
                                  AND (transmitflag = '0' OR transmitflag = '1') )
                  BEGIN
                     INSERT INTO VITALLOG (Tablename, Key1, Key2, Key3, Transmitflag, TransmitBatch)
                     VALUES ('VSKULOG', @c_StorerKey,'', @c_Sku, '0', '')

                     IF @@ERROR <> 0
                     BEGIN
                        SET @n_continue = 3
                        SET @n_err = 63706
                        SET @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5),ISNULL(@n_err,0)) +
                                        ': Insert into VITALLOG Failed. (ntrSkuUpdate)' +
                                        ' ( ' + ' SQLSvr MESSAGE = ' + ISNULL(dbo.fnc_LTRIM(dbo.fnc_RTRIM(@c_errmsg)),'') + ' ) '
                     END
                  END

                  IF @b_success <> 1
                  BEGIN
                     SELECT @n_continue = 3
                  END
               END -- @c_authority_vskuitf = '1'
            END -- IF @b_success = 1
         END
         -- (MC01) - End

         -- (MC02) - S
         SELECT @b_success = 0
         SELECT @c_Authority_UpdSkuLog = '0'

         EXECUTE dbo.nspGetRight
                   ''                     -- Facility
                 , @c_StorerKey           -- Storer
                 , ''                     -- Sku
                 , @c_ConfigKey_UpdSkuLog -- ConfigKey
                 , @b_success             OUTPUT
                 , @c_Authority_UpdSkuLog OUTPUT
                 , @n_err                 OUTPUT
                 , @c_errmsg              OUTPUT

         IF @b_success <> 1
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err=63801
            SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5),ISNULL(@n_err,0))
                             + ': Retrieve of Right (UPDSKULOG) Failed (ntrSkuUpdate) ( SQLSvr MESSAGE='
                             + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
         END

         IF @c_Authority_UpdSkuLog = '1'
         BEGIN
            SET @c_UpdateColumn = ''

            SELECT @c_UpdateColumn = CASE WHEN INSERTED.DESCR <> DELETED.DESCR THEN 'DESCR|' ELSE '' END
                                   + CASE WHEN INSERTED.SUSR1 <> DELETED.SUSR1 THEN 'SUSR1|' ELSE '' END
                                   + CASE WHEN INSERTED.SUSR2 <> DELETED.SUSR2 THEN 'SUSR2|' ELSE '' END
                                   + CASE WHEN INSERTED.SUSR3 <> DELETED.SUSR3 THEN 'SUSR3|' ELSE '' END
                                   + CASE WHEN INSERTED.SUSR4 <> DELETED.SUSR4 THEN 'SUSR4|' ELSE '' END
                                   + CASE WHEN INSERTED.SUSR5 <> DELETED.SUSR5 THEN 'SUSR5|' ELSE '' END
                                   + CASE WHEN INSERTED.MANUFACTURERSKU <> DELETED.MANUFACTURERSKU THEN 'MANUFACTURERSKU|' ELSE '' END
                                   + CASE WHEN INSERTED.STDGROSSWGT <> DELETED.STDGROSSWGT THEN 'STDGROSSWGT|' ELSE '' END
                                   + CASE WHEN INSERTED.STDNETWGT <> DELETED.STDNETWGT THEN 'STDNETWGT|' ELSE '' END
                                   + CASE WHEN INSERTED.STDCUBE <> DELETED.STDCUBE THEN 'STDCUBE|' ELSE '' END
                                   + CASE WHEN INSERTED.CLASS <> DELETED.CLASS THEN 'CLASS|' ELSE '' END
                                   + CASE WHEN INSERTED.ACTIVE <> DELETED.ACTIVE THEN 'ACTIVE|' ELSE '' END
                                   + CASE WHEN INSERTED.SKUGROUP <> DELETED.SKUGROUP THEN 'SKUGROUP|' ELSE '' END
                                   + CASE WHEN INSERTED.BUSR1 <> DELETED.BUSR1 THEN 'BUSR1|' ELSE '' END
                                   + CASE WHEN INSERTED.BUSR2 <> DELETED.BUSR2 THEN 'BUSR2|' ELSE '' END
                                   + CASE WHEN INSERTED.BUSR3 <> DELETED.BUSR3 THEN 'BUSR3|' ELSE '' END
                                   + CASE WHEN INSERTED.BUSR4 <> DELETED.BUSR4 THEN 'BUSR4|' ELSE '' END
                                   + CASE WHEN INSERTED.BUSR5 <> DELETED.BUSR5 THEN 'BUSR5|' ELSE '' END
                                   + CASE WHEN INSERTED.LOTTABLE01LABEL <> DELETED.LOTTABLE01LABEL THEN 'LOTTABLE01LABEL|' ELSE '' END
                                   + CASE WHEN INSERTED.LOTTABLE02LABEL <> DELETED.LOTTABLE02LABEL THEN 'LOTTABLE02LABEL|' ELSE '' END
                                   + CASE WHEN INSERTED.LOTTABLE03LABEL <> DELETED.LOTTABLE03LABEL THEN 'LOTTABLE03LABEL|' ELSE '' END
                                   + CASE WHEN INSERTED.LOTTABLE04LABEL <> DELETED.LOTTABLE04LABEL THEN 'LOTTABLE04LABEL|' ELSE '' END
                                   --+ CASE WHEN INSERTED.NOTES1 <> DELETED.NOTES1 THEN 'NOTES1|' ELSE '' END
                                   + CASE WHEN INSERTED.ABC <> DELETED.ABC THEN 'ABC|' ELSE '' END
                                   + CASE WHEN INSERTED.ReorderPoint <> DELETED.ReorderPoint THEN 'ReorderPoint|' ELSE '' END
                                   + CASE WHEN INSERTED.ReorderQty <> DELETED.ReorderQty THEN 'ReorderQty|' ELSE '' END
                                   + CASE WHEN INSERTED.Price <> DELETED.Price THEN 'Price|' ELSE '' END
                                   + CASE WHEN INSERTED.Cost <> DELETED.Cost THEN 'Cost|' ELSE '' END
                                   + CASE WHEN INSERTED.SkuStatus <> DELETED.SkuStatus THEN 'SkuStatus|' ELSE '' END
                                   + CASE WHEN INSERTED.Itemclass <> DELETED.Itemclass THEN 'Itemclass|' ELSE '' END
                                   + CASE WHEN INSERTED.ShelfLife <> DELETED.ShelfLife THEN 'ShelfLife|' ELSE '' END
                                   + CASE WHEN INSERTED.Facility <> DELETED.Facility THEN 'Facility|' ELSE '' END
                                   + CASE WHEN INSERTED.BUSR6 <> DELETED.BUSR6 THEN 'BUSR6|' ELSE '' END
                                   + CASE WHEN INSERTED.BUSR7 <> DELETED.BUSR7 THEN 'BUSR7|' ELSE '' END
                                   + CASE WHEN INSERTED.BUSR8 <> DELETED.BUSR8 THEN 'BUSR8|' ELSE '' END
                                   + CASE WHEN INSERTED.Style <> DELETED.Style THEN 'Style|' ELSE '' END
                                   + CASE WHEN INSERTED.Color <> DELETED.Color THEN 'Color|' ELSE '' END
                                   + CASE WHEN INSERTED.Size <> DELETED.Size THEN 'Size|' ELSE '' END
                                   + CASE WHEN INSERTED.Measurement <> DELETED.Measurement THEN 'Measurement|' ELSE '' END
                                   --+ CASE WHEN INSERTED.NOTES2 <> DELETED.NOTES2 THEN 'NOTES2|' ELSE '' END
                                   + CASE WHEN INSERTED.RetailSku <> DELETED.RetailSku THEN 'RetailSku|' ELSE '' END
                                   + CASE WHEN INSERTED.AltSku <> DELETED.AltSku THEN 'AltSku|' ELSE '' END
                                   + CASE WHEN INSERTED.CartonGroup <> DELETED.CartonGroup THEN 'CartonGroup|' ELSE '' END
                                   + CASE WHEN INSERTED.BUSR9 <> DELETED.BUSR9 THEN 'BUSR9|' ELSE '' END
                                   + CASE WHEN INSERTED.BUSR10 <> DELETED.BUSR10 THEN 'BUSR10|' ELSE '' END
                                   + CASE WHEN INSERTED.IVAS <> DELETED.IVAS THEN 'IVAS|' ELSE '' END
                                   + CASE WHEN INSERTED.OVAS <> DELETED.OVAS THEN 'OVAS|' ELSE '' END
                                   + CASE WHEN INSERTED.IOFlag <> DELETED.IOFlag THEN 'IOFlag|' ELSE '' END
                                   + CASE WHEN INSERTED.StdOrderCost <> DELETED.StdOrderCost THEN 'StdOrderCost|' ELSE '' END
                                   + CASE WHEN INSERTED.CarryCost <> DELETED.CarryCost THEN 'CarryCost|' ELSE '' END
                                   + CASE WHEN INSERTED.GROSSWGT <> DELETED.GROSSWGT THEN 'GROSSWGT|' ELSE '' END
                                   + CASE WHEN INSERTED.NETWGT <> DELETED.NETWGT THEN 'NETWGT|' ELSE '' END
                                   + CASE WHEN INSERTED.CUBE <> DELETED.CUBE THEN 'CUBE|' ELSE '' END
            FROM  INSERTED, DELETED
            WHERE INSERTED.StorerKey = DELETED.StorerKey
            AND   INSERTED.SKU       = DELETED.SKU
            AND   INSERTED.Storerkey = @c_Storerkey
            AND   INSERTED.SKU       = @c_SKU

            IF @c_UpdateColumn <> ''
            BEGIN

               SET @c_Found = 'N'

               DECLARE C_CodeLkUp CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               SELECT ISNULL(RTRIM(Code), '')
               FROM   CodeLkUp WITH (NOLOCK)
               WHERE  ListName  = @c_ListName_UpdSkuLog
               AND    StorerKey = @c_StorerKey

               OPEN C_CodeLkUp
               FETCH NEXT FROM C_CodeLkUp INTO @c_FieldName

               WHILE @@FETCH_STATUS <> -1
               BEGIN

                  SET @c_FieldName = '%' + UPPER(@c_FieldName) + '|' + '%'

                  SELECT @c_Found = CASE WHEN UPPER(@c_UpdateColumn) like @c_FieldName THEN 'Y' ELSE 'N' END

                  IF @c_Found  = 'Y'
                  BEGIN
                     BREAK
                  END

                  FETCH NEXT FROM C_CodeLkUp INTO @c_FieldName
               END -- WHILE @@FETCH_STATUS <> -1
               CLOSE C_CodeLkUp
               DEALLOCATE C_CodeLkUp

               IF @c_Found = 'Y'
               BEGIN

                  SET @c_Key2 = CONVERT(CHAR(8), Getdate(), 112) + REPLACE(CONVERT(CHAR(8), Getdate(), 108), ':','')  --(MC02)

                  --EXEC dbo.ispGenTransmitLog3 @c_ConfigKey_UpdSkuLog, @c_StorerKey, '0', @c_SKU, ''  -- (YokeBeen02)
                  EXEC dbo.ispGenTransmitLog3 @c_ConfigKey_UpdSkuLog, @c_StorerKey, @c_Key2, @c_SKU, ''  --(MC02)
                                            , @b_success OUTPUT
                                            , @n_err OUTPUT
                                            , @c_errmsg OUTPUT
                  IF @b_success <> 1
                  BEGIN
                     SELECT @n_continue = 3
                     SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err=63802
                     SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5),ISNULL(@n_err,0))
                                      + ': Insert Into TransmitLog3 Table (UPDSKULOG) Failed (ntrSkuUpdate)( SQLSvr MESSAGE='
                                      + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
                  END
               END
            END --IF @c_UpdateColumn <> ''
         END --IF @c_Authority_UpdSkuLog = '1'
         -- (MC02) - E

         --(KH01) - S
         SELECT @b_success = 0
         SELECT @c_Authority_WSUpdSku = '0'

         EXECUTE dbo.nspGetRight
                   ''                     -- Facility
                 , @c_StorerKey           -- Storer
                 , ''                     -- Sku
                 , @c_ConfigKey_WSUpdSku  -- ConfigKey
                 , @b_success             OUTPUT
                 , @c_Authority_WSUpdSku  OUTPUT
                 , @n_err                 OUTPUT
                 , @c_errmsg              OUTPUT

         IF @b_success <> 1
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err=63801
            SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5),ISNULL(@n_err,0))
                             + ': Retrieve of Right (WSUPDSKU) Failed (ntrSkuUpdate) ( SQLSvr MESSAGE='
                             + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
         END

         IF @c_Authority_WSUpdSku = '1'
         BEGIN
            SET @c_UpdateColumn = ''

            SELECT @c_UpdateColumn = CASE WHEN INSERTED.DESCR <> DELETED.DESCR THEN 'DESCR|' ELSE '' END
                                   + CASE WHEN INSERTED.SUSR1 <> DELETED.SUSR1 THEN 'SUSR1|' ELSE '' END
                                   + CASE WHEN INSERTED.SUSR2 <> DELETED.SUSR2 THEN 'SUSR2|' ELSE '' END
                                   + CASE WHEN INSERTED.SUSR3 <> DELETED.SUSR3 THEN 'SUSR3|' ELSE '' END
                                   + CASE WHEN INSERTED.SUSR4 <> DELETED.SUSR4 THEN 'SUSR4|' ELSE '' END
                                   + CASE WHEN INSERTED.SUSR5 <> DELETED.SUSR5 THEN 'SUSR5|' ELSE '' END
                                   + CASE WHEN INSERTED.MANUFACTURERSKU <> DELETED.MANUFACTURERSKU THEN 'MANUFACTURERSKU|' ELSE '' END
                                   + CASE WHEN INSERTED.STDGROSSWGT <> DELETED.STDGROSSWGT THEN 'STDGROSSWGT|' ELSE '' END
                                   + CASE WHEN INSERTED.STDNETWGT <> DELETED.STDNETWGT THEN 'STDNETWGT|' ELSE '' END
                                   + CASE WHEN INSERTED.STDCUBE <> DELETED.STDCUBE THEN 'STDCUBE|' ELSE '' END
                                   + CASE WHEN INSERTED.CLASS <> DELETED.CLASS THEN 'CLASS|' ELSE '' END
                                   + CASE WHEN INSERTED.ACTIVE <> DELETED.ACTIVE THEN 'ACTIVE|' ELSE '' END
                                   + CASE WHEN INSERTED.SKUGROUP <> DELETED.SKUGROUP THEN 'SKUGROUP|' ELSE '' END
                                   + CASE WHEN INSERTED.BUSR1 <> DELETED.BUSR1 THEN 'BUSR1|' ELSE '' END
                                   + CASE WHEN INSERTED.BUSR2 <> DELETED.BUSR2 THEN 'BUSR2|' ELSE '' END
                                   + CASE WHEN INSERTED.BUSR3 <> DELETED.BUSR3 THEN 'BUSR3|' ELSE '' END
                                   + CASE WHEN INSERTED.BUSR4 <> DELETED.BUSR4 THEN 'BUSR4|' ELSE '' END
                                   + CASE WHEN INSERTED.BUSR5 <> DELETED.BUSR5 THEN 'BUSR5|' ELSE '' END
                                   + CASE WHEN INSERTED.LOTTABLE01LABEL <> DELETED.LOTTABLE01LABEL THEN 'LOTTABLE01LABEL|' ELSE '' END
                                   + CASE WHEN INSERTED.LOTTABLE02LABEL <> DELETED.LOTTABLE02LABEL THEN 'LOTTABLE02LABEL|' ELSE '' END
                                   + CASE WHEN INSERTED.LOTTABLE03LABEL <> DELETED.LOTTABLE03LABEL THEN 'LOTTABLE03LABEL|' ELSE '' END
                                   + CASE WHEN INSERTED.LOTTABLE04LABEL <> DELETED.LOTTABLE04LABEL THEN 'LOTTABLE04LABEL|' ELSE '' END
                                   + CASE WHEN INSERTED.ABC <> DELETED.ABC THEN 'ABC|' ELSE '' END
                                   + CASE WHEN INSERTED.ReorderPoint <> DELETED.ReorderPoint THEN 'ReorderPoint|' ELSE '' END
                                   + CASE WHEN INSERTED.ReorderQty <> DELETED.ReorderQty THEN 'ReorderQty|' ELSE '' END
                                   + CASE WHEN INSERTED.Price <> DELETED.Price THEN 'Price|' ELSE '' END
                                   + CASE WHEN INSERTED.Cost <> DELETED.Cost THEN 'Cost|' ELSE '' END
                                   + CASE WHEN INSERTED.SkuStatus <> DELETED.SkuStatus THEN 'SkuStatus|' ELSE '' END
                                   + CASE WHEN INSERTED.Itemclass <> DELETED.Itemclass THEN 'Itemclass|' ELSE '' END
                                   + CASE WHEN INSERTED.ShelfLife <> DELETED.ShelfLife THEN 'ShelfLife|' ELSE '' END
                                   + CASE WHEN INSERTED.Facility <> DELETED.Facility THEN 'Facility|' ELSE '' END
                                   + CASE WHEN INSERTED.BUSR6 <> DELETED.BUSR6 THEN 'BUSR6|' ELSE '' END
                                   + CASE WHEN INSERTED.BUSR7 <> DELETED.BUSR7 THEN 'BUSR7|' ELSE '' END
                                   + CASE WHEN INSERTED.BUSR8 <> DELETED.BUSR8 THEN 'BUSR8|' ELSE '' END
                                   + CASE WHEN INSERTED.Style <> DELETED.Style THEN 'Style|' ELSE '' END
                                   + CASE WHEN INSERTED.Color <> DELETED.Color THEN 'Color|' ELSE '' END
                                   + CASE WHEN INSERTED.Size <> DELETED.Size THEN 'Size|' ELSE '' END
                                   + CASE WHEN INSERTED.Measurement <> DELETED.Measurement THEN 'Measurement|' ELSE '' END
                                   + CASE WHEN INSERTED.RetailSku <> DELETED.RetailSku THEN 'RetailSku|' ELSE '' END
                                   + CASE WHEN INSERTED.AltSku <> DELETED.AltSku THEN 'AltSku|' ELSE '' END
                                   + CASE WHEN INSERTED.CartonGroup <> DELETED.CartonGroup THEN 'CartonGroup|' ELSE '' END
                                   + CASE WHEN INSERTED.BUSR9 <> DELETED.BUSR9 THEN 'BUSR9|' ELSE '' END
                                   + CASE WHEN INSERTED.BUSR10 <> DELETED.BUSR10 THEN 'BUSR10|' ELSE '' END
                                   + CASE WHEN INSERTED.IVAS <> DELETED.IVAS THEN 'IVAS|' ELSE '' END
                                   + CASE WHEN INSERTED.OVAS <> DELETED.OVAS THEN 'OVAS|' ELSE '' END
                                   + CASE WHEN INSERTED.IOFlag <> DELETED.IOFlag THEN 'IOFlag|' ELSE '' END
                                   + CASE WHEN INSERTED.StdOrderCost <> DELETED.StdOrderCost THEN 'StdOrderCost|' ELSE '' END
                                   + CASE WHEN INSERTED.CarryCost <> DELETED.CarryCost THEN 'CarryCost|' ELSE '' END
                                   + CASE WHEN INSERTED.GROSSWGT <> DELETED.GROSSWGT THEN 'GROSSWGT|' ELSE '' END
                                   + CASE WHEN INSERTED.NETWGT <> DELETED.NETWGT THEN 'NETWGT|' ELSE '' END
                                   + CASE WHEN INSERTED.CUBE <> DELETED.CUBE THEN 'CUBE|' ELSE '' END
            FROM  INSERTED, DELETED
            WHERE INSERTED.StorerKey = DELETED.StorerKey
            AND   INSERTED.SKU       = DELETED.SKU
            AND   INSERTED.Storerkey = @c_Storerkey
            AND   INSERTED.SKU       = @c_SKU

            IF @c_UpdateColumn <> ''
            BEGIN
               SET @c_Found = 'N'

               DECLARE C_CodeLkUp CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               SELECT ISNULL(RTRIM(Code), '')
               FROM   CodeLkUp WITH (NOLOCK)
               WHERE  ListName  = @c_ListName_WSUpdSku
               AND    StorerKey = @c_StorerKey

               OPEN C_CodeLkUp
               FETCH NEXT FROM C_CodeLkUp INTO @c_FieldName

               WHILE @@FETCH_STATUS <> -1
               BEGIN

                  SET @c_FieldName = '%' + UPPER(@c_FieldName) + '|' + '%'

                  SELECT @c_Found = CASE WHEN UPPER(@c_UpdateColumn) like @c_FieldName THEN 'Y' ELSE 'N' END

                  IF @c_Found  = 'Y'
                  BEGIN
                     BREAK
                  END

                  FETCH NEXT FROM C_CodeLkUp INTO @c_FieldName
               END -- WHILE @@FETCH_STATUS <> -1
               CLOSE C_CodeLkUp
               DEALLOCATE C_CodeLkUp

               IF @c_Found = 'Y'
               BEGIN
                  SET @c_Key2 = CONVERT(CHAR(8), Getdate(), 112) + REPLACE(CONVERT(CHAR(8), Getdate(), 108), ':','') 

                  EXEC dbo.ispGenTransmitLog2 @c_ConfigKey_WSUpdSku, @c_StorerKey, @c_Key2, @c_SKU, '' 
                                            , @b_success OUTPUT
                                            , @n_err OUTPUT
                                            , @c_errmsg OUTPUT
                  IF @b_success <> 1
                  BEGIN
                     SELECT @n_continue = 3
                     SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err=63802
                     SELECT @c_errmsg = 'NSQL' + CONVERT(NVARCHAR(5),ISNULL(@n_err,0))
                                      + ': Insert Into TransmitLog2 Table (WSUPDSKU) Failed (ntrSkuUpdate)( SQLSvr MESSAGE='
                                      + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
                  END
               END
            END --IF @c_UpdateColumn <> ''
         END --IF @c_Authority_WSUpdSku = '1'
         --(KH01) - E

         IF @n_continue=1 OR @n_continue=2
         BEGIN
            SELECT @b_success = 0
            EXECUTE nspGetRight NULL,
                                @c_Storerkey,       -- Storer
                                NULL,               -- Sku
                                'OWITF',            -- ConfigKey
                                @b_success          output,
                                @c_authority_owitf  output,
                                @n_err              output,
                                @c_errmsg           output

            IF @b_success <> 1
            BEGIN
               SELECT @n_continue = 3, @n_err = 63700, @c_errmsg = 'ntrSkuUpdate: ' + ISNULL(dbo.fnc_RTrim(@c_errmsg),'')
            END

            IF (@c_authority_owitf = '1')
            BEGIN
               -- Check if Pack info was updated
               IF EXISTS ( SELECT 1 FROM INSERTED JOIN DELETED ON (INSERTED.Packkey = DELETED.Packkey)
                            WHERE INSERTED.Packkey = @c_PackKey AND (INSERTED.StdCube <> DELETED.StdCube OR
                                                                     INSERTED.StdGrossWgt <> DELETED.StdGrossWgt) )
               BEGIN
                  IF NOT EXISTS ( SELECT 1 FROM TRANSMITLOG WITH (NOLOCK) WHERE Key1 = @c_PackKey
                                            AND Key2 = @c_Storerkey AND Key3 = @c_Sku AND TransmitFlag = '0' )
                  BEGIN
                     -- Retrieve additional info
                     SELECT @c_transmitlogkey = ''
                     SELECT @b_success = 1

                     EXECUTE nspg_getkey
                        'TransmitlogKey'
                        , 10
                        , @c_transmitlogkey OUTPUT
                        , @b_success OUTPUT
                        , @n_err OUTPUT
                        , @c_errmsg OUTPUT

                     IF NOT @b_success=1
                     BEGIN
                        SELECT @n_continue = 3 , @n_err = 63701
                        SELECT @c_errmsg = 'ntrSkuUpdate: ' + ISNULL(dbo.fnc_RTrim(@c_errmsg),'')
                     END

                     IF ( @n_continue = 1 OR @n_continue = 2 )
                     BEGIN
                        INSERT TRANSMITLOG (Transmitlogkey, Tablename, Key1, Key2, Key3, Transmitflag)
                        VALUES ( @c_transmitlogkey, 'OWCBM', @c_PackKey, @c_Storerkey, @c_Sku, 0 )

                        SELECT @n_err = @@Error
                        IF NOT @n_err = 0
                        BEGIN
                           SELECT @n_continue = 3
                           SELECT @n_err = 63702
                           SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),ISNULL(@n_err,0))+
                                            ': Insert Into TransmitLog Table (OWCBM) Failed (ntrSkuUpdate)' +
                                            ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '
                        END
                     END
   --                EXEC dbo.ispGenTransmitLog 'OWCBM', @c_PackKey, @c_Storerkey, @c_Sku, ''
   --                     , @b_success OUTPUT
   --                     , @n_err OUTPUT
   --                     , @c_errmsg OUTPUT
   --
   --                IF @b_success <> 1
   --                BEGIN
   --                   SELECT @n_continue = 3, @n_err = 63702, @c_errmsg = 'ntrSkuUpdate: ' + ISNULL(dbo.fnc_RTrim(@c_errmsg),'')
   --                End
                  END -- (Outstanding TransmitLog record not exists)
               END -- Sku Exists
            END -- (@c_authority_owitf = '1')
         END -- @n_continue=1 OR @n_continue=2

         FETCH NEXT FROM C_TransmitLogUpdate INTO @c_Storerkey, @c_Sku, @c_PackKey
      END -- WHILE @@FETCH_STATUS <> -1
      CLOSE C_TransmitLogUpdate
      DEALLOCATE C_TransmitLogUpdate
   --  END   -- tlting01 remove
   -- (YokeBeen01) - End

   -- Added By Ricky Yee for IDSV5
   -- 21 June 2002
   /*
   IF @n_continue=1 OR @n_continue=2
   BEGIN
      DECLARE @c_Action NVARCHAR(100),
              @c_OldValue NVARCHAR(30),
              @c_NewValue NVARCHAR(30)
      SELECT @c_Action = 'Updating '

      IF UPDATE(DESCR)
      BEGIN
         SELECT @c_OldValue = DESCR FROM DELETED

         SELECT @c_SKU = SKU,
                @c_NewValue = DESCR
           FROM INSERTED

         SELECT @c_Action = ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_Action)),'') + ' /Description. Origin:'
                          + ISNULL(dbo.fnc_RTrim(@c_OldValue),'') + ' New:' + ISNULL(dbo.fnc_RTrim(@c_NewValue),'')
      END
      IF UPDATE(SKU)
      BEGIN
         SELECT @c_OldValue = SKU FROM DELETED
         SELECT @c_NewValue = SKU FROM INSERTED

         SELECT @c_Action = ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_Action)),'') + ' /SKU Origin:'  + ISNULL(dbo.fnc_RTrim(@c_OldValue),'')
                          + ' New:' + ISNULL(dbo.fnc_RTrim(@c_NewValue),'')
      END
      IF UPDATE(PackKey)
      BEGIN
         SELECT @c_OldValue = PackKey FROM DELETED

         SELECT @c_SKU = SKU,
                @c_NewValue = PackKey
           FROM INSERTED

         SELECT @c_Action = ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_Action)),'') + ' /PackKey SKU:' + ISNULL(dbo.fnc_RTrim(@c_SKU),'')
                          + ' Origin:' + ISNULL(dbo.fnc_RTrim(@c_OldValue),'') + ' New:' + ISNULL(dbo.fnc_RTrim(@c_NewValue),'')
      END

      INSERT INTO SKULog (Person, ActionTime, ActionDescr)
      SELECT SUSER_SNAME(), GetDate(), @c_Action
        FROM  INSERTED

      UPDATE SKU
         SET EditDate = GETDATE(),
             EditWho = SUSER_SNAME()
        FROM INSERTED
       WHERE SKU.StorerKey = INSERTED.StorerKey
         AND SKU.Sku = INSERTED.Sku

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(NVARCHAR(250),@n_err), @n_err=63703   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(NVARCHAR(5),ISNULL(@n_err,0))+': Update Failed On Table SKU. (ntrSkuUpdate)' + ' ( '
                        + ' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '
      END
   END
   */
   -- end
   
   --WL01 START
   IF @n_continue=1 or @n_continue=2 OR (@c_TrafficCopAllowTriggerSP = 'Y' AND @n_continue <> 3)
   BEGIN
      IF EXISTS (SELECT 1 FROM DELETED d
                 JOIN storerconfig s WITH (NOLOCK) ON  d.storerkey = s.storerkey
                 JOIN sys.objects sys WITH (NOLOCK) ON sys.type = 'P' AND sys.name = s.Svalue
                 WHERE  s.configkey = 'SKUTrigger_SP')
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
   
         EXECUTE dbo.isp_SKUTrigger_Wrapper
                   'UPDATE'  --@c_Action
                 , @b_Success  OUTPUT
                 , @n_Err      OUTPUT
                 , @c_ErrMsg   OUTPUT
   
         IF @b_success <> 1
         BEGIN
            SELECT @n_continue = 3
                  ,@c_errmsg = 'ntrSKUUpdate ' + RTRIM(LTRIM(ISNULL(@c_errmsg,'')))
         END
   
         IF OBJECT_ID('tempdb..#INSERTED') IS NOT NULL
            DROP TABLE #INSERTED
   
         IF OBJECT_ID('tempdb..#DELETED') IS NOT NULL
            DROP TABLE #DELETED
      END
   END
   --WL01 END
QUIT:
   /* #INCLUDE <TRRDA2.SQL> */
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

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrSKUUpdate'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012

      IF @b_debug = 2
      BEGIN
         SELECT @profiler = 'PROFILER,637,00,9,ntrSKUUpdate Tigger, ' + CONVERT(NVARCHAR(12), getdate(), 114)
         PRINT @profiler
      END
      RETURN
   END
   ELSE
   BEGIN
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END

      IF @b_debug = 2
      BEGIN
         SELECT @profiler = 'PROFILER,637,00,9,ntrSKUUpdate Trigger, ' + CONVERT(NVARCHAR(12), getdate(), 114) PRINT @profiler
      END
      RETURN
   END
END
GO
ALTER TABLE [dbo].[SKU] ADD CONSTRAINT [PKSKU] PRIMARY KEY CLUSTERED ([StorerKey], [Sku]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_AltSku] ON [dbo].[SKU] ([ALTSKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_BUSR5] ON [dbo].[SKU] ([BUSR5], [StorerKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_BUSR6] ON [dbo].[SKU] ([BUSR6], [StorerKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_BUSR7] ON [dbo].[SKU] ([BUSR7], [StorerKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_Color] ON [dbo].[SKU] ([Color]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_editdate] ON [dbo].[SKU] ([EditDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_ManufacturerSku] ON [dbo].[SKU] ([MANUFACTURERSKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_Measurement] ON [dbo].[SKU] ([Measurement]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_OTM_SKUGroup] ON [dbo].[SKU] ([OTM_SKUGroup], [StorerKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_PackKey] ON [dbo].[SKU] ([PACKKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_PutawayZone] ON [dbo].[SKU] ([PutawayZone]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_RetailSKU] ON [dbo].[SKU] ([RETAILSKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_Size] ON [dbo].[SKU] ([Size]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SKU_SKU] ON [dbo].[SKU] ([Sku]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SKU_CIdx] ON [dbo].[SKU] ([StorerKey], [BUSR5], [itemclass], [SKUGROUP], [Style], [Color], [Size], [Measurement]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SKU_Style] ON [dbo].[SKU] ([Style]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SKU] WITH NOCHECK ADD CONSTRAINT [FK_SKU_STORER_01] FOREIGN KEY ([StorerKey]) REFERENCES [dbo].[STORER] ([StorerKey])
GO
EXEC sp_addextendedproperty N'MS_Description', 'Stock Keeping Unit (SKU) is also called as an item number, commodity, or product code.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'ABC designation of the SKU where A - fast mover, B - average mover, C - slow mover. Used during putaway to direct fast moving commodities to the correct locations', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'ABC'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Commodities in the warehouse can be identified with a variety of labels, each referring to the product by a different name or item number', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'ALTSKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Estimated average weight for the commodity', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'AvgCaseWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'BUSR1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'BUSR10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'BUSR2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Product Group', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'BUSR3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Product bitmap file path - where the bitmap is kept', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'BUSR4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'BUSR5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'BUSR6'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'BUSR7'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'BUSR8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'BUSR9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Cost the facility incurs to carry the inventory', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'CarryCost'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Code used to identify the family of cartons used during cartonization. If this commodity does not use the cartonization function, create a standard cartonization code for commodities of this type', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'CartonGroup'
GO
EXEC sp_addextendedproperty N'MS_Description', 'testing', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'CLASS'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Apparel related - commodity color e.g. red, yellow, white, black, blue etc', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Color'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Purchase prince for a master unit of the commodity', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Cost'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton Pick Qty', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'CtnPickQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Records the maximum cubic size for a Commodity the carton can hold.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of days between cycle counts for the commodity', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'CycleCountFrequency'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Data capture upon inbound and/or outbound', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'DataCapture'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the commodity', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'DESCR'
GO
EXEC sp_addextendedproperty N'MS_Description', 'EcomCartonType', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'EcomCartonType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This is the warehouse or DC in which the goods are residing', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Hazardous Code', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'HazardousFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Height of the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Height'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick method to use when picking inner packs in the zone.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'InnerPack'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Communicates to the system the time when weight capture should take place.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'IOFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifies the commodity class which is normally the department', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'itemclass'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Inbound value added services', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'IVAS'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the last cycle count', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'LastCycleCount'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Length per inner pack', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Length'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Contain attributes that define a CommodityÆs lots. For example, perishable product might be lotted by expiration date, clothing by mill number and size or textiles by dye lot.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'LOTTABLE01LABEL'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Contain attributes that define a CommodityÆs lots. For example, perishable product might be lotted by expiration date, clothing by mill number and size or textiles by dye lot.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'LOTTABLE02LABEL'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Contain attributes that define a CommodityÆs lots. For example, perishable product might be lotted by expiration date, clothing by mill number and size or textiles by dye lot.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'LOTTABLE03LABEL'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Contain attributes that define a CommodityÆs lots. For example, perishable product might be lotted by expiration date, clothing by mill number and size or textiles by dye lot.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'LOTTABLE04LABEL'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Contain attributes that define a CommodityÆs lots. For example, perishable product might be lotted by expiration date, clothing by mill number and size or textiles by dye lot.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'LOTTABLE05LABEL'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Information that describes a particular commodity.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'LotxIdDetailOtherlabel1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Information that describes a particular commodity.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'LotxIdDetailOtherlabel2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Information that describes a particular commodity.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'LotxIdDetailOtherlabel3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Commodity code the manufacturer uses to refer to the commodity.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'MANUFACTURERSKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Apparel related - commodity measurement', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Measurement'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unlimited text field for entry of additional information about the commodity', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'NOTES1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unlimited text field for entry of additional information about the commodity', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'NOTES2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates whether the pack key used for receipt should be copied to the LOTTABLE01 field.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'OnReceiptCopyPackkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Outbound value added services', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'OVAS'
GO
EXEC sp_addextendedproperty N'MS_Description', 'UOM identifying how the commodity is tracked', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'PACKKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'It is used to sort the lots during replenishment candidate selection.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'PickCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Retail price per master unit of the commodity', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Price'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Product Model', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'ProductModel'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Putaway location for the commodity in the facility', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'PutawayLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Putaway zone in which the commodity is staged prior to actual putaway.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'PutawayZone'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Algorithm that determines where the commodity is putaway during receiving process. The default is nspPASTd. Putaway strategy: This is setup at Support->Setup->Strategies->Putaway', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'PutCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Hold code to use if commodity is placed on hold upon RF receipt.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'ReceiptHoldCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Putaway algorithm will direct the product to this location for inspection/quality control purposes', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'ReceiptInspectionLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This is the default receipt location which can be used by the system during the ASN Receipt or RDT Receive', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'ReceiptLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Minimum inventory level of the commodity for the facility. This field is not used for any logic processes in the system.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'ReorderPoint'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity that must be re-ordered when re-order point is reached', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'ReorderQty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Commodity code retailers use to refer to the commodity.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'RETAILSKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'During the return process, the system will use this location field to receive the stock return', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'ReturnLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Serial no capture', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'SerialNoCapture'
GO
EXEC sp_addextendedproperty N'MS_Description', 'shelflife', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'ShelfLife'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Apparel related - commodity size e.g. small, medium, large etc.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Size'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifies the commodity group which is normally the sub department', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'SKUGROUP'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifies whether the commodity is active or inactive', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'SkuStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates the total number of block stack allowed', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'StackFactor'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifies the default cube per unit in terms of eaches (Master Unit) for this commodity. Cube per unit in terms of eaches (Master Unit)', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'STDCUBE'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Gross weight per unit in terms of eaches', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'STDGROSSWGT'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifies the net weight per unit in terms of eaches (Master Unit)', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'STDNETWGT'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Cost to re-order the commodity', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'StdOrderCost'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the storer associated with the new Commodity', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Master strategy which comprises of putaway, pre-allocation and allocation', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'StrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Apparel related - commodity style e.g. jackets, dress, pants, shorts, tops, blazers etc', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Style'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Commodity shelf life that will be used to check the incoming stock. Number of days permitted before the expiration date or the number of days permitted after the manufacturing date.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'SUSR1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of days that the customer allows between the current date and either the expiration date or the manufacturing date for the item being shipped.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'SUSR2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customer''s principal that manufactures the goods', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'SUSR3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Tolerance percentage for incoming receipt', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'SUSR4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Variance allowed', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'SUSR5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Difference between the net weight and the gross weight of the commodity', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'TareWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Type of tariff assigned to the commodity.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Tariffkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Temperature Code', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'TemperatureFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Amount of difference allowed between the average case weight and the actual weight', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'TolerancePct'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Weight of the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'weight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Width of the Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'Width'
GO
EXEC sp_addextendedproperty N'MS_Description', 'During the crossdock process, the system will use this location field to receive the stock', 'SCHEMA', N'dbo', 'TABLE', N'SKU', 'COLUMN', N'XDockReceiptLoc'
GO
