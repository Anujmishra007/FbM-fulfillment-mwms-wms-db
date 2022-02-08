CREATE TABLE [dbo].[PODETAIL]
(
[POKey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[POLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PODetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_PODetailKey] DEFAULT (' '),
[ExternPOKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_ExternPOKey] DEFAULT (' '),
[ExternLineNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_ExternLineNo] DEFAULT (' '),
[MarksContainer] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_MarksContainer] DEFAULT (' '),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Sku] DEFAULT (' '),
[SKUDescription] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_SKUDescription] DEFAULT (' '),
[ManufacturerSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_ManufacturerSku] DEFAULT (' '),
[RetailSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_RetailSku] DEFAULT (' '),
[AltSku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_AltSku] DEFAULT (' '),
[QtyOrdered] [int] NULL CONSTRAINT [DF_PODETAIL_QtyOrdered] DEFAULT ((0)),
[QtyAdjusted] [int] NULL CONSTRAINT [DF_PODETAIL_QtyAdjusted] DEFAULT ((0)),
[QtyReceived] [int] NULL CONSTRAINT [DF_PODETAIL_QtyReceived] DEFAULT ((0)),
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PODETAIL_PackKey] DEFAULT ('STD'),
[UnitPrice] [float] NULL CONSTRAINT [DF_PODETAIL_UnitPrice] DEFAULT ((0)),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_UOM] DEFAULT (' '),
[Notes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveDate] [datetime] NOT NULL CONSTRAINT [DF_PODETAIL_EffectiveDate] DEFAULT (getdate()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PODETAIL_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PODETAIL_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PODETAIL_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PODETAIL_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POLineStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_POLineStatus] DEFAULT ('OPEN'),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Facility] DEFAULT (' '),
[shortcode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Best_bf_Date] [datetime] NULL CONSTRAINT [DF_PODETAIL_Best_bf_Date] DEFAULT (getdate()),
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Lottable01] DEFAULT (' '),
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Lottable02] DEFAULT (' '),
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Lottable03] DEFAULT (' '),
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_UserDefine08] DEFAULT (' '),
[UserDefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_UserDefine10] DEFAULT (' '),
[ToId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODetail_ToId] DEFAULT (' '),
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Lottable06] DEFAULT (''),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Lottable07] DEFAULT (''),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Lottable08] DEFAULT (''),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Lottable09] DEFAULT (''),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Lottable10] DEFAULT (''),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Lottable11] DEFAULT (''),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Lottable12] DEFAULT (''),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL,
[Channel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PODETAIL_Channel] DEFAULT ('')
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PODETAIL] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PODETAIL] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PODETAIL] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PODETAIL] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PODETAIL] TO [NSQL]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: ntrPODetailAdd                                      */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purpose: normal receipt                                              */
/*                                                                      */
/* Called from: 3                                                       */
/*    1. From PowerBuilder                                              */
/*    2. From scheduler                                                 */
/*    3. From others stored procedures or triggers                      */
/*    4. From interface program. DX, DTS                                */
/*                                                                      */
/* Exceed version: 5.4                                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev  Author    Purposes                                   */
/* 2002-08-05 1.0  admin     Initial version                            */
/* 2003-09-16 1.1  wtshong   SOS# 14983 PO Header did not update        */
/*                           Supplier code                              */
/* 2003-09-16 1.2  wtshong   Bugs fixing                                */
/* 2006-06-17 1.3  ung       SOS53688 Retrieve archived PO              */
/*                           Added ArchiveCop                           */
/* 2009-06-16 1.4  Rick Liew SOS96737 - Remove hardcoding for C4LGMY		*/
/* 2014-08-26 1.5  YTWan     SOS#319232 - TH-PO not allow to add        */
/*                           Invactive-SKU. (Wan01)                     */
/* 2017-07-27 1.6  TLTING   1.1  SET Option, missing nolock             */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrPODetailAdd]
ON  [dbo].[PODETAIL]
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
,       @c_storerkey NVARCHAR(15)
,       @c_authority   NVARCHAR(1)

DECLARE @c_primaryPDKey NVARCHAR(15), @c_POKey NVARCHAR(20), @c_Poline NVARCHAR(20),
      @n_rowcount int, @c_TransmitLogKey NVARCHAR(10)
      ,  @c_PODisallowInactiveSku   NVARCHAR(10)      --(Wan01)
      ,  @c_InactiveSku             NVARCHAR(20)      --(Wan01)

SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

-- SOS53688 Added ArchiveCop
IF EXISTS( SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
   SELECT @n_continue = 4

   /* #INCLUDE <TRPODA1.SQL> */
/* 12.9.99 WALLY - copy externpokey of header */
/*
IF @n_continue = 1 or @n_continue=2
BEGIN
DECLARE @n_lineno int
SELECT @n_lineno = MAX(CONVERT(int,PODetail.externlineno)) + 1
FROM PODetail, INSERTED
WHERE PODetail.pokey = INSERTED.pokey
UPDATE PODetail
SET PODetail.externpokey = PO.externpokey, PODetail.externlineno = @n_lineno
FROM PO, PODETAIL, INSERTED
WHERE PO.pokey = INSERTED.pokey
AND PODETAIL.pokey = PO.pokey
AND PODETAIL.polinenumber = INSERTED.polinenumber
SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
IF @n_err <> 0
BEGIN
SELECT @n_continue = 3
SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=64603   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Insert failed on table PO. (ntrPODetailAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
END
END
*/

--(Wan01) - START
IF @n_continue=1 or @n_continue=2
BEGIN
   SELECT TOP 1 @c_Storerkey = Storerkey
   FROM   INSERTED

   SET @c_PODisAllowInactiveSku = 0
   SET @b_success = 0
   Execute nspGetRight null   -- facility
           ,  @c_StorerKey    -- Storerkey
           ,  null            -- Sku
           ,  'PODisallowInactiveSku'    -- Configkey
           ,  @b_success               OUTPUT
           ,  @c_PODisAllowInactiveSku OUTPUT
           ,  @n_err                   OUTPUT
           ,  @c_errmsg                OUTPUT
   IF @b_success <> 1
   BEGIN
      SET @n_continue = 3
      SET @c_errmsg = 'ntrPODetailAdd ' + RTRIM(@c_errmsg)
   END
   ELSE IF @c_PODisAllowInactiveSku = '1'
   BEGIN
      SET @c_InactiveSku = ''
      SELECT TOP 1 @c_InactiveSku = RTRIM(SKU.Sku)
      FROM INSERTED 
      JOIN SKU WITH (NOLOCK) ON (INSERTED.Storerkey = SKU.Storerkey) 
                             AND(INSERTED.Sku = SKU.Sku)
      WHERE SKU.SkuStatus = 'Inactive'

      IF @c_InactiveSku <> '' 
      BEGIN
         SET @n_continue = 3
         SET @c_errmsg = 'ntrPODetailAdd. Disallow Inactive Sku: ' + RTRIM(@c_InactiveSku) + 'add to PO.'
      END
   END
END  
--(Wan01) - END

-- Added for IDSV5 by June 21.Jun.02, (extract from IDSSG) *** Start
IF @n_continue=1 or @n_continue=2
BEGIN
   SELECT @c_Storerkey = Storerkey
   FROM   Inserted

   SELECT @b_success = 0
   Execute nspGetRight null,  -- facility
             @c_StorerKey,    -- Storerkey
             null,            -- Sku
             'EXTPOKEYUPD',   -- Configkey
             @b_success    output,
             @c_authority  output,
             @n_err        output,
             @c_errmsg     output
   IF @b_success <> 1
   BEGIN
      SELECT @n_continue = 3, @c_errmsg = 'ntrPODetailAdd' + dbo.fnc_RTrim(@c_errmsg)
   END
   ELSE IF @c_authority = '1'
   BEGIN
    /* Added by YokeBeen (4-October-2001) - Ticket # 1876
      To update the ExternPOKey in PODETAIL when the new PO is being created
      - START */
    UPDATE PODetail WITH (ROWLOCK)
       SET PODetail.EXTERNPOKEY = PO.EXTERNPOKEY
    FROM PO (NOLOCK), PODETAIL, INSERTED
    WHERE PO.pokey = INSERTED.pokey
      AND PODETAIL.pokey = INSERTED.pokey
      AND PODETAIL.polinenumber = INSERTED.polinenumber
    /* - END */
   END
END -- Added for IDSV5 by June 21.Jun.02, (extract from IDSSG) *** End

-- Added by Ricky for carrefour CrossDock Impl.
IF @n_continue=1 or @n_continue=2
BEGIN
   SELECT @c_Storerkey = Storerkey
   FROM   Inserted

   SELECT @b_success = 0, @c_authority = 0

   Execute nspGetRight null,  -- facility
             @c_StorerKey,    -- Storerkey
             null,            -- Sku
             'XDLottable02Link',   -- Configkey
             @b_success    output,
             @c_authority  output,
             @n_err        output,
             @c_errmsg     output

   IF @b_success <> 1
   BEGIN
      SELECT @n_continue = 3, @c_errmsg = 'ntrPODetailAdd' + dbo.fnc_RTrim(@c_errmsg)
   END
   ELSE IF @c_authority = '1'
   BEGIN
    UPDATE PODetail
       SET PODetail.LOTTABLE02 = PO.EXTERNPOKEY,
           PODetail.Trafficcop = NULL
    FROM PO (NOLOCK), PODETAIL, INSERTED
    WHERE PO.pokey = INSERTED.pokey
      AND PODETAIL.pokey = INSERTED.pokey
      AND PODETAIL.polinenumber = INSERTED.polinenumber
      AND PO.POTYPE IN ('5', '8')
   END
END

/* 2 Dec 2004 YTWan C4- Populate Externpokey to Lottable03 - Start */
IF @n_continue=1 or @n_continue=2
BEGIN
   SELECT @b_success = 0, @c_authority = 0

   Execute nspGetRight null,  -- facility
             @c_StorerKey,    -- Storerkey
             null,            -- Sku
             'XDLottable03Link',   -- Configkey
             @b_success    output,
             @c_authority  output,
             @n_err        output,
             @c_errmsg     output

   IF @b_success <> 1
   BEGIN
      SELECT @n_continue = 3, @c_errmsg = 'ntrPODetailAdd' + dbo.fnc_RTrim(@c_errmsg)
   END
   ELSE IF @c_authority = '1'
   BEGIN
	 -- Start : SOS96737
	 /*      
    UPDATE PODetail
       SET PODetail.LOTTABLE03 = PO.EXTERNPOKEY,
           PODetail.Trafficcop = NULL
    FROM PO (NOLOCK), PODETAIL, INSERTED
    WHERE PO.pokey = INSERTED.pokey
      AND PODETAIL.pokey = INSERTED.pokey
      AND PODETAIL.polinenumber = INSERTED.polinenumber
      AND PO.POTYPE IN ('5', '6', '8', '8A')
    */
    UPDATE PODetail
       SET PODetail.LOTTABLE03 = PO.EXTERNPOKEY,
           PODetail.Trafficcop = NULL
    FROM PO (NOLOCK), PODETAIL, CODELKUP (NOLOCK), INSERTED
    WHERE PO.pokey = INSERTED.pokey
      AND PODETAIL.pokey = INSERTED.pokey
      AND PODETAIL.polinenumber = INSERTED.polinenumber
		AND PO.POTYPE = CODELKUP.CODE
	   AND CODELKUP.LISTNAME = 'Lot03Link'
	 -- End : SOS96737    
   END
END
/* 2 Dec 2004 YTWan C4- Populate Externpokey to Lottable03 - End */

IF @n_continue=1 or @n_continue=2
BEGIN
   SELECT @c_Storerkey = Storerkey
   FROM   Inserted

   SELECT @b_success = 0, @c_authority = 0

   Execute nspGetRight null,  -- facility
             @c_StorerKey,    -- Storerkey
             null,            -- Sku
             'XDOCKSKUEXISTINWHALERT',   -- Configkey
             @b_success    output,
             @c_authority  output,
             @n_err        output,
             @c_errmsg     output

   IF @b_success <> 1
   BEGIN
      SELECT @n_continue = 3, @c_errmsg = 'ntrPODetailAdd' + dbo.fnc_RTrim(@c_errmsg)
   END
   ELSE IF @c_authority = '1'
   BEGIN
      IF (SELECT count(*) FROM INSERTED
            JOIN SKUXLOC (Nolock)
                  ON INSERTED.STORERKEY = SKUXLOC.STORERKEY
                 AND INSERTED.SKU = SKUXLOC.SKU
            JOIN LOC WITH (NOLOCK)
                  ON SKUXLOC.LOC = LOC.LOC
           WHERE SKUXLOC.STORERKEY = @c_StorerKey
             AND LOC.Locationflag = 'NONE'
             AND SKUXLOC.QTY - SKUXLOC.QtyAllocated - SKUXLOC.QtyPicked > 0) > 0
      BEGIN
         -- Create the log for the Alert (VB) to pick up
         SELECT @c_primaryPDKey = ''
         WHILE (1=1)
         BEGIN
            SET ROWCOUNT 1

            SELECT @c_primaryPDKey = dbo.fnc_RTrim(INSERTED.POKey)+dbo.fnc_RTrim(INSERTED.POLineNumber),
                   @c_POKey = dbo.fnc_RTrim(INSERTED.POKey),
                   @c_Poline = dbo.fnc_RTrim(INSERTED.POLineNumber)
              FROM INSERTED
              JOIN SKUXLOC (Nolock)
                   ON INSERTED.STORERKEY = SKUXLOC.STORERKEY
                   AND INSERTED.SKU = SKUXLOC.SKU
              JOIN LOC WITH (NOLOCK)
                   ON SKUXLOC.LOC = LOC.LOC
             WHERE SKUXLOC.STORERKEY = @c_StorerKey
               AND LOC.Locationflag = 'NONE'
               AND SKUXLOC.QTY - SKUXLOC.QtyAllocated - SKUXLOC.QtyPicked > 0
               AND dbo.fnc_RTrim(INSERTED.POKey)+dbo.fnc_RTrim(INSERTED.POLineNumber) > @c_primaryPDKey
            ORDER BY POKey, POLineNumber

            SELECT @n_rowcount = @@ROWCOUNT

            SET ROWCOUNT 0

            IF @n_rowcount = 0 Break

            IF NOT EXISTS (SELECT 1 FROM TRANSMITLOG2 (NOLOCK)
                            WHERE TableName = 'SOHALERT'
                              AND key1 = @c_POKey
                              AND Key2 = @c_Poline )
            BEGIN
               SELECT @c_TransmitLogKey=''
               SELECT @b_success=1

               EXECUTE nspg_getkey
                  'TransmitLogKey2'
                  , 10
                  , @c_TransmitLogKey OUTPUT
                  , @b_success OUTPUT
                  , @n_err OUTPUT
                  , @c_errmsg OUTPUT

               IF NOT @b_success=1
               BEGIN
                  SELECT @n_continue=3
               END

               IF ( @n_continue = 1 or @n_continue = 2 )
               BEGIN -- @n_continue inner loop
                  INSERT TransmitLog2 (TransmitLogKey,    tablename,  key1,  key2, key3)
                  VALUES (@c_TransmitLogKey, 'SOHALERT', @c_POKey, @c_Poline, @c_Storerkey )

                  SELECT @n_err= @@Error
                  IF NOT @n_err=0
                  BEGIN
                     SELECT @n_continue=3
                     Select @c_errmsg= CONVERT(char(250), @n_err), @n_err=22806
                     Select @c_errmsg= "NSQL"+CONVERT(char(5), @n_err)+":Insert failed on TransmitLog2. (ntrPodetailAdd)"+"("+"SQLSvr MESSAGE="+dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg))+")"
                  END
               END
            END
         END -- End While Loop
      END
   END
END

IF @n_continue = 1 or @n_continue=2
BEGIN
   DECLARE @n_insertedcount int
   SELECT @n_insertedcount = (select count(*) FROM inserted)
   IF @n_insertedcount = 1
   BEGIN
      UPDATE PO
      SET  PO.OpenQty = PO.OpenQty + (INSERTED.QtyOrdered - INSERTED.QtyReceived)
      FROM PO, INSERTED
      WHERE PO.POKey = INSERTED.POKey
   END
   ELSE
   BEGIN
      UPDATE PO SET PO.OpenQty
      = (Select Sum(PODetail.QtyOrdered - PODetail.QtyReceived)
      From PODETAIL WITH (NOLOCK)
      Where PODetail.PoKey = PO.PoKey)
      FROM PO,INSERTED
      WHERE PO.POkey IN (Select Distinct POkey From Inserted)
      AND PO.POkey = Inserted.POkey
   END
   SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
   IF @n_err <> 0
   BEGIN
      SELECT @n_continue = 3
      SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=64603   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Insert failed on table PO. (ntrPODetailAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
   END
   ELSE IF @n_cnt = 0
   BEGIN
      SELECT @n_continue = 3
      SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=64604   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Zero rows affected updating table PO. (ntrPODetailAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
   END
END  

/* #INCLUDE <TRPODA2.SQL> */
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
   execute nsp_logerror @n_err, @c_errmsg, "ntrPODetailAdd"
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
/* Trigger: ntrPODetailDelete                                           */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:  Update/Delete other transactions while PODetail line is    */
/*           to be deleted.                                             */
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Return Status:                                                       */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When records deleted                                      */
/*                                                                      */
/* PVCS Version: 1.2                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author     Purposes                                     */
/* 01-Jun-2005  YokeBeen   For NSC PO/UCC Inbound - (YokeBeen01)        */
/*                         Purge the records from the UCC table as the  */
/*                         podetail lines being purged.                 */
/* 16-Feb-2007  YokeBeen   For WMS-E1 Inbound - (YokeBeen02)            */
/*                         Having check on the PODetail.QtyReceived in  */
/*                         order to proceed with the valid deletion of  */
/*                         PODetail lines for E1 Storers. - (SOS#66639) */
/* 28-Apr-2011  KHLim01    Insert Delete log                            */
/* 14-Jul-2011  KHLim02    GetRight for Delete log                      */
/* 27-Jul-2017  TLTING   1.1  SET Option, missing nolock                */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrPODetailDelete]  
ON [dbo].[PODETAIL]  
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

	DECLARE @b_debug int  
	SELECT @b_debug = 0  

	IF @b_debug = 1  
	BEGIN  
		SELECT "DELETED ", POKey, POLineNumber, StorerKey, Sku FROM DELETED  
	END  

	DECLARE @b_Success      int,       -- Populated by calls to stored procedures - was the proc successful?  
			@n_err            int,       -- Error number returned by stored procedure or this trigger  
			@c_errmsg         NVARCHAR(250), -- Error message returned by stored procedure or this trigger  
			@n_continue       int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing  
			@n_starttcnt      int,       -- Holds the current transaction count  
			@n_cnt            int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.  
        ,@c_authority      NVARCHAR(1)  -- KHLim02

	SELECT @n_continue	= 1, 
			 @n_starttcnt	= @@TRANCOUNT,  
			 @b_Success		= 0,
			 @n_err			= 0,
			 @c_errmsg		= '',
			 @n_cnt			= 0

	IF (SELECT COUNT(*) FROM DELETED) = (SELECT COUNT(*) FROM DELETED WHERE DELETED.ArchiveCop = '9')  
	BEGIN  
		SELECT @n_continue = 4  
	END  

	/* #INCLUDE <TRPODD1.SQL> */       
	IF @n_continue = 1 OR @n_continue = 2  
	BEGIN  
      -- (YokeBeen02) - Start
		IF EXISTS (SELECT 1 FROM DELETED JOIN STORERCONFIG WITH (NOLOCK) ON (DELETED.Storerkey = STORERCONFIG.Storerkey) 
                  WHERE STORERCONFIG.ConfigKey = 'OWITF' AND STORERCONFIG.sValue = '1' 
                    AND (DELETED.QtyReceived > 0 OR DELETED.QtyReceived = 0))  
		BEGIN  
       UPDATE PO  
          SET Status = '9', 
              ExternStatus = 'CANC', 
              TrafficCop = NULL 
         FROM DELETED 
         JOIN PO WITH (NOLOCK) ON (DELETED.POKey = PO.POKey) 
         JOIN STORERCONFIG WITH (NOLOCK) ON (PO.Storerkey = STORERCONFIG.Storerkey AND STORERCONFIG.ConfigKey = 'OWITF' 
                                   AND STORERCONFIG.sValue = '1') 
        WHERE NOT EXISTS (SELECT 1 FROM PODETAIL WITH (NOLOCK) WHERE PODETAIL.POKey = DELETED.POKey 
                                                            AND PO.POKey = DELETED.POKey) 
      END 
      -- (YokeBeen02) - End 
      ELSE IF EXISTS (SELECT 1 FROM DELETED WHERE DELETED.QtyReceived > 0)  
      BEGIN 
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 64801   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg="NSQL"+CONVERT(CHAR(5),@n_err)+": Delete Trigger On Table PODETAIL Failed - QtyReceived must be zero. (ntrPODetailDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "  
		END  
	END  

	IF @n_continue = 1 OR @n_continue = 2  
	BEGIN  
		DELETE CASEMANIFEST  
		  FROM CASEMANIFEST, DELETED  
		 WHERE CASEMANIFEST.StorerKey = DELETED.StorerKey  
			AND CASEMANIFEST.Sku = DELETED.Sku  
			AND CASEMANIFEST.ExpectedPOKey = DELETED.POKey  

		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  

		IF @n_err <> 0  
		BEGIN  
			SELECT @n_continue = 3  
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 64203   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
			SELECT @c_errmsg="NSQL"+CONVERT(CHAR(5),@n_err)+": Delete Trigger On Table CASEMANIFEST Failed - QtyReceived must be zero. (ntrPODetailDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "  
		END  
		ELSE IF @b_debug = 1  
		BEGIN  
			SELECT @n_cnt  

			SELECT StorerKey, Sku, ExpectedPOKey  
			  FROM CASEMANIFEST  WITH (NOLOCK)

			SELECT StorerKey, Sku, POKey  
			  FROM DELETED  
		END  
	END  

	-- (YokeBeen01) - Start
	IF @n_continue = 1 OR @n_continue = 2  
	BEGIN  
		IF EXISTS ( SELECT 1 FROM UCC WITH (NOLOCK) JOIN DELETED ON (UCC.Storerkey = DELETED.Storerkey 
							AND UCC.SourceKey = (CONVERT(CHAR(10),DELETED.POKey) + CONVERT(CHAR(5),DELETED.POLineNumber))) 
						 WHERE UCC.SourceType = 'PO' )
		BEGIN
			DELETE UCC  
			  FROM UCC WITH (NOLOCK) 
			  JOIN DELETED ON (UCC.Storerkey = DELETED.Storerkey 
								AND UCC.SourceKey = (CONVERT(CHAR(10),DELETED.POKey) + CONVERT(CHAR(5),DELETED.POLineNumber))) 
			 WHERE UCC.SourceType = 'PO' 

			SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  

			IF @n_err <> 0  
			BEGIN  
				SELECT @n_continue = 3  
				SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 64204   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
				SELECT @c_errmsg="NSQL"+CONVERT(CHAR(5),@n_err)+": Delete Trigger On Table UCC Failed. (ntrPODetailDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "  
			END  
			ELSE IF @b_debug = 1  
			BEGIN  
				SELECT @n_cnt  

				SELECT StorerKey, Sku, SourceKey  
				  FROM UCC  WITH (NOLOCK)

				SELECT StorerKey, Sku, POKey, POLineNumber  
				  FROM DELETED  
			END  
		END -- If record exists
	END  
	-- (YokeBeen01) - End

	IF @n_continue = 1 OR @n_continue=2  
	BEGIN  
		DECLARE @n_deletedcount int  
		SELECT @n_deletedcount = (SELECT count(*) FROM deleted)  

		IF @n_deletedcount = 1  
		BEGIN  
			UPDATE PO  
				SET OpenQty = PO.OpenQty - (DELETED.QtyOrdered - DELETED.QtyReceived)  
			  FROM PO, DELETED  
			 WHERE PO.POKey = DELETED.POKey  
		END  
		ELSE  
		BEGIN  
			UPDATE PO 
				SET PO.OpenQty = (PO.Openqty -  
					(SELECT SUM(DELETED.QtyOrdered - DELETED.QtyReceived) FROM DELETED WHERE DELETED.POKey = PO.POKey))  
			  FROM PO,DELETED  
			 WHERE PO.POKey IN (SELECT DISTINCT POKey FROM DELETED)  
				AND PO.POKey = DELETED.POKey  
		END  

		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  

		IF @n_err <> 0  
		BEGIN  
			SELECT @n_continue = 3  
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=64803   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
			SELECT @c_errmsg="NSQL"+CONVERT(CHAR(5),@n_err)+": Insert failed on table PO. (ntrPODetailDelete)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "  
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
               ,@c_errmsg = 'ntrPODetailDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.PODETAIL_DELLOG ( POKey, POLineNumber )
         SELECT POKey, POLineNumber FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table PODETAIL Failed. (ntrPODetailDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END
   -- End (KHLim01) 

	/* #INCLUDE <TRPODD2.SQL> */  
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

		EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrPODetailDelete"  
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
END  -- Trigger End
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrPODetailUpdate                                           */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Input Parameters: NONE                                               */
/*                                                                      */
/* Output Parameters: NONE                                              */
/*                                                                      */
/* Return Status: NONE                                                  */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When records updated                                      */
/*                                                                      */
/* PVCS Version: 1.3                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/* 17-Mar-2009  TLTING   1.0  Change user_name() to SUSER_SNAME()       */
/* 22-May-2012  TLTING01 1.1  DM Integrity issue - Update editdate for  */
/*                            status < '9'                              */
/* 28-Oct-2013  TLTING   1.2  Review Editdate column update             */
/* 2014-08-26   YTWan    1.3  SOS#319232 - TH-PO not allow to add       */
/*                            Invactive-SKU. (Wan01)                    */
/* 2016-08-02   Ung      1.4  IN00110559 Enable trigger pass out error  */
/************************************************************************/
CREATE TRIGGER [dbo].[ntrPODetailUpdate]
ON  [dbo].[PODETAIL]
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
   ,  @c_PODisallowInactiveSku   NVARCHAR(10)      --(Wan01)
   ,  @c_Storerkey               NVARCHAR(15)      --(Wan01)
   ,  @c_InactiveSku             NVARCHAR(20)      --(Wan01)
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   
   IF UPDATE(ArchiveCop)
   BEGIN
      SELECT @n_continue = 4
   END
   
   --tlting01
   IF ( @n_continue=1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE PODETAIL
      SET EditDate = GETDATE(), EditWho = Suser_Sname(), TrafficCop = NULL
      FROM PODETAIL, INSERTED
      WHERE PODETAIL.POKey = INSERTED.POKey AND PODETAIL.POLineNumber = INSERTED.POLineNumber
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err)
         SELECT @n_err = 200001
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table PODETAIL. (ntrPODetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
      END
   END
   
   IF UPDATE(TrafficCop)
   BEGIN
      SELECT @n_continue = 4
   END
   
        /* #INCLUDE <TRPODU1.SQL> */
   -- Added By SHONG
   -- Spec From Thailand
   -- Not Allow to Modify PO When Extern Status = 9 or CLOSED
   -- Date: 05th Dec 2000
   --IF @n_continue=1 or @n_continue=2
   --BEGIN
   --   IF EXISTS(SELECT DELETED.POKEY FROM DELETED, PO WHERE PO.POKey = DELETED.POKEY
   --            AND    PO.ExternStatus = "9")
   --   BEGIN
   --      SELECT @n_continue = 3
   --      SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=64705   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
   --      SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": PO Detail Cannot be Modified, Status = CLOSED. (ntrPODetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
   --   END
   --END
   -- End of Modify
   --(Wan01) - START
   
   IF @n_continue=1 or @n_continue=2
   BEGIN
      SET @c_Storerkey = ''
      SELECT TOP 1 @c_Storerkey = INSERTED.Storerkey
      FROM INSERTED
      JOIN DELETED ON (INSERTED.POKey = DELETED.POKey)
                   AND(INSERTED.POLineNumber = DELETED.POLineNumber)
   
      SET @c_PODisAllowInactiveSku = 0
      SET @b_success = 0
      Execute nspGetRight null   -- facility
              ,  @c_StorerKey    -- Storerkey
              ,  null            -- Sku
              ,  'PODisallowInactiveSku'    -- Configkey
              ,  @b_success               OUTPUT
              ,  @c_PODisAllowInactiveSku OUTPUT
              ,  @n_err                   OUTPUT
              ,  @c_errmsg                OUTPUT
      IF @b_success <> 1
      BEGIN
         SET @n_continue = 3
         SET @n_err = 200002
         SET @c_errmsg = 'ntrPODetailUpdate ' + RTRIM(@c_errmsg)
      END
      ELSE IF @c_PODisAllowInactiveSku = '1'
      BEGIN
         SET @c_InactiveSku = ''
         SELECT TOP 1 @c_InactiveSku = RTRIM(SKU.Sku)
         FROM INSERTED
         JOIN DELETED ON (INSERTED.POKey = DELETED.POKey)
                      AND(INSERTED.POLineNumber = DELETED.POLineNumber)
         JOIN SKU WITH (NOLOCK) ON (INSERTED.Storerkey = SKU.Storerkey)
                                AND(INSERTED.Sku = SKU.Sku)
         WHERE SKU.SkuStatus = 'Inactive'
   
         IF @c_InactiveSku <> ''
         BEGIN
            SET @n_continue = 3
            SET @n_err = 200003
            SET @c_errmsg = 'ntrPODetailUpdate. Disallow Inactive Sku: ' + RTRIM(@c_InactiveSku) + 'add to PO.'
         END
      END
   END
   --(Wan01) - END
   
   IF @n_continue=1 or @n_continue=2
   BEGIN
      IF @n_continue = 1 or @n_continue=2
      BEGIN
         UPDATE    CASEMANIFEST
         SET   StorerKey = INSERTED.StorerKey,
               Sku       = INSERTED.Sku,
               ExpectedPOKey = INSERTED.POKey,
               EditDate = GETDATE(),   --tlting
               EditWho = SUSER_SNAME()
         FROM  CASEMANIFEST, INSERTED, DELETED
         WHERE CASEMANIFEST.StorerKey             = DELETED.StorerKey
         AND  CASEMANIFEST.Sku                   = DELETED.Sku
         AND  CASEMANIFEST.ExpectedPOKey         = DELETED.POKey
         AND ( NOT INSERTED.StorerKey   = DELETED.StorerKey
               OR   NOT INSERTED.Sku         = DELETED.Sku
               OR   NOT INSERTED.POKey       = DELETED.POKey )
      END
      IF @n_continue=1 or @n_continue=2
      BEGIN
         UPDATE PODETAIL
         SET PODETAIL.QtyAdjusted = PODETAIL.QtyAdjusted - DELETED.QtyOrdered + INSERTED.QtyOrdered
         FROM PODETAIL, DELETED, INSERTED
         WHERE PODETAIL.POKey = DELETED.POKey AND PODETAIL.POLineNumber = DELETED.POLineNumber
         AND PODETAIL.POKey = INSERTED.POKey AND PODETAIL.POLineNumber = INSERTED.POLineNumber
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err)
            SELECT @n_err = 200004
            SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table PODETAIL. (ntrPODetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
         END
      END
   END
   
   IF @n_continue = 1 or @n_continue=2
   BEGIN
      DECLARE @n_deletedcount int
      SELECT @n_deletedcount = (select count(*) FROM deleted)
      IF @n_deletedcount = 1
      BEGIN
         UPDATE PO  with (ROWLOCK)
         SET  OpenQty = PO.OpenQty - (DELETED.QtyOrdered - DELETED.QtyReceived) + (INSERTED.QtyOrdered - INSERTED.QtyReceived),
               EditDate = GETDATE(),   --tlting
               EditWho = SUSER_SNAME()
         FROM PO, INSERTED, DELETED
         WHERE PO.POKey = INSERTED.POKey
           AND INSERTED.POKey = DELETED.POKey
      END
      ELSE
      BEGIN
         UPDATE PO SET PO.OpenQty = (PO.Openqty -
               (Select Sum(DELETED.QtyOrdered - DELETED.QtyReceived) From DELETED
                 Where DELETED.POKey = PO.POKey)
                +
               (Select Sum(INSERTED.QtyOrdered - INSERTED.QtyReceived) From INSERTED
                Where INSERTED.POKey = PO.POKey)
                ),
                EditDate = GETDATE(),   --tlting
                EditWho = SUSER_SNAME()
         FROM PO,DELETED,INSERTED
         WHERE PO.POKey IN (SELECT Distinct POKey From DELETED)
         AND PO.POKey = DELETED.POKey
         AND PO.POKey = INSERTED.POKey
         AND INSERTED.POKey = DELETED.POKey
         AND INSERTED.POLineNumber = DELETED.POLineNumber
      END
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err)
         SELECT @n_err = 200005   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Insert failed on table PO. (ntrPODetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
      END
   END

   /* #INCLUDE <TRPODU2.SQL> */
   IF @n_continue=3  -- Error Occured - Process And Return
   BEGIN
      DECLARE @n_IsRDT INT
      EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT
   
      IF @n_IsRDT = 1
      BEGIN
         -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here
         -- Instead we commit and raise an error back to parent, let the parent decide
   
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
         execute nsp_logerror @n_err, @c_errmsg, "ntrPODetailUpdate"
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
ALTER TABLE [dbo].[PODETAIL] ADD CONSTRAINT [PKPODETAIL] PRIMARY KEY CLUSTERED ([POKey], [POLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ExternPODETAIL] ON [dbo].[PODETAIL] ([ExternPOKey], [ExternLineNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [AK_PODETAIL_01] ON [dbo].[PODETAIL] ([StorerKey], [Sku], [POKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PODETAIL] WITH NOCHECK ADD CONSTRAINT [FK_PODETAIL_SKU_01] FOREIGN KEY ([StorerKey], [Sku]) REFERENCES [dbo].[SKU] ([StorerKey], [Sku])
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Alternate Commodity ID to be linked to the Master Commodity.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'AltSku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Update to ''9'' for archiving purpose', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Best before date', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Best_bf_Date'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Enter the date on which the transfer should take place', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'External purchase order detail line number imported', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'ExternLineNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'ExternPOKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The warehouse in which the SKU will be delivered to', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lottable01', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lottable02 - Batch No', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lottable03', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Product expiry date', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Product receipt date', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable06', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable07', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable08', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable09', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable10', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable10'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable11', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable11'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable12', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable12'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable13', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable13'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable14', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable14'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined lottable15', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Lottable15'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Manufacturer SKU', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'ManufacturerSku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Marks container', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'MarksContainer'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information about Purchase Orders detail.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Notes'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Packing configuration of the SKU. Will be defaulted to the pack key assigned in the Commodity screen', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders detail.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'PODetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'POKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Podetail line number', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'POLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PO line status', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'POLineStatus'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity adjusted', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'QtyAdjusted'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity ordered', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'QtyOrdered'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity received', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'QtyReceived'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Retail SKU', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'RetailSku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Shortcode', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'shortcode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The SKU being ordered', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Description of the SKU', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'SKUDescription'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable Unit', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'ToId'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit price', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UnitPrice'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measurement in which the SKU will be shipped', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UOM'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 1', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 2', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 3', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 4', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 5', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 6', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 7', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 8', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 9', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User defined field 10', 'SCHEMA', N'dbo', 'TABLE', N'PODETAIL', 'COLUMN', N'UserDefine10'
GO
