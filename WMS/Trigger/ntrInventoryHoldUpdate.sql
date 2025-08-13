SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Trigger:  ntrInventoryHoldUpdate                                     */  
/* Creation Date: 2011-4-11                                             */  
/* Copyright: IDS                                                       */  
/* Written by: KHLim                                                    */  
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
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author    Ver.  Purposes                                */  
/* 2011-06-06   KHLim     1.0   SET WhoOff = WhoOn                      */  
/* 2011-06-24   KHLim01   1.0   add UPDATE(TrafficCop) to allow bypass  */  
/* 2015-09-11   MCTang    1.1   ADD INVHCHGLOG (MC01)                   */ 
/* 2025-08-08   Michael   1.2   FCR-6025-Add InventoryHold TLOG2 (ML01) */
/************************************************************************/  
CREATE OR ALTER TRIGGER [dbo].[ntrInventoryHoldUpdate]  
ON  [dbo].[INVENTORYHOLD]  
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
      , @c_errmsg      Nvarchar(250) -- Error message returned by stored procedure or this trigger  
      , @n_continue    int  
      , @n_starttcnt   int       -- Holds the current transaction count  
      , @c_preprocess  Nvarchar(250) -- preprocess  
      , @c_pstprocess  Nvarchar(250) -- post process  
      , @n_cnt         int  
      , @b_debug       int  

      , @c_InventoryHoldKey   NVARCHAR(10) 
      , @c_TransmitLogKey     NVARCHAR(10) 
      , @c_StorerKey          NVARCHAR(15)
      , @c_Lot                NVARCHAR(10) 
      , @c_Loc                NVARCHAR(10)   --ML01
      , @c_ID                 NVARCHAR(18)
      , @c_DelStatus          NVARCHAR(5)
      , @c_InsStatus          NVARCHAR(5)    --ML01
      , @c_Hold               NVARCHAR(1)    --ML01
      , @c_authority          NVARCHAR(30)   --ML01
  
SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT, @b_debug = 0  
  
IF UPDATE(TrafficCop)         -- KHLim01  
BEGIN  
   SELECT @n_continue = 4  
END  
  
IF (@n_continue = 1 OR @n_continue= 2) AND UPDATE(Hold)  
BEGIN  
   IF EXISTS (SELECT 1 FROM INSERTED, DELETED  
              WHERE INSERTED.InventoryHoldKey = DELETED.InventoryHoldKey  
              AND INSERTED.Hold <> DELETED.Hold  
              AND INSERTED.Hold = '1')  
   BEGIN  
      UPDATE InventoryHold  
      SET InventoryHold.DateOff = InventoryHold.DateOn,  
          InventoryHold.WhoOff = InventoryHold.WhoOn  
      FROM InventoryHold, INSERTED ,DELETED   
      WHERE InventoryHold.InventoryHoldKey = INSERTED.InventoryHoldKey  
      AND DELETED.InventoryHoldKey = INSERTED.InventoryHoldKey    
      AND INSERTED.Hold <> DELETED.Hold  
      AND INSERTED.Hold = '1'  
      SELECT @n_err = @@ERROR  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 70001   
         SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))   
                          + ': Unable to Update InventoryHold table (ntrInventoryHoldUpdate)'   
                          + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '   
      END  
   END  

   --ML01-S
   IF @n_Continue IN (1,2)
   BEGIN
      DECLARE INVHOLD_CUR CURSOR LOCAL READ_ONLY FAST_FORWARD FOR  
      SELECT InventoryHoldKey  
      FROM   INSERTED  

      OPEN INVHOLD_CUR  
      FETCH NEXT FROM INVHOLD_CUR INTO @c_InventoryHoldKey
      
      WHILE @@FETCH_STATUS = 0 AND @n_continue IN (1,2)
      BEGIN 
         IF EXISTS (SELECT 1 FROM INSERTED, DELETED  
                    WHERE INSERTED.InventoryHoldKey = DELETED.InventoryHoldKey  
                    AND   INSERTED.Hold <> DELETED.Hold
                    AND   INSERTED.InventoryHoldKey = @c_InventoryHoldKey)  
         BEGIN
            SELECT @c_StorerKey = '', @c_Lot = '', @c_Loc = '', @c_ID = '', @c_Hold = '', @c_InsStatus = ''

            SELECT @c_StorerKey = ISNULL(INSERTED.Storerkey, '')
                 , @c_Lot = ISNULL(INSERTED.LOT, '')
                 , @c_Loc = ISNULL(INSERTED.LOC, '')
                 , @c_ID = ISNULL(INSERTED.ID, '')
                 , @c_Hold = ISNULL(INSERTED.Hold,'')
                 , @c_InsStatus = ISNULL(INSERTED.Status,'')
            FROM   INSERTED
            WHERE  InventoryHoldKey = @c_InventoryHoldKey

            IF ISNULL(@c_StorerKey,'') = '' AND @c_Lot <> ''
            BEGIN
               SELECT TOP 1 @c_StorerKey = ISNULL(Storerkey, '')
               FROM LOT WITH(NOLOCK)
               WHERE LOT = @c_Lot
            END
            IF ISNULL(@c_StorerKey,'') = '' AND @c_ID <> ''
            BEGIN
               SELECT TOP 1 @c_StorerKey = ISNULL(Storerkey, '')
               FROM LOTXLOCXID WITH(NOLOCK)
               WHERE ID = @c_ID
            END
            IF ISNULL(@c_StorerKey,'') = '' AND @c_Loc <> ''
            BEGIN
               SELECT TOP 1 @c_StorerKey = ISNULL(Storerkey, '')
               FROM LOTXLOCXID WITH(NOLOCK)
               WHERE LOC = @c_Loc
            END

            IF @c_StorerKey <> '' AND (dbo.fnc_RTrim(@c_Loc) <> '' OR dbo.fnc_RTrim(@c_Lot) <> '' OR  dbo.fnc_RTrim(@c_ID) <> '')
            BEGIN
               EXECUTE nspGetRight
                    NULL          -- Facility
                  , @c_StorerKey  -- Storer
                  , NULL          -- Sku
                  , 'INVENTORY HOLD - INTERFACE2'   -- ConfigKey
                  , @b_success    OUTPUT
                  , @c_authority  OUTPUT
                  , @n_err        OUTPUT
                  , @c_errmsg     OUTPUT
               IF @b_success <> 1
               BEGIN
                  SELECT @n_continue = 3
                  SELECT @n_err = 70002
                  SELECT @c_errmsg = 'ntrInventoryHoldUpdate: ' + dbo.fnc_RTrim(@c_errmsg)
               END
               ELSE IF @c_authority = '1'
               BEGIN
                  EXECUTE nspg_getkey
                       'TransmitlogKey2'
                     , 10
                     , @c_transmitlogkey OUTPUT
                     , @b_success OUTPUT
                     , @n_err OUTPUT
                     , @c_errmsg OUTPUT
                  IF NOT @b_success=1
                  BEGIN
                     SELECT @n_continue=3
                     SELECT @n_err = 70003
                     SELECT @c_errmsg = 'ntrInventoryHoldUpdate: ' + dbo.fnc_RTrim(@c_errmsg)
                  END
                  ELSE
                  BEGIN
                     INSERT TRANSMITLOG2 (Transmitlogkey, tablename, key1, key2, key3, transmitflag)
                     VALUES (@c_transmitlogkey, 'InventoryHold', @c_InventoryHoldKey, @c_InsStatus, @c_StorerKey, '0')
                     SELECT @n_err= @@Error
                     IF NOT @n_err=0
                     BEGIN
                        SELECT @n_continue=3
                        SELECT @n_err = 70004
                        SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))
                                         + ': Unable insert TRANSMITLOG2 Table. (ntrInventoryHoldUpdate)'
                                         + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
                     END
                  END
               END
            END --IF @c_StorerKey <> '' 
         END
         FETCH NEXT FROM INVHOLD_CUR INTO @c_InventoryHoldKey
      END -- while orderkey  
      CLOSE INVHOLD_CUR  
      DEALLOCATE INVHOLD_CUR
   END
   --ML01-E
END  
  
--(MC01) - S
IF ( @n_Continue = 1 OR @n_Continue = 2 ) AND UPDATE(Status)
BEGIN
   DECLARE INVH_CUR CURSOR LOCAL READ_ONLY FAST_FORWARD FOR  
   SELECT InventoryHoldKey  
   FROM   INSERTED  
  
   OPEN INVH_CUR  
   FETCH NEXT FROM INVH_CUR INTO @c_InventoryHoldKey
  
   WHILE @@FETCH_STATUS <> -1  AND (@n_continue = 1 OR @n_continue = 2)  
   BEGIN 
      IF EXISTS (SELECT 1 FROM INSERTED, DELETED  
                 WHERE INSERTED.InventoryHoldKey = DELETED.InventoryHoldKey  
                 AND   INSERTED.Status <> DELETED.Status
                 AND   INSERTED.InventoryHoldKey = @c_InventoryHoldKey)  
      BEGIN
         SELECT @c_StorerKey = ISNULL(INSERTED.Storerkey, '')
              , @c_Lot = ISNULL(INSERTED.LOT, '')
              , @c_ID = ISNULL(INSERTED.ID, '')
         FROM   INSERTED
         WHERE  InventoryHoldKey = @c_InventoryHoldKey

         IF @c_StorerKey = ''
         BEGIN
            IF @c_Lot <> ''
            BEGIN
               SELECT @c_StorerKey = ISNULL(Storerkey, '')
               FROM   LOT WITH (NOLOCK)
               WHERE  LOT = @c_Lot
            END
            IF @c_ID <> ''
            BEGIN
               SELECT TOP 1 @c_StorerKey = ISNULL(Storerkey, '')
               FROM   LOTXLOCXID WITH (NOLOCK)
               WHERE  ID = @c_ID
            END
         END

         IF @c_StorerKey <> ''
         BEGIN
            IF EXISTS(SELECT 1 FROM StorerConfig (NOLOCK)   
                      WHERE StorerKey = @c_StorerKey   
                      AND   ConfigKey = 'INVHCHGLOG' )   
            BEGIN  

               SELECT @c_DelStatus = ISNULL(DELETED.Status, '')
               FROM  INSERTED, DELETED  
               WHERE INSERTED.InventoryHoldKey = DELETED.InventoryHoldKey  
               AND   INSERTED.InventoryHoldKey = @c_InventoryHoldKey

               SELECT @c_TransmitLogKey = ''  
               SELECT @b_success = 1  
               EXECUTE nspg_getkey  
                      'TransmitlogKey3'  
                    , 10  
                    , @c_TransmitLogKey OUTPUT  
                    , @b_success        OUTPUT  
                    , @n_err            OUTPUT  
                    , @c_errmsg         OUTPUT  

               IF @b_success <> 1  
               BEGIN  
                  SELECT @n_continue = 3  
                  SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 70001   
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))   
                                   + ': Unable to obtain transmitlogkey. (ntrInventoryHoldUpdate)'   
                                   + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '  
               END  
               ELSE  
               BEGIN  

                  INSERT INTO TRANSMITLOG3 (Transmitlogkey, Tablename, Key1, Key2, Key3, Transmitflag)  
                  VALUES (@c_TransmitLogKey, 'INVHCHGLOG', @c_InventoryHoldKey, @c_DelStatus, @c_StorerKey, '0')  

                  IF @@ROWCOUNT=0  
                  BEGIN  
                     SELECT @n_continue = 3  
                     SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 70001   
                     SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))   
                                      + ': Unable insert TRANSMITLOG3 Table. (ntrInventoryHoldUpdate)'   
                                      + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '     
                  END   
               END  
            END --ConfigKey = 'INVHCHGLOG'
         END --IF @c_StorerKey <> '' 
      END
      FETCH NEXT FROM INVH_CUR INTO @c_InventoryHoldKey
   END -- while orderkey  
   CLOSE INVH_CUR  
   DEALLOCATE INVH_CUR
END
--(MC01) - E

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
   EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrInventoryHoldUpdate'   
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