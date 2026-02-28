SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Trigger: ntrInventoryHoldAdd                                         */
/* Creation Date:                                                       */
/* Copyright: MAERSK                                                    */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By: When records added into ITRN                              */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 07-Sep-2006  MaryVong      Add in RDT compatible error messages      */
/* 09-Aug-2016  TLTING        Change Set ROWCOUNT 1 to Top 1            */
/* 09-May-2025  SSA01         FCR-3392- Modified to enable storer level */
/*                            config                                    */
/* 22-May-2025  SSA02         FCR-3392- Updated key2 and Key3 values    */
/* 09-Jul-2025  PPA01         FCR-6025- Added lot and Id level checks   */
/* 08-Aug-2025  Michael       FCR-6025- Handle Hold&Release(TLOG2)(ML01)*/
/* 25-Sep-2025  Michael       FCR-7829 Inventory UCC-level HOLD (ML02)  */
/* 25-Feb-2026  Michael       FCR-10889- TLog2 Trigger enhancement(ML03)*/
/************************************************************************/
CREATE OR ALTER TRIGGER [dbo].[ntrInventoryHoldAdd]
ON  [dbo].[INVENTORYHOLD]
FOR INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

/* (ML03) New OPTION5 Parameters for StorerCOnfig.Configkey 'INVENTORY HOLD - INTERFACE2'
   TRANSMITLOG2.TableName = 'InventoryHold'
   OPTION5:
      @c_NoTLog2AddUnhold  = Y/N              Not  gen TransmitLog2 if Hold<>1 in InventoryHold Add Trigger (default gen for Hold and Unhold)
      @c_HoldFlag          = 0,1              Only gen Transmitlog2 if Hold = specific value2 (0 or 1) (default gen for Hold and Unhold)
      @c_HoldStatus        = Sts1,Sts2,...    Only gen Transmitlog2 if Status = specific values (default gen for all Status)
      @c_HoldStatusExclude = Sts3,Sts4,...    Only gen Transmitlog2 if Status <> specific values (default gen for all Status)
      @c_HoldMethod        = LOT,LOC,ID,UCC   Only gen Transmitlog2 if Hold Method is specific methos (default gen for all methods)
      @c_TLogKey2PfxHold   = Y/N              Append Hold prefix (H_ or U_) or not (default not append prefix)
*/

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
   /* #INCLUDE <TRADA1.SQL> */
   /************************************************************************
   *  Add records in TransmitLog to track the QC HOLD            *
   *************************************************************************/
   DECLARE @c_LOT    NVARCHAR(10),
         @c_LOC    NVARCHAR(10),
         @c_ID     NVARCHAR(18),
         @c_String NVARCHAR(255),
         @c_InventoryHoldKey NVARCHAR(10),
         @c_StorerKey        NVARCHAR(20),
         @c_Hold             NVARCHAR(1),
         @c_SKU              NVARCHAR(20),
         @n_Qty              float,
         @c_WorkOrderNo      NVARCHAR(18),
         @c_BatchNo          NVARCHAR(18),
         @c_Status           NVARCHAR(10)    -- (SSA02)
       , @c_UCCNo            NVARCHAR(20)    --ML02
       --ML03-S
       , @c_Option5           NVARCHAR(4000)
       , @c_NoTLog2AddUnhold  NVARCHAR(30)
       , @c_HoldFlag          NVARCHAR(30)
       , @c_HoldStatus        NVARCHAR(4000)
       , @c_HoldStatusExclude NVARCHAR(4000)
       , @c_HoldMethod        NVARCHAR(30)
       , @c_TLogKey2PfxHold   NVARCHAR(30)
       , @c_Key2              NVARCHAR(30)
       , @b_GenTLog2          INT
       --ML03-E

   /* IDSV5 - Leo */
   Declare @c_primarykey NVARCHAR(10), @b_interface NVARCHAR(1), @c_transmitlogkey NVARCHAR(10), @c_authority NVARCHAR(1)
   Select @c_primarykey = ''
   While 1 = 1
   Begin
      -- Set rowcount 1
      Select TOP 1 @c_primarykey = InventoryHoldKey,
      @c_hold = ISNULL(INSERTED.Hold, ''),  --(SSA01)
      @c_loc = ISNULL(INSERTED.Loc, ''),    --(SSA01)
      @c_LOT = ISNULL(INSERTED.Lot, ''),    --(PPA01)
      @c_ID = ISNULL(INSERTED.Id, ''),      --(PPA01)
      @c_UCCNo = ISNULL(INSERTED.UCCNo, ''),   --ML02
      @c_StorerKey = ISNULL(INSERTED.Storerkey, ''), --(SSA01)
      @c_Status = ISNULL(INSERTED.Status, '')  --(SSA02)
      From INSERTED
      Where INSERTED.InventoryHoldKey > @c_primarykey
      Order by INSERTED.InventoryHoldKey
      if @@rowcount = 0
      Begin
         -- set rowcount 0
         break
      End

      --ML01-S
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
      --ML01-E

      Execute nspGetRight null,  -- Facility
         null,  -- Storer
         null,  -- Sku
         'INVENTORY HOLD - INTERFACE',      -- ConfigKey
         @b_success    output,
         @c_authority  output,
         @n_err        output,
         @c_errmsg     output
      If @b_success <> 1
      Begin
         SELECT @n_continue = 3
         SELECT @n_err = 62476
         Select @c_errmsg = 'ntrInventoryHoldAdd: ' + dbo.fnc_RTrim(@c_errmsg)
         Break
      End
      Else
      Begin
         If @c_authority = '1'
            Select @b_interface = '1'
         Else
            Select @b_interface = '0'
      End
      
      If @b_interface = '1'
      BEGIN
         If dbo.fnc_RTrim(@c_loc) is not null and @c_hold = '1'
         Begin
            EXECUTE nspg_getkey
               'TransmitlogKey'
               ,10
               , @c_transmitlogkey OUTPUT
               , @b_success OUTPUT
               , @n_err OUTPUT
               , @c_errmsg OUTPUT
            IF NOT @b_success=1
            BEGIN
               SELECT @n_continue=3
               SELECT @n_err = 62477
               SELECT @c_errmsg = 'ntrInventoryHoldAdd: ' + dbo.fnc_RTrim(@c_errmsg)
            END
      
            IF ( @n_continue = 1 or @n_continue = 2 )
            BEGIN
               INSERT TRANSMITLOG  (Transmitlogkey, tablename, key1, key2, key3,  transmitflag)
               VALUES  (@c_transmitlogkey, "InventoryHold", @c_primarykey, '', 'HOLD','0')
               SELECT @n_err= @@Error
               IF NOT @n_err=0
               BEGIN
                  SELECT @n_continue=3
                  /* Trap SQL Server Error */
                  Select @n_err = 62478 -- 99701
                  Select @c_errmsg= 'NSQL'+CONVERT(char(5), @n_err)+':Insert Into TransmitLog Table (InventoryHold) Failed. (ntrInventoryHoldAdd)'+'('+'SQLSvr MESSAGE='+dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg))+')'
                  /* End Trap SQL Server Error */
               END
            END
         End
      End

      --SSA01-S
      Execute nspGetRight null,  -- Facility
         @c_StorerKey,  -- Storer
         null,  -- Sku
         'INVENTORY HOLD - INTERFACE2',      -- ConfigKey
         @b_success    output,
         @c_authority  output,
         @n_err        output,
         @c_errmsg     output
       , @c_Option5 = @c_Option5 OUTPUT   --ML03

      IF @b_success <> 1
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = 62479
         SELECT @c_errmsg = 'ntrInventoryHoldAdd: ' + dbo.fnc_RTrim(@c_errmsg)
         BREAK
      END
      ELSE
      BEGIN
         IF @c_authority = '1'
            SELECT @b_interface = '1'
         ELSE
            SELECT @b_interface = '0'
      END
      
      IF @b_interface = '1'
      BEGIN
--ML01         IF (@c_hold = '1'  and (dbo.fnc_RTrim(@c_loc) <> '' OR dbo.fnc_RTrim(@c_LOT) <> '' OR  dbo.fnc_RTrim(@c_ID) <> '') ) --PPA01
         IF (dbo.fnc_RTrim(@c_loc) <> '' OR dbo.fnc_RTrim(@c_LOT) <> '' OR  dbo.fnc_RTrim(@c_ID) <> '')   --ML01
            OR dbo.fnc_RTrim(@c_UCCNo) <> ''   --ML02
         BEGIN
            --ML03-S
            SELECT @c_NoTLog2AddUnhold = ''
                 , @c_HoldFlag   = ''
                 , @c_HoldStatus = ''
                 , @c_HoldStatusExclude = ''
                 , @c_HoldMethod = ''
                 , @b_GenTLog2   = 1

            SELECT @c_NoTLog2AddUnhold  = dbo.fnc_GetParamValueFromString('@c_NoTLog2AddUnhold' , @c_Option5, @c_NoTLog2AddUnhold )   -- Y/N
                 , @c_HoldFlag          = dbo.fnc_GetParamValueFromString('@c_HoldFlag'         , @c_Option5, @c_HoldFlag         )   -- 0,1
                 , @c_HoldStatus        = dbo.fnc_GetParamValueFromString('@c_HoldStatus'       , @c_Option5, @c_HoldStatus       )   -- Sts1,Sts2,...
                 , @c_HoldStatusExclude = dbo.fnc_GetParamValueFromString('@c_HoldStatusExclude', @c_Option5, @c_HoldStatusExclude)   -- Sts3,Sts4,...
                 , @c_HoldMethod        = dbo.fnc_GetParamValueFromString('@c_HoldMethod'       , @c_Option5, @c_HoldMethod       )   -- LOT,LOC,ID,UCC

            IF @b_GenTLog2 = 1 AND @c_NoTLog2AddUnhold='Y' AND ISNULL(@c_hold,'')<>'1'
            BEGIN
               SET @b_GenTLog2 = 0
            END

            IF @b_GenTLog2 = 1 AND ISNULL(@c_HoldFlag,'')<>''
            BEGIN
               IF NOT EXISTS(SELECT TOP 1 1 FROM STRING_SPLIT(@c_HoldFlag,',') WHERE value<>'' AND TRIM(value)=@c_hold)
                  SET @b_GenTLog2 = 0
            END

            IF @b_GenTLog2 = 1 AND ISNULL(@c_HoldStatus,'')<>''
            BEGIN
               IF NOT EXISTS(SELECT TOP 1 1 FROM STRING_SPLIT(@c_HoldStatus,',') WHERE value<>'' AND TRIM(value)=@c_Status)
                  SET @b_GenTLog2 = 0
            END

            IF @b_GenTLog2 = 1 AND ISNULL(@c_HoldStatusExclude,'')<>''
            BEGIN
               IF EXISTS(SELECT TOP 1 1 FROM STRING_SPLIT(@c_HoldStatusExclude,',') WHERE value<>'' AND TRIM(value)=@c_Status)
                  SET @b_GenTLog2 = 0
            END

            IF @b_GenTLog2 = 1 AND ISNULL(@c_HoldMethod,'')<>''
            BEGIN
               SET @c_HoldMethod = (SELECT DISTINCT ','+UPPER(TRIM(value)) FROM STRING_SPLIT(@c_HoldMethod,',') ORDER BY 1 FOR XML PATH('')) + ','
               IF NOT (ISNULL(@c_LOT  ,'')<>'' AND @c_HoldMethod LIKE '%,LOT,%') AND
                  NOT (ISNULL(@c_loc  ,'')<>'' AND @c_HoldMethod LIKE '%,LOC,%') AND
                  NOT (ISNULL(@c_ID   ,'')<>'' AND @c_HoldMethod LIKE '%,ID,%' ) AND
                  NOT (ISNULL(@c_UCCNo,'')<>'' AND @c_HoldMethod LIKE '%,UCC,%')
                  SET @b_GenTLog2 = 0
            END

            IF @b_GenTLog2 = 1
            BEGIN
               SET @c_Key2 = @c_Status
               SET @c_TLogKey2PfxHold = ''
               SET @c_TLogKey2PfxHold = dbo.fnc_GetParamValueFromString('@c_TLogKey2PfxHold', @c_Option5, @c_TLogKey2PfxHold)   -- Y/N

               IF ISNULL(@c_TLogKey2PfxHold,'')='Y'
               BEGIN
                  SET @c_Key2 = CASE WHEN @c_hold='1' THEN 'H_' ELSE 'U_' END + @c_Key2
               END
            --ML03-E

               EXECUTE nspg_getkey
                  'TransmitlogKey2'
                  ,10
                  , @c_transmitlogkey OUTPUT
                  , @b_success OUTPUT
                  , @n_err OUTPUT
                  , @c_errmsg OUTPUT
               IF NOT @b_success=1
               BEGIN
                  SELECT @n_continue=3
                  SELECT @n_err = 62480
                  SELECT @c_errmsg = 'ntrInventoryHoldAdd: ' + dbo.fnc_RTrim(@c_errmsg)
               END

               IF ( @n_continue = 1 or @n_continue = 2 )
               BEGIN
                  INSERT TRANSMITLOG2 (Transmitlogkey, tablename, key1, key2, key3, transmitflag)
--ML03                  VALUES (@c_transmitlogkey, 'InventoryHold', @c_primarykey, @c_Status, @c_StorerKey, '0')
                  VALUES (@c_transmitlogkey, 'InventoryHold', @c_primarykey, @c_Key2, @c_StorerKey, '0')   --ML03
                  SELECT @n_err= @@Error
                  IF NOT @n_err=0
                  BEGIN
                     SELECT @n_continue=3
                     SELECT @n_err = 62481
                     SELECT @c_errmsg= 'NSQL'+CONVERT(char(5), @n_err)+':Insert Into TransmitLog2 Table (InventoryHold) Failed. (ntrInventoryHoldAdd)'+'('+'SQLSvr MESSAGE='+dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg))+')'
                  END
               END
            END  --ML03
         END
      END
      --SSA01-E
   End
   /* IDSV5 - Leo */

   /* #INCLUDE <TRADA2.SQL> */
   IF @n_continue = 3  -- Error Occured - Process And Return
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
         EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrInventoryHoldAdd'
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