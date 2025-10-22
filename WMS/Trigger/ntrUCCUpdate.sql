SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Trigger: ntrUCCUpdate                                                */  
/* Creation Date:                                                       */  
/* Copyright: IDS                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose:  Update UCC.                                                */  
/*                                                                      */  
/* Return Status:                                                       */  
/*                                                                      */  
/* Usage:                                                               */  
/*                                                                      */  
/* Called By: When records Updated                                      */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Modifications:                                                       */  
/* Date         Author   Ver  Purposes                                  */  
/* 07-Jun-2012 KHLim01   1.1  prefix rdt. if come from RDT              */
/* 24-08-2012  ChewKP    1.2  SOS#253989 Update UCC information to      */  
/*                            Traceinfo (ChewKP01)                      */
/* 28-Oct-2013 TLTING    1.3  Review Editdate column update             */
/* 01-11-2013  Shong     1.3  Remove TraceInfo and Do not update        */
/*                            EditDate if already update                */  
/* 16-05-2014  TLTING    1.3  New primary key UCC_RowRef                */  
/* 19-08-2014  TLTING    1.4  Add ArchiveCop & TrrafficCop              */  
/* 25-09-2025  MICHAEL   1.5  FCR-7829 Inventory UCC-level HOLD (ML01)  */
/* 09-10-2025  SPC040    1.6  Replace SUSER_SNAME with fnc_GetUserName  */
/************************************************************************/  
CREATE OR ALTER TRIGGER [dbo].[ntrUCCUpdate]  
ON  [dbo].[UCC]   
FOR UPDATE  
AS  
BEGIN  
   IF @@ROWCOUNT = 0  
   BEGIN  
      RETURN  
   END  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET ANSI_WARNINGS OFF  
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
         , @n_IsRDT INT            -- KHLim01
         , @c_PreUN varchar(5)     -- KHLim01
--ML01-S
         , @c_Storerkey        NVARCHAR(15)
         , @c_CurrentStorerkey NVARCHAR(15)
         , @c_CurrentUCCNo     NVARCHAR(20)
         , @c_CurrentStorerUCC NVARCHAR(40)
         , @c_InvHoldLog       NVARCHAR(1)
         , @c_InvHoldUCC       NVARCHAR(1)
         , @n_IDCnt            INT
         , @n_LocCnt           INT
         , @c_InvHoldKey       NVARCHAR(10)
         , @c_transmitlogkey   NVARCHAR(10)
         , @c_InStatus         NVARCHAR(10)
         , @c_DelStatus        NVARCHAR(10)
         , @c_Key2             NVARCHAR(30)
--ML01-E
           
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  

   IF UPDATE(ArchiveCop)      --KH01
   BEGIN
      SELECT @n_continue = 4
   END

   IF UPDATE(TrafficCop)      --KH01
   BEGIN
      SELECT @n_continue = 4
   END

   IF (@n_continue = 1 OR @n_continue = 2) AND NOT UPDATE(EditDate)  
   BEGIN 
      -- KHLim01 start
      EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT
      IF @n_IsRDT = 1 
      BEGIN
         SET @c_PreUN = 'rdt.' 
      END
      ELSE
      BEGIN
         SET @c_PreUN = ''
      END
      -- KHLim01 end
             
      UPDATE UCC  with (RowLock)
         SET EditDate = dbo.fnc_GetDate(),  
             EditWho = @c_PreUN + dbo.fnc_GetUserName() -- KHLim01
        FROM UCC, INSERTED  
       WHERE UCC.UCC_RowRef = INSERTED.UCC_RowRef
 
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=85803   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))  
                         +': Update Failed On Table UCC. (ntrUCCUpdate)' + ' ( '   
                         +' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '  
      END  
   END  
   /* END Added */

   --ML01-S
   IF ( @n_continue=1 OR @n_continue=2) AND UPDATE(STATUS)
      AND EXISTS(SELECT TOP 1 1 FROM sys.columns where object_id=OBJECT_ID(N'[dbo].[INVENTORYHOLD]') AND name='UCCNo')
   BEGIN
      IF EXISTS (SELECT TOP 1 1
                   FROM INVENTORYHOLD (NOLOCK), INSERTED, DELETED
                  WHERE INSERTED.UCC_RowRef = DELETED.UCC_RowRef
                    AND INSERTED.Storerkey = INVENTORYHOLD.Storerkey
                    AND INSERTED.UCCNo = INVENTORYHOLD.UCCNo
                    AND (ISNULL(INSERTED.STATUS,'')='H' AND ISNULL(DELETED.STATUS,'')<>'H'
                      OR ISNULL(INSERTED.STATUS,'')<>'H' AND ISNULL(DELETED.STATUS,'')='H') )
      BEGIN
         SET @c_CurrentStorerUCC = ''
         SET @c_Storerkey = ''
         SET @c_InvHoldLog = '0'
         SET @c_InvHoldUCC = '0'

         WHILE (1=1) -- UCC Level
         BEGIN
            SELECT TOP 1
                   @c_CurrentStorerkey = INSERTED.Storerkey
                 , @c_CurrentUCCNo     = INSERTED.UCCNo
                 , @c_InStatus         = INSERTED.Status
                 , @c_DelStatus        = DELETED.Status
                 , @c_InvHoldKey       = INVENTORYHOLD.InventoryHoldKey
            FROM INVENTORYHOLD (NOLOCK), INSERTED, DELETED
            WHERE INSERTED.UCC_RowRef = DELETED.UCC_RowRef
              AND INSERTED.Storerkey = INVENTORYHOLD.Storerkey
              AND INSERTED.UCCNo = INVENTORYHOLD.UCCNo
              AND (ISNULL(INSERTED.STATUS,'')='H' AND ISNULL(DELETED.STATUS,'')<>'H'
                OR ISNULL(INSERTED.STATUS,'')<>'H' AND ISNULL(DELETED.STATUS,'')='H')
              AND CONVERT(NCHAR(15),ISNULL(INSERTED.Storerkey,'')) + CONVERT(NCHAR(20),ISNULL(INSERTED.UCCNo,'')) > @c_CurrentStorerUCC
            ORDER BY INSERTED.Storerkey, INSERTED.UCCNo, INSERTED.UCC_RowRef

            IF @@ROWCOUNT <= 0
               BREAK

            SET @c_CurrentStorerUCC = CONVERT(NCHAR(15),ISNULL(@c_CurrentStorerkey,'')) + CONVERT(NCHAR(20),ISNULL(@c_CurrentUCCNo,''))

            IF @c_Storerkey <> @c_CurrentStorerkey
            BEGIN
               SET @c_Storerkey = @c_CurrentStorerkey
               SET @b_success = 0
               SET @c_InvHoldLog = '0'
               SET @c_InvHoldUCC = '0'

               EXECUTE nspGetRight
               NULL,          -- Facility
               @c_StorerKey,  -- Storer
               NULL,          -- Sku
               'INVHOLDLOG',  -- ConfigKey
               @b_success     OUTPUT,
               @c_InvHoldLog  OUTPUT,
               @n_err         OUTPUT,
               @c_errmsg      OUTPUT

               IF @b_success <> 1
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @n_err = 60981
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5), @n_err)+ ' ntrUCCUpdate :' + RTrim(@c_errmsg)
                  BREAK
               END


               EXECUTE nspGetRight
               NULL,          -- Facility
               @c_StorerKey,  -- Storer
               NULL,          -- Sku
               'InvHoldUCC',  -- ConfigKey
               @b_success     OUTPUT,
               @c_InvHoldUCC  OUTPUT,
               @n_err         OUTPUT,
               @c_errmsg      OUTPUT

               IF @b_success <> 1
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @n_err = 60982
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5), @n_err)+ ' ntrUCCUpdate :' + RTrim(@c_errmsg)
                  BREAK
               END
            END

            IF (@n_continue = 1 or @n_continue = 2) AND @c_InvHoldLog = '1'
            BEGIN
               -- To prevent double sending of records
               SELECT @n_IDCnt = 0,  @n_LocCnt = 0

               SELECT @n_IDCnt = COUNT(*)
               FROM TRANSMITLOG3 T3 (NOLOCK)
               JOIN INVENTORYHOLD IH (NOLOCK) ON (IH.InventoryHoldKey = T3.Key1)
               JOIN UCC (NOLOCK) ON (UCC.ID = IH.ID AND UCC.Storerkey = @c_CurrentStorerkey AND UCC.UCCNo = @c_CurrentUCCNo)
               JOIN LOTxLOCxID LLI (NOLOCK) ON (UCC.Lot=LLI.Lot AND UCC.Loc=LLI.Loc AND UCC.ID=LLI.ID)
               WHERE T3.Tablename = 'INVHOLDLOG-ID'
               AND   T3.Transmitflag = '0'
               AND   T3.Key2 = @c_InStatus

               IF @n_IDCnt = 0
               BEGIN
                  SELECT @n_LocCnt = COUNT(*)
                  FROM TRANSMITLOG3 T3 (NOLOCK)
                  JOIN INVENTORYHOLD IH (NOLOCK) ON (IH.InventoryHoldKey = T3.Key1)
                  JOIN UCC (NOLOCK) ON (UCC.LOC = IH.LOC AND UCC.Storerkey = @c_CurrentStorerkey AND UCC.UCCNo = @c_CurrentUCCNo)
                  JOIN LOTxLOCxID LLI (NOLOCK) ON (UCC.Lot=LLI.Lot AND UCC.Loc=LLI.Loc AND UCC.ID=LLI.ID)
                  WHERE T3.Tablename = 'INVHOLDLOG-LOC'
                  AND   T3.Transmitflag = '0'
                  AND   T3.Key2 = @c_InStatus
               END

               IF (@n_IDCnt = 0) AND (@n_LocCnt = 0)
               BEGIN
                  IF NOT EXISTS ( SELECT 1 FROM TransmitLog3 (NOLOCK) WHERE TableName = 'INVHOLDLOG-UCC'
                                  AND Key1 = @c_InvHoldKey AND Key2 = @c_InStatus
                                  AND Key3 = @c_CurrentStorerkey AND Transmitflag = '0')
                  BEGIN
                     SELECT @c_transmitlogkey = ''
                     SELECT @b_success = 1
                     EXECUTE nspg_getkey
                         'TransmitlogKey3'
                         ,10
                         , @c_transmitlogkey OUTPUT
                         , @b_success OUTPUT
                         , @n_err OUTPUT
                         , @c_errmsg OUTPUT

                     IF @b_success <> 1
                     BEGIN
                        SELECT @n_continue=3
                        SELECT @n_err = 60983
                        SELECT @c_errmsg = 'NSQL' + CONVERT(char(5), @n_err)+ ' ntrUCCUpdate :' + RTrim(@c_errmsg)
                     END
                     ELSE
                     BEGIN
                        INSERT INTO TRANSMITLOG3 (Transmitlogkey, Tablename, Key1, Key2, Key3, Transmitflag)
                        VALUES (@c_transmitlogkey, 'INVHOLDLOG-UCC', @c_InvHoldKey, @c_InStatus, @c_CurrentStorerkey, '0')

                        SELECT @n_err= @@ERROR

                        IF NOT @n_err=0
                        BEGIN
                           SELECT @n_continue=3
                           SELECT @c_errmsg= CONVERT(char(250), @n_err), @n_err=60984
                           SELECT @c_errmsg= 'NSQL' + CONVERT(char(5), @n_err)+ ':Insert failed on TransmitLog3 (INVHOLDLOG-UCC). (ntrUCCUpdate)' +'(' + 'SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ')'
                        END
                     END
                  END
               END
            END -- IF (@n_continue = 1 or @n_continue = 2) AND @c_InvHoldLog = '1'


            IF (@n_continue = 1 or @n_continue = 2) AND @c_InvHoldUCC = '1'
            BEGIN
               SELECT @c_transmitlogkey = ''
               SELECT @b_success = 1
               EXECUTE nspg_getkey
                   'TransmitlogKey2'
                   ,10
                   , @c_transmitlogkey OUTPUT
                   , @b_success OUTPUT
                   , @n_err OUTPUT
                   , @c_errmsg OUTPUT

               IF @b_success <> 1
               BEGIN
                  SELECT @n_continue=3
                  SELECT @n_err = 60985
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5), @n_err)+ ' ntrUCCUpdate :' + RTrim(@c_errmsg)
               END
               ELSE
               BEGIN
                  SET @c_Key2 = CONVERT(NCHAR(1),ISNULL(@c_DelStatus,'')) + CONVERT(NCHAR(1),ISNULL(@c_InStatus,'')) +'-'+ ISNULL(RTRIM(@c_CurrentUCCNo),'')

                  INSERT INTO TRANSMITLOG2 (Transmitlogkey, Tablename, Key1, Key2, Key3, Transmitflag)
                  VALUES (@c_transmitlogkey, 'InvHoldUCC', @c_InvHoldKey, @c_Key2, @c_CurrentStorerkey, '0')

                  SELECT @n_err= @@ERROR

                  IF NOT @n_err=0
                  BEGIN
                     SELECT @n_continue=3
                     SELECT @c_errmsg= CONVERT(char(250), @n_err), @n_err=60986
                     SELECT @c_errmsg= 'NSQL' + CONVERT(char(5), @n_err)+ ':Insert failed on TransmitLog2 (InvHoldUCC). (ntrUCCUpdate)' +'(' + 'SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ')'
                  END
               END
            END -- IF (@n_continue = 1 or @n_continue = 2) AND @c_InvHoldUCC = '1'
         END -- WHILE (1=1)
      END -- if record exists
   END -- IF ( @n_continue=1 OR @n_continue=2) AND UPDATE(STATUS)
   --ML01-E
 
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
  
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrUCCUpdate'  
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