IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[nspArchiveReceipt2]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[nspArchiveReceipt2]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc : nspArchiveReceipt2                                     */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By: /                                                         */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 11-Sep-2017  Leong         Duplicate from nspArchiveReceipt.         */
/*                            Customize where clause.                   */
/************************************************************************/

CREATE PROCEDURE nspArchiveReceipt2
     @c_archivekey       NVARCHAR(10)
   , @b_Success          INT            OUTPUT
   , @n_err              INT            OUTPUT
   , @c_errmsg           NVARCHAR(250)  OUTPUT
   , @c_WhereClauseExtra NVARCHAR(4000) = ''
AS
BEGIN  -- main
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_continue  INT,
           @n_starttcnt INT, -- Holds the current transaction count
           @n_cnt       INT, -- Holds @@ROWCOUNT after certain operations
           @b_debug     INT  -- Debug On OR Off

   DECLARE @n_retain_days                 INT,          -- days to hold data
           @d_Receiptdate                 DATETIME,     -- Receipt Date from Receipt header table
           @d_result                      DATETIME,     -- date Receipt_date - (GETDATE() - noofdaystoretain
           @c_datetype                    NVARCHAR(10), -- 1=ReceiptDATE, 2=EditDate, 3=AddDate
           @n_archive_Receipt_records     INT,          -- # of Receipt records to be archived
           @n_archive_Rcpt_detail_records INT           -- # of Receipt_detail records to be archived

   DECLARE @local_n_err    INT,
           @local_c_errmsg NVARCHAR(254)

   DECLARE @c_copyfrom_db             NVARCHAR(55),
           @c_copyto_db               NVARCHAR(55),
           @c_ReceiptActive           NVARCHAR(2),
           @c_ReceiptStorerKeyStart   NVARCHAR(15),
           @c_ReceiptStorerKeyEnd     NVARCHAR(15),
           @c_ReceiptStart            NVARCHAR(10),
           @c_ReceiptEnd              NVARCHAR(10),
           @c_whereclause             NVARCHAR(350),
           @c_temp                    NVARCHAR(254),
           @CopyRowsToArchiveDatabase NVARCHAR(1)

   DECLARE @cReceiptKey        NVARCHAR(10) -- added by Ong (SOS38267) 2005-Aug-10
         , @cReceiptLineNumber NVARCHAR(5)  -- Added by SHONG (SHONG20051128)

   SELECT @n_starttcnt = @@TRANCOUNT, @n_continue = 1, @b_success = 0, @n_err = 0, @c_errmsg = '',
          @b_debug = 0, @local_n_err = 0, @local_c_errmsg = ''

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN -- 1
      SELECT @c_copyfrom_db             = livedatabasename,
             @c_copyto_db               = archivedatabasename,
             @n_retain_days             = ReceiptNumberofDaysToRetain,
             @c_datetype                = Receiptdatetype,
             @c_ReceiptActive           = ReceiptActive,
             @c_ReceiptStorerKeyStart   = ISNULL(ReceiptStorerKeyStart,'0'),
             @c_ReceiptStorerKeyEnd     = ISNULL(ReceiptStorerKeyEnd,'ZZZZZZZZZZ'),
             @c_ReceiptStart            = ISNULL(ReceiptStart,'0'),
             @c_ReceiptEnd              = ISNULL(ReceiptEnd,'ZZZZZZZZZZ'),
             @CopyRowsToArchiveDatabase = CopyRowsToArchiveDatabase
      FROM ArchiveParameters (NOLOCK)
      WHERE archivekey = @c_archivekey

      IF DB_ID(@c_copyto_db) IS NULL
      BEGIN
         SELECT @n_continue = 3
         SELECT @local_n_err = 74101
         SELECT @local_c_errmsg = CONVERT(CHAR(5),@local_n_err)
         SELECT @local_c_errmsg = ": Target Database " + @c_copyto_db + " Does NOT exist " + " ( " +
                                  " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")" +' (nspArchiveReceipt2) '
      END

      SELECT @d_result = DATEADD(DAY,-@n_retain_days,GETDATE())
      SELECT @d_result = DATEADD(DAY,1,@d_result)
   END -- 1

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      SELECT @b_success = 1
      SELECT @c_temp = "Archive Of Receipt Started with Parms; Datetype = " + dbo.fnc_RTrim(@c_datetype) +
         ' ; Active = '+ dbo.fnc_RTrim(@c_ReceiptActive)+ ' ; Storer = '+ dbo.fnc_RTrim(@c_ReceiptStorerKeyStart)+'-'+
         dbo.fnc_RTrim(@c_ReceiptStorerKeyEnd) + ' ; Receipt = '+dbo.fnc_RTrim(@c_ReceiptStart)+'-'+dbo.fnc_RTrim(@c_ReceiptEnd)+
         ' ; Copy Rows to Archive = '+dbo.fnc_RTrim(@CopyRowsToArchiveDatabase) + '; Retain Days = '+ CONVERT(CHAR(6),@n_retain_days)
      EXECUTE nspLogAlert
         @c_ModuleName   = "nspArchiveReceipt2",
         @c_AlertMessage = @c_Temp ,
         @n_Severity     = 0,
         @b_success       = @b_success OUTPUT,
         @n_err          = @n_err OUTPUT,
         @c_errmsg       = @c_errmsg OUTPUT
      IF NOT @b_success = 1
      BEGIN
         SELECT @n_continue = 3
      END
   END

   IF (@n_continue = 1 OR @n_continue = 2)
   BEGIN -- 2
      SELECT @c_whereclause = ' '
      SELECT @c_temp = ' '

      --SELECT @c_temp = 'AND Receipt.StorerKey BETWEEN '+ 'N'''+dbo.fnc_RTrim(@c_ReceiptStorerKeyStart) + ''''+ ' AND '+
      --                 'N'''+dbo.fnc_RTrim(@c_ReceiptStorerKeyEnd)+''''
      --
      --SELECT @c_temp = @c_temp + ' AND Receipt.ReceiptKey BETWEEN '+ 'N''' + dbo.fnc_RTrim(@c_ReceiptStart) + '''' +' AND '+
      --                 'N'''+dbo.fnc_RTrim(@c_ReceiptEnd)+''''

      IF ((@n_continue = 1 OR @n_continue = 2) AND @CopyRowsToArchiveDatabase = 'Y')
      BEGIN
         SELECT @b_success = 1
         EXEC nsp_Build_Archive_Table
            @c_copyfrom_db,
            @c_copyto_db,
            'Receipt',
            @b_success OUTPUT,
            @n_err OUTPUT,
            @c_errmsg OUTPUT
         IF NOT @b_success = 1
         BEGIN
            SELECT @n_continue = 3
         END
      END

      IF ((@n_continue = 1 OR @n_continue = 2) AND @CopyRowsToArchiveDatabase = 'Y')
      BEGIN
         IF (@b_debug = 1)
         BEGIN
            PRINT "starting Table Existence Check For ReceiptDetail..."
         END
         SELECT @b_success = 1
         EXEC nsp_Build_Archive_Table
            @c_copyfrom_db,
            @c_copyto_db,
            'ReceiptDetail',
            @b_success OUTPUT,
            @n_err OUTPUT,
            @c_errmsg OUTPUT
         IF NOT @b_success = 1
         BEGIN
            SELECT @n_continue = 3
         END
      END

      IF ((@n_continue = 1 OR @n_continue = 2) AND @CopyRowsToArchiveDatabase = 'Y')
      BEGIN
         IF (@b_debug = 1)
         BEGIN
            PRINT "building alter table string for Receipt..."
         END
         EXECUTE nspBuildAlterTableString
            @c_copyto_db,
            'Receipt',
            @b_success OUTPUT,
            @n_err OUTPUT,
            @c_errmsg OUTPUT
         IF NOT @b_success = 1
         BEGIN
            SELECT @n_continue = 3
         END
      END

      IF ((@n_continue = 1 OR @n_continue = 2) AND @CopyRowsToArchiveDatabase = 'Y')
      BEGIN
         IF (@b_debug = 1)
         BEGIN
            PRINT "building alter table string for ReceiptDetail..."
         END
         EXECUTE nspBuildAlterTableString
            @c_copyto_db,
            'ReceiptDetail',
            @b_success OUTPUT,
            @n_err OUTPUT,
            @c_errmsg OUTPUT
         IF NOT @b_success = 1
         BEGIN
            SELECT @n_continue = 3
         END
      END

      IF LEN(ISNULL(RTRIM(@c_WhereClauseExtra), '') ) > 0
      BEGIN
         SET @c_WhereClause = @c_WhereClause + @c_WhereClauseExtra
      END
      ELSE
      BEGIN
         SELECT @n_continue = 3
         SELECT @local_n_err = 74104
         SELECT @local_c_errmsg = CONVERT(CHAR(5),@local_n_err)
         SELECT @local_c_errmsg = 'WHERE clause NOT exist. ( ' +
                                  'SQLSvr MESSAGE = ' + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ')' + ' (nspArchiveReceipt2) '
      END

      IF ((@n_continue = 1 OR @n_continue = 2) AND @CopyRowsToArchiveDatabase = 'Y')
      BEGIN -- 3
         -- IF @c_datetype = "1" -- ReceiptDATE
         -- BEGIN
         --     -- Start : SOS42269
         --     -- SELECT @c_whereclause = "WHERE Receipt.ReceiptDate  <= " + '"'+ CONVERT(CHAR(11),@d_result,106)+'"' + " AND (Receipt.Status = '9' OR ASNStatus = 'CANC') " +  @c_temp
         --     SELECT @c_whereclause = "WHERE Receipt.ReceiptDate  <= " + '"'+ CONVERT(CHAR(11),@d_result,106)+'"' + " AND (Receipt.Status = '9' OR ASNStatus = 'CANC' OR ASNStatus = '9') " +  @c_temp
         --     -- End : SOS42269
         -- END
         -- IF @c_datetype = "2" -- EditDate
         -- BEGIN
         --    -- Start : SOS42269
         --    -- SELECT @c_whereclause = "WHERE Receipt.EditDate <= " + '"'+ CONVERT(CHAR(11),@d_result,106)+'"' + " AND (Receipt.Status = '9' OR ASNStatus = 'CANC') " + @c_temp
         --    SELECT @c_whereclause = "WHERE Receipt.EditDate <= " + '"'+ CONVERT(CHAR(11),@d_result,106)+'"' + " AND (Receipt.Status = '9' OR ASNStatus = 'CANC' OR ASNStatus = '9') " + @c_temp
         --    -- End : SOS42269
         -- END
         -- IF @c_datetype = "3" -- AddDate
         -- BEGIN
         --    -- Start : SOS42269
         --    -- SELECT @c_whereclause = "WHERE Receipt.AddDate <= " +'"'+ CONVERT(CHAR(11),@d_result,106)+'"' + " AND (Receipt.Status = '9' OR ASNStatus = 'CANC') " + @c_temp
         --    SELECT @c_whereclause = "WHERE Receipt.AddDate <= " +'"'+ CONVERT(CHAR(11),@d_result,106)+'"' + " AND (Receipt.Status = '9' OR ASNStatus = 'CANC' OR ASNStatus = '9') " + @c_temp
         --    -- End : SOS42269
         -- END

         /* BEGIN (SOS38267) UPDATE*/
         -- Modified by MaryVong on 15-Nov-2005
         IF (@b_debug = 1)
         BEGIN
            PRINT "starting Table Existence Check For Receipt..."
         END

         SELECT @n_archive_Receipt_records = 0

         WHILE @@TRANCOUNT > @n_starttcnt
            COMMIT TRAN

         EXEC (
         ' DECLARE C_ReceiptKey CURSOR FAST_FORWARD READ_ONLY FOR ' +
         ' SELECT ReceiptKey FROM Receipt (NOLOCK) ' + @c_WhereClause +
         ' ORDER BY ReceiptKey ' )

         OPEN C_ReceiptKey
         FETCH NEXT FROM C_ReceiptKey INTO @cReceiptKey

         WHILE @@fetch_status <> -1
         BEGIN
            BEGIN TRAN

            IF @b_debug = 1
            BEGIN
               PRINT 'ReceiptKey: ' + @cReceiptKey
            END

            UPDATE Receipt WITH (ROWLOCK)
               SET ArchiveCop = '9'
            WHERE ReceiptKey = @cReceiptKey

            SELECT @local_n_err = @@error   --, @n_cnt = @@rowcount
            SELECT @n_archive_Receipt_records = @n_archive_Receipt_records + 1
            IF @local_n_err <> 0
            BEGIN
               SELECT @n_continue = 3
               SELECT @local_n_err = 74102
               SELECT @local_c_errmsg = CONVERT(CHAR(5),@local_n_err)
               SELECT @local_c_errmsg = ": Update of ArchiveCop failed - Receipt. (nspArchiveReceipt2) " + " ( " +
                                        " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
               ROLLBACK TRAN
            END
            ELSE
            BEGIN
               COMMIT TRAN
            END

            FETCH NEXT FROM C_ReceiptKey INTO @cReceiptKey
         END -- while ReceiptKey
         CLOSE C_ReceiptKey
         DEALLOCATE C_ReceiptKey

         IF (@n_continue = 1 OR @n_continue = 2)
         BEGIN
            WHILE @@TRANCOUNT > @n_starttcnt
               COMMIT TRAN

            /* BEGIN (SOS38267) UPDATE*/
            SELECT @n_archive_Rcpt_detail_records = 0

            DECLARE C_Receiptkey CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT ReceiptDetail.Receiptkey, ReceiptDetail.ReceiptLineNumber
            FROM Receipt (NOLOCK)
            JOIN ReceiptDetail (NOLOCK) ON (ReceiptDetail.Receiptkey = Receipt.Receiptkey)
            WHERE (Receipt.ArchiveCop = '9')
            ORDER BY ReceiptDetail.Receiptkey

            OPEN C_Receiptkey
            FETCH NEXT FROM C_Receiptkey INTO @cReceiptkey, @cReceiptLineNumber

            WHILE @@fetch_status <> -1
            BEGIN
               BEGIN TRAN
               UPDATE ReceiptDetail
                  SET ArchiveCop = '9'
               WHERE Receiptkey = @cReceiptkey
               AND   ReceiptLineNumber = @cReceiptLineNumber

               SELECT @local_n_err = @@error --, @n_cnt = @@rowcount

               IF @local_n_err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @local_n_err = 74103
                  SELECT @local_c_errmsg = CONVERT(CHAR(5),@local_n_err)
                  SELECT @local_c_errmsg = ": Update of ArchiveCop failed - ReceiptDetail. (nspArchiveReceipt2) " + " ( " +
                                           " SQLSvr MESSAGE = " + dbo.fnc_LTrim(dbo.fnc_RTrim(@local_c_errmsg)) + ")"
                  ROLLBACK TRAN
               END
               ELSE
               BEGIN
                  SELECT @n_archive_Rcpt_detail_records = @n_archive_Rcpt_detail_records + 1
                  COMMIT TRAN
               END

               FETCH NEXT FROM C_Receiptkey INTO @cReceiptkey, @cReceiptLineNumber
            END -- while Receiptkey

            CLOSE C_Receiptkey
            DEALLOCATE C_Receiptkey
            /* END (SOS38267) UPDATE*/
         END

         IF ((@n_continue = 1 OR @n_continue = 2)  AND @CopyRowsToArchiveDatabase = 'Y')
         BEGIN
            SELECT @c_temp = "Attempting to Archive " + dbo.fnc_RTrim(CONVERT(CHAR(6),@n_archive_Receipt_records )) +
                             " Receipt records AND " + dbo.fnc_RTrim(CONVERT(CHAR(6),@n_archive_Rcpt_detail_records )) + " ReceiptDetail records"
            EXECUTE nspLogAlert
               @c_ModuleName   = "nspArchiveReceipt2",
               @c_AlertMessage = @c_Temp ,
               @n_Severity     = 0,
               @b_success       = @b_success OUTPUT,
               @n_err          = @n_err OUTPUT,
               @c_errmsg       = @c_errmsg OUTPUT
            IF NOT @b_success = 1
            BEGIN
               SELECT @n_continue = 3
            END
         END

         IF ((@n_continue = 1 OR @n_continue = 2) AND @CopyRowsToArchiveDatabase = 'Y')
         BEGIN
            IF (@b_debug = 1)
            BEGIN
               PRINT "Building INSERT for ReceiptDetail..."
            END
            SELECT @b_success = 1
            EXEC nsp_Build_Insert
               @c_copyto_db,
               'ReceiptDetail',
               1 ,
               @b_success OUTPUT,
               @n_err OUTPUT,
               @c_errmsg OUTPUT
            IF NOT @b_success = 1
            BEGIN
               SELECT @n_continue = 3
            END
         END

         IF @n_continue = 1 OR @n_continue = 2
         BEGIN
            WHILE @@TRANCOUNT > @n_starttcnt
               COMMIT TRAN

            IF @n_continue = 1 OR @n_continue = 2
            BEGIN
               IF (@b_debug = 1)
               BEGIN
                  PRINT "Building INSERT for Receipt..."
               END
               SELECT @b_success = 1
               EXEC nsp_Build_Insert
                  @c_copyto_db,
                  'Receipt',
                  1,
                  @b_success OUTPUT,
                  @n_err OUTPUT,
                  @c_errmsg OUTPUT
               IF NOT @b_success = 1
               BEGIN
                  SELECT @n_continue = 3
               END
            END
         END
      END -- 3
   END -- 2

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      SELECT @b_success = 1
      EXECUTE nspLogAlert
         @c_ModuleName   = "nspArchiveReceipt2",
         @c_AlertMessage = "Archive Of Receipt Ended Normally.",
         @n_Severity     = 0,
         @b_success      = @b_success OUTPUT,
         @n_err          = @n_err OUTPUT,
         @c_errmsg       = @c_errmsg OUTPUT
      IF NOT @b_success = 1
      BEGIN
         SELECT @n_continue = 3
      END
   END
   ELSE
   BEGIN
      IF @n_continue = 3
      BEGIN
         SELECT @b_success = 1
            EXECUTE nspLogAlert
            @c_ModuleName   = "nspArchiveReceipt2",
            @c_AlertMessage = "Archive Of Receipt Ended Abnormally - Check This Log For Additional Messages.",
            @n_Severity     = 0,
            @b_success      = @b_success OUTPUT,
            @n_err          = @n_err OUTPUT,
            @c_errmsg       = @c_errmsg OUTPUT
         IF NOT @b_success = 1
         BEGIN
            SELECT @n_continue = 3
         END
      END
   END

   IF @n_continue = 3  -- Error Occured - Process AND Return
   BEGIN
      SELECT @b_success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_starttcnt
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
      SELECT @n_err = @local_n_err
      SELECT @c_errmsg = @local_c_errmsg
      IF (@b_debug = 1)
      BEGIN
         SELECT @n_err,@c_errmsg, 'before putting in nsp_logerr at the bottom'
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, "nspArchiveReceipt2"
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
END -- main
GO
GRANT EXECUTE ON [dbo].[nspArchiveReceipt2] TO nSQL 
GO
