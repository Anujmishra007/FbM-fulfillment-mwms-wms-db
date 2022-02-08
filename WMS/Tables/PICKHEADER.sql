CREATE TABLE [dbo].[PICKHEADER]
(
[PickHeaderKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_WaveKey] DEFAULT (' '),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_OrderKey] DEFAULT (' '),
[ExternOrderKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_ExternOrderKey] DEFAULT (' '),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_StorerKey] DEFAULT (' '),
[ConsigneeKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_ConsigneeKey] DEFAULT (' '),
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_Priority] DEFAULT ('5'),
[Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_Type] DEFAULT ('5'),
[Zone] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_Zone] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_Status] DEFAULT ('0'),
[PickType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_PickType] DEFAULT ('3'),
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_PICKHEADER_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PICKHEADER_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PICKHEADER_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PICKHEADER_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConsoOrderKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PICKHEADER_LoadKey] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/************************************************************************/
/* Trigger: ntrPickHeaderAdd                                            */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by: James                                                    */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By: When Add Pick Header Record                               */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver.  Purposes                                */
/* 23-Oct-2007  James     1.0   SOS80716 - When discrete pickslip is    */
/*                              printed and configkey 'TMSOutOrdHDR' is */
/*                              ON then Gen TMSLog for TMSHK.           */
/* 26-Mar-2009  YokeBeen  1.1   Added Trigger Point for CMS Project.    */
/*                              (SOS#170507) - (YokeBeen01)             */
/* 15-Sep-2015  NJOW01    1.2   352837 - update pickslip# to pickdetail */
/* 11-Oct-2016  TLTING01  1.3   Perfromance Tune                        */
/* 26-Jan-2108  MCTang    1.3   Enhance Generaic Trigger Interface(MC01)*/
/************************************************************************/

CREATE TRIGGER [dbo].[ntrPickHeaderAdd]
ON  [dbo].[PICKHEADER]
FOR INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
           @b_Success              int       -- Populated by calls to stored procedures - was the proc successful?
         , @n_err                  int       -- Error number returned by stored procedure or this trigger
         , @n_err2                 int       -- For Additional Error Detection
         , @c_errmsg               NVARCHAR(250) -- Error message returned by stored procedure or this trigger
         , @n_continue             int                 
         , @n_starttcnt            int       -- Holds the current transaction count
         , @n_cnt                  int                  
         , @c_authority_tms        NVARCHAR(1) 
         , @c_Tablename            NVARCHAR(30) 
         , @c_StorerKey            NVARCHAR(15)
         , @c_orderkey             NVARCHAR(10)
         , @c_UserDefine08         NVARCHAR(10)
         , @c_authority            NVARCHAR(1) 
         , @n_TMSFleetWise         int 
         , @c_auth_LPALLOCCMS      NVARCHAR(1)   -- (YokeBeen01) 
         , @c_LoadKey              NVARCHAR(10)  -- (YokeBeen01) 
         , @c_UpdPickslipToPickDet NVARCHAR(10)  --NJOW01
         , @c_Facility             NVARCHAR(5)   --NJOW01
         , @c_Pickheaderkey        NVARCHAR(10)  --NJOW01
         , @c_Proceed              CHAR(1)       --(MC01)

   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

   DECLARE @b_ColumnsUpdated VARBINARY(1000)       --(MC01)      
   SET @b_ColumnsUpdated = COLUMNS_UPDATED()       --(MC01)

   SET @c_Proceed = ''                             --(MC01)

   /* #INCLUDE <TRPHU1.SQL> */     
   IF @n_continue=1 or @n_continue=2
   BEGIN
	   --Added by James on 18/10/2007 SOS#80716 Start
      --check wether configkey has been setup for 'TMS_Fleetwise'
      EXEC nspGetRight 
            NULL,   -- Facility
            NULL,   -- Storer
            NULL,   -- No Sku in this Case
            'TMS_Fleetwise',	-- ConfigKey
            @b_success    		 output, 
            @c_authority   	 output, 
            @n_err        		 output, 
            @c_errmsg     		 output

      IF @c_authority = '1'
         SET @n_TMSFleetWise = 1 -- has been setup
      ELSE
         SET @n_TMSFleetWise = 0

      -- (YokeBeen01) - Start  
      -- Cursor Loop declaration
	  -- TLTING01
	  IF   EXISTS ( SELECT 1 FROM INSERTED 
					 JOIN ORDERS WITH (NOLOCK) ON (INSERTED.ExternOrderKey = ORDERS.LoadKey)
					WHERE ISNULL(RTRIM(INSERTED.Orderkey),'') = '' )
	  BEGIN
		  DECLARE Cur_PickHeaderAdd CURSOR LOCAL READ_ONLY FAST_FORWARD FOR 			
		   SELECT Orders.Storerkey 
				, Orders.Orderkey  
				, Orders.UserDefine08 
				, INSERTED.ExternOrderKey 
				, Orders.Facility
				, INSERTED.Pickheaderkey
			 FROM INSERTED 
			 JOIN ORDERS WITH (NOLOCK) ON (INSERTED.ExternOrderKey = ORDERS.LoadKey)
			WHERE ISNULL(RTRIM(INSERTED.Orderkey),'') = ''

	  END 
	  ELSE
	  BEGIN
		  DECLARE Cur_PickHeaderAdd CURSOR LOCAL READ_ONLY FAST_FORWARD FOR 			
		   SELECT Orders.Storerkey 
				, INSERTED.Orderkey  
				, Orders.UserDefine08 
				, INSERTED.ExternOrderKey 
				, Orders.Facility --NJOW01
				, INSERTED.Pickheaderkey --NJOW01
			 FROM INSERTED 
			 JOIN ORDERS WITH (NOLOCK) ON (INSERTED.OrderKey = ORDERS.OrderKey)
			WHERE ISNULL(RTRIM(INSERTED.Orderkey),'') <> ''

	  END

      OPEN Cur_PickHeaderAdd
      FETCH NEXT FROM Cur_PickHeaderAdd INTO @c_StorerKey, @c_orderkey, @c_UserDefine08, @c_LoadKey, 
                                             @c_Facility, @c_Pickheaderkey --NJOW01

      WHILE @@FETCH_STATUS <> -1 
      BEGIN
         IF @n_TMSFleetWise = 1
         BEGIN 
            SET @c_authority_tms = '0'

            SELECT @c_authority_tms = ISNULL(sValue, '0')
              FROM StorerConfig WITH (NOLOCK)
             WHERE StorerConfig.StorerKey = @c_StorerKey 
               AND ConfigKey = 'TMSOutOrdHDR'
			
            IF @c_authority_tms = '1' AND @c_UserDefine08 = 'Y'	--make sure is discrete order
            BEGIN
               IF ISNULL(RTRIM(@c_OrderKey),'') <> '' 
               BEGIN 
                  SET @c_Tablename = 'TMSOutOrdHDR'

                  EXEC ispGenTMSLog @c_Tablename, @c_OrderKey, 'A', @c_StorerKey, ''
                                    , @b_success OUTPUT
                                    , @n_err OUTPUT
                                    , @c_errmsg OUTPUT

                  IF @b_success <> 1
                  BEGIN
                     SELECT @n_continue = 3
                     SELECT @c_errmsg = CONVERT(CHAR(250),ISNULL(@n_err,0)), @n_err=68000   
                     SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0)) 
                                      + ': Insert into TMSLog Failed (ntrPickHeaderAdd) ( SQLSvr MESSAGE=' 
                                      + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '
                  END
               END -- IF ISNULL(RTRIM(@c_OrderKey),'') <> '' 
            END -- IF @c_authority_tms = '1' AND @c_UserDefine08 = 'Y' 
         END	--end for @nTMS_Fleetwise = 1
         -- Added by James on 18/10/2007 SOS#80716 End	 

         -- (YokeBeen01) - CMS Interface  
         IF @n_continue=1 or @n_continue=2
         BEGIN
            SELECT @c_auth_LPALLOCCMS = 0
            SELECT @b_success = 0

            EXEC nspGetRight 
                  NULL,           -- Facility
                  @c_StorerKey,   -- Storer
                  NULL,           -- No Sku in this Case
                  'LPALLOCCMS',   -- ConfigKey
                  @b_success           OUTPUT, 
                  @c_auth_LPALLOCCMS   OUTPUT, 
                  @n_err               OUTPUT, 
                  @c_errmsg            OUTPUT

            IF @b_success <> 1
            BEGIN
               SELECT @n_continue = 3, @c_errmsg = 'ntrPickHeaderAdd' + ISNULL(RTRIM(@c_errmsg),'')
            END
         END -- IF @n_continue=1 or @n_continue=2

         IF @b_success = 1 AND @c_auth_LPALLOCCMS = '1'
         BEGIN   
            IF ISNULL(RTRIM(@c_LoadKey),'') <> '' 
            BEGIN 
               EXEC ispGenCMSLOG 'LPALLOCCMS', @c_LoadKey, 'L', @c_StorerKey, ''
                  , @b_success OUTPUT
                  , @n_err OUTPUT
                  , @c_errmsg OUTPUT 

               IF @b_success <> 1
               BEGIN
                  SELECT @n_continue = 3 
                  SELECT @c_errmsg = CONVERT(CHAR(250),ISNULL(@n_err,0)), @n_err=68001   
                  SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0)) 
                                   + ': Insert into CMSLOG Failed (ntrPickHeaderAdd) ( SQLSvr MESSAGE=' 
                                   + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '
               END     
            END -- IF ISNULL(RTRIM(@c_LoadKey),'') <> '' 
         END -- if @b_success = 1 AND @c_auth_LPALLOCCMS = '1' 
         -- (YokeBeen01) - End 
         
         --NJOW01
         IF (@n_continue=1 or @n_continue=2) AND ISNULL(@c_Orderkey,'') <> ''
         BEGIN
            SELECT @c_UpdPickslipToPickDet = ''
            SELECT @b_success = 0

            EXEC nspGetRight 
                  @c_Facility,           -- Facility
                  @c_StorerKey,   -- Storer
                  NULL,           -- No Sku in this Case
                  'UpdPickslipToPickDet',   -- ConfigKey
                  @b_success              OUTPUT, 
                  @c_UpdPickslipToPickDet OUTPUT, 
                  @n_err               OUTPUT, 
                  @c_errmsg            OUTPUT

            IF @b_success <> 1
            BEGIN
               SELECT @n_continue = 3, @c_errmsg = 'ntrPickHeaderAdd' + ISNULL(RTRIM(@c_errmsg),'')
            END
            ELSE IF @c_UpdPickslipToPickDet = '1'
            BEGIN
            	 UPDATE PICKDETAIL WITH (ROWLOCK)
            	 SET Pickslipno = @c_Pickheaderkey,
            	     EditDate = GETDATE(),
            	     TrafficCop = NULL            	
            	 WHERE Orderkey = @c_Orderkey            	            	
            END
         END -- IF @n_continue=1 or @n_continue=2
                  
         FETCH NEXT FROM Cur_PickHeaderAdd INTO @c_StorerKey, @c_orderkey, @c_UserDefine08, @c_LoadKey, 
                                                @c_Facility, @c_Pickheaderkey  --NJOW01
      END -- End for WHILE @@FETCH_STATUS <> -1
      CLOSE Cur_PickHeaderAdd
      DEALLOCATE Cur_PickHeaderAdd
   END -- @n_continue=1 or @n_continue=2

   /********************************************************/  
   /* Interface Trigger Points Calling Process - (Start)   */  
   /********************************************************/  
   --MC01 - S
   IF @n_continue = 1 OR @n_continue = 2   
   BEGIN 

      DECLARE Cur_Itf_TriggerPoints CURSOR LOCAL FAST_FORWARD READ_ONLY FOR                                                                                           
      SELECT DISTINCT IND.PickHeaderKey, OH.StorerKey                                                                    
      FROM   INSERTED IND  
      JOIN   Orders OH WITH (NOLOCK) ON IND.OrderKey = OH.OrderKey 
      WHERE  IND.OrderKey <> '' 
      UNION
      SELECT DISTINCT IND.PickHeaderKey, OH.StorerKey
      FROM   INSERTED IND        
      JOIN   LoadPlanDetail LD WITH (NOLOCK)    ON IND.LoadKey = LD.LoadKey  
      JOIN   Orders OH WITH (NOLOCK)            ON LD.OrderKey = OH.OrderKey  
      WHERE  IND.LoadKey <> ''       
                                                                               
      OPEN Cur_Itf_TriggerPoints
      FETCH NEXT FROM Cur_Itf_TriggerPoints INTO @c_PickHeaderKey, @c_StorerKey

      WHILE @@FETCH_STATUS <> -1
      BEGIN
         SET @c_Proceed = 'N'

         IF EXISTS ( SELECT 1 
   	               FROM  ITFTriggerConfig ITC WITH (NOLOCK)       
   	               WHERE ITC.StorerKey   = @c_Storerkey
   	               AND   ITC.SourceTable = 'PickHeader'  
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
   	                            AND   ITC.SourceTable = 'PickHeader'  
                                  AND   ITC.sValue      = '1' 
                                  AND   ITC.ConfigKey   = STC.ConfigKey ) )
         BEGIN                  
            SET @c_Proceed = 'Y'                          	
         END  

         IF @c_Proceed = 'Y'
         BEGIN
            EXECUTE dbo.isp_ITF_ntrPickHeader   
                     @c_TriggerName    = 'ntrPickHeaderAdd'
                   , @c_SourceTable    = 'PickHeader'  
                   , @c_StorerKey      = @c_StorerKey 
                   , @c_PickHeaderKey  = @c_PickHeaderKey  
                   , @b_ColumnsUpdated = @b_ColumnsUpdated       
                   , @b_Success        = @b_Success OUTPUT  
                   , @n_err            = @n_err    OUTPUT  
                   , @c_errmsg         = @c_errmsg  OUTPUT  
         END

         FETCH NEXT FROM Cur_Itf_TriggerPoints INTO @c_PickHeaderKey, @c_StorerKey
      END -- WHILE @@FETCH_STATUS <> -1
      CLOSE Cur_Itf_TriggerPoints
      DEALLOCATE Cur_Itf_TriggerPoints

   END
   --MC01 - E
   /********************************************************/  
   /* Interface Trigger Points Calling Process - (End)     */  
   /********************************************************/  

   /* #INCLUDE <TRPHU2.SQL> */
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
      EXECUTE dbo.nsp_logerror @n_err, @c_errmsg, 'ntrPickHeaderAdd'
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

/***************************************************************************************/
/* Trigger: ntrPickHeaderDelete                                                        */
/* Creation Date:                                                                      */
/* Copyright: IDS                                                                      */
/* Written by:                                                                         */
/*                                                                                     */
/* Purpose: SOS# 39810 Picklist for KCPI (Philippine)                                  */
/*                                                                                     */
/* Called By:                                                                          */
/*                                                                                     */
/* PVCS Version: 1.2                                                                   */
/*                                                                                     */
/* Version: 5.4.2                                                                      */
/*                                                                                     */
/* Data Modifications:                                                                 */
/*                                                                                     */
/* Updates:                                                                            */
/* Date         Author        Purposes                                                 */
/* 39856        SHONG         Delete REFKEYLOOKUP Records when PickHeader was deleted  */
/* 12-May-2011  KHLim01       Insert Delete log                                        */
/* 14-Jul-2011  KHLim02       GetRight for Delete log                                  */
/* 14-Nov-2016  TLTING        Perfromance tune - delete pickdetail                     */
/***************************************************************************************/
CREATE TRIGGER [dbo].[ntrPickHeaderDelete]
ON [dbo].[PICKHEADER]
FOR DELETE
AS
BEGIN
   IF @@ROWCOUNT = 0
   BEGIN
      RETURN
   END
   DECLARE @b_Success  int,       -- Populated by calls to stored procedures - was the proc successful?
   @n_err              int,       -- Error number returned by stored procedure or this trigger
   @c_errmsg           NVARCHAR(250), -- Error message returned by stored procedure or this trigger
   @n_continue         int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
   @n_starttcnt        int,       -- Holds the current transaction count
   @n_cnt              int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
  ,@c_authority        NVARCHAR(1)  -- KHLim02

   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
      
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   IF (SELECT COUNT(*) from DELETED) = (select count(*) from DELETED where DELETED.ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
   END
   /* #INCLUDE <TRPHD1.SQL> */
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      -- Added By SHONG 26-Jul-2002
      -- Check before update, Reduce Table Blocking
      IF EXISTS(SELECT 1 FROM PickDetail (NOLOCK), Deleted
      WHERE PickDetail.PickHeaderKey=Deleted.PickHeaderKey
      AND PickDetail.PickHeaderKey <> '' )
      BEGIN
         DELETE PickDetail
         FROM PickDetail, Deleted
         WHERE PickDetail.PickHeaderKey=Deleted.PickHeaderKey
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63200   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On PickHeader Failed. (ntrPickHeaderDelete)" + " ( " + " SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + " ) "
         END
      END
   END

   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      -- SOS 6774
      -- Bug fixes for Performance Tuning
      -- Added By SHONG 26-Jul-2002
      -- Check before update, Reduce Table Blocking
      IF EXISTS(SELECT 1 FROM PickingInfo (NOLOCK), Deleted WHERE PickingInfo.PickSlipNo=Deleted.PickHeaderKey)
      BEGIN
         DELETE PickingInfo
         FROM PickingInfo, Deleted
         WHERE PickingInfo.PickSlipNo=Deleted.PickHeaderKey
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63200   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On PickHeader Failed. (ntrPickHeaderDelete)" + " ( " + " SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + " ) "
         END
      END
   END

   -- to re-initialize PickSlipNo no in pickdetail table
   -- WALLY 11.06.00
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      -- Added By SHONG 26-Jul-2002
      -- Check before update, Reduce Table Blocking
      IF EXISTS( SELECT 1 FROM PICKDETAIL (NOLOCK), DELETED WHERE PICKDETAIL.PickSlipNo = DELETED.PickHeaderKey)
      BEGIN
         UPDATE PICKDETAIL
            SET trafficcop = NULL, PickSlipNo = ''
         FROM PICKDETAIL, DELETED
         WHERE PICKDETAIL.PickSlipNo = DELETED.PickHeaderKey
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63200   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On PickHeader Failed. (ntrPickHeaderDelete)" + " ( " + " SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + " ) "
         END
      END
   END


   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      DECLARE @cPickDetailkey NVARCHAR(10)

      -- Added By SHONG 26-Jul-2002
      -- Check before update, Reduce Table Blocking
      DECLARE C_DeleteRefKeyLkup CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT PickDetailKey 
      FROM REFKEYLOOKUP (NOLOCK), DELETED
      WHERE REFKEYLOOKUP.PickSlipNo = DELETED.PickHeaderKey
      ORDER BY PickDetailKey
         
      OPEN C_DeleteRefKeyLkup 
      
      FETCH NEXT FROM C_DeleteRefKeyLkup INTO @cPickDetailkey 
      
      WHILE @@FETCH_STATUS <> -1 AND (@n_continue = 1 or @n_continue = 2)
      BEGIN

         DELETE REFKEYLOOKUP
         WHERE PickDetailKey = @cPickDetailkey 
         
         SELECT @n_err = @@ERROR 

         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 63200   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On PickHeader Failed. (ntrPickHeaderDelete)" + " ( " + " SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + " ) "
         END
         
         FETCH NEXT FROM C_DeleteRefKeyLkup INTO @cPickDetailkey 
      END
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
               ,@c_errmsg = 'ntrPICKHEADERDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.PICKHEADER_DELLOG ( PickHeaderKey )
         SELECT PickHeaderKey FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table PICKHEADER Failed. (ntrPICKHEADERDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END
   -- End (KHLim01) 

   
   /* #INCLUDE <TRPHD2.SQL> */
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrPickHeaderDelete'
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
/***************************************************************************/  
/* Trigger: ntrPickDetailDelete                                            */  
/* Creation Date:                                                          */  
/* Copyright: IDS                                                          */  
/* Written by:                                                             */  
/*                                                                         */  
/* Purpose:                                                                */  
/*                                                                         */  
/* Usage:                                                                  */  
/*                                                                         */  
/* Called By: When records delete from PickDetail                          */  
/*                                                                         */  
/* PVCS Version: 1.9                                                       */  
/*                                                                         */  
/* Version: 5.4                                                            */  
/*                                                                         */  
/* Modifications:                                                          */  
/* Date         Author     Ver.  Purposes                                  */  
/* 17-Mar-2009  TLTING     1.1   Change user_name() to SUSER_SNAME()       */
/* 24-May-2012  TLTING01   1.2   DM integrity - add update editdate B4     */
/*                               TrafficCop check                          */  
/* 28-Oct-2013  TLTING     1.3   Review Editdate column update             */
/***************************************************************************/ 

CREATE TRIGGER [dbo].[ntrPickHeaderUpdate]
 ON  [dbo].[PICKHEADER]
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
 
 IF ( @n_continue=1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
 BEGIN
 UPDATE PickHeader SET EditDate=GETDATE(), EditWho=SUSER_SNAME()
 FROM PickHeader,inserted
 WHERE PickHeader.PickHeaderKey=inserted.PickHeaderKey
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @n_continue = 3
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=63300   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On PickHeader. (ntrPickheaderUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
 END
  
 IF UPDATE(TrafficCop)
 BEGIN
 SELECT @n_continue = 4 
 END

      /* #INCLUDE <TRPHU1.SQL> */     


      /* #INCLUDE <TRPHU2.SQL> */
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
 execute nsp_logerror @n_err, @c_errmsg, "ntrPickHeaderUpdate"
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
ALTER TABLE [dbo].[PICKHEADER] WITH NOCHECK ADD CONSTRAINT [CK_PICKHEADER_Status] CHECK ((rtrim([Status]) like '[0-9]'))
GO
ALTER TABLE [dbo].[PICKHEADER] ADD CONSTRAINT [PKPickHeader] PRIMARY KEY NONCLUSTERED ([PickHeaderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PICKHEADER_Consignee] ON [dbo].[PICKHEADER] ([ConsigneeKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PICKHEADER_ConsoOrderKey] ON [dbo].[PICKHEADER] ([ConsoOrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PICKHD_LOADKEY] ON [dbo].[PICKHEADER] ([ExternOrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PICKHEADER01] ON [dbo].[PICKHEADER] ([ExternOrderKey], [Zone]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PICKHEADER_OrderKey] ON [dbo].[PICKHEADER] ([OrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PICKHEADER6] ON [dbo].[PICKHEADER] ([PickHeaderKey], [ExternOrderKey], [Zone]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PICKHEADER_UNIQUE] ON [dbo].[PICKHEADER] ([WaveKey], [OrderKey], [ExternOrderKey], [ConsoOrderKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PICKHEADER5] ON [dbo].[PICKHEADER] ([Zone]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PICKHEADER] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PICKHEADER] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PICKHEADER] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PICKHEADER] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PICKHEADER] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the Consignee.', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'ConsigneeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'ExternOrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Orders.', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'OrderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Pick Header.', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'PickHeaderKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Priority of the task. (1-highest through 9-lowest)', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'Priority'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Wave.', 'SCHEMA', N'dbo', 'TABLE', N'PICKHEADER', 'COLUMN', N'WaveKey'
GO
