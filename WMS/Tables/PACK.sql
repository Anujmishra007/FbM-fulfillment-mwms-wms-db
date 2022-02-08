CREATE TABLE [dbo].[PACK]
(
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PackDescr] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PackUOM1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_PackUOM1] DEFAULT (' '),
[CaseCnt] [float] NOT NULL CONSTRAINT [DF_PACK_CaseCnt] DEFAULT ((0)),
[ISWHQty1] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ISWHQty1] DEFAULT (' '),
[ReplenishUOM1] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishUOM1] DEFAULT ('N'),
[ReplenishZone1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishZone1] DEFAULT ('N'),
[CartonizeUOM1] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_CartonizeUOM1] DEFAULT ('N'),
[LengthUOM1] [float] NOT NULL CONSTRAINT [DF_PACK_lengthuom1] DEFAULT ((0)),
[WidthUOM1] [float] NOT NULL CONSTRAINT [DF_PACK_widthuom1] DEFAULT ((0)),
[HeightUOM1] [float] NOT NULL CONSTRAINT [DF_PACK_heightuom1] DEFAULT ((0)),
[CubeUOM1] [float] NOT NULL CONSTRAINT [DF_PACK_CubeUOM1] DEFAULT ((0)),
[PackUOM2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_PackUOM2] DEFAULT (' '),
[InnerPack] [float] NOT NULL CONSTRAINT [DF_PACK_InnerPack] DEFAULT ((0)),
[ISWHQty2] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ISWHQty2] DEFAULT (' '),
[ReplenishUOM2] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishUOM2] DEFAULT ('N'),
[ReplenishZone2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishZone2] DEFAULT ('N'),
[CartonizeUOM2] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_CartonizeUOM2] DEFAULT ('N'),
[LengthUOM2] [float] NOT NULL CONSTRAINT [DF_PACK_lengthuom2] DEFAULT ((0)),
[WidthUOM2] [float] NOT NULL CONSTRAINT [DF_PACK_widthuom2] DEFAULT ((0)),
[HeightUOM2] [float] NOT NULL CONSTRAINT [DF_PACK_heightuom2] DEFAULT ((0)),
[CubeUOM2] [float] NOT NULL CONSTRAINT [DF_PACK_CubeUOM2] DEFAULT ((0)),
[PackUOM3] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_PackUOM3] DEFAULT (' '),
[Qty] [float] NOT NULL CONSTRAINT [DF_PACK_Qty] DEFAULT ((0)),
[ISWHQty3] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ISWHQty3] DEFAULT (' '),
[ReplenishUOM3] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishUOM3] DEFAULT ('Y'),
[ReplenishZone3] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishZone3] DEFAULT ('N'),
[CartonizeUOM3] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_CartonizeUOM3] DEFAULT ('N'),
[LengthUOM3] [float] NOT NULL CONSTRAINT [DF_PACK_lengthuom3] DEFAULT ((0)),
[WidthUOM3] [float] NOT NULL CONSTRAINT [DF_PACK_widthuom3] DEFAULT ((0)),
[HeightUOM3] [float] NOT NULL CONSTRAINT [DF_PACK_heightuom3] DEFAULT ((0)),
[CubeUOM3] [float] NOT NULL CONSTRAINT [DF_PACK_CubeUOM3] DEFAULT ((0)),
[PackUOM4] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_PackUOM4] DEFAULT (' '),
[Pallet] [float] NOT NULL CONSTRAINT [DF_PACK_Pallet] DEFAULT ((0)),
[ISWHQty4] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ISWHQty4] DEFAULT (' '),
[ReplenishUOM4] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishUOM4] DEFAULT ('N'),
[ReplenishZone4] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishZone4] DEFAULT ('N'),
[CartonizeUOM4] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_CartonizeUOM4] DEFAULT ('N'),
[LengthUOM4] [float] NOT NULL CONSTRAINT [DF_PACK_lengthuom4] DEFAULT ((0)),
[WidthUOM4] [float] NOT NULL CONSTRAINT [DF_PACK_widthuom4] DEFAULT ((0)),
[HeightUOM4] [float] NOT NULL CONSTRAINT [DF_PACK_heightuom4] DEFAULT ((0)),
[CubeUOM4] [float] NOT NULL CONSTRAINT [DF_PACK_CubeUOM4] DEFAULT ((0)),
[PalletWoodLength] [float] NOT NULL CONSTRAINT [DF_PACK_PalletWoodLength] DEFAULT ((0)),
[PalletWoodWidth] [float] NOT NULL CONSTRAINT [DF_PACK_PalletWoodWidth] DEFAULT ((0)),
[PalletWoodHeight] [float] NOT NULL CONSTRAINT [DF_PACK_PalletWoodHeight] DEFAULT ((0)),
[PalletTI] [int] NOT NULL CONSTRAINT [DF_PACK_PalletTI] DEFAULT ((0)),
[PalletHI] [int] NOT NULL CONSTRAINT [DF_PACK_PalletHI] DEFAULT ((0)),
[PackUOM5] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_PackUOM5] DEFAULT (' '),
[Cube] [float] NOT NULL CONSTRAINT [DF_PACK_Cube] DEFAULT ((0)),
[ISWHQty5] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ISWHQty5] DEFAULT (' '),
[PackUOM6] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_PackUOM6] DEFAULT (' '),
[GrossWgt] [float] NOT NULL CONSTRAINT [DF_PACK_GrossWgt] DEFAULT ((0)),
[ISWHQty6] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ISWHQty6] DEFAULT (' '),
[PackUOM7] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_PackUOM7] DEFAULT (' '),
[NetWgt] [float] NOT NULL CONSTRAINT [DF_PACK_NetWgt] DEFAULT ((0)),
[ISWHQty7] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ISWHQty7] DEFAULT (' '),
[PackUOM8] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PACK_PackUOM8] DEFAULT (' '),
[OtherUnit1] [float] NOT NULL CONSTRAINT [DF_PACK_OtherUnit1] DEFAULT ((0)),
[ISWHQty8] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ISWHQty8] DEFAULT (' '),
[ReplenishUOM8] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishUOM8] DEFAULT ('N'),
[ReplenishZone8] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishZone8] DEFAULT ('N'),
[CartonizeUOM8] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_CartonizeUOM8] DEFAULT ('N'),
[LengthUOM8] [float] NOT NULL CONSTRAINT [DF_PACK_lengthuom8] DEFAULT ((0)),
[WidthUOM8] [float] NOT NULL CONSTRAINT [DF_PACK_widthuom8] DEFAULT ((0)),
[HeightUOM8] [float] NOT NULL CONSTRAINT [DF_PACK_heightuom8] DEFAULT ((0)),
[PackUOM9] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_PackUOM9] DEFAULT (' '),
[OtherUnit2] [float] NOT NULL CONSTRAINT [DF_PACK_OtherUnit2] DEFAULT ((0)),
[ISWHQty9] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ISWHQty9] DEFAULT (' '),
[ReplenishUOM9] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishUOM9] DEFAULT ('N'),
[ReplenishZone9] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_ReplenishZone9] DEFAULT ('N'),
[CartonizeUOM9] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_CartonizeUOM9] DEFAULT ('N'),
[LengthUOM9] [float] NOT NULL CONSTRAINT [DF_PACK_lengthuom9] DEFAULT ((0)),
[WidthUOM9] [float] NOT NULL CONSTRAINT [DF_PACK_widthuom9] DEFAULT ((0)),
[HeightUOM9] [float] NOT NULL CONSTRAINT [DF_PACK_heightuom9] DEFAULT ((0)),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PACK_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PACK_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PACK_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrPackAdd                                                  */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By: When records Added                                        */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/* 03-Mar-2011  SPChin   1.0  SOS#207316 - Allow Pack update            */
/* 29-Mar-2012  NJOW01   1.1  SOS#244886 - Calculate cube by multi-uom  */
/* 21-Jul-2017  TLTING   1.7  SET Option                                */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrPackAdd]
 ON  [dbo].[PACK]
 FOR INSERT
 AS
 BEGIN
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

 /* SOS#207316 Start
 IF UPDATE(TrafficCop)
 BEGIN
 SELECT @n_continue = 4
 END
 IF UPDATE(ArchiveCop)
 BEGIN
 SELECT @n_continue = 4
 END
 SOS#207316 End */

 --SOS#207316 Start
 IF @n_continue = 1 OR @n_continue = 2
  BEGIN
    IF EXISTS (SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
    BEGIN
       SELECT @n_continue = 4
    END
  END
 --SOS#207316 End

      /* #INCLUDE <TRPA_1.SQL> */
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 UPDATE PACK SET
 PACK.CubeUOM1 = dbo.fnc_CalculateCube(INSERTED.LengthUOM1, INSERTED.WidthUOM1, INSERTED.HeightUOM1,'','',''),  --NJOW01
 PACK.CubeUOM2 = dbo.fnc_CalculateCube(INSERTED.LengthUOM2, INSERTED.WidthUOM2, INSERTED.HeightUOM2,'','',''),  --NJOW01 
 PACK.CubeUOM3 = dbo.fnc_CalculateCube(INSERTED.LengthUOM3, INSERTED.WidthUOM3, INSERTED.HeightUOM3,'','',''),  --NJOW01 
 PACK.CubeUOM4 = dbo.fnc_CalculateCube(INSERTED.LengthUOM4, INSERTED.WidthUOM4, INSERTED.HeightUOM4,'','',''),  --NJOW01 
 TrafficCop = NULL
 FROM PACK, INSERTED
 WHERE PACK.PACKKEY = INSERTED.PACKKEY
 END
 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 IF @n_err <> 0
 BEGIN
 SELECT @n_continue = 3
 SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=85700   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Insert Failed On Table PACK. (ntrPackAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
 END
      /* #INCLUDE <TRPA_2.SQL> */
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
 execute nsp_logerror @n_err, @c_errmsg, "ntrPackAdd"
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

/* 14-Jul-2011  KHLim02    1.2   GetRight for Delete log                */
/* 21-Jul-2017  TLTING   1.3  SET Option                                */

CREATE TRIGGER [dbo].[ntrPackDelete]
 ON [dbo].[PACK]
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

 DECLARE @b_Success       int,       -- Populated by calls to stored procedures - was the proc successful?
 @n_err              int,       -- Error number returned by stored procedure or this trigger
 @c_errmsg           NVARCHAR(250), -- Error message returned by stored procedure or this trigger
 @n_continue         int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
 @n_starttcnt        int,       -- Holds the current transaction count
 @n_cnt              int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
,@c_authority        NVARCHAR(1)  -- KHLim02
 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
 IF (select count(*) from DELETED) =
 (select count(*) from DELETED where DELETED.ArchiveCop = '9')
 BEGIN
 SELECT @n_continue = 4
 END
      /* #INCLUDE <TRPD1.SQL> */     
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 IF EXISTS(SELECT *
 FROM DELETED, SKU (nolock), LOT (nolock)
 WHERE DELETED.PackKey = SKU.PackKey
 and SKU.StorerKey = LOT.StorerKey
 and SKU.Sku = LOT.Sku
 and LOT.Qty > 0 )
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err = 86601
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On Pack Failed As There Is Outstanding Product by SKU.PackKey. (ntrPackDelete)"
 END
 END
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 IF EXISTS(SELECT *
 FROM DELETED, SKU (nolock), LOT (nolock), LOTATTRIBUTE (nolock)
 WHERE SKU.OnReceiptCopyPackKey = '1'
 and SKU.StorerKey = LOTATTRIBUTE.StorerKey
 and SKU.Sku = LOTATTRIBUTE.Sku
 and LOTATTRIBUTE.Lot = LOT.Lot
 and LOTATTRIBUTE.Lottable01 = DELETED.PackKey
 and LOT.Qty > 0 )
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err = 86602
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Delete Trigger On Pack Failed As There Is Outstanding Product by Lottable01. (ntrPackDelete)"
 END
 END

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
               ,@c_errmsg = 'ntrPackDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.PACK_DELLOG ( PackKey )
         SELECT PackKey FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table PACK Failed. (ntrPackDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END

      /* #INCLUDE <TRPD2.SQL> */
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
 EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrPackDelete"
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
/* Trigger: ntrPackUpdate                                                  */
/* Creation Date:                                                          */
/* Copyright: IDS                                                          */
/* Written by:                                                             */
/*                                                                         */
/* Purpose:  Update other transactions while PACK line is to be updated.   */
/*                                                                         */
/* Return Status:                                                          */
/*                                                                         */
/* Usage:                                                                  */
/*                                                                         */
/* Called By: When records Updated                                         */
/*                                                                         */
/* PVCS Version: 1.1                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Modifications:                                                          */
/* Date         Author   Ver. Purposes                                     */
/* 14-Jun-2007  YokeBeen 1.0  FBR#78500 - CBM Outbound - (YokeBeen01)      */
/*                            Trigger records into TransmitLog when update */
/*                            on fields - LengthUOM3/WidthUOM3/HeightUOM3. */
/*                            - SQL2005 Changes.                           */
/* 27-Jun-2008  Shong    1.1  Performance Tuning                           */
/* 17-Mar-2009  TLTING   1.2  Change user_name() to SUSER_SNAME()          */
/* 22-May-2012  TLTING01 1.3  DM integrity - add update editdate B4        */
/*                            TrafficCop check                             */  
/* 29-Mar-2012  NJOW01   1.4  SOS#244886 - Calculate cube by multi-uom     */
/*	01-Jun-2012  GTGOH    1.5  SOS#236126 - Add new field for PACKLOG(GOH01)*/
/* 28-Oct-2013  TLTING   1.6  Review Editdate column update                */
/* 21-Jul-2017  TLTING   1.7  SET Option                                   */
/* 07-Aug-2019  WLChooi  1.8  WMS-9809 - Update SKU table from Pack (WL01) */
/* 09-Sep-2020  WLChooi  1.9  WMS-15120 - Update SKU table from Pack for CN*/
/*                            (WL02)                                       */
/* 02-Oct-2020  TLTING02 1.10 EXCEPT replace UPDATE() -actual value changed*/
/***************************************************************************/

CREATE TRIGGER [dbo].[ntrPackUpdate]
ON  [dbo].[PACK]
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
   DECLARE @b_Success int          -- Populated by calls to stored procedures - was the proc successful?
         , @n_err int              -- Error number returned by stored procedure or this trigger
         , @n_err2 int             -- For Additional Error Detection
         , @c_errmsg NVARCHAR(250)     -- Error message returned by stored procedure or this trigger
         , @n_continue int                 
         , @n_starttcnt int        -- Holds the current transaction count
         , @c_preprocess NVARCHAR(250) -- preprocess
         , @c_pstprocess NVARCHAR(250) -- post process
         , @n_cnt int              
         , @c_Country    NVARCHAR(10) = ''  --WL01
         , @c_authority  NVARCHAR(1)  = ''  --WL01  
         , @C_TEST nvarchar(100)  

   -- (YokeBeen01) - Start
   DECLARE @c_Storerkey NVARCHAR(15) 
         , @c_Sku NVARCHAR(20) 
         , @c_PackKey NVARCHAR(10) 
         , @c_authority_owitf NVARCHAR(1)  
         , @c_transmitlogkey NVARCHAR(10) 

   SELECT  @c_Storerkey  = '' 
         , @c_Sku        = ''
         , @c_PackKey    = ''
         , @c_authority_owitf = ''  
   -- (YokeBeen01) - End

   --WL01 Start
   SELECT @c_Country = LTRIM(RTRIM(NSQLValue))
   FROM NSQLConfig (NOLOCK) 
   WHERE Configkey = 'Country'
   --WL01 End

   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

   IF UPDATE(ArchiveCop)
   BEGIN
      SELECT @n_continue = 4 
   END
   
   /* START -- Added by YokeBeen -- 17th-July-2001 */
   IF ( @n_continue = 1 OR @n_continue = 2 )  AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE PACK with (ROWLOCK)
         SET EditDate = GETDATE(),
             EditWho = SUSER_SNAME(),
             TrafficCop = NULL
        FROM PACK, INSERTED
       WHERE PACK.PackKey = INSERTED.PackKey

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=85803   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))
                         +': Update Failed On Table PACK. (ntrPackUpdate)' + ' ( ' 
                         +' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '
      END
   END
   /* END Added */
   
   IF UPDATE(TrafficCop)
   BEGIN
      SELECT @n_continue = 4 
   END

   -- (YokeBeen01) - Start
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      -- Retrieve related info from INSERTED table into a cursor for TransmitLog Insertion 
       DECLARE C_TransmitLogUpdate CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
       SELECT SKU.Storerkey, 
              SKU.SKU, 
              INSERTED.Packkey  
         FROM INSERTED 
         JOIN SKU WITH (NOLOCK) ON (INSERTED.Packkey = SKU.Packkey)
         JOIN STORERCONFIG WITH (NOLOCK) ON (STORERCONFIG.StorerKey = SKU.StorerKey 
                                             AND STORERCONFIG.sValue = '1'
                                             AND STORERCONFIG.ConfigKey = 'OWITF')

   
      OPEN C_TransmitLogUpdate
      FETCH NEXT FROM C_TransmitLogUpdate INTO @c_Storerkey, @c_Sku, @c_PackKey  

      WHILE @@FETCH_STATUS <> -1 
      BEGIN
         -- Check if Pack info was updated
         IF EXISTS ( SELECT 1 FROM INSERTED 
                     JOIN DELETED   ON (INSERTED.Packkey = DELETED.Packkey) 
                     WHERE INSERTED.Packkey = @c_PackKey AND (INSERTED.LengthUOM3 <> DELETED.LengthUOM3 OR 
                                                              INSERTED.WidthUOM3  <> DELETED.WidthUOM3 OR 
                                                              INSERTED.HeightUOM3 <> DELETED.HeightUOM3) )
         BEGIN
            IF NOT EXISTS ( SELECT 1 FROM TRANSMITLOG WITH (NOLOCK) WHERE Key1 = @c_PackKey 
                            AND Key2 = @c_Storerkey AND Key3 = @c_Sku AND TransmitFlag = '0' ) 
            BEGIN 
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
                  SELECT @n_continue = 3 , @n_err = 85801
                  SELECT @c_errmsg = 'ntrPackUpdate: ' + ISNULL(dbo.fnc_RTrim(@c_errmsg),'') 
               END

               IF ( @n_continue = 1 OR @n_continue = 2 ) 
               BEGIN
                  INSERT TRANSMITLOG (Transmitlogkey, Tablename, Key1, Key2, Key3, Transmitflag) 
                  VALUES ( @c_transmitlogkey, 'OWCBM', @c_PackKey, @c_Storerkey, @c_Sku, 0 )

                  SELECT @n_err = @@Error
                  IF NOT @n_err = 0
                  BEGIN
                     SELECT @n_continue = 3
                     SELECT @n_err = 85802
                     SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))+
                                      ': Insert Into TransmitLog Table (OWCBM) Failed (ntrPackUpdate)' + 
                                      ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '
                  END 
               END 
            END -- (Outstanding TransmitLog record not exists) 
         END -- Packkey Exists

         FETCH NEXT FROM C_TransmitLogUpdate INTO @c_Storerkey, @c_Sku, @c_PackKey 
      END -- WHILE @@FETCH_STATUS <> -1 
      CLOSE C_TransmitLogUpdate
      DEALLOCATE C_TransmitLogUpdate 
   END -- @n_continue = 1 OR @n_continue = 2
   -- (YokeBeen01) - End

   /* #INCLUDE <TRPU_1.SQL> */  
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      --TLTING02
      IF EXISTS (
           SELECT PackUOM1, Casecnt, PackUOM2, InnerPack, PackUOM3, Qty, PackUOM4, Pallet, LengthUOM1, WidthUOM1, 
           HeightUOM1, CubeUOM1  FROM inserted
           EXCEPT
           SELECT PackUOM1, Casecnt, PackUOM2, InnerPack, PackUOM3, Qty, PackUOM4, Pallet, LengthUOM1, WidthUOM1, 
           HeightUOM1, CubeUOM1 FROM deleted
          ) 
       BEGIN 
         INSERT INTO PACKLOG ( PackKey, PackDescr
                        , OldPackUOM1, OldCaseCnt, PackUOM1, CaseCnt
                        , OLDPackUOM2, OLDInnerPack, PackUOM2, InnerPack
                        , OLDPackUOM3, OLDQty, PackUOM3, Qty
                        , OLDPackUOM4, OLDPallet, PackUOM4, Pallet
                        , EditDate, EditWho
                        , OLDLengthUOM1, LengthUOM1, OLDWidththUOM1, WidthUOM1
                        , OLDHeightUOM1, HeightUOM1, OLDCubeUOM1, CubeUOM1 
                         )
         SELECT INSERTED.Packkey, INSERTED.PackDescr, 
                DELETED.PackUOM1, DELETED.Casecnt,   INSERTED.PackUOM1, INSERTED.Casecnt,
                DELETED.PackUOM2, DELETED.InnerPack, INSERTED.PackUOM2, INSERTED.InnerPack, 
                DELETED.PackUOM3, DELETED.Qty,       INSERTED.PackUOM3, INSERTED.Qty, 
                DELETED.PackUOM4, DELETED.Pallet,    INSERTED.PackUOM4, INSERTED.Pallet, 
                GETDATE(), SUSER_SNAME() 
               ,DELETED.LengthUOM1, INSERTED.LengthUOM1, DELETED.WidthUOM1, INSERTED.WidthUOM1, 
                DELETED.HeightUOM1, INSERTED.HeightUOM1, DELETED.CubeUOM1, 
					 dbo.fnc_CalculateCube(INSERTED.LengthUOM1, INSERTED.WidthUOM1, INSERTED.HeightUOM1,'','','') 
           FROM INSERTED 
           JOIN DELETED ON (INSERTED.PACKKEY = DELETED.PACKKEY)
      END

      --TLTING02
      IF EXISTS (
           SELECT LengthUOM1, WidthUOM1, HeightUOM1, LengthUOM2, WidthUOM2, HeightUOM2,  LengthUOM3, WidthUOM3, HeightUOM3
           , LengthUOM4, WidthUOM4, HeightUOM4 FROM inserted
           EXCEPT
           SELECT LengthUOM1, WidthUOM1, HeightUOM1, LengthUOM2, WidthUOM2, HeightUOM2,  LengthUOM3, WidthUOM3, HeightUOM3
           , LengthUOM4, WidthUOM4, HeightUOM4 FROM deleted
          ) 
          
   /*   IF UPDATE(LengthUOM1) OR UPDATE(WidthUOM1) OR UPDATE(HeightUOM1) OR
         UPDATE(LengthUOM2) OR UPDATE(WidthUOM2) OR UPDATE(HeightUOM2) OR
         UPDATE(LengthUOM3) OR UPDATE(WidthUOM3) OR UPDATE(HeightUOM3) OR
         UPDATE(LengthUOM4) OR UPDATE(WidthUOM4) OR UPDATE(HeightUOM4) */
      BEGIN 
         UPDATE PACK SET
                PACK.CubeUOM1 = dbo.fnc_CalculateCube(INSERTED.LengthUOM1, INSERTED.WidthUOM1, INSERTED.HeightUOM1,'','',''),  --NJOW01
                PACK.CubeUOM2 = dbo.fnc_CalculateCube(INSERTED.LengthUOM2, INSERTED.WidthUOM2, INSERTED.HeightUOM2,'','',''),  --NJOW01
                PACK.CubeUOM3 = dbo.fnc_CalculateCube(INSERTED.LengthUOM3, INSERTED.WidthUOM3, INSERTED.HeightUOM3,'','',''),  --NJOW01
                PACK.CubeUOM4 = dbo.fnc_CalculateCube(INSERTED.LengthUOM4, INSERTED.WidthUOM4, INSERTED.HeightUOM4,'','','')   --NJOW01
           FROM PACK WITH (NOLOCK) 
           JOIN INSERTED ON (PACK.PACKKEY = INSERTED.PACKKEY)
      END 
   END

   SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
   IF @n_err <> 0
   BEGIN
      SELECT @n_continue = 3
      SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=85802   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),ISNULL(@n_err,0))
                      +': Update Failed On Table PACK. (ntrPackUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' 
                      + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '
   END

   --WL01 Start
   --IF (@n_continue = 1 OR @n_continue = 2) AND @c_Country = 'SG'   --WL02
   IF (@n_continue = 1 OR @n_continue = 2) AND @c_Country IN ('SG','CN')   --WL02
   BEGIN
      --TLTING02
      IF EXISTS (
           SELECT GrossWgt, NetWgt, LengthUOM3, WidthUOM3, HeightUOM3, LengthUOM1, WidthUOM1, HeightUOM1, CubeUOM3, CubeUOM1 
           FROM inserted
           EXCEPT
           SELECT GrossWgt, NetWgt, LengthUOM3, WidthUOM3, HeightUOM3, LengthUOM1, WidthUOM1, HeightUOM1, CubeUOM3, CubeUOM1
           FROM deleted
          ) 
  /*    IF UPDATE(GrossWgt) OR UPDATE(NetWgt) OR
         UPDATE(LengthUOM3) OR UPDATE(WidthUOM3) OR UPDATE(HeightUOM3) OR
         UPDATE(LengthUOM1) OR UPDATE(WidthUOM1) OR UPDATE(HeightUOM1) OR
         UPDATE(CubeUOM3) OR UPDATE(CubeUOM1)*/
      BEGIN
         DECLARE cur_UpdateSKUFromPack CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT SKU.StorerKey, SKU.SKU, SKU.PACKKey
         FROM INSERTED
         JOIN SKU (NOLOCK) ON (SKU.PACKKey = INSERTED.PackKey)

         OPEN cur_UpdateSKUFromPack

         FETCH NEXT FROM cur_UpdateSKUFromPack INTO @c_Storerkey, @c_SKU, @c_PACKKey

         WHILE @@FETCH_STATUS <> -1
         BEGIN 
               EXEC nspGetRight   
               ''                   -- facility  
            ,  @c_Storerkey         -- Storerkey  
            ,  NULL                 -- Sku  
            ,  'UpdateSKUFromPack'   -- Configkey  
            ,  @b_Success           OUTPUT   
            ,  @c_authority         OUTPUT   
            ,  @n_Err               OUTPUT   
            ,  @c_ErrMsg            OUTPUT 
            
            IF @b_success <> 1  
            BEGIN  
               SET @n_continue = 3  
               SET @n_err = 85803   
               SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Error Executing nspGetRight. (ntrPackUpdate)'   
                           + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg),'') + ' ) '    
            END
            
            --WL02 START
            IF @c_authority = 1 AND @c_Country = 'SG'   --WL02 
            BEGIN
               UPDATE SKU WITH (ROWLOCK)
               SET SKU.StdGrossWgt = INSERTED.GrossWgt,
                   SKU.StdCube     = CAST(((INSERTED.LengthUOM3 * INSERTED.WidthUOM3 * INSERTED.HeightUOM3) / 1000000) AS DECIMAL(30,6)),
                   SKU.GrossWgt    = INSERTED.NetWgt,
                   SKU.[Cube]      = CAST(((INSERTED.LengthUOM1 * INSERTED.WidthUOM1 * INSERTED.HeightUOM1) / 1000000) AS DECIMAL(30,6))
               FROM SKU
               JOIN INSERTED WITH (NOLOCK) ON (INSERTED.Packkey = SKU.Packkey)
               WHERE SKU.StorerKey = @c_Storerkey AND SKU.SKU = @c_SKU AND SKU.PACKKey = @c_PACKKey
            END
            ELSE IF @c_authority = 1 AND @c_Country = 'CN'
            BEGIN
               UPDATE SKU WITH (ROWLOCK)
               SET SKU.StdGrossWgt = INSERTED.GrossWgt,
                   SKU.StdCube     = (CAST(((INSERTED.LengthUOM1 * INSERTED.WidthUOM1 * INSERTED.HeightUOM1) / 1000000) AS DECIMAL(30,6)) / INSERTED.Casecnt),
                   SKU.GrossWgt    = INSERTED.NetWgt,
                   SKU.[Cube]      = CAST(((INSERTED.LengthUOM1 * INSERTED.WidthUOM1 * INSERTED.HeightUOM1) / 1000000) AS DECIMAL(30,6)),
                   SKU.Measurement = NULL
               FROM SKU
               JOIN INSERTED WITH (NOLOCK) ON (INSERTED.Packkey = SKU.Packkey)
               WHERE SKU.StorerKey = @c_Storerkey AND SKU.SKU = @c_SKU AND SKU.PACKKey = @c_PACKKey AND SKU.Measurement = 'new'
            END
            --WL02 END
            FETCH NEXT FROM cur_UpdateSKUFromPack INTO @c_Storerkey, @c_SKU, @c_PACKKey
         END
         CLOSE cur_UpdateSKUFromPack
         DEALLOCATE cur_UpdateSKUFromPack
      END
   END
   --WL01 End
QUIT_SP:
   /* #INCLUDE <TRPU_2.SQL> */
   IF @n_continue=3  -- Error Occured - Process And Return
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

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrPackUpdate'
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
ALTER TABLE [dbo].[PACK] WITH NOCHECK ADD CONSTRAINT [CK_Pack_NoDuplicates1] CHECK ((isnull(rtrim([PackUOM1]),' ')=' ' OR isnull(rtrim([PackUOM4]),' ')=' ' OR rtrim([PackUOM1])<>rtrim([PackUOM4])))
GO
ALTER TABLE [dbo].[PACK] WITH NOCHECK ADD CONSTRAINT [CK_Pack_NoDuplicates2] CHECK ((isnull(rtrim([PackUOM2]),' ')=' ' OR isnull(rtrim([PackUOM3]),' ')=' ' OR rtrim([PackUOM2])<>rtrim([PackUOM3])))
GO
ALTER TABLE [dbo].[PACK] ADD CONSTRAINT [PKPack] PRIMARY KEY CLUSTERED ([PackKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PACK] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PACK] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PACK] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PACK] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PACK] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Together with UOM(s), the pack codes are used to determine the measurements in which the WMS uses to track products in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'PACK', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Check box that determines whether cartonization routines run for each UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'CartonizeUOM3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Determines how many master units are in this UOM. When defining the master unit, this value is always one (1)', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'CaseCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'cube', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'grosswgt', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'GrossWgt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'HeightUOM1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'HeightUOM2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'HeightUOM3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'HeightUOM4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'HeightUOM8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Height:', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'HeightUOM9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Determines how many master units are in this UOM. When defining the master unit, this value is always one (1)', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'InnerPack'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'LengthUOM1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'LengthUOM2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'LengthUOM3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'LengthUOM4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'LengthUOM8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'netwgt', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'NetWgt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Determines how many master units are in this UOM. When defining the master unit, this value is always one (1)', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'OtherUnit1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'otherunit2', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'OtherUnit2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Text describing the pack code', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PackDescr'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the pack', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lists all of the codes in the general code list relative to the UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PackUOM1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lists all of the codes in the general code list relative to the UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PackUOM2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lists all of the codes in the general code list relative to the UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PackUOM3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lists all of the codes in the general code list relative to the UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PackUOM4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'packuom5', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PackUOM5'
GO
EXEC sp_addextendedproperty N'MS_Description', 'packuom6', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PackUOM6'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lists all of the codes in the general code list relative to the UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PackUOM8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Determines how many master units are in this UOM. When defining the master unit, this value is always one (1)', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'Pallet'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of tiers per pallet', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PalletHI'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Number of cases per tier', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PalletTI'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the physical pallet wood', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PalletWoodHeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the physical pallet wood', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PalletWoodLength'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the physical pallet wood', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'PalletWoodWidth'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Determines how many master units are in this UOM. When defining the master unit, this value is always one (1)', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'replenishuom1', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'ReplenishUOM1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'replenishuom2', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'ReplenishUOM2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Check box that determines whether replenishment routings run for each UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'ReplenishUOM3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Location from which an item is selected', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'ReplenishZone1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Location from which an item is selected', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'ReplenishZone2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Location from which an item is selected', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'ReplenishZone3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Location from which an item is selected', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'ReplenishZone4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Location from which an item is selected', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'ReplenishZone8'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Location from which an item is selected', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'ReplenishZone9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'WidthUOM1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'WidthUOM2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'WidthUOM3'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'WidthUOM4'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Dimensions associated with the specific UOM', 'SCHEMA', N'dbo', 'TABLE', N'PACK', 'COLUMN', N'WidthUOM8'
GO
