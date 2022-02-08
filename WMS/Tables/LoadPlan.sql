CREATE TABLE [dbo].[LoadPlan]
(
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseCnt] [int] NULL CONSTRAINT [DF_LoadPlan_CaseCnt] DEFAULT ((0)),
[PalletCnt] [int] NULL CONSTRAINT [DF_LoadPlan_PalletCnt] DEFAULT ((0)),
[Weight] [float] NULL CONSTRAINT [DF_LoadPlan_Weight] DEFAULT ((0)),
[Cube] [float] NULL CONSTRAINT [DF_LoadPlan_Cube] DEFAULT ((0)),
[CustCnt] [int] NULL CONSTRAINT [DF_LoadPlan_CustCnt] DEFAULT ((0)),
[AddDate] [datetime] NULL CONSTRAINT [DF_LoadPlan_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlan_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_LoadPlan_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlan_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlan_Status] DEFAULT ('0'),
[TruckSize] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SuperOrderFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SectionKey] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarrierKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Route] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrfRoom] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DummyRoute] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderCnt] [int] NULL CONSTRAINT [DF_LoadPlan_OrderCnt] DEFAULT ((0)),
[facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlan_Facility] DEFAULT ('F1'),
[PROCESSFLAG] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlan_ProcessFlag] DEFAULT ('N'),
[Return_Weight] [float] NULL CONSTRAINT [DF_LoadPlan_Return_Weight] DEFAULT ((0)),
[Return_Cube] [float] NULL CONSTRAINT [DF_LoadPlan_Return_Cube] DEFAULT ((0)),
[Vehicle_Type] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery_Zone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Truck_Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Load_Userdef1] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Load_Userdef2] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[weightlimit] [float] NULL CONSTRAINT [DF_LoadPlan_weightlimit] DEFAULT ((0.0)),
[volumelimit] [float] NULL CONSTRAINT [DF_LoadPlan_volumelimit] DEFAULT ((0.0)),
[AllocatedCube] [float] NULL CONSTRAINT [DF_LoadPlan_AllocatedCube] DEFAULT ((0.0)),
[AllocatedWeight] [float] NULL CONSTRAINT [DF_LoadPlan_AllocatedWeight] DEFAULT ((0.0)),
[AllocatedCaseCnt] [int] NULL CONSTRAINT [DF_LoadPlan_AllocatedCaseCnt] DEFAULT ((0)),
[AllocatedPalletCnt] [int] NULL CONSTRAINT [DF_LoadPlan_AllocatedPalletCnt] DEFAULT ((0)),
[AllocatedOrderCnt] [int] NULL CONSTRAINT [DF_LoadPlan_AllocatedOrderCnt] DEFAULT ((0)),
[AllocatedCustCnt] [int] NULL CONSTRAINT [DF_LoadPlan_AllocatedCustCnt] DEFAULT ((0)),
[lpuserdefdate01] [datetime] NULL,
[FinalizeFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlan_FinalizeFlag] DEFAULT ('N'),
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLAN_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLAN_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLAN_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLAN_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLAN_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLAN_UserDefine08] DEFAULT ('N'),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLAN_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLAN_UserDefine10] DEFAULT (' '),
[ExternLoadKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlan_ExternLoadKey] DEFAULT (' '),
[CtnTyp1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Loadplan_CtnTyp1] DEFAULT ((0)),
[CtnTyp2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Loadplan_CtnTyp2] DEFAULT ((0)),
[CtnTyp3] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Loadplan_CtnTyp3] DEFAULT ((0)),
[CtnTyp4] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Loadplan_CtnTyp4] DEFAULT ((0)),
[CtnTyp5] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Loadplan_CtnTyp5] DEFAULT ((0)),
[CtnCnt1] [int] NULL CONSTRAINT [DF_Loadplan_CtnCnt1] DEFAULT ((0)),
[CtnCnt2] [int] NULL CONSTRAINT [DF_Loadplan_CtnCnt2] DEFAULT ((0)),
[CtnCnt3] [int] NULL CONSTRAINT [DF_Loadplan_CtnCnt3] DEFAULT ((0)),
[CtnCnt4] [int] NULL CONSTRAINT [DF_Loadplan_CtnCnt4] DEFAULT ((0)),
[CtnCnt5] [int] NULL CONSTRAINT [DF_Loadplan_CtnCnt5] DEFAULT ((0)),
[TotCtnWeight] [float] NULL CONSTRAINT [DF_Loadplan_TotCtnWeight] DEFAULT ((0)),
[TotCtnCube] [float] NULL CONSTRAINT [DF_Loadplan_TotCtnCube] DEFAULT ((0)),
[CartonGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Loadplan_CartonGroup] DEFAULT (''),
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_loadplan_Priority] DEFAULT ('9'),
[DispatchPalletPickMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlan_DispatchPalletPickMethod] DEFAULT ('1'),
[DispatchCasePickMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlan_DispatchCasePickMethod] DEFAULT ('1'),
[DispatchPiecePickMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlan_DispatchPiecePickMethod] DEFAULT ('1'),
[LoadPickMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlan_LoadPickMethod] DEFAULT (''),
[MBOLGroupMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultStrategykey] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BookingNo] [int] NULL,
[OTM_DispatchDate] [datetime] NOT NULL CONSTRAINT [DF_LoadPlan_OTM_DispatchDate] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/***************************************************************************/
/* Trigger: ntrLoadPlanAdd                                                 */
/* Creation Date:                                                          */
/* Copyright: IDS                                                          */
/* Written by:                                                             */
/*                                                                         */
/* Purpose:                                                                */
/*                                                                         */
/* Return Status:                                                          */
/*                                                                         */
/* Usage:                                                                  */
/*                                                                         */
/* Called By: When records Inserted                                        */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Modifications:                                                          */
/* Date         Author     Ver   Purposes                                  */
/* 05-Jun-2017  Leong            IN00365955 - Add Log for missing header.  */
/*                               (temp only).                              */
/* 27-Jul-2017  TLTING     1.1   Set Option                                */
/***************************************************************************/

CREATE TRIGGER [dbo].[ntrLoadPlanAdd]
ON [dbo].[LoadPlan]
FOR INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
        @b_Success     INT           -- Populated by calls to stored procedures - was the proc successful?
      , @n_err         INT           -- Error number returned by stored procedure OR this trigger
      , @n_err2        INT           -- For Additional Error Detection
      , @c_errmsg      NVARCHAR(250) -- Error message returned by stored procedure OR this trigger
      , @n_continue    INT
      , @n_starttcnt   INT           -- Holds the current transaction count
      , @c_preprocess  NVARCHAR(250) -- preprocess
      , @c_pstprocess  NVARCHAR(250) -- post process
      , @n_cnt         INT

   SELECT @n_continue = 1, @n_starttcnt = @@TRANCOUNT

   -- IN00365955 (Start)
   DECLARE @c_LoadKey   NVARCHAR(10)
         , @c_Facility  NVARCHAR(5)
         , @c_FieldName NVARCHAR(30)

   SELECT @c_LoadKey   = LoadKey
        , @c_Facility  = Facility
        , @c_FieldName = 'LPHEADER'
   FROM INSERTED

   EXEC isp_Sku_log
        @cStorerKey = @c_LoadKey
      , @cSKU       = @c_Facility
      , @cFieldName = @c_FieldName
      , @cOldValue  = ''
      , @cNewValue  = 'INSERTED'
   -- IN00365955 (End)

   /* #INCLUDE <TRMBOA1.SQL> */
   -- Added By SHONG
   -- 30th Apr 2003
   -- Do Nothing when ArchiveCop = '9'
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      IF EXISTS (SELECT 1 FROM INSERTED WHERE ArchiveCop = "9")
      BEGIN
         SELECT @n_continue = 4
      END
   END
   -- END 30th Apr 2003

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      IF EXISTS (SELECT * FROM INSERTED WHERE Status = "9")
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 72602
         SELECT @c_errmsg = "NSQL"+CONVERT(char(5),@n_err)+": Bad LoadPlan.Status. (ntrLoadPlanAdd)"
      END
   END

   /* #INCLUDE <TRMBOHA2.SQL> */
   IF @n_continue = 3  -- Error Occured - Process And Return
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

      EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrLoadPlanAdd"
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
/* Trigger:  ntrLoadPlanDelete                                          */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:  Fire and perform requested process, when Loadplan Deletion */
/*           is took place.                                             */
/*                                                                      */
/* Output Parameters:  None                                             */
/*                                                                      */
/* Return Status:  None                                                 */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When records updated                                      */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver.  Purposes                                */
/* 11-Mar-2009  YokeBeen  1.1   Added Trigger Point for CMS Project.    */
/*                              - SOS#170510 - (YokeBeen01)             */
/* 18-Mar-2010  TLTING    1.2   Delete LoadPlanLaneDetail (tlting01)    */
/*  9-Jun-2011  KHLim01   1.3   Insert Delete log                       */
/* 14-Jul-2011  KHLim02   1.4   GetRight for Delete log                 */
/* 11-Apr-2016  Leong     1.5   TS00009807 - Update LoadplanLaneDetail  */
/*                              EditDate.                               */
/* 18-Jul-2016  SHONG01   1.6   Update LoadKey to Pick & Pack Tables    */
/*                              SOS#373412                              */ 
/* 27-Jul-2017  TLTING    1.4   Missing NOLOCK                          */
/* 29-Sep-2018  TLTING    1.5   remove row lock                          */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrLoadPlanDelete]
ON [dbo].[LoadPlan]
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

   DECLARE @b_Success     int         -- Populated by calls to stored procedures - was the proc successful?
         , @n_err         int         -- Error number returned by stored procedure or this trigger
         , @c_errmsg      NVARCHAR(250)   -- Error message returned by stored procedure or this trigger
         , @n_continue    int         -- continuation flag: 1=Continue, 2=failed but continue processsing,
                                         -- 3=failed do not continue processing, 4=successful but skip further processing
         , @n_starttcnt   int         -- Holds the current transaction count
         , @n_cnt         int         -- Holds the number of rows affected by the DELETE statement that fired this trigger.
         , @c_loadkey     NVARCHAR(10)
         , @c_PickSlipNo  NVARCHAR(10)
         , @c_facility    NVARCHAR(5)     -- Added for IDSV5 by June 26.Jun.02
         , @c_authority   NVARCHAR(1)     -- Added for IDSV5 by June 26.Jun.02
         
         , @cKeepPickHDWhenLpdDelete   NVARCHAR(1)  --SHONG01
         , @c_DelOrderKey              NVARCHAR(10) --SHONG01
         
    SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

      /* #INCLUDE <TRMBOHD1.SQL> */
   IF (SELECT count(*) FROM DELETED) = (SELECT count(*) FROM DELETED WHERE DELETED.ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
   END

   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      IF EXISTS (SELECT * FROM DELETED WHERE Status = '9')
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 72701
         SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                          + ': DELETE rejected. LoadPlan.Status = ''Shipped''. (ntrLoadPlanDelete)'
      END
   END

   -- SOS32395 : Move from 'BATCHPICK'
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      SELECT @c_Facility = Facility
      FROM   DELETED
   END

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      SELECT @b_success = 0
      Execute nspGetRight @c_Facility, -- facility, SOS32395
               null,    -- Storerkey
               null,          -- Sku
               'FinalizeLP',     -- Configkey
               @b_success     output,
               @c_authority   output,
               @n_err         output,
               @c_errmsg      output

      IF @b_success <> 1
      BEGIN
         SELECT @n_continue = 3, @c_errmsg = 'ntrLoadplanDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE IF @c_authority = '1'
      BEGIN
         -- Once finalized, no more deletion allowed, requested by KO, 5th Jan 2002
         IF EXISTS (SELECT 1 FROM DELETED WHERE FinalizeFlag = 'Y' )
         BEGIN
            SELECT @n_continue = 3
            SELECT @n_err=73000
            SELECT @c_errmsg = 'NSQL' +CONVERT(char(5),ISNULL(@n_err,0))
                             + ': Loadplan has been finalized. DELETE rejected. (ntrLoadPlanDelete)'
         END
      END
   END   -- Added for IDSV5 by June 26.Jun.02, (extract from IDSHK) *** End

   -- Modified for Batch Pick
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      -- Added for IDSV5 by June 26.Jun.02, (extract from IDSHK) *** Start
      SELECT @b_success = 0
      Execute nspGetRight @c_Facility, -- facility
               null,    -- Storerkey
               null,          -- Sku
               'BATCHPICK',         -- Configkey
               @b_success     output,
               @c_authority   output,
               @n_err         output,
               @c_errmsg      output

      IF @b_success <> 1
      BEGIN
         SELECT @n_continue = 3, @c_errmsg = 'ntrLoadplanDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE IF @c_authority = '1'
      BEGIN  -- Added for IDSV5 by June 26.Jun.02, (extract from IDSHK) *** End
         -- only allow delete of loadplan if NONE of the batchpick tasks are completed
         IF EXISTS (SELECT 1 FROM Taskdetail WITH (NOLOCK)
                      JOIN DELETED ON ( Taskdetail.Sourcekey = DELETED.Loadkey )
                     WHERE Taskdetail.Sourcetype = 'BATCHPICK'
                     AND Taskdetail.Status = '9' )
         BEGIN
            SELECT @n_continue = 3
            SELECT @n_err = 72702
            SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                             + ': DELETE rejected. Some RF Tasks has been completed . (ntrLoadPlanDelete)'
         END
      END -- by June SOS29101

      IF @n_continue = 1 OR @n_continue = 2
      BEGIN
         -- to delete the details, we need to bypass the trigger,
         -- as it disallow delete of detail when task has been released.
         -- delete of loadplan can only be from the header, which means deleting all the related tasks and pickslips.
         IF EXISTS (SELECT 1 FROM LOADPLANDETAIL WITH (NOLOCK)
                      JOIN DELETED ON ( DELETED.Loadkey = LOADPLANDETAIL.Loadkey ))
         BEGIN
            UPDATE Loadplandetail  
               SET trafficcop = '9'
              FROM LOADPLANDETAIL
              JOIN DELETED ON ( DELETED.Loadkey = LOADPLANDETAIL.Loadkey )
         END

         -- sos 6710
         -- check if there any return loadplan details
         -- wally 18.july.2002
         IF EXISTS (SELECT 1 FROM LOADPLANRETDETAIL WITH (NOLOCK)
                      JOIN DELETED ON ( DELETED.Loadkey = LOADPLANRETDETAIL.Loadkey ))
         BEGIN
            UPDATE LOADPLANRETDETAIL  
               SET trafficcop = '9'
              FROM LOADPLANRETDETAIL
              JOIN DELETED ON (DELETED.Loadkey = LOADPLANRETDETAIL.Loadkey)
         END
         -- tlting01 start
         IF EXISTS (SELECT 1 FROM LoadPlanLaneDetail WITH (NOLOCK)
                      JOIN DELETED ON ( DELETED.Loadkey = LoadPlanLaneDetail.Loadkey ))
         BEGIN
            UPDATE LoadPlanLaneDetail  
               SET trafficcop = '9'
                 , EditDate = GETDATE() -- TS00009807
              FROM LoadPlanLaneDetail
              JOIN DELETED ON ( DELETED.Loadkey = LoadPlanLaneDetail.Loadkey )
         END -- tlting01 end

         -- delete tasks
         IF EXISTS (SELECT 1 FROM TASKDETAIL WITH (NOLOCK)
                      JOIN DELETED ON (DELETED.Loadkey = TASKDETAIL.Sourcekey)
                     WHERE TASKDETAIL.Sourcetype = 'BATCHPICK' )
         BEGIN
            SELECT DISTINCT @c_loadkey = LOADKEY FROM DELETED
            DELETE TASKDETAIL
             WHERE SOURCEKEY = @c_loadkey
               AND SOURCETYPE = 'BATCHPICK'

            IF @@ERROR <> 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @n_err = 72703
               SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                                + ': DELETE rejected. Some RF Tasks has been completed . (ntrLoadPlanDelete)'
            END
         END   -- IF EXISTS
         -- delete Pick slip

         IF @n_continue = 1 OR @n_continue = 2
         BEGIN
            SELECT @c_PickSlipNo = ''
            SELECT @c_PickSlipNo = Pickheaderkey 
            FROM   PICKHEADER with (NOLOCK)
            WHERE  ExternOrderkey = @c_loadkey

            IF ISNULL(RTRIM(@c_PickSlipNo),'') <> ''
            BEGIN
               -- SHONG01
         	   SET @cKeepPickHDWhenLpdDelete = ''  

               SELECT TOP 1 
                     @cKeepPickHDWhenLpdDelete = ISNULL(sValue, '0')   
               FROM  STORERCONFIG WITH (NOLOCK)   
               JOIN  ORDERS AS o WITH (NOLOCK) ON o.StorerKey = STORERCONFIG.StorerKey 
               JOIN LoadPlanDetail AS lpd WITH (NOLOCK) ON lpd.OrderKey = o.OrderKey  
               WHERE lpd.LoadKey = @c_loadkey    
               AND   ConfigKey = 'KeepPickHDWhenLpdDelete'   
               AND   sVAlue = '1' 
      
               IF @cKeepPickHDWhenLpdDelete <> '1'
               BEGIN
                  -- delete pick header info
                  DELETE PICKHEADER
                  WHERE ExternOrderkey = @c_loadkey

                  SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
                  IF @n_err <> 0
                  BEGIN
                     SELECT @n_continue = 3
                     SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 72704
                     SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                                      + ': Unable to delete Pickslip. (ntrLoadPlanDelete)'
                                      + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
                  END

                  IF @n_continue = 1 OR @n_continue = 2
                  BEGIN
                     -- delete picking info
                     DELETE PICKINGINFO
                      WHERE PICKSLIPNO = @c_PickSlipNo

                     SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
                     IF @n_err <> 0
                     BEGIN
                        SELECT @n_continue = 3
                        SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 72705
                        SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                                         + ': Unable to delete Pickslip. (ntrLoadPlanDelete)'
                                         + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
                     END
                  END -- @n_continue       	
               END
               ELSE 
               BEGIN
               	DECLARE DEL_PickSlipNo CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               	SELECT p.PickHeaderKey 
               	FROM PICKHEADER AS p WITH (NOLOCK)
               	WHERE p.ExternOrderKey = @c_loadkey 
               	
               	OPEN DEL_PickSlipNo 
               	FETCH NEXT FROM DEL_PickSlipNo INTO @c_PickSlipNo 
               	
               	WHILE @@FETCH_STATUS = 0 
               	BEGIN
            	      UPDATE PICKHEADER 
            	       SET ExternOrderKey = '', 
            	           TrafficCop = NULL, 
            	           EditDate = GETDATE(), 
            	           EditWho = SUSER_SNAME() 
            	      WHERE ExternOrderKey = @c_loadkey 
            	        AND OrderKey = @c_DelOrderKey  
            	        AND PickHeaderKey = @c_PickSlipNo  
            	   
            	      IF EXISTS(SELECT 1 FROM PackHeader AS ph WITH (NOLOCK)
            	                WHERE ph.PickSlipNo = @c_PickSlipNo 
            	                AND   ph.LoadKey = @c_loadkey )
            	      BEGIN
            	   	   UPDATE PackHeader  
            	   	      SET LoadKey = ''
            	   	   WHERE PickSlipNo = @c_PickSlipNo
            	   	            	   	
            	      END -- PackHeader 
            	      IF EXISTS(SELECT 1 FROM RefKeyLookup AS rkl WITH (NOLOCK)
            	                WHERE rkl.Pickslipno = @c_PickSlipNo 
            	                AND rkl.Loadkey = @c_loadkey)
            	      BEGIN
            	   	   UPDATE RefKeyLookup
            	   	      SET Loadkey = ''
            	   	   WHERE Pickslipno = @c_PickSlipNo  
            	         AND Loadkey = @c_loadkey
            	      END -- RefKeyLookup
               		FETCH NEXT FROM DEL_PickSlipNo INTO @c_PickSlipNo 
               	END      	      
               	CLOSE DEL_PickSlipNo
               	DEALLOCATE DEL_PickSlipNo
               END -- @cKeepPickHDWhenLpdDelete = 1               	
            END -- @c_PickSlipNo exists 
         END -- @n_continue
      END -- @n_continue
   -- END -- Authority = 1 : SOS29101
   END   -- End  Batch Picking

   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      DELETE LoadPlanDetail
        FROM LoadPlanDETAIL
        JOIN DELETED ON (LoadPlanDETAIL.LoadKey = DELETED.LoadKey)
       WHERE LOADPLANDETAIL.Trafficcop = '9'

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 72706
         SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                          + ': Delete Trigger On Table LoadPlanDETAIL Failed. (ntrLoadPlanDelete)'
                          + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END
   END

   -- SOS 6710
   -- delete any return loadplan details
   -- wally 18.july.2002
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      DELETE LoadPlanRetDetail
        FROM LoadPlanRetDETAIL
        JOIN DELETED ON (LoadPlanRetDETAIL.LoadKey = DELETED.LoadKey)
       WHERE LOADPLANRetDETAIL.Trafficcop = '9'

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 72707
         SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                          + ': Delete Trigger On Table LoadPlanRetDETAIL Failed. (ntrLoadPlanDelete)'
                          + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END
   END

   -- tlting01 Start
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      DELETE LoadPlanLaneDetail
        FROM LoadPlanLaneDetail
        JOIN DELETED ON (LoadPlanLaneDetail.LoadKey = DELETED.LoadKey)
       WHERE LoadPlanLaneDetail.Trafficcop = '9'

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 72706
         SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                          + ': Delete Trigger On Table LoadPlanLaneDetail Failed. (ntrLoadPlanDelete)'
                          + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
      END
   END -- tlting01 End

   -- (YokeBeen01) - Start
   -- Record has been triggered into CMSLOG with normal Status upon the last LoadplanDetail line is to be purged.
   -- This record will be updated from CMSLOG.TransmitFlag from "0" to "2",
   -- when this Loadplan Header record is to be purged.
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      IF EXISTS ( SELECT 1 FROM DELETED
                    JOIN CMSLOG WITH (NOLOCK) ON (DELETED.LoadKey = CMSLOG.Key1)
                   WHERE CMSLOG.TableName = 'LPCANCCMS' AND CMSLOG.TransmitFlag = '0')
      BEGIN
         UPDATE CMSLOG  
            SET TransmitFlag = '2'
           FROM DELETED
           JOIN CMSLOG ON (DELETED.LoadKey = CMSLOG.Key1)
          WHERE CMSLOG.TableName = 'LPCANCCMS' AND CMSLOG.TransmitFlag = '0'

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=63810
            SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                             + ': Unable to Update CMSLog Record, TableName = LPCANCCMS (ntrLoadPlanDelete)'
                             + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
         END -- IF @n_err <> 0
      END -- IF Key EXISTS and CMSLOG.TableName = 'LPCANCCMS'
   END -- IF @n_continue = 1 or @n_continue = 2
   -- (YokeBeen01) - End

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
               ,@c_errmsg = 'ntrLoadPlanDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.LoadPlan_DELLOG ( LoadKey )
         SELECT LoadKey FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table ORDERS Failed. (ntrLoadPlanDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END
   -- End (KHLim01)

   /* #INCLUDE <TRMBOHD2.SQL> */
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

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrLoadPlanDelete'
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
/* Trigger:  ntrLoadPlanUpdate                                          */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:  None                                             */
/*                                                                      */
/* Return Status:  None                                                 */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When records updated                                      */
/*                                                                      */
/* PVCS Version: 1.7                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver.  Purposes                                */
/* 13-Sep-2005  June      1.0   SOS40637 - bug fixed, no trxlog rec     */  
/*                              'ITSRCPT'.                              */  
/* 10-Sep-2007  Leong     1.0   SOS 85340 - Set Round (SKU.StdCube,6)   */  
/* 11-Mar-2009  YokeBeen  1.1   Added Trigger Point for CMS Project.    */  
/*                              - SOS#170508/170509 - (YokeBeen01)      */  
/* 06-May-2009  YokeBeen  1.2   Added Generic Trigger Point 'LOADSHPLOG'*/  
/*                              with Key1 = LoadKey. -- (YokeBeen02)    */  
/* 17-Feb-2010  ChewKP    1.3   Update LoadPlanLaneDetail to release    */  
/*                              Staging Lane when LP.Status = '9'       */  
/*                              (ChewKP01)                              */  
/* 08-Apr-2010  Vicky     1.4   Update LoadPlanLaneDetail to release    */  
/*                              Staging Lane should filter out those    */  
/*                              already has status = 9 (Vicky01)        */  
/* 04-May-2010  Leong     1.4   SOS# 171476 - Bug Fix on Status update  */  
/* 06-Aug-2010  TLTING    1.5   Cube & Weight Calculate status < 5      */  
/*                               (tlting01)                             */  
/* 22-May-2012  TLTING01  1.6   DM integrity - add update editdate B4   */
/*                              TrafficCop for status < '9'             */   
/* 10-Jul-2013  Shong     1.7   Include missing changes from UK         */
/* 28-Oct-2013  TLTING    1.8   Review Editdate column update           */
/* 03-Jun-2014  MCTang    1.9   Add New LOADFNZLOG (MC01)               */
/* 28-Nov-2014  TLTING    1.10  Performance Tuning                      */  
/* 03-Jun-2014  MCTang    1.11  Add New LOADFRCLOG (MC02)               */
/* 20-Sep-2016  MCTang    1.12  Enhance Generaic Trigger Interface &    */
/*                              OTMLOG Generaic Trigger Interface (MC03)*/
/* 16-Aug-2017  TLTING    1.13  Add TraceLog update ArchiveCop (TL01)   */ 
/* 11-Nov-2017  TLTING    1.14  Tune, verify LP status (TL01)           */ 
/* 15-Aug-2017  MCTang    1.13  Enhance Trigger Interface (MC04)        */
/* 04-Sep-2018  MCTang    1.14  Enhance Generaic Trigger Interface(MC05)*/
/* 20-Oct-2020  TLTING02  1.15  Performance tune                        */
/************************************************************************/

CREATE  TRIGGER [dbo].[ntrLoadPlanUpdate]
ON  [dbo].[LoadPlan]
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

DECLARE @b_Success     int       -- Populated by calls to stored procedures - was the proc successful?
      , @n_err         int       -- Error number returned by stored procedure or this trigger
      , @n_err2        int       -- For Additional Error Detection
      , @c_errmsg      NVARCHAR(250) -- Error message returned by stored procedure or this trigger
      , @n_continue    int
      , @n_starttcnt   int       -- Holds the current transaction count
      , @c_preprocess  NVARCHAR(250) -- preprocess
      , @c_pstprocess  NVARCHAR(250) -- post process
      , @n_cnt         int
      , @b_debug       int
      , @c_facility    NVARCHAR(5) -- Add For IDSV5 by June 26.Jun.02
      , @c_authority   NVARCHAR(1) -- Add For IDSV5 by June 26.Jun.02
      , @c_OWITF       NVARCHAR(1) -- Add For IDSV5 by June 26.Jun.02
      , @c_ITSITF      NVARCHAR(1) -- Add For IDSV5 By Ricky 30.Aug.02
      , @c_DPREPICK1   NVARCHAR(1) -- Add For IDSV5 By Ricky 30.Aug.02
      , @c_DPREPICK    NVARCHAR(1) -- Add For IDSV5 By Ricky 30.Aug.02
      , @c_NIKEREGITF  NVARCHAR(1) -- Add For NSC Project (SOS#15353) By YokeBeen on 14-Nov-2003
      , @c_LPPKCFMCMS  NVARCHAR(1) -- (YokeBeen01)
      , @c_LPSHPCFMCMS NVARCHAR(1) -- (YokeBeen01)
      , @c_LoadShpLog  NVARCHAR(1) -- (YokeBeen02)
      , @c_LOADFNZLOG  NVARCHAR(1) -- (MC01)
      , @c_LOADFRCLOG  NVARCHAR(1) -- (MC02)

-- Start - Modified by YokeBeen on 30-Apr-2002 (FBR089)
DECLARE @c_XStorerkey   NVARCHAR(15)
      , @c_trmlogkey    NVARCHAR(10)
      , @c_XLoadKey     NVARCHAR(10)
      , @c_PICKTRF      NVARCHAR(1)
-- End

DECLARE @c_FinalizeFlag    NVARCHAR(1)
      , @c_Userdefine08    NVARCHAR(10)
      , @c_PreFinFlag      NVARCHAR(1)
      , @c_EditWho         NVARCHAR(18)
      , @c_LoadKey         NVARCHAR(10)   
      , @c_Storerkey       NVARCHAR(15)   --(MC03)
      , @c_StatusUpdated   CHAR(1)        --(MC04) 
      , @c_Proceed         CHAR(1)        --(MC04)
      , @c_COLUMN_NAME     VARCHAR(50)    --(MC04) 
      , @c_ColumnsUpdated  VARCHAR(1000)  --(MC04)

DECLARE @c_TraceKey           NVARCHAR(10)         --(TL01)  
      , @c_ArchiveCop         NVARCHAR(10) = ''    --(TL01)  
      , @c_InsertedStatus     NVARCHAR(10) = ''    --(TL01)  

DECLARE @c_LP_Min_Status      NVARCHAR(10) = '0'     --(TL01)  
      , @c_LP_Max_Status      NVARCHAR(10) = '0'     --(TL01)  

SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT, @b_debug = 0
SET @c_StatusUpdated = 'N'                --(MC04)
SET @c_Proceed       = 'N'                --(MC04)     

IF UPDATE(ArchiveCop)
BEGIN
   SELECT @n_continue = 4
   --SELECT @c_TraceKey = LoadKey
   --     , @c_ArchiveCop = ArchiveCop
   --     , @c_InsertedStatus = [STATUS]
   --FROM INSERTED
   --IF @c_InsertedStatus <> '9' AND @c_ArchiveCop = '9'
   --   BEGIN
   --      EXEC isp_Sku_Log '', @c_TraceKey, 'UPD-Load', '', @c_ArchiveCop --(TL01) 
   --      EXEC isp_Sku_Log '', @c_TraceKey, 'UPD-Load', 'stutus', @c_InsertedStatus --(TL01)  
   --   END
END

DECLARE @b_ColumnsUpdated VARBINARY(1000)       --MC03
SET @b_ColumnsUpdated = COLUMNS_UPDATED()       --MC03

-- tlting01
IF EXISTS ( SELECT 1 FROM INSERTED, DELETED 
            WHERE INSERTED.LoadKey = DELETED.LoadKey
            AND ( INSERTED.[status] < '9' OR DELETED.[status] < '9' ) ) 
   AND (@n_continue=1 or @n_continue=2)
   AND NOT UPDATE(EditDate)
BEGIN
   UPDATE LoadPlan  
   SET EditDate = GETDATE(), EditWho=SUSER_SNAME(),
         TrafficCop = NULL       
   FROM LoadPlan,INSERTED       
   WHERE LoadPlan.LoadKey=INSERTED.LoadKey      
   AND LoadPlan.[status] < '9'
   SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT             
   IF @n_err <> 0      
   BEGIN      
      SELECT @n_continue = 3       
      SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72815      
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On LoadPlan. (ntrLoadPlanUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '      
   END      
END 

IF UPDATE(TrafficCop)
BEGIN
   SELECT @n_continue = 4
END

/* #INCLUDE <TRMBOHU1.SQL> */
IF @n_continue=1 or @n_continue=2
BEGIN
   IF EXISTS (SELECT * FROM DELETED WHERE Status = '9')
   BEGIN
      SELECT @n_continue=3
      SELECT @n_err=72810
      SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                       + ': UPDATE rejected. LoadPlan.Status = ''SHIPPED''. (ntrLoadPlanUpdate)'
   END
END

IF @n_continue=1 or @n_continue=2
BEGIN
   DECLARE @c_FinalizeLP NVARCHAR(1)
   SELECT @b_success = 0

   Execute nspGetRight null,  -- facility
            null,      -- Storerkey
            null,      -- Sku
            'FinalizeLP', -- Configkey
            @b_success    output,
            @c_FinalizeLP output,
            @n_err        output,
            @c_errmsg     output

   IF @b_success <> 1
   BEGIN
      SELECT @n_continue = 3, @c_errmsg = 'ntrLoadPlanUpdate' + RTrim(@c_errmsg)
   END
END

-- Start - Add by June 31.Jan.02 FBR039
IF (@n_continue=1 or @n_continue=2) AND UPDATE(FinalizeFlag)
BEGIN
   DECLARE @c_XOrderKey  NVARCHAR(30)
   SELECT @c_XOrderKey = SPACE(30)

   DECLARE C_Loadplan_Add CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT LOADPLANDETAIL.OrderKey,
          ORDERS.Storerkey,
          LOADPLANDETAIL.LoadKey,
          INSERTED.FinalizeFlag,
          DELETED.FinalizeFlag,
          ORDERS.Userdefine08
   FROM   INSERTED
   JOIN   DELETED ON (INSERTED.LoadKey = DELETED.LoadKey)
   JOIN   LOADPLANDETAIL WITH (NOLOCK) ON (INSERTED.Loadkey = LOADPLANDETAIL.Loadkey)
   JOIN   ORDERS WITH (NOLOCK) ON (LOADPLANDETAIL.Orderkey = Orders.Orderkey
                               and LOADPLANDETAIL.Loadkey = ORDERS.Loadkey)
   ORDER BY LOADPLANDETAIL.OrderKey

   OPEN C_Loadplan_Add

   FETCH NEXT FROM C_Loadplan_Add INTO
      @c_XOrderKey,   @c_XStorerkey,  @c_XLoadKey, @c_FinalizeFlag, @c_PreFinFlag, @c_UserDefine08

   WHILE @@FETCH_STATUS <> -1
   BEGIN
      SELECT @b_success = 0
      SELECT @c_DPREPICK = 0  -- Modified by June 20.Feb.03 FBR9706
      SELECT @c_DPREPICK1 = 0 -- Modified by June 20.Feb.03 FBR9706


      IF @c_FinalizeFlag = 'Y' AND @c_PreFinFlag <> 'Y'
      BEGIN
         Execute nspGetRight null, -- facility
         @c_XStorerkey,   -- Storerkey
         null,            -- Sku
         'OWITF',         -- Configkey
         @b_success    output,
         @c_OWITF      output,
         @n_err        output,
         @c_errmsg     output

         IF @b_success <> 1
         BEGIN
            SELECT @n_continue = 3, @c_errmsg = 'ntrLoadPlanUpdate' + RTrim(@c_errmsg)
         END

         IF @b_success = 1 AND @c_OWITF = '1'
         BEGIN
            -- Add by June 8.Aug.02
            -- Status 542 for Discrete Prepick is send during Print Discrete Pickslip
            -- Dun send again in LP finalize

            SELECT @b_success = 0
            Execute nspGetRight null, -- facility
            @c_XStorerkey,   -- Storerkey
            null,   -- Sku
            'DPREPICK',-- Configkey
            @b_success    output,
            @c_DPREPICK   output,
            @n_err        output,
            @c_errmsg     output
            IF @b_success <> 1
            BEGIN
               SELECT @n_continue = 3, @c_errmsg = 'ntrLoadPlanUpdate' + RTrim(@c_errmsg)
            END

            IF @n_continue = 1 or @n_continue = 2
            BEGIN
               SELECT @b_success = 0
               Execute nspGetRight null, -- facility
               @c_XStorerkey,   -- Storerkey
               null,   -- Sku
               'DPREPICK+1',-- Configkey
               @b_success    output,
               @c_DPREPICK1  output,
               @n_err        output,
               @c_errmsg     output

               IF @b_success <> 1
               BEGIN
                  SELECT @n_continue = 3, @c_errmsg = 'ntrLoadPlanUpdate' + RTrim(@c_errmsg)
               END
            END

            -- Modified by June 20.Feb.03 FBR9706 -- Cater for storer with no 'DPREPICK/DPREPICK+1' config setup.
            -- IF @b_success = 1 AND @c_DPREPICK <> '1' AND @c_DPREPICK1 <> '1'
            IF @c_DPREPICK <> '1' AND @c_DPREPICK1 <> '1'
            BEGIN
               -- Start - Add by June 20.Feb.03 FBR9706
               IF @n_continue = 1 or @n_continue = 2
               BEGIN
                  IF @c_Userdefine08 = 'Y'
                  BEGIN
                     SELECT @b_success = 0
                     Execute nspGetRight null, -- facility
                     @c_XStorerkey,   -- Storerkey
                     null,   -- Sku
                     'PICK-TRF',-- Configkey
                     @b_success    output,
                     @c_PICKTRF    output,
                     @n_err        output,
                     @c_errmsg     output

                     IF @b_success <> 1
                     BEGIN
                        SELECT @n_continue = 3, @c_errmsg = 'ntrLoadPlanUpdate' + RTrim(@c_errmsg)
                     END
                  END
                  ELSE
                     SELECT @c_PICKTRF = '0'
               END
               -- End - FBR9706

               IF @c_PICKTRF = '0'
               BEGIN
                  EXEC ispGenTransmitLog 'OWLPLAN', @c_XOrderKey, '', '', ''
                  , @b_success OUTPUT
                  , @n_err OUTPUT
                  , @c_errmsg OUTPUT

                  IF @b_success <> 1
                  BEGIN
                     SELECT @n_continue = 3
                     SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72801
                     SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                                      + ': Unable to obtain transmitlogkey (ntrLoadPlanUpdate)'
                                      + ' ( SQLSvr MESSAGE=' + RTrim(@c_errmsg) + ' ) '  
                  END
               END -- DPREPICK & DPREPICK+1 not ON
               ELSE
               BEGIN
                  -- DPREPICK / DPREPICK+1 ON, Insert OWLPLAN for Existing Pending Orders
                  -- Need to remove later, say in 2002 NOV
                  IF EXISTS (SELECT 1 FROM TransmitLog WITH (NOLOCK)
                              WHERE TableName = 'OWORDALLOC' AND Key1 = @c_XOrderKey )
                  BEGIN
                     EXEC ispGenTransmitLog 'OWLPLAN', @c_XOrderKey, '', '', ''
                     , @b_success OUTPUT
                     , @n_err OUTPUT
                     , @c_errmsg OUTPUT

                     IF @b_success <> 1
                     BEGIN
                        SELECT @n_continue = 3
                        SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72802
                        SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                                         + ': Unable to obtain transmitlogkey (ntrLoadPlanUpdate)'
                                         + ' ( SQLSvr MESSAGE=' + RTrim(@c_errmsg) + ' ) '
                     END
                  END -- not exists in transmitlog, OWORDALLOC
               END -- DPREPICK & DPREPICK+1 ON
            END -- @c_DPREPICK <> '1' AND @c_DPREPICK1 <> '1'
         END -- OWITF = '1'

         SELECT @c_ITSITF = '0'
         Execute nspGetRight null, -- facility
                  @c_XStorerkey,   -- Storerkey
                  null,            -- Sku
                  'ITSITF',        -- Configkey
                  @b_success    output,
                  @c_ITSITF      output,
                  @n_err        output,
                  @c_errmsg     output

         IF @b_success <> 1
         BEGIN
            SELECT @n_continue = 3, @c_errmsg = 'ntrLoadPlanUpdate' + RTrim(@c_errmsg)
         END

         IF @b_success = 1 AND @c_ITSITF = '1'
         BEGIN
         -- Added by YokeBeen on 10-March-2002 -- FBR089
            EXEC ispGenTransmitLog 'ITSORD', @c_XLoadKey, '', @c_XOrderKey, ''
                                 , @b_success OUTPUT
                                 , @n_err OUTPUT
                                 , @c_errmsg OUTPUT

            IF @b_success <> 1
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72803
               SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                                + ': Unable to Generate transmitlog Record, TableName = ITSORD (ntrLoadPlanUpdate)'
                                + ' ( SQLSvr MESSAGE=' + RTrim(@c_errmsg) + ' ) '
            END
         END

         -- Added by Shong om 9-Aug-2003 SOS#12796 NIKEHK Interface
         IF EXISTS (SELECT 1 FROM StorerConfig WITH (NOLOCK) WHERE StorerConfig.StorerKey = @c_XStorerkey
                       AND StorerConfig.ConfigKey = 'NIKEHK_LOADPLAN' AND StorerConfig.sValue = '1')
         BEGIN -- End - SOS#12796
            EXEC ispGenTransmitLog 'NIKEHKLP', @c_XLoadKey, '', @c_XOrderKey, ''
                                 , @b_success OUTPUT
                                 , @n_err OUTPUT
                                 , @c_errmsg OUTPUT

            IF @b_success <> 1
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72804
               SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                                + ': Unable to Generate NSCLog Record, TableName = NIKEHKLP (ntrLoadPlanUpdate)'
                                + ' ( SQLSvr MESSAGE=' + RTrim(@c_errmsg) + ' ) '
            END
         END -- End - SOS#12796

         -- Added by YokeBeen on 14-Nov-2003 - Nike Regional Interface (NSC Project)
         -- (SOS#15353) - 'S' - Scheduled. This is the only absolute requirement.
         SELECT @c_NIKEREGITF = 0
         SELECT @b_success = 0

         EXECUTE nspGetRight
                  NULL,            -- Facility
                  @c_XStorerkey,   -- Storerkey
                  NULL,            -- Sku
                  'NIKEREGITF',    -- Configkey
                  @b_success    output,
                  @c_NIKEREGITF output,
                  @n_err        output,
                  @c_errmsg     output

         IF @b_success <> 1
         BEGIN
            SELECT @n_continue = 3, @c_errmsg = 'ntrLoadPlanUpdate' + RTrim(@c_errmsg)
         END

         IF @b_success = 1 AND @c_NIKEREGITF = '1'
         BEGIN
            -- Modified By YokeBeen on 20-Feb-2004 For NIKE Regional (NSC) Project - (SOS#20000)
            -- Changed to trigger records into NSCLog table with 'NSCKEY'.
            EXEC ispGenNSCLog 'NIKEREGDSS', @c_XLoadKey, '', @c_XOrderKey, ''
            , @b_success OUTPUT
            , @n_err OUTPUT
            , @c_errmsg OUTPUT

            IF @b_success <> 1
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72805
               SELECT @c_errmsg = 'NSQL' +CONVERT(char(5),ISNULL(@n_err,0))
                                + ': Unable to Generate NSCLog Record, TableName = NIKEREGDSS (ntrLoadPlanUpdate)'
                                + ' ( SQLSvr MESSAGE=' + RTrim(@c_errmsg) + ' ) '
            END
            -- End Modified By YokeBeen on 20-Feb-2004 For NIKE Regional (NSC) Project (SOS#20000)
         END -- IF @b_success = 1 AND @c_NIKEREGITF = '1'
         -- End - (SOS#15353) - NSC Project
      END -- If update Finalize Flag
      FETCH NEXT FROM C_Loadplan_Add INTO
      @c_XOrderKey,   @c_XStorerkey,  @c_XLoadKey, @c_FinalizeFlag, @c_PreFinFlag, @c_UserDefine08
   END -- while
   CLOSE C_Loadplan_Add
   DEALLOCATE C_Loadplan_Add
END -- continue = 1

-- Start - Added by YokeBeen on 30-Apr-2002 (FBR089)
IF @n_continue=1 or @n_continue=2
BEGIN
   IF UPDATE(Finalizeflag) AND
      EXISTS( SELECT 1 FROM INSERTED
              JOIN   LOADPLANRETDETAIL WITH (NOLOCK) ON (INSERTED.Loadkey = LOADPLANRETDETAIL.Loadkey)
              WHERE  INSERTED.FinalizeFlag = 'Y')
   BEGIN
      DECLARE @c_XReceiptKey  NVARCHAR(30)
      SELECT @c_XReceiptKey = SPACE(30)

      DECLARE C_Loadplan_Add CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT LOADPLANRETDETAIL.ReceiptKey,
             RECEIPT.Storerkey,
             LOADPLANRETDETAIL.LoadKey
      FROM   INSERTED
      JOIN   LOADPLANRETDETAIL WITH (NOLOCK) ON (INSERTED.Loadkey = LOADPLANRETDETAIL.Loadkey)
      JOIN   RECEIPT WITH (NOLOCK) ON (LOADPLANRETDETAIL.Receiptkey = RECEIPT.Receiptkey
                                   AND LOADPLANRETDETAIL.Loadkey = RECEIPT.Loadkey)
      JOIN   StorerConfig WITH (NOLOCK) ON (RECEIPT.StorerKey = StorerConfig.StorerKey
      AND    StorerConfig.ConfigKey = 'OWITF' AND StorerConfig.sValue = '1')
      WHERE  INSERTED.FinalizeFlag = 'Y'
      ORDER BY LOADPLANRETDETAIL.ReceiptKey

      OPEN C_Loadplan_Add

      FETCH NEXT FROM C_Loadplan_Add INTO @c_XReceiptKey, @c_XStorerkey, @c_XLoadKey

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         -- Start : SOS40637
         -- IF @@ROWCOUNT = 0
         -- BREAK
         -- End : SOS40637

         IF NOT EXISTS (SELECT 1 FROM TransmitLog WITH (NOLOCK) WHERE TableName = 'ITSRCPT'
                        AND    Key3 = @c_XReceiptKey )
         BEGIN
            SELECT @b_success = 1

            EXEC ispGenTransmitLog 'ITSRCPT', @c_XLoadKey, '', @c_XReceiptKey, ''
                  , @b_success OUTPUT
                  , @n_err OUTPUT
                  , @c_errmsg OUTPUT

            IF @b_success <> 1
            BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72806
               SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err)
                                + ': Unable to Generate transmitlog Record, TableName = ITSRCPT (ntrLoadPlanUpdate)'
                                + ' ( SQLSvr MESSAGE=' + RTrim(@c_errmsg) + ' ) '
            END
         END -- not exists in transmitlog, ITSRCPT
         FETCH NEXT FROM C_Loadplan_Add INTO @c_XReceiptKey, @c_XStorerkey, @c_XLoadKey
      END -- while
      CLOSE C_Loadplan_Add
      DEALLOCATE C_Loadplan_Add

      --MC02 - S
      SELECT TOP 1 @c_XStorerkey = RECEIPT.Storerkey
                 , @c_XLoadKey = LOADPLANRETDETAIL.LoadKey
      FROM   INSERTED
      JOIN   LOADPLANRETDETAIL WITH (NOLOCK) 
      ON     (INSERTED.Loadkey = LOADPLANRETDETAIL.Loadkey)
      JOIN   RECEIPT WITH (NOLOCK) 
      ON     (LOADPLANRETDETAIL.Receiptkey = RECEIPT.Receiptkey
              AND LOADPLANRETDETAIL.Loadkey = RECEIPT.Loadkey)
      WHERE  INSERTED.FinalizeFlag = 'Y'

      SELECT @c_LOADFRCLOG = 0
      SELECT @b_success = 0

      EXECUTE nspGetRight
               NULL,                  -- Facility
               @c_XStorerkey,         -- Storerkey
               NULL,                  -- Sku
               'LOADFRCLOG',          -- Configkey
               @b_success    output,
               @c_LOADFRCLOG output,
               @n_err        output,
               @c_errmsg     output

      IF @b_success <> 1
      BEGIN
         SELECT @n_continue = 3, @c_errmsg = 'ntrLoadPlanUpdate' + RTrim(@c_errmsg) 
      END

      IF @b_success = 1 AND @c_LOADFRCLOG = '1'
      BEGIN
         EXEC ispGenTransmitLog3 'LOADFRCLOG', @c_XLoadKey, '', @c_XStorerkey, ''
                                 , @b_success OUTPUT
                                 , @n_err OUTPUT
                                 , @c_errmsg OUTPUT

         IF @b_success <> 1
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72808
            SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                             + ': Unable to Generate CMSLog Record, TableName = LOADFNZLOG (ntrLoadPlanUpdate)'
                             + ' ( SQLSvr MESSAGE=' + RTrim(@c_errmsg) + ' ) '
         END
      END -- IF @b_success = 1 AND @c_LPPKCFMCMS = '1'
      --MC02 - E
   END -- Update FinalizeFlag
END -- End - FBR089

-- Added for IDSV5 by June 26.Jun.02, (extract from IDSHK) *** Start
IF @n_continue=1 or @n_continue=2
BEGIN
   DECLARE @c_CurrentLoad NVARCHAR(10)
         , @c_Status      NVARCHAR(1)
         , @c_LPStatus    NVARCHAR(1)

   DECLARE
      @n_Alloc_CaseCnt     int,
      @n_Alloc_PalletCnt   int,
      @n_Alloc_Weight      float,
      @n_Alloc_Cube        float,
      @n_Alloc_CustCnt     int,
      @n_Alloc_OrderCnt    int

   SELECT @c_CurrentLoad = SPACE(10)

   DECLARE C_Loadplan_Add CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
    SELECT INSERTED.LoadKey, INSERTED.Status, INSERTED.FinalizeFlag, INSERTED.EditWho
      FROM INSERTED
     ORDER BY INSERTED.LoadKey

   OPEN C_Loadplan_Add

   FETCH NEXT FROM C_Loadplan_Add INTO @c_CurrentLoad, @c_LPStatus, @c_FinalizeFlag, @c_EditWho

   WHILE @@FETCH_STATUS <> -1
   BEGIN
      -- (YokeBeen02) - Start
      DECLARE @c_CurrentStorerKey NVARCHAR(15)
            , @c_CurrentFacility NVARCHAR(5)
      SET @c_CurrentStorerKey = ''
      SET @c_CurrentFacility = ''

      SELECT @c_Status = ''
      -- SOS# 171476 (Start)
      -- SELECT @c_Status = CASE
      --                       WHEN MAX(LOADPLANDETAIL.Status) = '0'
      --                          THEN '0'
      --                       WHEN MIN(LOADPLANDETAIL.Status) = '0' and MAX(LOADPLANDETAIL.Status) >= '1'
      --                          THEN '1'
      --                       ELSE MIN(LOADPLANDETAIL.Status)
      --                    END
      --   , @c_CurrentStorerKey = ORDERS.Storerkey
      --   , @c_CurrentFacility = LOADPLAN.Facility
      -- FROM LOADPLANDETAIL WITH (NOLOCK)
      -- JOIN LOADPLAN WITH (NOLOCK) ON (LOADPLANDETAIL.LoadKey = LOADPLAN.LoadKey)
      -- JOIN ORDERS WITH (NOLOCK) ON (ORDERS.OrderKey = LOADPLANDETAIL.OrderKey)
      -- WHERE LOADPLANDETAIL.Loadkey = @c_CurrentLoad
      -- GROUP BY ORDERS.Storerkey, LOADPLAN.Facility

      --(TL01) - S
      /*
      SELECT @c_Status = CASE
                           WHEN MAX(Status) = '0'
                              THEN '0'
                           WHEN MIN(Status) = '0' and MAX(Status) >= '1'
                              THEN '1'
                           ELSE MIN(Status)
                         END
      FROM  LOADPLANDETAIL WITH (NOLOCK)
      WHERE Loadkey = @c_CurrentLoad
      */

   	SELECT @c_LP_Min_Status = '0', 
   	       @c_LP_Max_Status = '0' 
   	             	
   	SELECT @c_LP_Min_Status = MIN(STATUS), 
   	       @c_LP_Max_Status = MAX(STATUS) 
   	FROM   LoadPlanDetail AS lpd WITH (NOLOCK)
   	WHERE  lpd.LoadKey = @c_CurrentLoad 
   	AND    lpd.[Status] NOT IN ('CANC')      	      

      SET @c_Status = CASE
                       WHEN @c_LP_Max_Status = '0' THEN '0'
                       WHEN @c_LP_Min_Status = '0' and @c_LP_Max_Status IN ('1','2')
                          THEN '1'
                       WHEN @c_LP_Min_Status IN ('0','1','2') AND @c_LP_Max_Status IN ('3','5')
                          THEN '3'
                       ELSE @c_LP_Min_Status
                    END  
      --(TL01) - E

      -- TLTING    1.10   Performance Tuning      
      SELECT TOP 1 @c_CurrentStorerKey = (ORDERS.Storerkey)  
                 , @c_CurrentFacility = (LOADPLAN.Facility)  
      FROM LOADPLAN WITH (NOLOCK)  
      JOIN LOADPLANDETAIL WITH (NOLOCK) ON (LOADPLANDETAIL.Loadkey = LOADPLAN.Loadkey)   --TLTING02
      JOIN ORDERS WITH (NOLOCK) ON (ORDERS.Orderkey = LOADPLANDETAIL.Orderkey)  
      WHERE LOADPLAN.Loadkey = @c_CurrentLoad   


      DECLARE @cDoNotCalcLPAllocInfo VARCHAR(10)  
  
      SET @cDoNotCalcLPAllocInfo = ''  
  
      SELECT @cDoNotCalcLPAllocInfo = ISNULL(sValue, '0')   
      FROM  STORERCONFIG WITH (NOLOCK)   
      WHERE StorerKey = @c_CurrentStorerKey   
      AND   ConfigKey = 'DoNotCalcLPAllocInfo'   
      AND   sVAlue = '1'  

      -- SOS# 171476 (End)
            
      IF ISNULL(RTRIM(@c_LPStatus),'') < '9'     
      BEGIN
         -- if status is null means no loadplan detail... stop process  
         IF ISNULL(RTrim(@c_Status),'') <> ''  
         BEGIN  
            SET @n_Alloc_CaseCnt     =0  
            SET @n_Alloc_PalletCnt   =0  
            SET @n_Alloc_Weight      =0  
            SET @n_Alloc_Cube        =0  
            SET @n_Alloc_CustCnt     =0  
            SET @n_Alloc_OrderCnt    =0  
            
            -- only get the allocated info when order detail status > 0
            IF @c_Status > '0' AND @c_LPStatus < '5' AND @cDoNotCalcLPAllocInfo <> '1'  
            BEGIN
               -- tlting01
               SELECT @n_Alloc_PalletCnt =     
                         CONVERT(Integer, SUM(CASE WHEN PACK.Pallet = 0 THEN 0    
                         ELSE ((OrderDetail.QtyAllocated + OrderDetail.QtyPicked) / PACK.Pallet) END)),    
                      @n_Alloc_CaseCnt =     
                         CONVERT(Integer, SUM(CASE WHEN PACK.CaseCnt = 0 THEN 0    
                         ELSE ((OrderDetail.QtyAllocated + OrderDetail.QtyPicked) / PACK.CaseCnt) END)),    
                      @n_Alloc_Cube = SUM((ORDERDETAIL.QtyAllocated + OrderDetail.QtyPicked) * ROUND(SKU.StdCube,6)), -- SOS 85340    
                      @n_Alloc_Weight = SUM((OrderDetail.QtyAllocated + OrderDetail.QtyPicked) * SKU.StdGrossWgt)
             FROM LoadPlanDetail WITH (NOLOCK)    
                 JOIN ORDERDETAIL WITH (NOLOCK) ON (ORDERDETAIL.OrderKey = LoadPlanDetail.OrderKey)     
                 JOIN PACK WITH (NOLOCK) ON (ORDERDETAIL.Packkey = PACK.Packkey)    
                 JOIN SKU WITH (NOLOCK, INDEX (PKSKU) ) ON (ORDERDETAIL.Storerkey = SKU.Storerkey AND ORDERDETAIL.SKU = SKU.SKU)     
                WHERE LoadPlandetail.LoadKey = @c_CurrentLoad     
                  AND (ORDERDETAIL.QtyAllocated + OrderDetail.QtyPicked + ORDERDETAIL.ShippedQty) > 0     
  
               SELECT @n_Alloc_OrderCnt = COUNT(DISTINCT LoadPlanDetail.OrderKey),    
                      @n_Alloc_CustCnt = COUNT(DISTINCT  LoadPlanDetail.ConsigneeKey)    
                 FROM LoadPlanDetail WITH (NOLOCK)    
                WHERE LoadPlandetail.LoadKey = @c_CurrentLoad     
                
               IF @n_Alloc_CaseCnt   IS NULL SELECT @n_Alloc_CaseCnt = 0
               IF @n_Alloc_Weight    IS NULL SELECT @n_Alloc_Weight = 0
               IF @n_Alloc_Cube      IS NULL SELECT @n_Alloc_Cube = 0
               IF @n_Alloc_OrderCnt  IS NULL SELECT @n_Alloc_OrderCnt = 0
               IF @n_Alloc_PalletCnt IS NULL SELECT @n_Alloc_PalletCnt = 0
               IF @n_Alloc_CustCnt   IS NULL SELECT @n_Alloc_CustCnt = 0
               
            END --IF @c_Status > '0' AND @c_LPStatus < '5' AND @cDoNotCalcLPAllocInfo <> '1'  

            IF @c_FinalizeLP =  '1'
            BEGIN
               IF @c_FinalizeFlag <> 'Y' OR @c_LPStatus > '5'
                  SELECT @c_Status = @c_LPStatus
            END
            ELSE
            BEGIN
               IF @c_LPStatus > '5'
                  SELECT @c_Status = @c_LPStatus
            END

            IF @c_LPStatus < '5'  -- Update only allocate order
            BEGIN
               
               SET @c_StatusUpdated = 'Y' -- (MC04)
               
               UPDATE LoadPlan  
                  SET AllocatedCustCnt   = @n_Alloc_CustCnt,
                      AllocatedOrderCnt  = @n_Alloc_OrderCnt,
                      AllocatedWeight    = @n_Alloc_Weight,
                      AllocatedCube      = @n_Alloc_Cube,
                      AllocatedPalletCnt = @n_Alloc_PalletCnt,
                      AllocatedCaseCnt   = @n_Alloc_CaseCnt,
                      Status = @c_Status,
                      EditDate = GETDATE(),  --tlting
                      EditWho = SUSER_SNAME(),
                      trafficcop = NULL
               WHERE LoadKey = @c_CurrentLoad
            END
            ELSE                 -- else only update status
            BEGIN

               SET @c_StatusUpdated = 'Y' -- (MC04)

               UPDATE LoadPlan  
                  SET Status = @c_Status,
                      EditWho = SUSER_SNAME(),
                      trafficcop = NULL,
                      EditDate = GETDATE()  --tlting
               WHERE LoadKey = @c_CurrentLoad               
            END

            SELECT @n_err = @@ERROR
            IF @n_err <> 0
                  BEGIN
               SELECT @n_continue = 3
               SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 72807
               SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                                + ': Unable to Update LoadPlan table (ispUpdateAllocatedLoad)'
                                + ' ( SQLSvr MESSAGE=' + RTrim(@c_errmsg) + ' ) '
            END
         END -- STATUS Not = BLANK 
      END -- IF ISNULL(RTRIM(@c_LPStatus),'') < '9'

      -- CMS Project Start - (YokeBeen01)
      IF @n_continue = 1 OR @n_continue = 2
      BEGIN
         IF @c_Status = '5'
         BEGIN
            SELECT @c_LPPKCFMCMS = 0
            SELECT @b_success = 0

            EXECUTE nspGetRight
                     NULL,                  -- Facility
                     @c_CurrentStorerKey,   -- Storerkey
                     NULL,                  -- Sku
                     'LPPKCFMCMS',          -- Configkey
                     @b_success    output,
                     @c_LPPKCFMCMS output,
                     @n_err        output,
                     @c_errmsg     output

            IF @b_success <> 1
            BEGIN
               SELECT @n_continue = 3, @c_errmsg = 'ntrLoadPlanUpdate' + RTrim(@c_errmsg) 
            END

            IF @b_success = 1 AND @c_LPPKCFMCMS = '1'
            BEGIN
               EXEC ispGenCMSLog 'LPPKCFMCMS', @c_CurrentLoad, 'L', @c_CurrentStorerKey, ''
                                 , @b_success OUTPUT
                                 , @n_err OUTPUT
                                 , @c_errmsg OUTPUT

               IF @b_success <> 1
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72808
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                                   + ': Unable to Generate CMSLog Record, TableName = LPPKCFMCMS (ntrLoadPlanUpdate)'
                                   + ' ( SQLSvr MESSAGE=' + RTrim(@c_errmsg) + ' ) '
               END
            END -- IF @b_success = 1 AND @c_LPPKCFMCMS = '1'
         END -- IF @c_Status = '5'
         ELSE IF @c_Status = '9'
         BEGIN
            SELECT @c_LPSHPCFMCMS = 0
            SELECT @b_success = 0

            EXECUTE nspGetRight
                     NULL,                  -- Facility
                     @c_CurrentStorerKey,   -- Storerkey
                     NULL,                  -- Sku
                     'LPSHPCFMCMS',         -- Configkey
                     @b_success     output,
                     @c_LPSHPCFMCMS output,
                     @n_err         output,
                     @c_errmsg      output

            IF @b_success <> 1
            BEGIN
               SELECT @n_continue = 3, @c_errmsg = 'ntrLoadPlanUpdate' + RTrim(@c_errmsg) 
            END

            IF @b_success = 1 AND @c_LPSHPCFMCMS = '1'
            BEGIN
               EXEC ispGenCMSLog 'LPSHPCFMCMS', @c_CurrentLoad, 'L', @c_CurrentStorerKey, ''
                                 , @b_success OUTPUT
                                 , @n_err OUTPUT
                                 , @c_errmsg OUTPUT

               IF @b_success <> 1
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72809
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                                   + ': Unable to Generate CMSLog Record, TableName = LPSHPCFMCMS (ntrLoadPlanUpdate)'
                                   + ' ( SQLSvr MESSAGE=' + RTrim(@c_errmsg) + ' ) '  
               END
            END -- IF @b_success = 1 AND @c_LPSHPCFMCMS = '1'
         -- CMS Project End - (YokeBeen01)


            SELECT @c_LoadShpLog = 0
            SELECT @b_success = 0

            EXECUTE nspGetRight
                     NULL,                 -- Facility
                     @c_CurrentStorerKey,  -- Storerkey
                     NULL,                 -- Sku
                     'LOADSHPLOG',         -- Configkey
                     @b_success     output,
                     @c_LoadShpLog  output,
                     @n_err         output,
                     @c_errmsg      output

            IF @b_success <> 1
            BEGIN
               SELECT @n_continue = 3, @c_errmsg = 'ntrLoadPlanUpdate' + RTrim(@c_errmsg) 
            END

            IF @b_success = 1 AND @c_LoadShpLog = '1'
            BEGIN
               EXEC ispGenTransmitLog3 'LOADSHPLOG', @c_CurrentLoad, @c_CurrentFacility, @c_CurrentStorerKey, ''
                                       , @b_success OUTPUT
                                       , @n_err OUTPUT
                                       , @c_errmsg OUTPUT

               IF @b_success <> 1
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72810
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                                   + ': Unable to Generate TransmitLog3 Record, TableName = LOADSHPLOG (ntrLoadPlanUpdate)'
                                   + ' ( SQLSvr MESSAGE=' + RTrim(@c_errmsg) + ' ) ' 
               END
            END -- IF @b_success = 1 AND @c_LoadShpLog = '1'

            -- Update Staging Lane on LoadPlanLaneDetail -- START (ChewKP01)
            IF EXISTS (SELECT 1 FROM LOADPLANLANEDETAIL LPL WITH (NOLOCK)
                       WHERE LPL.Loadkey = @c_CurrentLoad
                       AND LPL.Status = '0')
            BEGIN
               Update LoadPlanLaneDetail  
                  SET Status = '9',
                      EditDate = GETDATE(),        --tlting
                      EditWho = SUSER_SNAME()
               Where Loadkey = @c_CurrentLoad
               AND   Status = '0' -- (Vicky01)
            END
            -- Update Staging Lane on LoadPlanLaneDetail -- END(ChewKP01)


         END -- ELSE IF @c_Status = '9'
      END -- IF @n_continue = 1 OR @n_continue = 2
      -- (YokeBeen02) - End
   
      --MC01 - S
      IF @n_continue = 1 OR @n_continue = 2
      BEGIN
         IF UPDATE(Finalizeflag) AND @c_FinalizeFlag = 'Y'
         BEGIN
            SELECT @c_LOADFNZLOG = 0
            SELECT @b_success = 0

            EXECUTE nspGetRight
                     NULL,                  -- Facility
                     @c_CurrentStorerKey,   -- Storerkey
                     NULL,                  -- Sku
                     'LOADFNZLOG',          -- Configkey
                     @b_success    output,
                     @c_LOADFNZLOG output,
                     @n_err        output,
                     @c_errmsg     output

            IF @b_success <> 1
            BEGIN
               SELECT @n_continue = 3, @c_errmsg = 'ntrLoadPlanUpdate' + RTrim(@c_errmsg) 
            END

            IF @b_success = 1 AND @c_LOADFNZLOG = '1'
            BEGIN
               EXEC ispGenTransmitLog3 'LOADFNZLOG', @c_CurrentLoad, @c_CurrentFacility, @c_CurrentStorerKey, ''
                                       , @b_success OUTPUT
                                       , @n_err OUTPUT
                                       , @c_errmsg OUTPUT

               IF @b_success <> 1
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72808
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                                   + ': Unable to Generate CMSLog Record, TableName = LOADFNZLOG (ntrLoadPlanUpdate)'
                                   + ' ( SQLSvr MESSAGE=' + RTrim(@c_errmsg) + ' ) '
               END
            END -- IF @b_success = 1 AND @c_LPPKCFMCMS = '1'
         END
      END
      --MC01 - E

      FETCH NEXT FROM C_Loadplan_Add INTO @c_CurrentLoad, @c_LPStatus, @c_FinalizeFlag, @c_EditWho
   END -- While 1=1
   CLOSE C_Loadplan_Add
   DEALLOCATE C_Loadplan_Add
END

-- (MC03) - S  
/********************************************************/  
/* Interface Trigger Points Calling Process - (Start)   */  
/********************************************************/  
IF @n_continue = 1 OR @n_continue = 2   
BEGIN  
   /*      
   DECLARE Cur_TriggerPoints CURSOR LOCAL FAST_FORWARD READ_ONLY FOR   
   SELECT DISTINCT INS.LoadKey, OH.StorerKey
   FROM   INSERTED INS 
   JOIN   LoadPlanDetail LD WITH (NOLOCK)    ON INS.LoadKey = LD.LoadKey  
   JOIN   Orders OH WITH (NOLOCK)            ON LD.OrderKey = OH.OrderKey  
   JOIN   ITFTriggerConfig ITC WITH (NOLOCK) ON ITC.StorerKey = OH.StorerKey  
   WHERE  ITC.SourceTable = 'LOADPLAN'  
   AND    ITC.sValue      = '1'       

   OPEN Cur_TriggerPoints  
   FETCH NEXT FROM Cur_TriggerPoints INTO @c_LoadKey, @c_Storerkey

   WHILE @@FETCH_STATUS <> -1  
   BEGIN  
      EXECUTE dbo.isp_ITF_ntrLoadPlan 
                 @c_TriggerName    = 'ntrLoadPlanUpdate'
               , @c_SourceTable    = 'LOADPLAN'  
               , @c_Storerkey      = @c_Storerkey
               , @c_LoadKey        = @c_LoadKey  
               , @b_ColumnsUpdated = @b_ColumnsUpdated    
               , @b_Success        = @b_Success   OUTPUT  
               , @n_err            = @n_err       OUTPUT  
               , @c_errmsg         = @c_errmsg    OUTPUT  

      FETCH NEXT FROM Cur_TriggerPoints INTO @c_LoadKey, @c_Storerkey
   END -- WHILE @@FETCH_STATUS <> -1  
   CLOSE Cur_TriggerPoints  
   DEALLOCATE Cur_TriggerPoints  

   DECLARE Cur_TriggerPoints CURSOR LOCAL FAST_FORWARD READ_ONLY FOR   
   SELECT DISTINCT INS.LoadKey, OH.StorerKey
   FROM   INSERTED INS 
   JOIN   LoadPlanDetail LD WITH (NOLOCK)    ON INS.LoadKey = LD.LoadKey  
   JOIN   Orders OH WITH (NOLOCK)            ON LD.OrderKey = OH.OrderKey    
   JOIN   ITFTriggerConfig ITC WITH (NOLOCK) ON ITC.StorerKey = 'ALL'  
   JOIN   StorerConfig STC WITH (NOLOCK)     ON OH.StorerKey = STC.StorerKey AND STC.ConfigKey = ITC.ConfigKey AND STC.SValue = '1'   
   WHERE  ITC.SourceTable = 'LOADPLAN'  
   AND    ITC.sValue      = '1'        

   OPEN Cur_TriggerPoints  
   FETCH NEXT FROM Cur_TriggerPoints INTO @c_LoadKey, @c_Storerkey

   WHILE @@FETCH_STATUS <> -1  
   BEGIN  
      EXECUTE dbo.isp_ITF_ntrLoadPlan  
                 @c_TriggerName    = 'ntrLoadPlanUpdate'
               , @c_SourceTable    = 'LOADPLAN'  
               , @c_Storerkey      = @c_Storerkey
               , @c_LoadKey        = @c_LoadKey  
               , @b_ColumnsUpdated = @b_ColumnsUpdated    
               , @b_Success        = @b_Success   OUTPUT  
               , @n_err            = @n_err       OUTPUT  
               , @c_errmsg         = @c_errmsg    OUTPUT  

      FETCH NEXT FROM Cur_TriggerPoints INTO @c_LoadKey, @c_Storerkey
   END -- WHILE @@FETCH_STATUS <> -1  
   CLOSE Cur_TriggerPoints  
   DEALLOCATE Cur_TriggerPoints 
   */

   --(MC04) - S
   DECLARE Cur_TriggerPoints CURSOR LOCAL FAST_FORWARD READ_ONLY FOR   
   SELECT DISTINCT INS.LoadKey, OH.StorerKey
   FROM   INSERTED INS 
   JOIN   LoadPlanDetail LD WITH (NOLOCK) ON INS.LoadKey = LD.LoadKey  
   JOIN   Orders OH WITH (NOLOCK)         ON LD.OrderKey = OH.OrderKey  

   OPEN Cur_TriggerPoints  
   FETCH NEXT FROM Cur_TriggerPoints INTO @c_LoadKey, @c_Storerkey

   WHILE @@FETCH_STATUS <> -1  
   BEGIN

      SET @c_Proceed = 'N'

      IF EXISTS ( SELECT 1 
   	            FROM  ITFTriggerConfig ITC WITH (NOLOCK)       
   	            WHERE ITC.StorerKey   = @c_Storerkey
   	            AND   ITC.SourceTable = 'LOADPLAN'  
                  AND   ITC.sValue      = '1' )
      BEGIN
         SET @c_Proceed = 'Y'           
      END

      -- For OTMLOG StorerKey = 'ALL'
   	IF EXISTS ( SELECT 1 
   	            FROM  StorerConfig STC WITH (NOLOCK)        
   	            WHERE STC.StorerKey = @c_Storerkey 
   	            AND   STC.SValue    = '1' 
   	            AND   EXISTS(SELECT 1 
                               FROM  ITFTriggerConfig ITC WITH (NOLOCK)
   	                         WHERE ITC.StorerKey   = 'ALL' 
   	                         AND   ITC.SourceTable = 'LOADPLAN'  
                               AND   ITC.sValue      = '1' 
                               AND   ITC.ConfigKey = STC.ConfigKey ) )
      BEGIN                  
         SET @c_Proceed = 'Y'                          	
      END       

      IF @c_Proceed = 'Y'
      BEGIN

         --(MC05) - S
         SET @c_ColumnsUpdated = ''

         IF UPDATE(Status) OR @c_StatusUpdated = 'Y' 
         BEGIN
            IF @c_ColumnsUpdated = ''
            BEGIN
               SET @c_ColumnsUpdated = 'Status'
            END
            ELSE
            BEGIN
               SET @c_ColumnsUpdated = @c_ColumnsUpdated + ',' + 'Status'
            END
         END

         /*
         SET @c_ColumnsUpdated = ''    

         DECLARE Cur_ColUpdated CURSOR LOCAL FAST_FORWARD READ_ONLY FOR   
         SELECT COLUMN_NAME FROM dbo.fnc_GetUpdatedColumns('LOADPLAN', @b_ColumnsUpdated) 
         OPEN Cur_ColUpdated  
         FETCH NEXT FROM Cur_ColUpdated INTO @c_COLUMN_NAME
         WHILE @@FETCH_STATUS <> -1  
         BEGIN  

            IF @c_ColumnsUpdated = ''
            BEGIN
               SET @c_ColumnsUpdated = @c_COLUMN_NAME
            END
            ELSE
            BEGIN
               SET @c_ColumnsUpdated = @c_ColumnsUpdated + ',' + @c_COLUMN_NAME
            END

            FETCH NEXT FROM Cur_ColUpdated INTO @c_COLUMN_NAME
         END -- WHILE @@FETCH_STATUS <> -1  
         CLOSE Cur_ColUpdated  
         DEALLOCATE Cur_ColUpdated  

         IF @c_StatusUpdated = 'Y' 
         BEGIN
            IF @c_ColumnsUpdated = ''
            BEGIN
               SET @c_ColumnsUpdated = 'STATUS'
            END
            ELSE
            BEGIN
               SET @c_ColumnsUpdated = @c_ColumnsUpdated + ',' + 'STATUS'
            END
         END
         */
         --(MC05) - E

         EXECUTE dbo.isp_ITF_ntrLoadPlan  
                    @c_TriggerName    = 'ntrLoadPlanUpdate'
                  , @c_SourceTable    = 'LOADPLAN'  
                  , @c_Storerkey      = @c_Storerkey
                  , @c_LoadKey        = @c_LoadKey  
                  --, @b_ColumnsUpdated = @b_ColumnsUpdated   
                  , @c_ColumnsUpdated = @c_ColumnsUpdated                           
                  , @b_Success        = @b_Success   OUTPUT  
                  , @n_err            = @n_err       OUTPUT  
                  , @c_errmsg         = @c_errmsg    OUTPUT 
      END

      FETCH NEXT FROM Cur_TriggerPoints INTO @c_LoadKey, @c_Storerkey
   END -- WHILE @@FETCH_STATUS <> -1  
   CLOSE Cur_TriggerPoints  
   DEALLOCATE Cur_TriggerPoints 
   --(MC04) - E

END -- IF @n_continue = 1 OR @n_continue = 2   
/********************************************************/  
/* Interface Trigger Points Calling Process - (End)     */  
/********************************************************/  
-- (MC03) - E

-- tlting01
IF ( @n_continue = 1 OR @n_continue = 2 ) AND NOT UPDATE(EditDate)
BEGIN
   UPDATE LoadPlan  
   SET EditDate = GETDATE()
     , EditWho = SUSER_SNAME()
     , TrafficCop = NULL       
   FROM LoadPlan,INSERTED       
   WHERE LoadPlan.LoadKey=INSERTED.LoadKey      
   AND INSERTED.[status] in ( '9', 'C', 'CANC' )

   SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT             

   IF @n_err <> 0      
   BEGIN      
      SELECT @n_continue = 3       
      SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72816      
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On LoadPlan. (ntrLoadPlanUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '      
   END      
END 

--IF @n_continue = 1 OR @n_continue = 2
--BEGIN
-- INSERT INTO T (status)
-- SELECT Status FrOM Inserted
--
--   IF EXISTS (SELECT 1 FROM INSERTED WITH (NOLOCK)
--              WHERE STATUS = '9' )
-- BEGIN
--
-- END
--END

/* #INCLUDE <TRMBOHU2.SQL> */
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
   EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrLoadPlanUpdate'
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
ALTER TABLE [dbo].[LoadPlan] WITH NOCHECK ADD CONSTRAINT [CK_LoadPlan_Loadkey_Numeric] CHECK ((isnumeric([Loadkey])=(1)))
GO
ALTER TABLE [dbo].[LoadPlan] ADD CONSTRAINT [PK_LoadPlan] PRIMARY KEY CLUSTERED ([LoadKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LoadPlan_UserDefine10] ON [dbo].[LoadPlan] ([UserDefine10], [LoadKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[LoadPlan] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[LoadPlan] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[LoadPlan] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[LoadPlan] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[LoadPlan] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Load Plan Header consists of load details with reference to the load size, transporter information, route to be taken, truck size, allocation method', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total allocated case count for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'AllocatedCaseCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total allocated cubic for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'AllocatedCube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total allocated customers for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'AllocatedCustCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total allocated orders for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'AllocatedOrderCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total allocated pallet count for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'AllocatedPalletCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total allocated weight for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'AllocatedWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transporter code. Vendor which performs the transportation', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'CarrierKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total case count for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'CaseCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total cubic count for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total  orders count for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'CustCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'An area where the goods for an order will be moved to before shipment', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Delivery_Zone'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Case Pick Task Dispatch Method', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'DispatchCasePickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'dispatchpalletpickmethod', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'DispatchPalletPickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Piece Pick Task Dispatch Method', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'DispatchPiecePickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Free text - user notes', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Driver'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Not being used', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'DummyRoute'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Load customer reference number', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'ExternLoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Warehouse for the order to withdraw the stock', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Based on storer set-up. If configured, user will not be able to do other tasks after the load is finalized', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'FinalizeFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User Defined #1:', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Load_Userdef1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User Defined #2:', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Load_Userdef2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Load plan unique key. It''s used to identify a specific load plan record. Automatically generated.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'LoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'It consists of Consolidate & Discrete pick method', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'LoadPickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The MBOL unique key', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'MBOLKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total orders count for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'OrderCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', N'OTM Dispatch Date', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'OTM_DispatchDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total pallet count for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'PalletCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Release the tasks to RF', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'PROCESSFLAG'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Expected cubic - to be collected', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Return_Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Expected weight - to be collected', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Return_Weight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The route in which the load will be delivered to', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Route'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The name of the section in the warehouse.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'SectionKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The stauts of loadplan progress : Fully Allocated, Pick in progress, Pick slip printed, Picked, Checked, Closed', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag to indicate whether the orders in the load will be batched for allocation processing i.e. all orders will be consolidated and pick by items', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'SuperOrderFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A room reference or room number where the goods will be transferred to before truck loading', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'TrfRoom'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Truck Type will be ordered for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Truck_Type'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Truck Size', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'TruckSize'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Vehicle Type', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Vehicle_Type'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Maximum volume for the load - calculated in batch planning only', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'volumelimit'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total weight count for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Weight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Maximum weight for the load - calculated in batch planning only', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'weightlimit'
GO
