CREATE TABLE [dbo].[PickingInfo]
(
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ScanInDate] [datetime] NULL,
[PickerID] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScanOutDate] [datetime] NULL,
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PickingInfo_AddWho] DEFAULT (suser_sname()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PickingInfo_EditWho] DEFAULT (suser_sname()),
[WaveKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_pickinginfo_WaveKey] DEFAULT (''),
[CaseID] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_pickinginfo_CaseID] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/************************************************************************/
/* Trigger: ntrPickingInfoAdd                                           */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:  Trigger for PickingInfo table                              */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By: When records updated                                      */
/*                                                                      */
/* Revision: 1.3                                                        */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver.  Purposes                                */
/* 14-Nov-2005  Vicky     1.0   SOS41737 - Add in Configkey "ScanInLog" */
/*                              to insert record to Transmitlog3 when   */
/*                              scanning in is carried out              */
/* 10-Nov-2006  June      1.0   SOS#58619 - Include TrafficCop check    */
/* 13-Nov-2007  YokeBeen  1.0   SOS#84285 - Consolidated Pick Ticket of */
/*                              USA. PickHeader.Zone -> Conso = 'C'     */
/*                                                   -> Discrete = 'D'  */
/*                              - (YokeBeen01)                          */
/* 15-Sep-2007  Shong     1.0   - SOS#84285 Discrete Pickslip Type = 'D'*/
/* 17-Jul-2008  YokeBeen  1.1   SOS#111333 - New trigger point for IDSTW*/
/*                              LOR for the Pick Confirmation Outbound. */
/*                              Records to be triggered when            */
/*                              ORDERS.Status = "3".                    */
/*                              Tablename = "PICKINPROG". - (YokeBeen02)*/
/* 28-Oct-2009  Shong     1.2   Insert into PickDet_Log if StorerConfig */
/*                              ScanInPickLog.                          */
/* 02-Feb-2010  MCTang    1.2   SOS#159235 - Assign Orders.Type to Keys */
/*                              for 'ScanInLog' IF 'WitronOL' is OFF    */
/*                              (MC01)                                  */
/* 25-Mar-2014  Leong     1.3   SOS#305979 - Remove TrafficCop when     */
/*                                           update Orders.             */
/* 25-Sep-2017  TLTING    1.4   SET ANSI                                */
/* 11-03-2020   MCTang    1.5   Add scanin2log (MC03)                   */
/* 11-May-2020  MCTang    1.6   Add scanin3log (MC04)                   */
/* 26-Mar-2021  NJOW01    1.7   WMS-16663 add transmitlog2 interface    */
/* 09-Jul-2021  NJOW02    1.8   Fix null value comparison issue         */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrPickingInfoAdd]
ON  [dbo].[PickingInfo]
FOR INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE   @b_Success              INT       -- Populated by calls to stored procedures - was the proc successful?
   ,         @n_err                  INT       -- Error number returned by stored procedure OR this trigger
   ,         @n_err2                 INT       -- For Additional Error Detection
   ,         @c_errmsg               NVARCHAR(250) -- Error message returned by stored procedure OR this trigger
   ,         @n_Continue             INT
   ,         @n_starttcnt            INT       -- Holds the current transaction count
   ,         @c_preprocess           NVARCHAR(250) -- preprocess
   ,         @c_pstprocess           NVARCHAR(250) -- post process
   ,         @n_cnt                  INT
   ,         @c_PickerID             NVARCHAR(18)
   ,         @c_authority_scaninlog  NVARCHAR(1)   -- SOS41737
   ,         @c_authority_scanin2log NVARCHAR(1)   -- MC03
   ,         @c_authority_scanin3log NVARCHAR(1)   -- MC04
   ,         @c_StorerKey            NVARCHAR(15)  -- SOS41737
   ,         @c_cfgvalue             NVARCHAR(1)   -- SOS41737
   ,         @c_authority_pickinprog NVARCHAR(1)   -- (YokeBeen02)
   ,         @c_OrderType            NVARCHAR(10)  -- MC01

   SELECT @n_Continue=1, @n_starttcnt=@@TRANCOUNT

   -- Start : SOS58619
   IF EXISTS (SELECT 1 FROM INSERTED WHERE Trafficcop = 'U')
   BEGIN
      SELECT @n_Continue = 4
   END
   -- End : SOS58619

   DECLARE @c_ScanInPickLog NVARCHAR(1)

   /* #INCLUDE <TRMBOA1.SQL> */
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      IF EXISTS (SELECT 1 FROM INSERTED WHERE ISNULL(Pickslipno,'') = '')
      BEGIN
          SELECT @n_Continue = 3
          SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12800
          SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                           + ': Error Printing Pickslip. Please Call PFC team. (ntrPickingInfoAdd) ( '
                           + ' SQLSvr MESSAGE=' + ISNULL(LTrim(RTRIM(@c_errmsg)),'') + ' ) '
      END
   END

   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      DECLARE @c_pickslipno    NVARCHAR(10)
      DECLARE @n_MaxChildSP    INT,
              @n_ChildSP       INT,
              @c_ParentSP      NVARCHAR(10)
      DECLARE @c_PickSlipType  NVARCHAR(10),
              @c_OrderKey      NVARCHAR(10),
              @c_LPOrderKey    NVARCHAR(10),
              @c_LoadKey       NVARCHAR(10),
              @c_Facility      NVARCHAR(5),
              @c_WSSIOption1   NVARCHAR(50),
              @c_WSScanInLog   NVARCHAR(30)

      DECLARE @c_xdOrderKey        NVARCHAR(10),
              @c_OrderLineNumber   NVARCHAR(5),
              @n_rowno             INT,
              @n_rowcount          INT,
              @c_PrevOrderKey      NVARCHAR(5),
              @c_PrevLoadKey       NVARCHAR(10),
              @c_PrevLoadOrderKey  NVARCHAR(10)

      SELECT @c_pickslipno = ''

      DECLARE C_PickInfo_Add_01 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
       SELECT INSERTED.PickSlipNo
       FROM   INSERTED
       WHERE ISNULL(ScanInDate,'') <> ''
       ORDER BY INSERTED.PickSlipNo

      OPEN C_PickInfo_Add_01

      FETCH NEXT FROM C_PickInfo_Add_01 INTO  @c_pickslipno

      WHILE @@FETCH_STATUS <> -1 AND (@n_Continue = 1 OR @n_Continue = 2)
      BEGIN
         IF ISNULL(RTRIM(@c_pickslipno),'') = ''
            BREAK

         SELECT @c_PickSlipType = ZONE,
                @c_LoadKey      = ExternOrderKey,
                @c_LPOrderKey   = ISNULL(OrderKey, '')
         FROM   PickHeader WITH (NOLOCK)
         WHERE  PickHeaderKey = @c_pickslipno

         IF @c_PickSlipType = '1' AND LEFT(RTRIM(LTrim(@c_pickslipno)), 1) = 'C'
         BEGIN
            SELECT @n_MaxChildSP = COUNT(C.Pickheaderkey), @c_ParentSP = MAX(C.Consigneekey)
            FROM   PICKHEADER C WITH (NOLOCK)
            JOIN   PICKHEADER P WITH (NOLOCK) ON (C.Consigneekey = P.Consigneekey)
            WHERE  P.Pickheaderkey = @c_pickslipno

            SELECT @n_ChildSP = COUNT(PickingInfo.PickSlipNo)
            FROM   PickingInfo WITH (NOLOCK)
            JOIN   PICKHEADER WITH (NOLOCK) ON (PickingInfo.PickslipNo = PICKHEADER.Pickheaderkey)
            WHERE  PICKHEADER.Consigneekey = @c_ParentSP

            IF @n_ChildSP = @n_MaxChildSP
            BEGIN -- Create Parent PickInfo
               SELECT @c_PickerID = PickerID FROM INSERTED

               INSERT INTO PickingInfo (PickSlipNo, ScanInDate, PickerID, ScanOutDate)
               VALUES (@c_ParentSP, GetDate(), @c_PickerID , NULL)
            END

            -- Added for SOS#41737
            -- MC01
            /*
            SELECT DISTINCT @c_StorerKey = StorerKey
            FROM ORDERS WITH (NOLOCK)
            WHERE Loadkey = @c_LoadKey
            */

            SELECT TOP 1 @c_StorerKey = StorerKey
                        , @c_OrderType = Type
            FROM  ORDERS WITH (NOLOCK)
            WHERE Loadkey = @c_LoadKey

            Execute dbo.nspGetRight '',
                  @c_StorerKey,   -- Storer
                  '',             -- Sku
                  'ScanInLog',     -- ConfigKey
                  @b_success              OUTPUT,
                  @c_authority_scaninlog  OUTPUT,
                  @n_err                  OUTPUT,
                  @c_errmsg               OUTPUT

            IF @b_success <> 1
            BEGIN
               SELECT @n_Continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12801   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
               SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                                + ': Retrieve of Right (ScanInLog) Failed (ntrPickingInfoAdd) ( '
                                + ' SQLSvr MESSAGE=' + ISNULL(LTrim(RTRIM(@c_errmsg)),'') + ' ) '
            End

            IF @c_authority_scaninlog = '1'
            BEGIN
               SELECT @c_cfgvalue = svalue
                 FROM StorerConfig WITH (NOLOCK)
                WHERE StorerKey = @c_StorerKey
                  AND Configkey = 'WitronOL'

               -- (MC01) S
               IF ISNULL(RTRIM(@c_cfgvalue), '0') = '0'
               BEGIN
                  SET @c_cfgvalue = ISNULL(RTRIM(@c_OrderType), '')
               END
               -- (MC01) E

               EXEC dbo.ispGenTransmitLog3 'ScanInLog', @c_LPOrderKey, @c_cfgvalue , @c_StorerKey, ''
                           , @b_success OUTPUT
                           , @n_err OUTPUT
                           , @c_errmsg OUTPUT
               IF @b_success <> 1
               BEGIN
                  SELECT @n_Continue = 3
               End
            END

            --(MC03) - S
            Execute dbo.nspGetRight '',
                  @c_StorerKey,   -- Storer
                  '',             -- Sku
                  'ScanIn2Log',     -- ConfigKey
                  @b_success              OUTPUT,
                  @c_authority_scanin2log  OUTPUT,
                  @n_err                  OUTPUT,
                  @c_errmsg               OUTPUT

            IF @b_success <> 1
            BEGIN
               SELECT @n_Continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12801   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
               SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                                + ': Retrieve of Right (ScanIn2Log) Failed (ntrPickingInfoAdd) ( '
                                + ' SQLSvr MESSAGE=' + ISNULL(LTrim(RTRIM(@c_errmsg)),'') + ' ) '
            End

            IF @c_authority_scanin2log = '1'
            BEGIN
               SELECT @c_cfgvalue = svalue
                 FROM StorerConfig WITH (NOLOCK)
                WHERE StorerKey = @c_StorerKey
                  AND Configkey = 'WitronOL'

               -- (MC01) S
               IF ISNULL(RTRIM(@c_cfgvalue), '0') = '0'
               BEGIN
                  SET @c_cfgvalue = ISNULL(RTRIM(@c_OrderType), '')
               END
               -- (MC01) E

               EXEC dbo.ispGenTransmitLog3 'ScanIn2Log', @c_LPOrderKey, @c_cfgvalue , @c_StorerKey, ''
                           , @b_success OUTPUT
                           , @n_err OUTPUT
                           , @c_errmsg OUTPUT
               IF @b_success <> 1
               BEGIN
                  SELECT @n_Continue = 3
               End
            END
            --(MC03) - E

            --(MC04) - S
            SET @c_authority_scanin3log = ''
            Execute dbo.nspGetRight '',
                  @c_StorerKey,   -- Storer
                  '',             -- Sku
                  'ScanIn3Log',     -- ConfigKey
                  @b_success              OUTPUT,
                  @c_authority_scanin3log  OUTPUT,
                  @n_err                  OUTPUT,
                  @c_errmsg               OUTPUT

            IF @b_success <> 1
            BEGIN
               SELECT @n_Continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12801   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
               SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                                + ': Retrieve of Right (ScanIn3Log) Failed (ntrPickingInfoAdd) ( '
                                + ' SQLSvr MESSAGE=' + ISNULL(LTrim(RTRIM(@c_errmsg)),'') + ' ) '
            End

            IF @c_authority_scanin3log = '1'
            BEGIN
               SELECT @c_cfgvalue = svalue
                 FROM StorerConfig WITH (NOLOCK)
                WHERE StorerKey = @c_StorerKey
                  AND Configkey = 'WitronOL'

               IF ISNULL(RTRIM(@c_cfgvalue), '0') = '0'
               BEGIN
                  SET @c_cfgvalue = ISNULL(RTRIM(@c_OrderType), '')
               END

               EXEC dbo.ispGenTransmitLog3 'ScanIn3Log', @c_LPOrderKey, @c_cfgvalue , @c_StorerKey, ''
                           , @b_success OUTPUT
                           , @n_err OUTPUT
                           , @c_errmsg OUTPUT
               IF @b_success <> 1
               BEGIN
                  SELECT @n_Continue = 3
               End
            END
            --(MC04) - E

         END -- PS Type = '1' AND 1st Char of PS# = 'C'

         -- Consolidated PickSlip Zone = '5'
         --IF @c_PickSlipType IN ('5','6','7','9','C') -- (YokeBeen01)
         IF @c_LPOrderKey = '' AND @c_PickSlipType NOT IN ('XD','LB','LP')
         BEGIN
            SELECT @c_OrderKey = ''

            DECLARE C_PKI_LoadPlanDet CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT LOADPLANDETAIL.OrderKey
            FROM   LOADPLANDETAIL WITH (NOLOCK)
            WHERE  LOADPLANDETAIL.LoadKey = @c_LoadKey
            ORDER BY LOADPLANDETAIL.OrderKey

            OPEN C_PKI_LoadPlanDet

            FETCH NEXT FROM C_PKI_LoadPlanDet INTO @c_OrderKey

            WHILE @@FETCH_STATUS <> -1 AND (@n_Continue = 1 OR @n_Continue = 2)
            BEGIN
               IF ISNULL(RTRIM(@c_OrderKey),'') = ''
                  BREAK

               SELECT @c_StorerKey = StorerKey
                    , @c_OrderType = Type  -- (MC01)
                    , @c_Facility = Facility --NJOW01
                 FROM ORDERS WITH (NOLOCK)
                WHERE OrderKey = @c_OrderKey

               /* Comment this for Performance Purposes
               UPDATE PICKDETAIL WITH (ROWLOCK)
               SET STATUS = '3'
               FROM PICKDETAIL
               WHERE OrderKey = @c_OrderKey
               AND   Status < '3'
               */

               UPDATE ORDERS WITH (ROWLOCK)
               SET Status = '3',
                   EditWho = sUser_sName(),
                   EditDate = GetDate()
               --, TrafficCop = NULL -- SOS#305979
               WHERE OrderKey = @c_OrderKey
               AND   Status < '3'

               SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

               IF @n_err <> 0
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12802   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                                   + ': Update Failed On Table ORDERS. (ntrPickingInfoAdd) ( '
                                   + ' SQLSvr MESSAGE=' + ISNULL(LTrim(RTRIM(@c_errmsg)),'') + ' ) '
               END

               IF @n_Continue = 1 OR @n_Continue = 2
               BEGIN
                  UPDATE ORDERDETAIL WITH (ROWLOCK)
                  SET Status = '3',
                      EditWho = sUser_sName(),
                      EditDate = GetDate(),
                      TrafficCop = NULL
                  WHERE ORDERDETAIL.OrderKey = @c_OrderKey
                  AND   ORDERDETAIL.Status < '3'

                  SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

                  IF @n_err <> 0
                  BEGIN
                      SELECT @n_Continue = 3
                      SELECT @c_errmsg = CONVERT(CHAR(250), @n_err),
                         @n_err = 12803 -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                      SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5), ISNULL(RTRIM(@n_err), 0))
                             +
                             ': Update Failed On Table ORDERDETAIL. (ntrPickingInfoAdd) ( '
                             + ' SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)), '')
                             + ' ) '
                  END
               END

               IF @n_Continue = 1 OR @n_Continue = 2
               BEGIN
                  UPDATE LOADPLANDETAIL WITH (ROWLOCK)
                  SET Status = '3',
                      EditWho = sUser_sName(),
                      EditDate = GetDate(),
                      TrafficCop = NULL
                  WHERE LOADPLANDETAIL.OrderKey = @c_OrderKey
                  AND   LOADPLANDETAIL.Status < '5'

                  SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

                  IF @n_err <> 0
                  BEGIN
                     SELECT @n_Continue = 3
                     SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12804   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                     SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0))
                                      + ': Update Failed On Table LOADPLANDETAIL. (ntrPickingInfoAdd) ( '
                                      + ' SQLSvr MESSAGE=' + LTrim(RTRIM(@c_errmsg)) + ' ) '
                  END
               END

               -- Added for SOS#41737
               IF @n_Continue = 1 OR @n_Continue = 2
               BEGIN
                  EXECUTE dbo.nspGetRight '',
                          @c_StorerKey,   -- Storer
                          '',             -- Sku
                          'ScanInLog',    -- ConfigKey
                          @b_success              OUTPUT,
                          @c_authority_scaninlog  OUTPUT,
                          @n_err                  OUTPUT,
                          @c_errmsg               OUTPUT

                  IF @b_success <> 1
                  BEGIN
                     SELECT @n_Continue = 3
                     SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12805   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                     SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                                      + ': Retrieve of Right (ScanInLog) Failed (ntrPickingInfoAdd) ( '
                                      + ' SQLSvr MESSAGE=' + ISNULL(LTrim(RTRIM(@c_errmsg)),'') + ' ) '
                  End

                  IF @c_authority_scaninlog = '1'
                  BEGIN
                     SELECT @c_cfgvalue = svalue
                       FROM StorerConfig WITH (NOLOCK)
                      WHERE StorerKey = @c_StorerKey
                        AND Configkey = 'WitronOL'

                     -- (MC01) S
                     IF ISNULL(RTRIM(@c_cfgvalue), '0') = '0'
                     BEGIN
                        SET @c_cfgvalue = ISNULL(RTRIM(@c_OrderType), '')
                     END
                     -- (MC01) E

                     EXEC dbo.ispGenTransmitLog3 'ScanInLog', @c_OrderKey, @c_cfgvalue, @c_StorerKey, ''
                           , @b_success OUTPUT
                           , @n_err OUTPUT
                           , @c_errmsg OUTPUT

                     IF @b_success <> 1
                     BEGIN
                        SELECT @n_Continue = 3
                     End
                  END
               END -- (continue =1)
               -- End SOS#41737

               --(MC03) - S
               IF @n_Continue = 1 OR @n_Continue = 2
               BEGIN
                  EXECUTE dbo.nspGetRight '',
                          @c_StorerKey,   -- Storer
                          '',             -- Sku
                          'ScanIn2Log',    -- ConfigKey
                          @b_success              OUTPUT,
                          @c_authority_scanin2log  OUTPUT,
                          @n_err                  OUTPUT,
                          @c_errmsg               OUTPUT

                  IF @b_success <> 1
                  BEGIN
                     SELECT @n_Continue = 3
                     SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12805   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                     SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                                      + ': Retrieve of Right (ScanIn2Log) Failed (ntrPickingInfoAdd) ( '
                                      + ' SQLSvr MESSAGE=' + ISNULL(LTrim(RTRIM(@c_errmsg)),'') + ' ) '
                  End

                  IF @c_authority_scanin2log = '1'
                  BEGIN
                     SELECT @c_cfgvalue = svalue
                       FROM StorerConfig WITH (NOLOCK)
                      WHERE StorerKey = @c_StorerKey
                        AND Configkey = 'WitronOL'

                     -- (MC01) S
                     IF ISNULL(RTRIM(@c_cfgvalue), '0') = '0'
                     BEGIN
                        SET @c_cfgvalue = ISNULL(RTRIM(@c_OrderType), '')
                     END
                     -- (MC01) E

                     EXEC dbo.ispGenTransmitLog3 'ScanIn2Log', @c_OrderKey, @c_cfgvalue, @c_StorerKey, ''
                           , @b_success OUTPUT
                           , @n_err OUTPUT
                           , @c_errmsg OUTPUT

                     IF @b_success <> 1
                     BEGIN
                        SELECT @n_Continue = 3
                     End
                  END
               END -- (continue =1)
               --(MC03) - E

               --(MC04) - S
               IF @n_Continue = 1 OR @n_Continue = 2
               BEGIN
                  SET @c_authority_scanin3log = ''
                  EXECUTE dbo.nspGetRight '',
                          @c_StorerKey,   -- Storer
                          '',             -- Sku
                          'ScanIn3Log',    -- ConfigKey
                          @b_success              OUTPUT,
                          @c_authority_scanin3log  OUTPUT,
                          @n_err                  OUTPUT,
                          @c_errmsg               OUTPUT

                  IF @b_success <> 1
                  BEGIN
                     SELECT @n_Continue = 3
                     SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12805   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                     SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                                      + ': Retrieve of Right (ScanIn3Log) Failed (ntrPickingInfoAdd) ( '
                                      + ' SQLSvr MESSAGE=' + ISNULL(LTrim(RTRIM(@c_errmsg)),'') + ' ) '
                  End

                  IF @c_authority_scanin3log = '1'
                  BEGIN
                     SELECT @c_cfgvalue = svalue
                       FROM StorerConfig WITH (NOLOCK)
                      WHERE StorerKey = @c_StorerKey
                        AND Configkey = 'WitronOL'

                     -- (MC01) S
                     IF ISNULL(RTRIM(@c_cfgvalue), '0') = '0'
                     BEGIN
                        SET @c_cfgvalue = ISNULL(RTRIM(@c_OrderType), '')
                     END
                     -- (MC01) E

                     EXEC dbo.ispGenTransmitLog3 'ScanIn3Log', @c_OrderKey, @c_cfgvalue, @c_StorerKey, ''
                           , @b_success OUTPUT
                           , @n_err OUTPUT
                           , @c_errmsg OUTPUT

                     IF @b_success <> 1
                     BEGIN
                        SELECT @n_Continue = 3
                     End
                  END
               END -- (continue =1)
               --(MC04) - E

               -- ScanInPickLog
               IF @n_Continue = 1 OR @n_Continue = 2
               BEGIN
                  EXEC dbo.isp_InsertPickDet_Log
                       @cOrderKey = @c_OrderKey,
                       @cOrderLineNumber='',
                       @n_err=@n_err OUTPUT,
                       @c_errmsg=@c_errmsg OUTPUT,
                       @cPickSlipNo = @c_pickslipno

               END -- (continue =1)

               -- (YokeBeen01) - Start
               IF @c_PickSlipType IN ('C')
               BEGIN
                  IF EXISTS (SELECT DISTINCT 1
                               FROM ORDERS WITH (NOLOCK)
                               JOIN PICKHEADER WITH (NOLOCK) ON (ORDERS.OrderKey = PICKHEADER.OrderKey)
                              WHERE ORDERS.LoadKey = @c_LoadKey
                                AND PICKHEADER.OrderKey = @c_OrderKey
                                AND PICKHEADER.Zone = 'D' )
                  BEGIN
                     SELECT @c_PickerID = PickerID FROM INSERTED

                     INSERT INTO PickingInfo (PickSlipNo, ScanInDate, PickerID, ScanOutDate)
                     SELECT PickHeaderKey, GETDATE(), @c_PickerID, NULL
                       FROM PICKHEADER WITH (NOLOCK)
                      WHERE OrderKey IN ( SELECT DISTINCT PICKHEADER.OrderKey
                                            FROM ORDERS WITH (NOLOCK)
                                            JOIN PICKHEADER WITH (NOLOCK) ON (ORDERS.OrderKey = PICKHEADER.OrderKey)
                                           WHERE ORDERS.LoadKey = @c_LoadKey
                                             AND ORDERS.OrderKey = @c_OrderKey   --tlting
                                             AND PICKHEADER.Zone = 'D' )
                  END
               END
               -- (YokeBeen01) - End

               -- (YokeBeen02) Start
               IF @n_Continue = 1 OR @n_Continue = 2
               BEGIN
                  SELECT @b_success = 0
                  EXECUTE dbo.nspGetRight  NULL,
                          @c_StorerKey,        -- Storer
                          '',                  -- Sku
                          'PICKINPROG',        -- ConfigKey
                          @b_success              OUTPUT,
                          @c_authority_pickinprog OUTPUT,
                          @n_err                  OUTPUT,
                          @c_errmsg               OUTPUT

                  IF @b_success <> 1
                  BEGIN
                     SELECT @n_Continue = 3
                     SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12806
                     SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0))
                                      + ': Retrieve of Right (PICKINPROG) Failed (ntrPickingInfoAdd)'
                                      + ' ( SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '
                  END
                  ELSE
                  BEGIN
                     IF @c_authority_pickinprog = '1'
                     BEGIN
                        EXEC dbo.ispGenTransmitLog3 'PICKINPROG', @c_OrderKey, '', @c_StorerKey, ''
                                 , @b_success OUTPUT
                                 , @n_err OUTPUT
                                 , @c_errmsg OUTPUT

                        IF @b_success <> 1
                        BEGIN
                           SELECT @n_Continue = 3
                           SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12807
                           SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0))
                                            + ': Insert into TransmitLog3 Failed (ntrPickingInfoAdd)'
                                            + ' ( SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '
                        END
                     END
                  END -- IF @b_success <> 1
               END
               -- (YokeBeen02) End

               FETCH NEXT FROM C_PKI_LoadPlanDet INTO @c_OrderKey
            END --while loop loadplan detail
            CLOSE C_PKI_LoadPlanDet
            DEALLOCATE C_PKI_LoadPlanDet
         END -- conso pickslip
         ELSE
         BEGIN
            -- Start - Add by June 28.May.03 (SOS11482)
            IF @c_PickSlipType IN ('8', '3', 'D') -- SOS#84285
            BEGIN
               IF EXISTS (SELECT 1 FROM PICKHEADER WITH (NOLOCK) WHERE Consigneekey = @c_pickslipno)
               BEGIN
                  SELECT @c_PickerID = PickerID FROM INSERTED

                  INSERT INTO PickingInfo (PickSlipNo, ScanInDate, PickerID, ScanOutDate)
                  SELECT PickHeaderKey, GetDate(), @c_PickerID, NULL
                    FROM PICKHEADER WITH (NOLOCK)
                   WHERE Consigneekey = @c_Pickslipno
               END -- End (SOS11482)
            END

            IF @n_Continue = 1 OR @n_Continue = 2
            BEGIN
               UPDATE ORDERS WITH (ROWLOCK)
                  SET Status = '3',
                      EditWho = sUser_sName(),
                      EditDate = GetDate()
                  --, TrafficCop = NULL -- SOS#305979
                WHERE OrderKey = @c_LPOrderKey
                  AND Status < '3'

               SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

               IF @n_err <> 0
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12808   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                                  +': Update Failed On Table ORDERS. (ntrPickingInfoAdd)' + ' ( '
                                  + ' SQLSvr MESSAGE=' + ISNULL(LTrim(RTRIM(@c_errmsg)),'') + ' ) '
               END
            END

            IF @n_Continue = 1 OR @n_Continue = 2
            BEGIN
               UPDATE ORDERDETAIL WITH (ROWLOCK)
                  SET Status = '3',
                      EditWho = sUser_sName(),
                      EditDate = GetDate(),
                      TrafficCop = NULL
                WHERE ORDERDETAIL.OrderKey = @c_LPOrderKey
                  AND ORDERDETAIL.Status < '3'

               SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

               IF @n_err <> 0
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12809   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                                  +': Update Failed On Table ORDERDETAIL. (ntrPickingInfoAdd)' + ' ( '
                                  + ' SQLSvr MESSAGE=' + ISNULL(LTrim(RTRIM(@c_errmsg)),'') + ' ) '
               END
            END

            IF @n_Continue = 1 OR @n_Continue = 2
            BEGIN
               UPDATE LOADPLANDETAIL WITH (ROWLOCK)
                  SET Status = '3',
                      EditWho = sUser_sName(),
                      EditDate = GetDate(),
                      TrafficCop = NULL
                WHERE LOADPLANDETAIL.OrderKey = @c_LPOrderKey
                  AND LOADPLANDETAIL.Status < '5'

               SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

               IF @n_err <> 0
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12810   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                                  +': Update Failed On Table LOADPLANDETAIL. (ntrPickingInfoAdd)' + ' ( '
                                  + ' SQLSvr MESSAGE=' + LTrim(RTRIM(@c_errmsg)) + ' ) '
               END
            END

            -- Added for SOS#41737
            SELECT @c_StorerKey = StorerKey
                 , @c_OrderType = Type     --(MC01)
                 , @c_Facility = Facility --NJOW01                 
              FROM ORDERS WITH (NOLOCK)
             WHERE OrderKey = @c_LPOrderKey

            EXECUTE dbo.nspGetRight '',
                  @c_StorerKey,   -- Storer
                  '',             -- Sku
                  'ScanInLog',     -- ConfigKey
                  @b_success              OUTPUT,
                  @c_authority_scaninlog  OUTPUT,
                  @n_err                  OUTPUT,
                  @c_errmsg               OUTPUT

            IF @b_success <> 1
            BEGIN
               SELECT @n_Continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12811   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
               SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                               +': Retrieve of Right (ScanInLog) Failed (ntrPickingInfoAdd)' + ' ( '
                               + ' SQLSvr MESSAGE=' + ISNULL(LTrim(RTRIM(@c_errmsg)),'') + ' ) '
            END

            IF @c_authority_scaninlog = '1'
            BEGIN
               SELECT @c_cfgvalue = svalue
                 FROM StorerConfig (NOLOCK)
                WHERE StorerKey = @c_StorerKey
                  AND Configkey = 'WitronOL'

               -- (MC01) S
               IF ISNULL(RTRIM(@c_cfgvalue), '0') = '0'
               BEGIN
                  SET @c_cfgvalue = ISNULL(RTRIM(@c_OrderType), '')
               END
               -- (MC01) E

               EXEC dbo.ispGenTransmitLog3 'ScanInLog', @c_LPOrderKey, @c_cfgvalue, @c_StorerKey, ''
                           , @b_success OUTPUT
                           , @n_err OUTPUT
                           , @c_errmsg OUTPUT

               IF @b_success <> 1
               BEGIN
                  SELECT @n_Continue = 3
               End
            END
            -- End SOS#41737

            --(MC03) - S
            EXECUTE dbo.nspGetRight '',
                  @c_StorerKey,   -- Storer
                  '',             -- Sku
                  'ScanIn2Log',     -- ConfigKey
                  @b_success              OUTPUT,
                  @c_authority_scanin2log  OUTPUT,
                  @n_err                  OUTPUT,
                  @c_errmsg               OUTPUT

            IF @b_success <> 1
            BEGIN
               SELECT @n_Continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12811   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
               SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                               +': Retrieve of Right (ScanIn2Log) Failed (ntrPickingInfoAdd)' + ' ( '
                               + ' SQLSvr MESSAGE=' + ISNULL(LTrim(RTRIM(@c_errmsg)),'') + ' ) '
            END

            IF @c_authority_scanin2log = '1'
            BEGIN
               SELECT @c_cfgvalue = svalue
                 FROM StorerConfig (NOLOCK)
                WHERE StorerKey = @c_StorerKey
                  AND Configkey = 'WitronOL'

               -- (MC01) S
               IF ISNULL(RTRIM(@c_cfgvalue), '0') = '0'
               BEGIN
                  SET @c_cfgvalue = ISNULL(RTRIM(@c_OrderType), '')
               END
               -- (MC01) E

               EXEC dbo.ispGenTransmitLog3 'ScanIn2Log', @c_LPOrderKey, @c_cfgvalue, @c_StorerKey, ''
                           , @b_success OUTPUT
                           , @n_err OUTPUT
                           , @c_errmsg OUTPUT

               IF @b_success <> 1
               BEGIN
                  SELECT @n_Continue = 3
               End
            END
            --(MC03) - E

            --(MC04) - S
            SET @c_authority_scanin3log = ''
            EXECUTE dbo.nspGetRight '',
                  @c_StorerKey,   -- Storer
                  '',             -- Sku
                  'ScanIn3Log',     -- ConfigKey
                  @b_success              OUTPUT,
                  @c_authority_scanin3log OUTPUT,
                  @n_err                  OUTPUT,
                  @c_errmsg               OUTPUT

            IF @b_success <> 1
            BEGIN
               SELECT @n_Continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12811   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
               SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                               +': Retrieve of Right (ScanIn3Log) Failed (ntrPickingInfoAdd)' + ' ( '
                               + ' SQLSvr MESSAGE=' + ISNULL(LTrim(RTRIM(@c_errmsg)),'') + ' ) '
            END

            IF @c_authority_scanin3log = '1'
            BEGIN
               SELECT @c_cfgvalue = svalue
                 FROM StorerConfig (NOLOCK)
                WHERE StorerKey = @c_StorerKey
                  AND Configkey = 'WitronOL'

               -- (MC01) S
               IF ISNULL(RTRIM(@c_cfgvalue), '0') = '0'
               BEGIN
                  SET @c_cfgvalue = ISNULL(RTRIM(@c_OrderType), '')
               END
               -- (MC01) E

               EXEC dbo.ispGenTransmitLog3 'ScanIn3Log', @c_LPOrderKey, @c_cfgvalue, @c_StorerKey, ''
                           , @b_success OUTPUT
                           , @n_err OUTPUT
                           , @c_errmsg OUTPUT

               IF @b_success <> 1
               BEGIN
                  SELECT @n_Continue = 3
               End
            END
            --(MC04) - E

            -- ScanInPickLog
            IF @n_Continue = 1 OR @n_Continue = 2
            BEGIN
               EXEC dbo.isp_InsertPickDet_Log
                    @cOrderKey = @c_LPOrderKey,
                    @cOrderLineNumber='',
                    @n_err=@n_err OUTPUT,
                    @c_errmsg=@c_errmsg OUTPUT,
                    @cPickSlipNo = @c_pickslipno

            END -- (continue =1)

            -- (YokeBeen02) Start
            IF @n_Continue = 1 OR @n_Continue = 2
            BEGIN
               SELECT @b_success = 0
               EXECUTE dbo.nspGetRight  NULL,
                       @c_StorerKey,        -- Storer
                       '',                  -- Sku
                       'PICKINPROG',        -- ConfigKey
                       @b_success              OUTPUT,
                       @c_authority_pickinprog OUTPUT,
                       @n_err                  OUTPUT,
                       @c_errmsg               OUTPUT

               IF @b_success <> 1
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12812
                  SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0))
                                   + ': Retrieve of Right (PICKINPROG) Failed (ntrPickingInfoAdd)'
                                   + ' ( SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '
               END
               ELSE
               BEGIN
                  IF @c_authority_pickinprog = '1'
                  BEGIN
                     EXEC dbo.ispGenTransmitLog3 'PICKINPROG', @c_LPOrderKey, '', @c_StorerKey, ''
                              , @b_success OUTPUT
                              , @n_err OUTPUT
                              , @c_errmsg OUTPUT

                     IF @b_success <> 1
                     BEGIN
                        SELECT @n_Continue = 3
                        SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12813
                        SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0))
                                         + ': Insert into TransmitLog3 Failed (ntrPickingInfoAdd)'
                                         + ' ( SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '
                     END
                  END
               END -- IF @b_success <> 1
            END
            -- (YokeBeen02) End
         END -- Normal Pick Slip

         -- CrossDock PickSlip Zone = 'XD'
         IF @c_PickSlipType = 'XD' OR
            @c_PickSlipType = 'LB' OR
            @c_PickSlipType = 'LP' -- SOS37177 & SOS37178 by Ong 7JUL2005
         BEGIN
            DECLARE uniqorder_cur CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT DISTINCT OrderKey, ORDERLINENUMBER
            FROM RefKeyLookup WITH (NOLOCK)
            WHERE PICKSLIPNO = @c_Pickslipno
            ORDER BY OrderKey, ORDERLINENUMBER -- Added by Shong on 06-Aug-2004

            OPEN uniqorder_cur
            FETCH NEXT FROM uniqorder_cur INTO @c_xdOrderKey, @c_OrderLineNumber

            WHILE @@FETCH_STATUS = 0
            BEGIN
               SELECT @c_LoadKey = ORDERDETAIL.LoadKey,
                      @c_StorerKey = ORDERDETAIL.StorerKey,
                      @c_Facility = ORDERS.Facility --NJOW01
               FROM ORDERDETAIL WITH (NOLOCK)
               JOIN ORDERS WITH (NOLOCK) ON ORDERDETAIL.Orderkey = ORDERS.Orderkey
               WHERE ORDERDETAIL.OrderKey = @c_xdOrderKey
               AND ORDERDETAIL.OrderLinenumber = @c_OrderLineNumber

               IF ISNULL(@c_PrevOrderKey,'') <> ISNULL(@c_xdOrderKey,'')  --NJOW02
               BEGIN
                  SELECT @c_PrevOrderKey = @c_xdOrderKey

                  UPDATE ORDERS WITH (ROWLOCK)
                     SET Status = '3',
                         EditWho = sUser_sName(),
                         EditDate = GetDate()
                     --, TrafficCop = NULL -- SOS#305979
                   WHERE OrderKey = @c_xdOrderKey
                     AND status < '3'

                  SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

                  IF @n_err <> 0
                  BEGIN
                     SELECT @n_Continue = 3
                     SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12814   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                     SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                                      + ': Update Failed On Table ORDERS. (ntrPickingInfoAdd) ( '
                                      + ' SQLSvr MESSAGE=' + ISNULL(LTrim(RTRIM(@c_errmsg)),'') + ' ) '
                  END
               END

               IF @n_Continue = 1 OR @n_Continue = 2
               BEGIN
                  UPDATE ORDERDETAIL WITH (ROWLOCK)
                     SET Status = '3',
                         EditWho = sUser_sName(),
                         EditDate = GetDate(),
                         TrafficCop = NULL
                   WHERE OrderKey = @c_xdOrderKey
                     AND OrderLinenumber = @c_OrderLineNumber
                     AND Status < '3'

                  SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

                  IF @n_err <> 0
                  BEGIN
                     SELECT @n_Continue = 3
                     SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12815   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                     SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                                      + ': Update Failed On Table ORDERDETAIL. (ntrPickingInfoAdd) ( '
                                      + ' SQLSvr MESSAGE=' + ISNULL(LTrim(RTRIM(@c_errmsg)),'') + ' ) '
                  END
               END

               -- ScanInPickLog
               IF @n_Continue = 1 OR @n_Continue = 2
               BEGIN
                  EXEC dbo.isp_InsertPickDet_Log
                       @cOrderKey = @c_xdOrderKey,
                       @cOrderLineNumber=@c_OrderLineNumber,
                       @n_err=@n_err OUTPUT,
                       @c_errmsg=@c_errmsg OUTPUT,
                       @cPickSlipNo = @c_pickslipno

               END -- (continue =1)

               IF @n_Continue = 1 OR @n_Continue = 2
               BEGIN
                  IF (ISNULL(@c_PrevLoadKey,'') <> ISNULL(@c_LoadKey,'')) OR (ISNULL(@c_PrevLoadOrderKey,'') <> ISNULL(@c_xdOrderKey,'')) --NJOW02
                  BEGIN
                     SELECT @c_PrevLoadKey = @c_LoadKey
                     SELECT @c_PrevLoadOrderKey = @c_xdOrderKey

                     UPDATE LOADPLANDETAIL WITH (ROWLOCK)
                        SET Status = '3',
                            EditWho = sUser_sName(),
                            EditDate = GetDate(),
                            TrafficCop = NULL
                      WHERE LoadKey = @c_LoadKey
                        AND OrderKey = @c_xdOrderKey
                        AND Status < '5'

                     SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

                     IF @n_err <> 0
                     BEGIN
                        SELECT @n_Continue = 3
                        SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12816   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                        SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                                         + ': Update Failed On Table LOADPLANDETAIL. (ntrPickingInfoAdd) ( '
                                         + ' SQLSvr MESSAGE=' + ISNULL(LTrim(RTRIM(@c_errmsg)),'') + ' ) '
                     END

                     IF @n_Continue = 1 OR @n_Continue = 2
                     BEGIN
                        UPDATE LoadPlan WITH (ROWLOCK)
                           SET Status = '3',
                               EditWho = sUser_sName(),
                               EditDate = GetDate(),
                               TrafficCop = NULL
                         WHERE LoadKey = @c_LoadKey
                           AND Status < '3'

                        SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

                        IF @n_err <> 0
                        BEGIN
                           SELECT @n_Continue = 3
                           SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12817   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                           SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                                            + ': Update Failed On Table LOADPLANDETAIL. (ntrPickingInfoAdd) ( '
                                            + ' SQLSvr MESSAGE=' + ISNULL(LTrim(RTRIM(@c_errmsg)),'') + ' ) '
                        END
                     END
                  END
               END

               EXECUTE dbo.nspGetRight '',
                  @c_StorerKey,   -- Storer
                  '',             -- Sku
                  'ScanInLog',     -- ConfigKey
                  @b_success              OUTPUT,
                  @c_authority_scaninlog  OUTPUT,
                  @n_err                  OUTPUT,
                  @c_errmsg               OUTPUT

               IF @b_success <> 1
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12818   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                                   + ': Retrieve of Right (ScanInLog) Failed (ntrPickingInfoAdd) ( '
                                   + ' SQLSvr MESSAGE=' + ISNULL(LTrim(RTRIM(@c_errmsg)),'') + ' ) '
               END

               IF @c_authority_scaninlog = '1'
               BEGIN
                  SELECT @c_cfgvalue = svalue
                    FROM StorerConfig WITH (NOLOCK)
                   WHERE StorerKey = @c_StorerKey
                     AND Configkey = 'WitronOL'

                  -- (MC01) S
                  SELECT @c_OrderType = Type
                  FROM ORDERS WITH (NOLOCK)
                  WHERE Orderkey = @c_xdorderkey

                  IF ISNULL(RTRIM(@c_cfgvalue), '0') = '0'
                  BEGIN
                     SET @c_cfgvalue = ISNULL(RTRIM(@c_OrderType), '')
                  END
                  -- (MC01) E

                  EXEC dbo.ispGenTransmitLog3 'ScanInLog', @c_xdOrderKey, @c_cfgvalue, @c_StorerKey, ''
                           , @b_success OUTPUT
                           , @n_err OUTPUT
                           , @c_errmsg OUTPUT
                  IF @b_success <> 1
                  BEGIN
                     SELECT @n_Continue = 3
                  End
               END
               -- End SOS#41737

               --(MC03) - S
               EXECUTE dbo.nspGetRight '',
                  @c_StorerKey,   -- Storer
                  '',             -- Sku
                  'ScanIn2Log',     -- ConfigKey
                  @b_success              OUTPUT,
                  @c_authority_scanin2log  OUTPUT,
                  @n_err                  OUTPUT,
                  @c_errmsg               OUTPUT

               IF @b_success <> 1
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12818   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                                   + ': Retrieve of Right (ScanIn2Log) Failed (ntrPickingInfoAdd) ( '
                                   + ' SQLSvr MESSAGE=' + ISNULL(LTrim(RTRIM(@c_errmsg)),'') + ' ) '
               END

               IF @c_authority_scanin2log = '1'
               BEGIN
                  SELECT @c_cfgvalue = svalue
                    FROM StorerConfig WITH (NOLOCK)
                   WHERE StorerKey = @c_StorerKey
                     AND Configkey = 'WitronOL'

                  -- (MC01) S
                  SELECT @c_OrderType = Type
                  FROM ORDERS WITH (NOLOCK)
                  WHERE Orderkey = @c_xdorderkey

                  IF ISNULL(RTRIM(@c_cfgvalue), '0') = '0'
                  BEGIN
                     SET @c_cfgvalue = ISNULL(RTRIM(@c_OrderType), '')
                  END
                  -- (MC01) E

                  EXEC dbo.ispGenTransmitLog3 'ScanIn2Log', @c_xdOrderKey, @c_cfgvalue, @c_StorerKey, ''
                           , @b_success OUTPUT
                           , @n_err OUTPUT
                           , @c_errmsg OUTPUT
                  IF @b_success <> 1
                  BEGIN
                     SELECT @n_Continue = 3
                  End
               END
               --(MC03) - E

               --(MC04) - S
               SET @c_authority_scanin3log = ''
               EXECUTE dbo.nspGetRight '',
                  @c_StorerKey,   -- Storer
                  '',             -- Sku
                  'ScanIn3Log',     -- ConfigKey
                  @b_success              OUTPUT,
                  @c_authority_scanin3log OUTPUT,
                  @n_err                  OUTPUT,
                  @c_errmsg               OUTPUT

               IF @b_success <> 1
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12818   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                                   + ': Retrieve of Right (ScanIn3Log) Failed (ntrPickingInfoAdd) ( '
                                   + ' SQLSvr MESSAGE=' + ISNULL(LTrim(RTRIM(@c_errmsg)),'') + ' ) '
               END

               IF @c_authority_scanin3log = '1'
               BEGIN
                  SELECT @c_cfgvalue = svalue
                    FROM StorerConfig WITH (NOLOCK)
                   WHERE StorerKey = @c_StorerKey
                     AND Configkey = 'WitronOL'

                  -- (MC01) S
                  SELECT @c_OrderType = Type
                  FROM ORDERS WITH (NOLOCK)
                  WHERE Orderkey = @c_xdorderkey

                  IF ISNULL(RTRIM(@c_cfgvalue), '0') = '0'
                  BEGIN
                     SET @c_cfgvalue = ISNULL(RTRIM(@c_OrderType), '')
                  END
                  -- (MC01) E

                  EXEC dbo.ispGenTransmitLog3 'ScanIn3Log', @c_xdOrderKey, @c_cfgvalue, @c_StorerKey, ''
                           , @b_success OUTPUT
                           , @n_err OUTPUT
                           , @c_errmsg OUTPUT
                  IF @b_success <> 1
                  BEGIN
                     SELECT @n_Continue = 3
                  End
               END
               --(MC04) - E

               -- (YokeBeen02) Start
               IF @n_Continue = 1 OR @n_Continue = 2
               BEGIN
                  SELECT @b_success = 0
                  EXECUTE dbo.nspGetRight  NULL,
                          @c_StorerKey,        -- Storer
                          '',                  -- Sku
                          'PICKINPROG',        -- ConfigKey
                          @b_success              OUTPUT,
                          @c_authority_pickinprog OUTPUT,
                          @n_err                  OUTPUT,
                          @c_errmsg               OUTPUT

                  IF @b_success <> 1
                  BEGIN
                     SELECT @n_Continue = 3
                     SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12819
                     SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0))
                                      + ': Retrieve of Right (PICKINPROG) Failed (ntrPickingInfoAdd)'
                                      + ' ( SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '
                  END
                  ELSE
                  BEGIN
                     IF @c_authority_pickinprog = '1'
                     BEGIN
                        EXEC dbo.ispGenTransmitLog3 'PICKINPROG', @c_xdOrderKey, '', @c_StorerKey, ''
                                 , @b_success OUTPUT
                                 , @n_err OUTPUT
                                 , @c_errmsg OUTPUT

                        IF @b_success <> 1
                        BEGIN
                           SELECT @n_Continue = 3
                           SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12820
                           SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0))
                                            + ': Insert into TransmitLog3 Failed (ntrPickingInfoAdd)'
                                            + ' ( SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '
                        END
                     END
                  END -- IF @b_success <> 1
               END
               -- (YokeBeen02) End
               FETCH NEXT FROM uniqorder_cur INTO @c_xdOrderKey, @c_OrderLineNumber
            END -- End while loop

            CLOSE uniqorder_cur
            DEALLOCATE uniqorder_cur
         END -- crossdock pickslip

         IF @c_PickSlipType <> 'XD' AND @c_PickSlipType <> 'LB' AND @c_PickSlipType <> 'LP' -- SOS37177 & SOS37178 by Ong 7JUL2005
         BEGIN
            UPDATE LoadPlan WITH (ROWLOCK)
               SET Status = '3',
                   EditWho = sUser_sName(),
                   EditDate = GetDate(),
                   TrafficCop = NULL
              FROM LoadPlan
             WHERE LoadPlan.LoadKey = @c_LoadKey
               AND LoadPlan.Status < '3'
         END

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_Continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12821   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                             + ': Update Failed On Table LoadPlan. (ntrPickingInfoAdd) ( '
                             + ' SQLSvr MESSAGE=' + LTrim(RTRIM(@c_errmsg)) + ' ) '
         END

         -- for watsons's pickslip : zone = 'W'
         -- wally : 23.oct.03
         -- startW
         IF (@n_Continue = 1 OR @n_Continue = 2) AND @c_PickSlipType = 'W'
         BEGIN
            SELECT @c_OrderKey = ''

            DECLARE C_PI_PickDetail CURSOR LOCAl FAST_FORWARD READ_ONLY FOR
            SELECT DISTINCT OrderKey
            FROM Pickdetail WITH (NOLOCK)
            WHERE Pickslipno = @c_pickslipno
            ORDER BY OrderKey

            OPEN C_PI_PickDetail

            FETCH NEXT FROM C_PI_PickDetail INTO @c_OrderKey

            -- while (1=1)
            WHILE @@FETCH_STATUS <> -1
            BEGIN
               --select @c_OrderKey = min(OrderKey)
               --from pickdetail (nolock)
               --where pickslipno = @c_pickslipno
               --AND OrderKey > @c_OrderKey

               IF ISNULL(@c_OrderKey, 0) = 0
               BREAK

               UPDATE ORDERS WITH (ROWLOCK)
                  SET --trafficcop = NULL, -- SOS#305979
                      EditWho = sUser_sName(),
                      EditDate = GetDate(),
                      status = '3'
                WHERE OrderKey = @c_OrderKey

               SELECT @n_err = @@error

               IF @n_err <> 0
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12822   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(RTRIM(@n_err),0))
                                   + ': Update Failed On Table Orders. (ntrPickingInfoAdd) ( '
                                   + ' SQLSvr MESSAGE=' + ISNULL(LTrim(RTRIM(@c_errmsg)),'') + ' ) '
               END

               SELECT @c_StorerKey = StorerKey
                    , @c_OrderType = Type      --(MC01)
               FROM ORDERS WITH (NOLOCK)
               WHERE OrderKey = @c_OrderKey

               EXECUTE dbo.nspGetRight '',
                     @c_StorerKey,   -- Storer
                     '',             -- Sku
                     'ScanInLog',     -- ConfigKey
                     @b_success              OUTPUT,
                     @c_authority_scaninlog  OUTPUT,
                     @n_err                  OUTPUT,
                     @c_errmsg               OUTPUT

               IF @b_success <> 1
               BEGIN
                      SELECT @n_Continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12823   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err)
                                       + ': Retrieve of Right (ScanInLog) Failed (ntrPickingInfoAdd) ( '
                                       + ' SQLSvr MESSAGE=' + LTrim(RTRIM(@c_errmsg)) + ' ) '
               END

               IF @c_authority_scaninlog = '1'
               BEGIN
                  SELECT @c_cfgvalue = svalue
                    FROM StorerConfig WITH (NOLOCK)
                   WHERE StorerKey = @c_StorerKey
                     AND Configkey = 'WitronOL'

                  -- (MC01) S
                  IF ISNULL(RTRIM(@c_cfgvalue), '0') = '0'
                  BEGIN
                     SET @c_cfgvalue = ISNULL(RTRIM(@c_OrderType), '')
                  END
                  -- (MC01) E

                  EXEC dbo.ispGenTransmitLog3 'ScanInLog', @c_OrderKey, @c_cfgvalue, @c_StorerKey, ''
                          , @b_success OUTPUT
                          , @n_err OUTPUT
                          , @c_errmsg OUTPUT

                  IF @b_success <> 1
                  BEGIN
                     SELECT @n_Continue = 3
                  END
               END
               -- End SOS#41737

               --(MC03) - S
               EXECUTE dbo.nspGetRight '',
                     @c_StorerKey,   -- Storer
                     '',             -- Sku
                     'ScanIn2Log',     -- ConfigKey
                     @b_success              OUTPUT,
                     @c_authority_scanin2log  OUTPUT,
                     @n_err                  OUTPUT,
                     @c_errmsg               OUTPUT

               IF @b_success <> 1
               BEGIN
                      SELECT @n_Continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12823   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err)
                                       + ': Retrieve of Right (ScanIn2Log) Failed (ntrPickingInfoAdd) ( '
                                       + ' SQLSvr MESSAGE=' + LTrim(RTRIM(@c_errmsg)) + ' ) '
               END

               IF @c_authority_scanin2log = '1'
               BEGIN
                  SELECT @c_cfgvalue = svalue
                    FROM StorerConfig WITH (NOLOCK)
                   WHERE StorerKey = @c_StorerKey
                     AND Configkey = 'WitronOL'

                  -- (MC01) S
                  IF ISNULL(RTRIM(@c_cfgvalue), '0') = '0'
                  BEGIN
                     SET @c_cfgvalue = ISNULL(RTRIM(@c_OrderType), '')
                  END
                  -- (MC01) E

                  EXEC dbo.ispGenTransmitLog3 'ScanIn2Log', @c_OrderKey, @c_cfgvalue, @c_StorerKey, ''
                          , @b_success OUTPUT
                          , @n_err OUTPUT
                          , @c_errmsg OUTPUT

                  IF @b_success <> 1
                  BEGIN
                     SELECT @n_Continue = 3
                  END
               END
               --(MC03) - E

               --(MC04) - S
               SET @c_authority_scanin3log = ''
               EXECUTE dbo.nspGetRight '',
                     @c_StorerKey,   -- Storer
                     '',             -- Sku
                     'ScanIn3Log',     -- ConfigKey
                     @b_success              OUTPUT,
                     @c_authority_scanin3log  OUTPUT,
                     @n_err                  OUTPUT,
                     @c_errmsg               OUTPUT

               IF @b_success <> 1
               BEGIN
                      SELECT @n_Continue = 3
                  SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12823   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),@n_err)
                                       + ': Retrieve of Right (ScanIn3Log) Failed (ntrPickingInfoAdd) ( '
                                       + ' SQLSvr MESSAGE=' + LTrim(RTRIM(@c_errmsg)) + ' ) '
               END

               IF @c_authority_scanin3log = '1'
               BEGIN
                  SELECT @c_cfgvalue = svalue
                    FROM StorerConfig WITH (NOLOCK)
                   WHERE StorerKey = @c_StorerKey
                     AND Configkey = 'WitronOL'

                  -- (MC01) S
                  IF ISNULL(RTRIM(@c_cfgvalue), '0') = '0'
                  BEGIN
                     SET @c_cfgvalue = ISNULL(RTRIM(@c_OrderType), '')
                  END
                  -- (MC01) E

                  EXEC dbo.ispGenTransmitLog3 'ScanIn3Log', @c_OrderKey, @c_cfgvalue, @c_StorerKey, ''
                          , @b_success OUTPUT
                          , @n_err OUTPUT
                          , @c_errmsg OUTPUT

                  IF @b_success <> 1
                  BEGIN
                     SELECT @n_Continue = 3
                  END
               END
               --(MC04) - E

               -- (YokeBeen02) Start
               IF @n_Continue = 1 OR @n_Continue = 2
               BEGIN
                  SELECT @b_success = 0
                  EXECUTE dbo.nspGetRight  NULL,
                          @c_StorerKey,        -- Storer
                          '',                  -- Sku
                          'PICKINPROG',        -- ConfigKey
                          @b_success              OUTPUT,
                          @c_authority_pickinprog OUTPUT,
                          @n_err                  OUTPUT,
                          @c_errmsg               OUTPUT

                  IF @b_success <> 1
                  BEGIN
                     SELECT @n_Continue = 3
                     SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12824
                     SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0))
                                      + ': Retrieve of Right (PICKINPROG) Failed (ntrPickingInfoAdd)'
                                      + ' ( SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '
                  END
                  ELSE
                  BEGIN
                     IF @c_authority_pickinprog = '1'
                     BEGIN
                        EXEC dbo.ispGenTransmitLog3 'PICKINPROG', @c_OrderKey, '', @c_StorerKey, ''
                                 , @b_success OUTPUT
                                 , @n_err OUTPUT
                                 , @c_errmsg OUTPUT

                        IF @b_success <> 1
                        BEGIN
                           SELECT @n_Continue = 3
                           SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12825
                           SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0))
                                            + ': Insert into TransmitLog3 Failed (ntrPickingInfoAdd)'
                                            + ' ( SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '
                        END
                     END
                  END -- IF @b_success <> 1
               END
               -- (YokeBeen02) End
               FETCH NEXT FROM C_PI_PickDetail INTO @c_OrderKey
            END
            CLOSE C_PI_PickDetail
            DEALLOCATE C_PI_PickDetail
         END
         -- endW
         
         --NJOW01 S                  
         IF LEFT(@c_Pickslipno,1) <> 'P'
         BEGIN
         	  SELECT TOP 1 @c_Storerkey = O.Storerkey,
         	               @c_Facility = O.Facility
         	  FROM STORERCONFIG SC (NOLOCK) 
         	  JOIN ORDERS O (NOLOCK) ON O.Storerkey = SC.Storerkey 
         	  JOIN PICKDETAIL PD (NOLOCK) ON PD.Orderkey = O.Orderkey     
         	  WHERE PD.Pickslipno = @c_Pickslipno
         	  AND SC.Configkey = 'WSScanInLog'       
         	  AND (SC.Facility = O.Facility OR ISNULL(SC.Facility,'') = '')
         	  AND SC.Svalue = '1'  	  
         	  AND O.Status <> '9'
         END
         
         SET @c_WSScanInLog = ''
         Execute nspGetRight                                
            @c_Facility  = @c_facility,                     
            @c_StorerKey = @c_StorerKey,                    
            @c_sku       = '',                          
            @c_ConfigKey = 'WSScanInLog', -- Configkey         
            @b_Success   = @b_success     OUTPUT,             
            @c_authority = @c_WSScanInLog OUTPUT,             
            @n_err       = @n_err         OUTPUT,             
            @c_errmsg    = @c_errmsg      OUTPUT,             
            @c_Option1 = @c_WSSIOption1 OUTPUT              
            
         IF ISNULL(@c_WSScanInLog,'') = '1' AND ISNULL(@c_WSSIOption1,'') <> '' AND
            NOT EXISTS(SELECT 1 FROM INSERTED WHERE Pickslipno = @c_Pickslipno AND PickerID = 'VoicePicking')        
         BEGIN         
         	  SET @b_success = 0
            EXEC dbo.ispGenTransmitLog2 @c_WSSIOption1, @c_pickslipno, '', @c_StorerKey, ''
                     , @b_success OUTPUT
                     , @n_err OUTPUT
                     , @c_errmsg OUTPUT
            
            IF @b_success <> 1
            BEGIN
               SELECT @n_Continue = 3
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=12814
               SELECT @c_errmsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_err,0))
                                + ': Insert into TransmitLog2 Failed (ntrPickingInfoAdd)'
                                + ' ( SQLSvr MESSAGE=' + ISNULL(LTRIM(RTRIM(@c_errmsg)),'') + ' ) '
            END         	
         END       
         --NJOW01 E

         FETCH NEXT FROM C_PickInfo_Add_01 INTO  @c_pickslipno
      END -- while pickslip no
      CLOSE C_PickInfo_Add_01
      DEALLOCATE C_PickInfo_Add_01
   END

   /* #INCLUDE <TRMBOHA2.SQL> */
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrPickingInfoAdd'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR -- SQL2012
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

/* 14-Jul-2011  KHLim02       GetRight for Delete log                   */

CREATE TRIGGER [dbo].[ntrPickingInfoDelete]
ON [dbo].[PickingInfo]
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

   DECLARE  @b_Success     int,       -- Populated by calls to stored procedures - was the proc successful?
            @n_err         int,       -- Error number returned by stored procedure or this trigger
            @c_errmsg      NVARCHAR(250), -- Error message returned by stored procedure or this trigger
            @n_continue    int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
            @n_starttcnt   int,       -- Holds the current transaction count
            @n_cnt         int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
           ,@c_authority   NVARCHAR(1)  -- KHLim02
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   IF (SELECT count(*) FROM DELETED) =
   (SELECT count(*) FROM DELETED WHERE DELETED.ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
   END

      /* #INCLUDE <TRCONHD1.SQL> */     
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
               ,@c_errmsg = 'ntrPickingInfoDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.PickingInfo_DELLOG ( PickSlipNo )
         SELECT PickSlipNo FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table PickingInfo Failed. (ntrPickingInfoDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END

      /* #INCLUDE <TRCOND2.SQL> */
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrPickingInfoDelete'
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

/*******************************************************************************/  
/* Trigger: ntrPickingInfoUpdate                                               */  
/* Creation Date:                                                              */  
/* Copyright: IDS                                                              */  
/* Written by:                                                                 */  
/*                                                                             */  
/* Purpose:                                                                    */  
/*                                                                             */  
/* Input Parameters:                                                           */  
/*                                                                             */  
/* Output Parameters:                                                          */  
/*                                                                             */  
/* Return Status:                                                              */  
/*                                                                             */  
/* Usage:                                                                      */  
/*                                                                             */  
/* Local Variables:                                                            */  
/*                                                                             */  
/* Called By: When records updated                                             */  
/*                                                                             */  
/* Revision: 1.3                                                               */  
/*                                                                             */  
/* Version: 5.4                                                                */  
/*                                                                             */  
/* Data Modifications:                                                         */  
/*                                                                             */  
/* Updates:                                                                    */  
/* Date         Author    Ver.   Purposes                                      */  
/* 22-Feb-2005  SHONG            Include the Patching for Qty Picked AND       */  
/*                               Qty Allocated in case update done halfway     */  
/* 22-Mar-2005  SHONG            Call ispPickConfirmCheck only when re-scan    */  
/* 29-Jun-2005  SHONG            Include TrafficCop AND Archive Cop            */  
/* 27-Mar-2006  SHONG            Performance Tuning                            */  
/* 13-Apr-2006  SHONG            Performance Tuning                            */  
/* 07-Sep-2006  MaryVong         Add in RDT compatible error messages          */  
/* 13-Nov-2007  YokeBeen         SOS#84285 - Consolidated Pick Ticket of USA.  */  
/*                               PickHeader.Zone -> Conso = 'C'                */  
/*                                               -> Discrete = 'D'             */  
/*                               - (YokeBeen03)                                */  
/* 30-Jul-2008  MCTANG    1.1    SOS#110279 - Vital Pack Confirm.              */  
/* 25-Nov-2008  KC        1.2    Incorporate SQL2005 Std - WITH (NOLOCK)       */  
/* 19-Apr-2012  Leong     1.3    SOS# 241301 - Exclude short pick record       */  
/* 28-Oct-2013  TLTING    1.4    Review Editdate column update                 */  
/* 19-Aug-2015  Shong01   1.5    Added Backend Pick Confirm                    */  
/* 21-Jun-2016  Wan01     1.6    Performance Tune                              */  
/* 22-Sep-2016  SHONG02   1.7    Backend Pack Confirm only for ECOM Orders     */
/* 23-Oct-2017  Shong     1.8    Performance Tuning (SWT02)                    */
/* 07-FEB-2018  Wan02     1.9    Bug Fixed                                     */
/* 15-JAN-2019  NJOW01    2.0    Fix - check discrete by orderkey              */
/* 02-Nov-2021  TLTING01  2.1    Deadlock tuning                               */
/*******************************************************************************/  
CREATE TRIGGER [dbo].[ntrPickingInfoUpdate]  
ON  [dbo].[PickingInfo]  
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

   -- Rewrote by SHONG on 16-Dec-2003  
  
   DECLARE @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?  
         , @n_err                int       -- Error number returned by stored procedure OR this trigger  
         , @n_err2               int       -- For Additional Error Detection  
         , @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure eor this trigger  
         , @n_continue           int  
         , @n_starttcnt          NVARCHAR(250) -- preprocess  
         , @c_pstprocess         NVARCHAR(250) -- post process  
         , @n_cnt                int  
         , @c_rfbatchpickenabled NVARCHAR(1)  
         , @c_OrderKey           NVARCHAR(10)  
         , @c_tablename          NVARCHAR(15)  
         , @c_OrderLineNumber    NVARCHAR(5)  
         , @c_TransmitLogKey     NVARCHAR(10)  
         , @c_storerkey          NVARCHAR(15)  
         , @c_authority          NVARCHAR(1)  -- Add by June 1.Jul.02 for IDSV5  
  
   DECLARE @b_debug                int  
         , @c_PickDetailKey        NVARCHAR(18) -- Change by SHONG from NVARCHAR(10) to NVARCHAR(18) follow table length  
         , @c_LoadKey              NVARCHAR(10)  
         , @c_PickOrderKey         NVARCHAR(10)  
         , @c_WaveKey              NVARCHAR(10)  
  
   DECLARE @c_PickSlipNo           NVARCHAR(10)  
         , @n_RF_BatchPicking      int  
         , @c_TicketType           NVARCHAR(10)  
         , @c_NextOrderKey         NVARCHAR(10)  
         , @c_NextPickSlipNo       NVARCHAR(10)  
         , @c_loritf               NVARCHAR(1) -- Added by Vicky - IDSPH LOREAL  
         , @c_BackendPickCfm       CHAR(1) -- SHONG01   
         , @c_DocType              NVARCHAR(1)           
         , @c_PickDet_Status       NVARCHAR(10) = ''  --SWT02
         , @c_PickDet_ShpFlg       NVARCHAR(1)  = ''  --SWT02
         , @c_Status               NVARCHAR(10) = ''  --SWT02
         , @c_LoadLineNumber       NVARCHAR(5)  = ''  --SWT02         
  
   SELECT @b_debug = 0, @c_PickDetailKey = ''  
   SELECT @n_continue = 1, @n_starttcnt = @@TRANCOUNT  
  
   BEGIN TRAN; 
   
   IF UPDATE(TrafficCop)  
   BEGIN  
      SELECT @n_continue = 4  
   END  
   IF UPDATE(ArchiveCop)  
   BEGIN  
      SELECT @n_continue = 4  
   END  
  
   -- Added By SHONG 27-Mar-2006  
   IF NOT UPDATE(ScanOutDate)  
   BEGIN  
      SELECT @n_continue = 4  
   END  
  
   -- (June01) - Start  
   -- TraceInfo  
   DECLARE @c_starttime datetime  
         , @c_endtime   datetime  
         , @c_step1     datetime  
         , @c_step2     datetime  
         , @c_step3     datetime  
         , @c_step4     datetime  
         , @c_step5     datetime  
         , @c_col1      NVARCHAR(20)  
         , @c_col2      NVARCHAR(20)  
         , @c_col3      NVARCHAR(20)  
         , @c_col4      NVARCHAR(20)  
         , @c_col5      NVARCHAR(20)  
         , @c_TraceName NVARCHAR(80)  
  
   SET @c_col1 = ''  
   SET @c_col2 = ''  
   SET @c_col3 = ''  
   SET @c_col4 = ''  
   SET @c_col5 = ''  
   SET @c_starttime = GetDate()
     
   -- TraceInfo  
   -- (June01) - End  
   /* #INCLUDE <TRMBOA1.SQL> */  
  
   IF @n_continue = 1 OR @n_continue = 2        --(Wan01)
   BEGIN                                        --(Wan01)  
      IF EXISTS( SELECT 1 FROM NSQLCONFIG WITH (NOLOCK) WHERE CONFIGKEY = 'RF_BATCH_PICK' AND NSQLVALUE = '1')  
         SELECT @n_RF_BatchPicking = 1  
      ELSE  
         SELECT @n_RF_BatchPicking = 0  
  
      SELECT @c_PickSlipNo = SPACE(10)  
  
      DECLARE C_trPkngInfoPickSlip CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
      SELECT INSERTED.PickSlipNo,  
             PickHeader.ZONE,  
             PickHeader.ExternOrderKey,  
             ISNULL(PickHeader.OrderKey, '')  
      FROM  INSERTED  
      JOIN  PickHeader WITH (NOLOCK) ON PickHeaderKey = INSERTED.PickSlipNo  
      WHERE INSERTED.ScanOutDate IS NOT NULL  
      ORDER BY INSERTED.PickSlipNo, PickHeader.ExternOrderKey, ISNULL(PickHeader.OrderKey, '')  
  
      OPEN C_trPkngInfoPickSlip  
      WHILE 1=1  
      BEGIN  
         FETCH NEXT FROM C_trPkngInfoPickSlip INTO @c_PickSlipNo, @c_TicketType, @c_LoadKey, @c_OrderKey  
  
         IF @@FETCH_STATUS = -1  
            BREAK  
  
         IF @b_debug = 1  
         BEGIN  
            PRINT 'Loop 1 - Picking Info, PickSlip No/Ticket Type = '  
                  + ISNULL(RTRIM(@c_PickSlipNo),'') + '/' + ISNULL(RTRIM(@c_TicketType),'')  
         END  
  
         -- Added by Ricky  
         IF @c_TicketType NOT IN ('XD','LB','LP')
         BEGIN  
            IF ISNULL(RTRIM(@c_OrderKey),'') = ''  
            BEGIN  
               -- Conso PickSlip - Loop for Order  
               SELECT @c_NextOrderKey = SPACE(10)  
               SELECT @c_NextPickSlipNo = SPACE(10)  
  
               DECLARE C_trPkngInfonNxtOrdKy CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
               SELECT LoadPlanDetail.OrderKey, Orders.StorerKey, Orders.DocType  
               FROM   LoadPlanDetail WITH (NOLOCK)  
               JOIN   Orders WITH (NOLOCK) ON LoadPlanDetail.OrderKey = Orders.OrderKey  
               WHERE  LoadPlanDetail.LoadKey = @c_LoadKey  
               ORDER BY LoadPlanDetail.OrderKey  
            END  
            ELSE  
            BEGIN  
               DECLARE C_trPkngInfonNxtOrdKy CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
               SELECT Orders.OrderKey, Orders.StorerKey, Orders.DocType  
               FROM   Orders WITH (NOLOCK)  
               WHERE  Orders.OrderKey = @c_OrderKey  
               ORDER BY Orders.OrderKey  
            END  
  
            SET @c_step1 = GetDate()  
  
            OPEN C_trPkngInfonNxtOrdKy
            FETCH NEXT FROM C_trPkngInfonNxtOrdKy INTO @c_NextOrderKey, @c_StorerKey, @c_DocType
              
            WHILE @@FETCH_STATUS = 0  
            BEGIN    
               IF @b_debug = 1  
               BEGIN  
                  IF @c_TicketType = 'C'  
                     PRINT 'Loop 2 - Loadplan Detail, PickSlipNo/OrderKey = '  
                           + ISNULL(RTRIM(@c_NextPickSlipNo),'') + '/' + ISNULL(RTRIM(@c_NextOrderKey),'')  
                  ELSE IF @c_TicketType <> 'C'  
                     PRINT 'Loop 2 - Loadplan Detail, OrderKey = ' + ISNULL(RTRIM(@c_NextOrderKey),'')  
               END  
  
               -- SHONG01  
               SET @c_BackendPickCfm = '0'  
               SELECT @c_BackendPickCfm = ISNULL(sValue, '0')  
               FROM   StorerConfig AS sc WITH (NOLOCK)   
               WHERE  StorerKey = @c_storerkey  
               AND    sc.ConfigKey = 'BackendPickConfirm'   
               AND    sc.SValue = '1'  
                   
               SET @c_step3 = GetDate()  
  
               -- 22-Feb-2005  
               -- Added By SHONG On 22-Mar-2005  
               IF EXISTS(SELECT 1 FROM DELETED, INSERTED  
                           WHERE INSERTED.PickSlipNo = @c_PickSlipNo  
                           AND   INSERTED.PickSlipNo = DELETED.PickSlipNo  
                           AND   INSERTED.ScanOutDate IS NOT NULL  
                           AND   INSERTED.ScanOutDate > DELETED.ScanOutDate)  
               BEGIN  
                  IF ISNULL(RTRIM(@c_LoadKey),'') <> '' 
                     EXEC dbo.ispPickConfirmCheck @c_LoadKey
                  ELSE 
                     EXEC dbo.ispPickConfirmCheck @c_LoadKey, @c_NextOrderKey  
               END
                 
               IF ISNULL(RTRIM(@c_LoadKey),'') <> ''
                 AND ISNULL(@c_Orderkey,'') = '' --NJOW01
               BEGIN
                  IF  @c_TicketType = '9' AND @n_RF_BatchPicking = 1
                  BEGIN
                     DECLARE CUR_UPDATE_PICKDETAIL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                     SELECT PickDetailKey
                     FROM  PICKDETAIL WITH (NOLOCK)                             
                     JOIN  ORDERDETAIL WITH (NOLOCK) ON (ORDERDETAIL.OrderKey = PICKDETAIL.OrderKey AND  
                                                      ORDERDETAIL.OrderLineNumber = PICKDETAIL.OrderLineNumber) 
                     WHERE ORDERDETAIL.OrderKey = @c_NextOrderKey     
                     AND   (PICKDETAIL.PickMethod = '8' OR PICKDETAIL.PickMethod = '')   
                     AND   PICKDETAIL.Status < '4'   
                     AND   PICKDETAIL.ShipFlag <> 'P' --(Wan01)  
                     AND   ORDERDETAIL.LoadKey = @c_LoadKey                     	
                  END       
                  ELSE IF @c_TicketType = 'C'
                  BEGIN
                     DECLARE CUR_UPDATE_PICKDETAIL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                     SELECT PickDetailKey
                     FROM  PICKDETAIL WITH (NOLOCK)  
                     JOIN  ORDERDETAIL WITH (NOLOCK) ON (ORDERDETAIL.OrderKey = PICKDETAIL.OrderKey AND  
                                                         ORDERDETAIL.OrderLineNumber = PICKDETAIL.OrderLineNumber) 
                     WHERE ORDERDETAIL.OrderKey = @c_NextOrderKey    
                     AND   PICKDETAIL.Status < '4'   
                     AND   PICKDETAIL.ShipFlag <> 'P' --(Wan01)   
                     AND   ORDERDETAIL.LoadKey = @c_LoadKey                          	
                  END
                  ELSE
                  BEGIN
                     DECLARE CUR_UPDATE_PICKDETAIL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                     SELECT PickDetailKey
                     FROM  PICKDETAIL WITH (NOLOCK)                       	    
                     JOIN  ORDERDETAIL WITH (NOLOCK) ON (ORDERDETAIL.OrderKey = PICKDETAIL.OrderKey AND  
                                                      ORDERDETAIL.OrderLineNumber = PICKDETAIL.OrderLineNumber)    
                     WHERE ORDERDETAIL.OrderKey = @c_NextOrderKey    
                     AND   PICKDETAIL.Status < '4' 
                     AND   PICKDETAIL.ShipFlag <> 'P' --(Wan01)  
                     AND   ORDERDETAIL.LoadKey = @c_LoadKey                      	
                  END                     	
               END
               ELSE 
               BEGIN
                  IF @c_TicketType = '9' AND @n_RF_BatchPicking = 1 -- (Wan02)
                  BEGIN
                     DECLARE CUR_UPDATE_PICKDETAIL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                     SELECT PickDetailKey
                     FROM  PICKDETAIL WITH (NOLOCK)                             
                     WHERE PICKDETAIL.OrderKey = @c_NextOrderKey     
                     AND   (PICKDETAIL.PickMethod = '8' OR PICKDETAIL.PickMethod = '')   
                     AND   PICKDETAIL.Status < '4'   
                     AND   PICKDETAIL.ShipFlag <> 'P' --(Wan01)                       	
                  END       
                  ELSE
                  BEGIN
                     DECLARE CUR_UPDATE_PICKDETAIL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                     SELECT PickDetailKey
                     FROM  PICKDETAIL WITH (NOLOCK)                       	    
                     WHERE PICKDETAIL.OrderKey = @c_NextOrderKey    
                     AND   PICKDETAIL.Status < '4' 
                     AND   PICKDETAIL.ShipFlag <> 'P' --(Wan01)                        	
                  END                              	
               END
                                               	
               OPEN CUR_UPDATE_PICKDETAIL
                        	
               FETCH FROM CUR_UPDATE_PICKDETAIL INTO @c_PickDetailKey
                        	
               WHILE @@FETCH_STATUS = 0
               BEGIN
               	-- SWT02 (Start)
                  SET @c_PickDet_Status = '' 
                  SET @c_PickDet_ShpFlg = ''
                  
                  SELECT @c_PickDet_Status = p.[Status], 
                         @c_PickDet_ShpFlg = p.ShipFlag
                  FROM PICKDETAIL AS p WITH(NOLOCK)  
                  WHERE PickDetailKey = @c_PickDetailKey

                  IF @c_PickDet_Status < '4' AND @c_PickDet_ShpFlg NOT IN ('P','Y')
                  BEGIN
                     IF  @c_BackendPickCfm = '1' AND @c_DocType = 'E'
                     BEGIN                  	 
                        UPDATE PICKDETAIL WITH (ROWLOCK)
                           SET ShipFlag = 'P', EditDate = GETDATE(), EditWho = SUSER_SNAME()
                        WHERE PickDetailKey = @c_PickDetailKey
                     END
                     ELSE
                     BEGIN
                        UPDATE PICKDETAIL WITH (ROWLOCK)
                           SET Status = '5', EditDate = GETDATE(), EditWho = SUSER_SNAME()
                        WHERE PickDetailKey = @c_PickDetailKey
                        AND   Status < '4'     --tlting01
                     END                  		
                  END
                  -- SWT02 (End) 
                  SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
                  IF @n_err <> 0    
                  BEGIN    
                     SELECT @n_continue = 3    
                     SELECT @n_err = 61790   
                     SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(RTrim(@n_err),0))   
                                       +': Update Failed On Table PICKDETAIL. (isp_ScanOutPickSlip)' + ' ( '   
                                       + ' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '    
                     --SET ROWCOUNT 0    
                     GOTO EXIT_TRIGGER  
                  END                           	
                        	
                  FETCH FROM CUR_UPDATE_PICKDETAIL INTO @c_PickDetailKey
               END                        	
               CLOSE CUR_UPDATE_PICKDETAIL
               DEALLOCATE CUR_UPDATE_PICKDETAIL                                                                       
                 
               IF @c_BackendPickCfm = '1'  
               BEGIN
                  EXEC isp_ConfirmPick 
                         @c_OrderKey  = @c_NextOrderKey
                        , @c_LoadKey  = @c_LoadKey
                        , @b_Success  = @b_Success OUTPUT
                        , @n_err      = @n_err     OUTPUT
                        , @c_errmsg   = @c_errmsg  OUTPUT  
                        
                 GOTO SKIP_ORDER_UPDATE
               END   
                 
               SET @c_step3 = GetDate() - @c_step3  
  
               IF @n_continue = 1 OR @n_continue = 2  
               BEGIN  
                  IF EXISTS(SELECT 1 FROM PickDetail WITH (NOLOCK) WHERE OrderKey = @c_NextOrderKey) AND  
                     NOT EXISTS(SELECT 1 FROM PickDetail WITH (NOLOCK) WHERE OrderKey = @c_NextOrderKey AND Status < '5')  
                  BEGIN  
                  	 -- SWT02
                  	 SET @c_Status = ''                  	
                  	 SELECT @c_Status = o.[Status]
                     FROM ORDERS AS o WITH(NOLOCK)
                     WHERE o.OrderKey = @c_NextOrderKey
                     
                     IF @c_Status < '5' AND @c_Status <> ''
                     BEGIN
                        UPDATE ORDERS WITH (ROWLOCK)
                           SET Status = '5',
                               EditDate = GetDate(),
                               EditWho  = sUser_sName()
                        WHERE  OrderKey = @c_NextOrderKey
                        AND   [Status] < '5'       --tlting01
                        SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
	                      IF @n_err <> 0  
	                      BEGIN  
	                         SELECT @n_continue = 3  
	                         SELECT @n_err = 61782 --22802   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
	                         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table Orders. (ntrPickingInfoUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '  
	                         GOTO EXIT_TRIGGER  
	                      END  
	                   END
                  END  
               END  
               
  
               IF @n_continue = 1 OR @n_continue = 2  
               BEGIN  
                  IF EXISTS( SELECT OrderKey FROM OrderDetail WITH (NOLOCK)  
                             WHERE  OrderKey = @c_NextOrderKey  
                             AND    Status < '5')  
                  BEGIN  
	               		-- SWT02
	                  DECLARE CUR_ORDER_LINES CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
	                  SELECT OrderLineNumber
	                  FROM ORDERDETAIL WITH (NOLOCK)
	                  WHERE OrderKey = @c_NextOrderKey 
	                  AND   [Status] < '5'
	      
	                  OPEN CUR_ORDER_LINES
	      
	                  FETCH FROM CUR_ORDER_LINES INTO @c_OrderLineNumber
	      
	                  WHILE @@FETCH_STATUS = 0
	                  BEGIN
	                     UPDATE ORDERDETAIL WITH (ROWLOCK)     
	                        SET [Status] = '5', EditDate = GETDATE(), EditWho=sUser_sName(), TrafficCop = NULL     
	                     WHERE OrderKey = @c_NextOrderKey   
	                     AND   OrderLineNumber = @c_OrderLineNumber
	                     AND   [Status] < '5'          --tlting01
	         
	                     IF @@ERROR <> 0    
	                     BEGIN    
                        SELECT @n_continue = 3  
                        SELECT @n_err = 61783 --22803   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
                        SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table OrderDetail. (ntrPickingInfoUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '  
                        GOTO EXIT_TRIGGER    
	                     END    
	      
	      	            FETCH FROM CUR_ORDER_LINES INTO @c_OrderLineNumber
	                  END      
	                  CLOSE CUR_ORDER_LINES
	                  DEALLOCATE CUR_ORDER_LINES   
	                                    	
                     -- cater for split Orders in loadplan  
                     --UPDATE OrderDetail WITH (ROWLOCK)  
                     --   SET Status = '5',  
                     --       EditDate = GetDate(),  
                     --       EditWho  = sUser_sName(),  
                     --       TrafficCop = NULL  
                     --WHERE  OrderKey = @c_NextOrderKey  
                     --AND    Loadkey = @c_LoadKey  
                     --AND    Status < '5'  
  
                     --SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT                       
                     --IF @n_err <> 0  
                     --BEGIN  
                     --   SELECT @n_continue = 3  
                     --   SELECT @n_err = 61783 --22803   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
                     --   SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table OrderDetail. (ntrPickingInfoUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '  
                     --   GOTO EXIT_TRIGGER  
                     --END  
                  END   
               END  
  
               -- Commented by SHONG on 13-Apr-2006  
               -- Not necessary, already update in OrderDetail update trigger.  
               -- IF @n_continue = 1 OR @n_continue = 2  
               -- BEGIN  
               --    IF @c_TicketType = '3' OR @c_TicketType = '8' OR @c_TicketType = '7'  
               --    BEGIN  
               --       UPDATE Orders  
               --          SET UserDefine03 = convert(char(20),(Select Sum(OrderDetail.QtyPicked * OrderDetail.unitprice)  
               --                                               From  OrderDetail (NOLOCK)  
               --                                               WHERE OrderDetail.OrderKey = Orders.OrderKey)),  
               --              EditDate = GetDate(),  
               --              EditWho  = sUser_sName(),  
               --              TrafficCop = NULL  
               --       FROM Orders  
               --       WHERE OrderKey = @c_NextOrderKey  
               --       SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
               --       IF @n_err <> 0  
               --       BEGIN  
               --          SELECT @n_continue = 3  
               --          SELECT @n_err=22804   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
               --          SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table Orders. (ntrPickingInfoUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '  
               --          GOTO EXIT_TRIGGER  
               --       END  
               --    END -- Ticket Type = 3 OR 8  
               -- END  
               
               SKIP_ORDER_UPDATE:
               IF @n_continue = 1 OR @n_continue = 2  
               BEGIN  
                  IF ISNULL(RTRIM(@c_LoadKey),'') <> ''  
                  BEGIN  
                  	-- SWT02
                  	SET @c_LoadLineNumber = ''
                  	
                  	SELECT @c_LoadLineNumber = LoadLineNumber
                  	FROM LOADPLANDETAIL WITH (NOLOCK) 
                     WHERE Loadkey = @c_LoadKey
                     AND OrderKey = @c_NextOrderKey
                     AND STATUS < '5' 
                  	
                     IF @c_LoadLineNumber <> ''
                     BEGIN
                        UPDATE LOADPLANDETAIL WITH (ROWLOCK)
                           SET STATUS = '5',
                                 EditDate = GetDate(),
                                 EditWho   = sUser_sName(),
                                 TrafficCop = null
                        WHERE Loadkey  = @c_LoadKey
                          AND LoadLineNumber = @c_LoadLineNumber
                          AND STATUS < '5'         --tlting01

                        SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
                        IF @n_err <> 0
                        BEGIN
                           SELECT @n_continue = 3  
                           SELECT @n_err = 61784 --22805    
                           SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table LoadPlanDetail. (ntrPickingInfoUpdate)'  
                                 + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '  
                           GOTO EXIT_TRIGGER  
                        END  
                     END                          	                  	
                     
                     --IF EXISTS( SELECT 1 FROM LoadPlanDetail WITH (NOLOCK) WHERE Loadkey = @c_LoadKey  
                     --           AND OrderKey = @c_NextOrderKey  
                     --           AND Status < '5' )  
                     --BEGIN  
                     --   UPDATE LoadPlanDetail WITH (ROWLOCK)  
                     --      SET Status = '5', EditDate = GetDate(),  
                     --          EditWho  = sUser_sName(), trafficcop = NULL  
                     --   WHERE Loadkey = @c_LoadKey  
                     --     AND OrderKey = @c_NextOrderKey  
                     --     AND Status < '5'  
  
                     --   SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
                     --   IF @n_err <> 0  
                     --   BEGIN  
                     --      SELECT @n_continue = 3  
                     --      SELECT @n_err = 61784 --22805   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
                     --      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table LoadPlanDetail. (ntrPickingInfoUpdate)'  
                     --            + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '  
                     --      -- 22-Feb-2005  
                     --      GOTO EXIT_TRIGGER  
                     --   END  
                     --END  
                  END  -- IF ISNULL(RTRIM(@c_LoadKey),'') <> ''
               END  
  
               IF @c_TicketType IN ('8','7','9') -- SWT02
               BEGIN  
                  IF EXISTS(SELECT 1 FROM StorerConfig WITH (NOLOCK) WHERE Storerkey = @c_StorerKey  
                            AND Configkey = 'ULVITF' AND SVALUE = '1')  
                  BEGIN  
                     IF NOT EXISTS (SELECT 1 FROM StorerConfig WITH (NOLOCK)  
                                    WHERE StorerKey = @c_StorerKey AND Configkey = 'ULVPODITF' AND SValue = '1' )  
                     BEGIN  
                        SELECT @c_tablename = CASE TYPE WHEN 'WT' THEN 'ULVNSO'  
                                                        WHEN 'W'  THEN 'ULVHOL'  
                                                        WHEN 'WC' THEN 'ULVINVTRF'  -- Added by YokeBeen on 19-Nov-2002 (FBR8623)  
                                                        WHEN 'WD' THEN 'ULVDAMWD'   -- (YokeBeen02)  
                                                        ELSE 'ULVPCF'  
                                              END  
                        FROM Orders WITH (NOLOCK)  
                        WHERE OrderKey = @c_NextOrderKey  
  
                        SELECT @c_OrderLineNumber = ''  
  
                        DECLARE C_trPkngInfOrdLnNr CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
                           SELECT OrderDetail.Orderlinenumber  
                           FROM OrderDetail WITH (NOLOCK)  
                           WHERE OrderKey = @c_NextOrderKey  
                           AND Status = '5'  
                           ORDER BY OrderDetail.Orderlinenumber  
  
                        OPEN C_trPkngInfOrdLnNr  
                        WHILE (1 = 1) AND (@n_continue = 1 OR @n_continue = 2)  
                        BEGIN  
                           FETCH NEXT FROM C_trPkngInfOrdLnNr INTO @c_OrderLineNumber  
  
                           IF @@FETCH_STATUS = -1  
                              BREAK  
  
                           EXEC dbo.ispGenTransmitLog2  @c_Tablename, @c_NextOrderKey, @c_OrderLineNumber, @c_StorerKey, ''  
                                 , @b_success OUTPUT  
                                 , @n_err OUTPUT  
                                 , @c_errmsg OUTPUT  
  
                           IF NOT @b_success = 1  
                           BEGIN  
                              SELECT @n_continue = 3  
                              GOTO EXIT_TRIGGER  
                           END  
                        END -- While Loop Order Line  
                        CLOSE C_trPkngInfOrdLnNr  
                        DEALLOCATE C_trPkngInfOrdLnNr  
                     END -- ULVPODITF turn on  
                  END -- if ULVITF Turn on  
               END -- IF @c_TicketType = '8' OR @c_TicketType = '7'  
  
               IF EXISTS(SELECT 1 FROM StorerConfig WITH (NOLOCK) WHERE Storerkey = @c_StorerKey  
                         AND Configkey = 'PICKLOG' AND SVALUE = '1')  
               BEGIN  
                  EXEC dbo.ispGenTransmitLog 'PICK', @c_NextOrderKey, '', @c_PickSlipNo, ''  
                                 , @b_success OUTPUT  
                                 , @n_err OUTPUT  
                                 , @c_errmsg OUTPUT  
  
                  IF NOT @b_success = 1  
                  BEGIN  
                     SELECT @n_continue = 3  
                     SELECT @n_err = 61785 --62900   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
                     SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Insert Into TransmitLog Table (PICK) Failed (ntrOrderDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '  
                     GOTO EXIT_TRIGGER  
                  END  
               END -- Interface ConfigKey 'PICKLOG'  
  
               IF EXISTS(SELECT 1 FROM StorerConfig WITH (NOLOCK) WHERE Storerkey = @c_StorerKey  
                         AND Configkey = 'CDSORD' AND SVALUE = '1')  
               BEGIN  
                  EXEC dbo.ispGenTransmitLog 'CDSORD', @c_NextOrderKey, '', '', ''  
                                 , @b_success OUTPUT  
                                 , @n_err OUTPUT  
                                 , @c_errmsg OUTPUT  
  
                  IF NOT @b_success = 1  
                  BEGIN  
                     SELECT @n_continue = 3  
                     SELECT @n_err = 61786 --62900   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
                     SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Insert Into TransmitLog Table (CDSORD) Failed (ntrOrderDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '  
                     GOTO EXIT_TRIGGER  
                  END  
               END -- Interface ConfigKey 'CDSORD'  
  
               IF EXISTS(SELECT 1 FROM StorerConfig WITH (NOLOCK) WHERE Storerkey = @c_StorerKey  
                         AND Configkey = 'LORITF' AND SVALUE = '1')  
               BEGIN  
                  EXEC dbo.ispGenTransmitLog 'LORPICK', @c_NextOrderKey, '', '', ''  
                              , @b_success OUTPUT  
                              , @n_err OUTPUT  
                              , @c_errmsg OUTPUT  
  
                  IF NOT @b_success = 1  
                  BEGIN  
                     SELECT @n_continue = 3  
                     SELECT @n_err = 61787 --62900   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
                     SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Insert Into TransmitLog Table (LORPICK) Failed (ntrOrderDetailUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '  
                     GOTO EXIT_TRIGGER  
                  END  
               END -- Interface ConfigKey 'LORITF'  
  
               -- Added by MCTANG on 30-Jul-2008 (SOS#110279 - Vital Pack Confirm) - Start  
               IF EXISTS(SELECT 1 FROM StorerConfig WITH (NOLOCK) WHERE Storerkey = @c_StorerKey  
                         AND Configkey = 'VPACKLOG' AND SVALUE = '1')  
               BEGIN  
                  SELECT @b_success = 1  
                  EXEC dbo.ispGenVitalLog 'VPACKLOG', @c_NextOrderKey, '', @c_storerkey, ''  
                              , @b_success OUTPUT  
                              , @n_err OUTPUT  
                              , @c_errmsg OUTPUT  
  
                  IF NOT @b_success = 1  
                  BEGIN  
                     SELECT @n_continue = 3  
                     SELECT @n_err = 61788 --62900   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
                     SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Insert Into TransmitLog Table (VPACKLOG) Failed (ntrPickingInfoUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '  
                     GOTO EXIT_TRIGGER  
                  END  
               END -- Interface ConfigKey 'VPACKLOG'  
               -- Added by MCTANG on 30-Jul-2008 (SOS#110279 - Vital Pack Confirm) - End  
               
               FETCH NEXT FROM C_trPkngInfonNxtOrdKy INTO @c_NextOrderKey, @c_StorerKey, @c_DocType               
            END -- While loop Order Key  
            CLOSE C_trPkngInfonNxtOrdKy  
            DEALLOCATE C_trPkngInfonNxtOrdKy  
  
            SET @c_step1 = GetDate() - @c_step1  
  
            --- End Order Key Loop ---------------------------------------------------------------------  
  
            SET @c_step2 = GetDate()  
  
            --IF ISNULL(RTRIM(@c_LoadKey),'') <> ''  
            --BEGIN  
            --   --(Wan01) - START
            --   SET @n_Cnt = 0 

            --   SELECT TOP 1 @n_Cnt = 1 
            --   FROM ORDERS WITH (NOLOCK)
            --   JOIN PICKDETAIL WITH (NOLOCK) ON (ORDERS.Orderkey = PICKDETAIL.Orderkey) 
            --   WHERE ORDERS.Loadkey = @c_LoadKey
            --   AND   PICKDETAIL.Status < '5' -- no more PickDetail with Status < '5'

            --   --IF NOT EXISTS (SELECT 1 FROM PickDetail WITH (NOLOCK), LoadPlanDetail WITH (NOLOCK), OrderDetail WITH (NOLOCK)
            --                  --WHERE LoadPlanDetail.Loadkey = OrderDetail.Loadkey
            --                  --AND   LoadPlanDetail.Loadkey = @c_LoadKey
            --                  --AND   PickDetail.OrderKey = OrderDetail.OrderKey
            --                  --AND   PickDetail.OrderlineNumber = OrderDetail.OrderlineNumber
            --                  --AND   PickDetail.Status < '5') -- no more PickDetail with Status < '5'
            --   IF @n_Cnt = 0 
            --   BEGIN
            --   --(Wan01) - END   
            --      UPDATE LOADPLAN WITH (ROWLOCK)  
            --         SET Status = '5', EditDate = GetDate(),  
            --             EditWho  = sUser_sName(), TrafficCop = NULL  
            --      WHERE Loadkey = @c_LoadKey --Added By Vicky 18 july 2002 Patch from IDSHK  
            --        AND Status < '5' --Added By Vicky 18 july 2002 Patch from IDSHK  
  
            --      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
  
            --      IF @n_err <> 0  
            --      BEGIN  
            --         SELECT @n_continue = 3  
            --         SELECT @n_err = 61788 --22809   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
            --         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table LOADPLAN. (ntrPickingInfoUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '  
            --         GOTO EXIT_TRIGGER  
            --      END  
            --   END -- NOT EXISTS  
            --END -- IF LTRIM(RTRIM(@c_LoadKey)) <> '' 
  
            SET @c_step2 = GetDate() - @c_step2  
         END -- IF @c_TicketType <> 'XD' AND @c_TicketType <> 'LB'  
         ELSE  
         BEGIN  
            IF @c_TicketType IN ('XD','LB','LP') -- SOS37177 & SOS37178, add by ONG 7.JUL.2005  
            BEGIN
               SELECT @c_PickDetailKey = SPACE(18)

               DECLARE C_PkngInfPckDtlKy CURSOR LOCAL FAST_FORWARD READ_ONLY
                  FOR  SELECT RefKeyLookup.PickDetailKey
                  FROM  RefKeyLookup WITH (NOLOCK)
                  WHERE PickslipNo = @c_PickSlipNo
                  ORDER BY RefKeyLookup.PickDetailKey

               OPEN C_PkngInfPckDtlKy
               FETCH NEXT FROM C_PkngInfPckDtlKy INTO @c_PickDetailKey
               WHILE @@FETCH_STATUS = 0
               BEGIN
               	SET @c_PickDet_Status = '5'
               	
               	SELECT @c_PickDet_Status = p.[Status]
               	FROM PICKDETAIL AS p WITH(NOLOCK)
               	WHERE p.PickDetailKey = @c_PickDetailKey
               	
               	IF @c_PickDet_Status < '4'
               	BEGIN
                     UPDATE PICKDETAIL WITH (ROWLOCK)
                        SET STATUS = '5', EditDate = GETDATE(), EditWho = SUSER_SNAME()
                     WHERE  PickDetailKey = @c_PickDetailKey
                     AND    Status < '4'     --tlting01
                     SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
                     IF @n_err <> 0
                     BEGIN
                        SELECT @n_continue = 3  
                        SELECT @n_err = 61789 --22801    
                        SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table PickDetail. (ntrPickingInfoUpdate)' 
                        + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '  
                        GOTO EXIT_TRIGGER  
                     END               		
               	END                    

                  FETCH NEXT FROM C_PkngInfPckDtlKy INTO @c_PickDetailKey
               END -- WHILE pickdetail
               CLOSE C_PkngInfPckDtlKy
               DEALLOCATE C_PkngInfPckDtlKy


               IF @n_continue = 1 OR @n_continue = 2
               BEGIN
                  --NJOW02
                  DECLARE cur_Orders CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                     SELECT Orderkey
                     FROM ( SELECT DISTINCT PICKDETAIL.Orderkey
                            FROM PICKDETAIL (NOLOCK)
                            JOIN RefKeyLookup WITH (NOLOCK) ON RefKeyLookup.PickDetailKey = PickDetail.PickDetailKey
                            WHERE RefKeyLookup.PickslipNo = @c_PickSlipNo
                            AND   PickDetail.Status = '5' ) AS A
                     WHERE NOT EXISTS (SELECT 1 FROM PICKDETAIL PD (NOLOCK) WHERE PD.Orderkey = A.Orderkey AND PD.Status < '5')
                     ORDER BY Orderkey

                  OPEN cur_Orders

                  FETCH NEXT FROM cur_Orders INTO @c_NextOrderKey

                  WHILE @@FETCH_STATUS <> -1
                  BEGIN
                  	SET @c_Status = '5'
                  	
                  	SELECT @c_Status = [Status]
                     FROM ORDERS AS o WITH(NOLOCK)
                     WHERE o.OrderKey = @c_NextOrderKey
                  	IF @c_Status < '5'
                  	BEGIN
                        UPDATE Orders WITH (ROWLOCK)
                           SET Status = '5', EditDate = GetDate(),
                               EditWho  = sUser_sName(), Trafficcop = NULL
                        WHERE Orderkey = @c_NextOrderKey
                        AND   Status < '5'    --tlting01

                        SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
                        IF @n_err <> 0
                        BEGIN
                           SELECT @n_continue = 3  
                           SELECT @n_err = 61790 --22801   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
                           SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table Orders. (ntrPickingInfoUpdate)' 
                              + ' ( ' + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_errmsg)) + ' ) '  
                           GOTO EXIT_TRIGGER  
                        END                  		
                  	END
                     FETCH NEXT FROM cur_Orders INTO @c_NextOrderKey
                  END
                  CLOSE cur_Orders
                  DEALLOCATE cur_Orders
               END
            END  -- IF @c_TicketType IN ('XD','LB','LP') 
         END  
      END -- while loop picking info  
      CLOSE C_trPkngInfoPickSlip  
      DEALLOCATE C_trPkngInfoPickSlip  
  
   END -- @n_continue = 1 OR @n_continue=2  
  
   EXIT_TRIGGER:  
   -- To turn this on only when need to trace on the performance.  
   -- insert into table, TraceInfo for tracing purpose.  
      IF @n_continue = 1 OR @n_continue = 2  
      BEGIN  
         SET @c_col1      = @c_PickSlipNo  
         SET @c_col2      = RTRIM(@c_TicketType)  
         SET @c_TraceName = 'ntrPickingInfoUpdate'  
         SET @c_endtime = GetDate()  
  
--         INSERT INTO TraceInfo (TraceName, TimeIn, TimeOut, TotalTime, Step1, Step2, Step3, Step4, Step5, Col1, Col2, Col3, Col4, Col5)  
--         VALUES ( @c_TraceName, @c_starttime, @c_endtime  
--                  , CONVERT(CHAR(12),@c_endtime-@c_starttime ,114)  
--                  , ISNULL(CONVERT(CHAR(12),@c_step1,114), '00:00:00:000')  
--                  , ISNULL(CONVERT(CHAR(12),@c_step2,114), '00:00:00:000')  
--                  , ISNULL(CONVERT(CHAR(12),@c_step3,114), '00:00:00:000')  
--                  , ISNULL(CONVERT(CHAR(12),@c_step4,114), '00:00:00:000')  
--                  , ISNULL(CONVERT(CHAR(12),@c_step5,114), '00:00:00:000')  
--                  , @c_Col1,@c_Col2,@c_Col3,@c_Col4,@c_Col5 )  
      END  
  
   /* #INCLUDE <TRMBOHA2.SQL> */  
   IF @n_continue = 3  -- Error Occured - Process AND Return  
   BEGIN  
      DECLARE @n_IsRDT INT  
      EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT  
  
      IF @n_IsRDT = 1  
      BEGIN  
         -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here  
         -- Instead we commit AND raise an error back to parent, let the parent decide  
  
         -- Commit until the level we begin with  
         WHILE @@TRANCOUNT > @n_starttcnt  
            COMMIT TRAN  
  
         -- Raise error with severity = 10, instead of the default severity 16.  
         -- RDT cannot handle error with severity > 10, which stop the processing after executed this trigger  
         RAISERROR (@n_err, 10, 1) WITH SETERROR  
         -- The RAISERROR has to be last line, to ensure @@ERROR is not getting overwritten  
      END  
      ELSE  
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
         EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrPickingInfoUpdate'  
         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012  
         RETURN  
      END  
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
ALTER TABLE [dbo].[PickingInfo] ADD CONSTRAINT [PK_PickingInfo] PRIMARY KEY CLUSTERED ([PickSlipNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [PickingInfo3] ON [dbo].[PickingInfo] ([ScanInDate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PickingInfo] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PickingInfo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PickingInfo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PickingInfo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PickingInfo] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PickingInfo', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'CaseID', 'SCHEMA', N'dbo', 'TABLE', N'PickingInfo', 'COLUMN', N'CaseID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PickingInfo', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the picker.', 'SCHEMA', N'dbo', 'TABLE', N'PickingInfo', 'COLUMN', N'PickerID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying Pickslip.', 'SCHEMA', N'dbo', 'TABLE', N'PickingInfo', 'COLUMN', N'PickSlipNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PickingInfo', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'WaveKey', 'SCHEMA', N'dbo', 'TABLE', N'PickingInfo', 'COLUMN', N'WaveKey'
GO
