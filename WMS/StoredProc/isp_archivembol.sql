if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_ArchiveMbol]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[isp_ArchiveMbol]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc : isp_ArchiveMbol                                        */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Input Parameters: NONE                                               */
/*                                                                      */
/* OUTPUT Parameters: NONE                                              */
/*                                                                      */
/* Return Status: NONE                                                  */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: nspArchiveShippingOrder                                   */
/*                                                                      */
/* PVCS Version:1.1                                                     */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 2005-Aug-09  Shong         Performance Tuning                        */
/* 2005-Aug-10  Ong           SOS38267 : obselete sku & storerkey       */
/* 2005-Nov-28  Shong         Change Commit transaction strategy to row */
/*                            Level to Reduce Blocking.                 */
/* 2005-Nov-30  Shong         SOS40882 - Archive MBOL only when all the */
/*                            Orders in the MBOLDetail was Archived     */
/*                            SOS40064 - Archive Those MBOL which Orders*/
/*                            No Longer Exists.                         */
/* 13-APR-2006  June          Include Manual Order                      */
/* 24-Apr-2012  Leong         SOS# 242479 - Update MBOL.ArchiveCop with */
/*                                          TrafficCop                  */
/************************************************************************/

CREATE PROC [dbo].[isp_ArchiveMbol]
   @c_copyfrom_db             NVARCHAR(55),
   @c_copyto_db               NVARCHAR(55),
   @copyrowstoarchivedatabase NVARCHAR(1),
   @b_success                 int OUTPUT
AS
/*--------------------------------------------------------------*/
-- THIS ARCHIVE SCRIPT IS EXECUTED FROM nsparchiveshippingorder
/*--------------------------------------------------------------*/
BEGIN -- main

   /* BEGIN 2005-Aug-10 (SOS38267) */
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   /* END 2005-Aug-10 (SOS38267) */

   DECLARE @n_continue int,
           @n_starttcnt int, -- holds the current transaction count
           @n_cnt int,       -- holds @@rowcount after certain operations
           @b_debug int      -- debug on or off

   /* #include <sparpo1.sql> */
   DECLARE @n_archive_mbol_records        int, -- # of MBOL records to be archived
           @n_archive_mbol_Detail_records int, -- # of MBOLDetail records to be archived
           @n_err                         int,
           @c_errmsg                      NVARCHAR(254),
           @local_n_err                   int,
           @local_c_errmsg                NVARCHAR(254),
           @c_temp                        NVARCHAR(254)

   DECLARE @cMBOLKey  NVARCHAR(10),
           @cMBOLLine NVARCHAR(5)

   SELECT @n_starttcnt=@@trancount , @n_continue=1, @b_success=0,@n_err=0,@c_errmsg='',
          @b_debug = 0, @local_n_err = 0, @local_c_errmsg = ' '

   IF ((@n_continue = 1 or @n_continue = 2) AND @copyrowstoarchivedatabase = 'y')
   BEGIN
      IF (@b_debug =1 )
      BEGIN
         PRINT 'starting table existence check for MBOL...'
      END
      SELECT @b_success = 1
      EXEC nsp_build_archive_table
            @c_copyfrom_db,
            @c_copyto_db,
            'MBOL',
            @b_success OUTPUT,
            @n_err     OUTPUT,
            @c_errmsg  OUTPUT
      IF NOT @b_success = 1
      BEGIN
         SELECT @n_continue = 3
      END
   END

   IF ((@n_continue = 1 or @n_continue = 2) AND @copyrowstoarchivedatabase = 'y')
   BEGIN
      IF (@b_debug =1 )
      BEGIN
         PRINT 'starting table existence check for MBOLDetail...'
      END
      SELECT @b_success = 1
      EXEC nsp_build_archive_table
            @c_copyfrom_db,
            @c_copyto_db,
            'MBOLDetail',
            @b_success OUTPUT,
            @n_err     OUTPUT,
            @c_errmsg  OUTPUT
      IF NOT @b_success = 1
      BEGIN
         SELECT @n_continue = 3
      END
   END

   IF ((@n_continue = 1 or @n_continue = 2) AND @copyrowstoarchivedatabase = 'y')
   BEGIN
      IF (@b_debug =1 )
      BEGIN
         PRINT 'building alter table string for MBOL...'
      END
      EXECUTE nspbuildaltertablestring
            @c_copyto_db,
            'MBOL',
            @b_success OUTPUT,
            @n_err     OUTPUT,
            @c_errmsg  OUTPUT
      IF NOT @b_success = 1
      BEGIN
         SELECT @n_continue = 3
      END
   END

   IF ((@n_continue = 1 or @n_continue = 2) AND @copyrowstoarchivedatabase = 'y')
   BEGIN
      IF (@b_debug =1 )
      BEGIN
         PRINT 'building alter table string for MBOLDetail...'
      END
      EXECUTE nspbuildaltertablestring
              @c_copyto_db,
              'MBOLDetail',
              @b_success OUTPUT,
              @n_err     OUTPUT,
              @c_errmsg  OUTPUT
      IF NOT @b_success = 1
      BEGIN
         SELECT @n_continue = 3
      END
   END

   WHILE @@trancount > 0
      COMMIT TRAN

      SELECT @n_archive_MBOL_records = 0
      SELECT @n_archive_MBOL_Detail_records = 0

      DECLARE C_ARC_MBOL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT MBOLKEY
         FROM  ORDERDETAIL WITH (NOLOCK)
         GROUP BY MBOLKEY
         HAVING COUNT(DISTINCT ISNULL(OrderDetail.ArchiveCop, '')) = 1
         AND MAX(ISNULL(OrderDetail.ArchiveCop, '')) = '9'
         UNION ALL
         SELECT MBOL.MBOLKEY
         FROM MBOL WITH (NOLOCK)
         LEFT OUTER JOIN (SELECT MBOLDetail.MBOLKEY FROM MBOLDetail WITH (NOLOCK)
                          JOIN ORDERS WITH (NOLOCK) ON  ORDERS.OrderKey = MBOLDetail.OrderKey) AS MD
                     ON MD.MBOLKey = MBOL.MBOLKEY
         WHERE MBOL.Status = '9'
         AND ISNULL(RTRIM(MD.MBOLKey),'') = ''
         UNION ALL
         SELECT MBOLKEY
         FROM  ORDERS WITH (NOLOCK)
         -- WHERE ORDERS.UserDefine08 = '2'     June 13-Apr-2006
         WHERE (ORDERS.UserDefine08 = '2' OR TYPE = 'M')
         AND MBOLKEY > ''
         GROUP BY MBOLKEY
         HAVING COUNT(DISTINCT ISNULL(ORDERS.ArchiveCop, '')) = 1
         AND MAX(ISNULL(ORDERS.ArchiveCop, '')) = '9'
         ORDER BY MBOLKey

      OPEN C_ARC_MBOL
      FETCH NEXT FROM C_ARC_MBOL INTO @cMBOLKey

      WHILE @@fetch_status <> -1 AND (@n_continue = 1 or @n_continue = 2)
      BEGIN
         BEGIN TRAN

         UPDATE MBOL WITH (ROWLOCK)
         SET MBOL.ArchiveCop = '9'
           , MBOL.TrafficCop = NULL -- SOS# 242479
         WHERE MBOL.MBOLkey = @cMBOLKey

         SELECT @local_n_err = @@error, @n_cnt = @@rowcount
         SELECT @n_archive_MBOL_records = @n_archive_MBOL_records + 1

         IF @local_n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @local_n_err = 77303
            SELECT @local_c_errmsg = CONVERT(NVARCHAR(5),@local_n_err)
            SELECT @local_c_errmsg = ': UPDATE of ArchiveCop failed - MBOLDetail. (isp_ArchiveMBOL) ' + ' ( ' +
                                     ' sqlsvr message = ' + LTRIM(RTRIM(@local_c_errmsg)) + ')'
            ROLLBACK TRAN
         END
         ELSE
         BEGIN
            COMMIT TRAN
         END

         IF @n_continue = 1 or @n_continue = 2
         BEGIN
            DECLARE C_ARC_MBOLDetail CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
               SELECT MBOLLineNumber
               FROM   MBOLDetail WITH (NOLOCK)
               WHERE  MBOLKey = @cMBOLKey

            OPEN C_ARC_MBOLDetail
            FETCH NEXT FROM C_ARC_MBOLDetail INTO @cMBOLLine

            WHILE @@fetch_status <> -1 AND (@n_continue = 1 or @n_continue = 2)
            BEGIN
               BEGIN TRAN

               UPDATE MBOLDetail WITH (ROWLOCK)
               SET MBOLDetail.ArchiveCop = '9'
                 , MBOLDetail.TrafficCop = NULL -- SOS# 242479
               WHERE MBOLkey = @cMBOLKey AND MBOLLineNumber = @cMBOLLine

               SELECT @local_n_err = @@error, @n_cnt = @@rowcount
               SELECT @n_archive_MBOL_Detail_records = @n_archive_MBOL_Detail_records + 1

               IF @local_n_err <> 0
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @local_n_err = 77303
                  SELECT @local_c_errmsg = CONVERT(NVARCHAR(5),@local_n_err)
                  SELECT @local_c_errmsg = ': UPDATE of ArchiveCop failed - MBOLDetail. (isp_ArchiveMBOL) ' + ' ( ' +
                                           ' sqlsvr message = ' + LTRIM(RTRIM(@local_c_errmsg)) + ')'
                  ROLLBACK TRAN
               END
               ELSE
               BEGIN
                  COMMIT TRAN
               END

               FETCH NEXT FROM C_ARC_MBOLDetail INTO @cMBOLLine
            END
            CLOSE C_ARC_MBOLDetail
            DEALLOCATE C_ARC_MBOLDetail
         END

         FETCH NEXT FROM C_ARC_MBOL INTO @cMBOLKey
      END
      CLOSE C_ARC_MBOL
      DEALLOCATE C_ARC_MBOL

   IF ((@n_continue = 1 or @n_continue = 2)  AND @copyrowstoarchivedatabase = 'y')
   BEGIN
      SELECT @c_temp = 'attempting to archive ' + RTRIM(CONVERT(NVARCHAR(6),@n_archive_mbol_records )) +
                       ' MBOL records AND ' + RTRIM(CONVERT(NVARCHAR(6),@n_archive_mbol_Detail_records )) + ' MBOLDetail records'
      EXECUTE nsplogalert
               @c_modulename   = 'isp_ArchiveMbol',
               @c_alertmessage = @c_temp ,
               @n_severity     = 0,
               @b_success      = @b_success OUTPUT,
               @n_err          = @n_err     OUTPUT,
               @c_errmsg       = @c_errmsg  OUTPUT
      IF NOT @b_success = 1
      BEGIN
         SELECT @n_continue = 3
      END
   END

   IF ((@n_continue = 1 or @n_continue = 2) AND @copyrowstoarchivedatabase = 'y')
   BEGIN
      IF (@b_debug =1 )
      BEGIN
         PRINT 'building insert for MBOLDetail...'
      END
      SELECT @b_success = 1
      EXEC nsp_build_insert
            @c_copyto_db,
            'MBOLDetail',
            1,
            @b_success OUTPUT,
            @n_err     OUTPUT,
            @c_errmsg  OUTPUT
      IF NOT @b_success = 1
      BEGIN
         SELECT @n_continue = 3
      END
   END

   IF ((@n_continue = 1 or @n_continue = 2) AND @copyrowstoarchivedatabase = 'y')
   BEGIN
      IF (@b_debug =1 )
      BEGIN
         PRINT 'building insert for MBOL...'
      END
      SELECT @b_success = 1
      EXEC nsp_build_insert
            @c_copyto_db,
            'MBOL',
            1,
            @b_success OUTPUT,
            @n_err     OUTPUT,
            @c_errmsg  OUTPUT
      IF NOT @b_success = 1
      BEGIN
         SELECT @n_continue = 3
      END
   END

   WHILE @@trancount > 0
      COMMIT TRAN

   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      SELECT @b_success = 1
      EXECUTE nsplogalert
               @c_modulename   = 'isp_ArchiveMbol',
               @c_alertmessage = 'archive of MBOL ended successfully.',
               @n_severity     = 0,
               @b_success      = @b_success OUTPUT,
               @n_err          = @n_err     OUTPUT,
               @c_errmsg       = @c_errmsg  OUTPUT
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
         EXECUTE nsplogalert
                  @c_modulename   = 'isp_ArchiveMbol',
                  @c_alertmessage = 'archive of MBOL failed - check this log for additional messages.',
                  @n_severity     = 0,
                  @b_success      = @b_success OUTPUT,
                  @n_err          = @n_err     OUTPUT,
                  @c_errmsg       = @c_errmsg  OUTPUT
         IF NOT @b_success = 1
         BEGIN
            SELECT @n_continue = 3
         END
      END
   END
END -- main
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

grant execute on isp_ArchiveMbol to nsql
go
