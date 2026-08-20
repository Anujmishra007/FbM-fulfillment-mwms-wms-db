SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
/************************************************************************/
/* Stored Procedure: isp_POTOASN01                                      */
/* Creation Date: 13-Jul-2026                                           */
/* Copyright: MAERSk                                                     */
/* Written by: JihHaur                                                   */
/*                                                                       */
/* Purpose: FCR-14046 [BEL] Schneider Electric - ASN Creation from API PO*/
/*          message Called at the end of PO processing (IML) to create / */
/*          extend / cancel the ASN (RECEIPT / RECEIPTDETAIL) derived    */
/*          from a PO.                                                   */
/*                                                                       */
/* Called By: IML (end of PO API message processing)                     */
/*                                                                       */
/* Version: 3.3                                                          */
/*                                                                       */
/* Updates:                                                              */
/* Date        Author  Ver.  Purposes                                    */
/* 13-Jul-2026 JH01    1.0   Initial creation (BEL Schneider PO->ASN)    */
/* 20-Aug-2026 JH02    1.2   FCR v1.3: ReceiptDetail.Lottable02 derived  */
/*                           from SKU + MarksContainer (MONO / MIX). The  */
/*                           earlier Lottable02-value rule (MIX / OHU /   */
/*                           DHU) is removed.                            */
/*************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_POTOASN01]
      @c_StorerKey    NVARCHAR(15)
   ,  @c_POKey        NVARCHAR(18)
   ,  @b_Success      INT            OUTPUT
   ,  @n_err          INT            OUTPUT
   ,  @c_errmsg       NVARCHAR(250)  OUTPUT
AS

SET NOCOUNT ON
SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF
SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE  @n_StartTCnt          INT            /* Holds the current transaction count */
      ,  @n_Continue           INT            /* 1=Continue, 3=failed do not continue */
      ,  @n_Cnt                INT
      ,  @n_MaxLine            INT
      ,  @n_LockRes            INT

      ,  @c_ExternStatus       NVARCHAR(10)
      ,  @c_UserDefine04       NVARCHAR(30)
      ,  @c_UserDefine10       NVARCHAR(30)
      ,  @c_ExternPOKey        NVARCHAR(20)   /* link key (SBK) -> Lottable07 */

      ,  @c_Key04              NVARCHAR(50)
      ,  @c_Key10              NVARCHAR(50)
      ,  @c_ChosenKey          NVARCHAR(50)
      ,  @c_ExternReceiptKey   NVARCHAR(50)
      ,  @c_ReceiptKey         NVARCHAR(10)

      ,  @c_ContainerKeyH      NVARCHAR(18)   /* PO2ASNMAP 0001 */
      ,  @c_FacilityH          NVARCHAR(15)   /* PO2ASNMAP 0002 */
      ,  @c_ContainerKeyD      NVARCHAR(18)   /* PO2ASNMAP 0003 */
      ,  @c_ToLocD             NVARCHAR(10)   /* PO2ASNMAP 0004 */
      ,  @c_ConditionCodeD     NVARCHAR(10)   /* PO2ASNMAP 0005 */
      ,  @c_UserDefine01D      NVARCHAR(30)   /* PO2ASNMAP 0006 */
      ,  @c_MissingCfg         NVARCHAR(200)

      ,  @c_DocType            NVARCHAR(1)
      ,  @c_LockName           NVARCHAR(255)
      ,  @c_LockKey1           NVARCHAR(50)   
      ,  @c_LockKey2           NVARCHAR(50)   

SELECT  @n_StartTCnt  = @@TRANCOUNT
     ,  @n_Continue   = 1
     ,  @b_Success    = 0
     ,  @n_err        = 0
     ,  @c_errmsg     = ''
     ,  @c_ReceiptKey = ''
     ,  @c_DocType    = 'A'                        

/*----------------------------------------------------------------------*/
/* 1. Load PO header                                                     */
/*----------------------------------------------------------------------*/
SELECT  @c_ExternStatus  = LTRIM(RTRIM(ISNULL(ExternStatus,'')))
     ,  @c_UserDefine04  = LTRIM(RTRIM(ISNULL(UserDefine04,'')))
     ,  @c_UserDefine10  = LTRIM(RTRIM(ISNULL(UserDefine10,'')))
     ,  @c_ExternPOKey   = LTRIM(RTRIM(ISNULL(ExternPOKey,'')))
FROM    PO WITH (NOLOCK)
WHERE   POKey     = @c_POKey
AND     StorerKey = @c_StorerKey

IF @@ROWCOUNT = 0
BEGIN
   SELECT @n_Continue = 3
        , @n_err      = 91540
        , @c_errmsg   = 'NSQL' + CONVERT(CHAR(5),91540) + ': PO not found. StorerKey [' + @c_StorerKey + '] POKey [' + @c_POKey + ']. (isp_POTOASN01)'
   GOTO QUIT
END

-- ExternStatus: '0' = add, 'X' = cancel
IF @c_ExternStatus NOT IN ('0','X')
BEGIN
   SELECT @n_Continue = 3
        , @n_err      = 91544
        , @c_errmsg   = 'NSQL' + CONVERT(CHAR(5),91544) + ': Unexpected PO.ExternStatus [' + @c_ExternStatus + '] - expected 0 (add) or X (cancel). POKey [' + @c_POKey + ']. (isp_POTOASN01)'
   GOTO QUIT
END

IF @c_ExternPOKey = ''
BEGIN
   SELECT @n_Continue = 3
        , @n_err      = 91546
        , @c_errmsg   = 'NSQL' + CONVERT(CHAR(5),91546) + ': PO.ExternPOKey is blank. POKey [' + @c_POKey + ']. (isp_POTOASN01)'
   GOTO QUIT
END

/*----------------------------------------------------------------------*/
/* 2. Configuration (CODELKUP 'PO2ASNMAP', scoped by StorerKey) and PO   */
/*    lines - both are only required on the ADD path.                    */
/*----------------------------------------------------------------------*/
IF @c_ExternStatus = '0'
BEGIN
   SELECT @c_ContainerKeyH = LTRIM(RTRIM(ISNULL(Long,'')))
   FROM   CODELKUP WITH (NOLOCK)
   WHERE  ListName  = 'PO2ASNMAP'
   AND    Code      = '0001'
   AND    Storerkey = @c_StorerKey

   SELECT @c_FacilityH = LTRIM(RTRIM(ISNULL(Long,'')))
   FROM   CODELKUP WITH (NOLOCK)
   WHERE  ListName  = 'PO2ASNMAP'
   AND    Code      = '0002'
   AND    Storerkey = @c_StorerKey

   SELECT @c_ContainerKeyD = LTRIM(RTRIM(ISNULL(Long,'')))
   FROM   CODELKUP WITH (NOLOCK)
   WHERE  ListName  = 'PO2ASNMAP'
   AND    Code      = '0003'
   AND    Storerkey = @c_StorerKey

   SELECT @c_ToLocD = LTRIM(RTRIM(ISNULL(Long,'')))
   FROM   CODELKUP WITH (NOLOCK)
   WHERE  ListName  = 'PO2ASNMAP'
   AND    Code      = '0004'
   AND    Storerkey = @c_StorerKey

   SELECT @c_ConditionCodeD = LTRIM(RTRIM(ISNULL(Long,'')))
   FROM   CODELKUP WITH (NOLOCK)
   WHERE  ListName  = 'PO2ASNMAP'
   AND    Code      = '0005'
   AND    Storerkey = @c_StorerKey

   SELECT @c_UserDefine01D = LTRIM(RTRIM(ISNULL(Long,'')))
   FROM   CODELKUP WITH (NOLOCK)
   WHERE  ListName  = 'PO2ASNMAP'
   AND    Code      = '0006'
   AND    Storerkey = @c_StorerKey

   SELECT  @c_ContainerKeyH  = ISNULL(@c_ContainerKeyH,'')
        ,  @c_FacilityH      = ISNULL(@c_FacilityH,'')
        ,  @c_ContainerKeyD  = ISNULL(@c_ContainerKeyD,'')
        ,  @c_ToLocD         = ISNULL(@c_ToLocD,'')
        ,  @c_ConditionCodeD = ISNULL(@c_ConditionCodeD,'')
        ,  @c_UserDefine01D = ISNULL(@c_UserDefine01D,'')

   SET @c_MissingCfg = ''
   IF @c_ContainerKeyH  = '' SET @c_MissingCfg = @c_MissingCfg + '0001,'
   IF @c_FacilityH      = '' SET @c_MissingCfg = @c_MissingCfg + '0002,'
   IF @c_ContainerKeyD  = '' SET @c_MissingCfg = @c_MissingCfg + '0003,'
   IF @c_ToLocD         = '' SET @c_MissingCfg = @c_MissingCfg + '0004,'
   IF @c_ConditionCodeD = '' SET @c_MissingCfg = @c_MissingCfg + '0005,'
   IF @c_UserDefine01D = '' SET @c_MissingCfg = @c_MissingCfg + '0006,'

   IF @c_MissingCfg <> ''
   BEGIN
      SELECT @n_Continue = 3
           , @n_err      = 91541
           , @c_errmsg   = 'NSQL' + CONVERT(CHAR(5),91541) + ': Missing CODELKUP PO2ASNMAP code(s) [' + LEFT(@c_MissingCfg, LEN(@c_MissingCfg) - 1) + '] for StorerKey [' + @c_StorerKey + ']. (isp_POTOASN01)'
      GOTO QUIT
   END

   SELECT @n_Cnt = COUNT(*)
   FROM   PODETAIL WITH (NOLOCK)
   WHERE  POKey = @c_POKey

   IF @n_Cnt = 0
   BEGIN
      SELECT @n_Continue = 3
           , @n_err      = 91545
           , @c_errmsg   = 'NSQL' + CONVERT(CHAR(5),91545) + ': No PODETAIL lines for POKey [' + @c_POKey + ']. (isp_POTOASN01)'
      GOTO QUIT
   END
END

/*----------------------------------------------------------------------*/
/* 3. Build normalized shipment key candidates                           */
/*    min 10 chars (left-pad '0'); if > 13 chars keep first 13           */
/*----------------------------------------------------------------------*/
SET @c_Key04 = ''
IF @c_UserDefine04 <> ''
BEGIN
   IF LEN(@c_UserDefine04) < 10 SET @c_Key04 = REPLICATE('0', 10 - LEN(@c_UserDefine04)) + @c_UserDefine04
   ELSE                         SET @c_Key04 = @c_UserDefine04
   IF LEN(@c_Key04) > 13 SET @c_Key04 = LEFT(@c_Key04, 13)
END

SET @c_Key10 = ''
IF @c_UserDefine10 <> ''
BEGIN
   IF LEN(@c_UserDefine10) < 10 SET @c_Key10 = REPLICATE('0', 10 - LEN(@c_UserDefine10)) + @c_UserDefine10
   ELSE                         SET @c_Key10 = @c_UserDefine10
   IF LEN(@c_Key10) > 13 SET @c_Key10 = LEFT(@c_Key10, 13)
END

IF @c_UserDefine04 <> '' SET @c_ChosenKey = @c_Key04
ELSE                     SET @c_ChosenKey = @c_Key10

IF @c_ChosenKey = ''
BEGIN
   SELECT @n_Continue = 3
        , @n_err      = 91542
        , @c_errmsg   = 'NSQL' + CONVERT(CHAR(5),91542) + ': PO.UserDefine04 and PO.UserDefine10 are both empty - no shipment key. POKey [' + @c_POKey + ']. (isp_POTOASN01)'
   GOTO QUIT
END

SET @c_ExternReceiptKey = @c_ChosenKey

/*----------------------------------------------------------------------*/
/* 4. Serialize per shipment (avoids duplicate ASN on concurrent msgs)   */
/*----------------------------------------------------------------------*/
BEGIN TRANSACTION

-- lock EVERY shipment key this PO could match on (Key04 and Key10),
-- not just the chosen one - section 5 searches both. Acquired in ascending
-- order so concurrent sessions queue instead of deadlocking. When only one
-- key is populated, MIN = MAX and a single lock is taken.
SELECT @c_LockKey1 = MIN(k)
     , @c_LockKey2 = MAX(k)
FROM ( VALUES (@c_Key04), (@c_Key10) ) AS v(k)
WHERE k <> ''

SET @c_LockName = 'isp_POTOASN01:' + LTRIM(RTRIM(@c_StorerKey)) + ':' + @c_LockKey1
EXEC @n_LockRes = sp_getapplock @Resource     = @c_LockName
                              , @LockMode     = 'Exclusive'
                              , @LockOwner    = 'Transaction'
                              , @LockTimeout  = 15000
IF @n_LockRes < 0
BEGIN
   SELECT @n_Continue = 3
        , @n_err      = 91543
        , @c_errmsg   = 'NSQL' + CONVERT(CHAR(5),91543) + ': Could not acquire lock for shipment [' + @c_LockKey1 + '] (rc=' + CONVERT(NVARCHAR(10),@n_LockRes) + '). (isp_POTOASN01)'
   GOTO QUIT
END

IF @c_LockKey2 <> @c_LockKey1
BEGIN
   SET @c_LockName = 'isp_POTOASN01:' + LTRIM(RTRIM(@c_StorerKey)) + ':' + @c_LockKey2
   EXEC @n_LockRes = sp_getapplock @Resource     = @c_LockName
                                 , @LockMode     = 'Exclusive'
                                 , @LockOwner    = 'Transaction'
                                 , @LockTimeout  = 15000
   IF @n_LockRes < 0
   BEGIN
      SELECT @n_Continue = 3
           , @n_err      = 91543
           , @c_errmsg   = 'NSQL' + CONVERT(CHAR(5),91543) + ': Could not acquire lock for shipment [' + @c_LockKey2 + '] (rc=' + CONVERT(NVARCHAR(10),@n_LockRes) + '). (isp_POTOASN01)'
      GOTO QUIT
   END
END

/*----------------------------------------------------------------------*/
/* 5. Find the open ASN (RECEIPT.Status = '0') - UD04 first, then UD10   */
/*----------------------------------------------------------------------*/
IF @c_Key04 <> ''
   SELECT TOP 1 @c_ReceiptKey = ReceiptKey, @c_ExternReceiptKey = ExternReceiptKey
   FROM   RECEIPT WITH (READCOMMITTED)          -- applock serializes;
   WHERE  ExternReceiptKey = @c_Key04
   AND    StorerKey        = @c_StorerKey
   AND    Status           = '0'
   ORDER BY ReceiptKey

IF @c_ReceiptKey = '' AND @c_Key10 <> ''
   SELECT TOP 1 @c_ReceiptKey = ReceiptKey, @c_ExternReceiptKey = ExternReceiptKey
   FROM   RECEIPT WITH (READCOMMITTED)          -- applock serializes; 
   WHERE  ExternReceiptKey = @c_Key10
   AND    StorerKey        = @c_StorerKey
   AND    Status           = '0'
   ORDER BY ReceiptKey

/*---------------------------------------------------------------------*/
/* 6a. CANCEL  (PO.ExternStatus = 'X')                                   */
/*     just update RECEIPTDETAIL.Status = 'X', QtyExpected = 0          */
/*---------------------------------------------------------------------*/
IF @c_ExternStatus = 'X'
BEGIN
   -- No open ASN -> nothing to cancel.
   IF @c_ReceiptKey = ''
   BEGIN
      GOTO QUIT
   END

   -- ignored ASN which already received. 
   IF EXISTS ( SELECT 1
               FROM   RECEIPTDETAIL WITH (NOLOCK)
               WHERE  ReceiptKey  = @c_ReceiptKey
               AND    Lottable07  = @c_ExternPOKey
               AND    QtyReceived <> 0 )
   BEGIN
      SELECT @n_Continue = 3
           , @n_err      = 91547
           , @c_errmsg   = 'NSQL' + CONVERT(CHAR(5),91547) + ': CANCEL rejected - ASN line already received. ReceiptKey [' + @c_ReceiptKey + '] POKey [' + @c_POKey + ']. (isp_POTOASN01)'
      GOTO QUIT
   END

   UPDATE RECEIPTDETAIL
   SET    Status      = 'CANC'
        , QtyExpected = 0
   WHERE  ReceiptKey  = @c_ReceiptKey
   AND    Lottable07  = @c_ExternPOKey
   AND    QtyReceived = 0
   AND    Status     <> 'CANC'                       

   SELECT @n_err = @@ERROR
   IF @n_err <> 0
   BEGIN
      SELECT @n_Continue = 3
           , @c_errmsg   = 'NSQL' + CONVERT(CHAR(5),91548) + ': UPDATE (cancel) RECEIPTDETAIL failed. ReceiptKey [' + @c_ReceiptKey + '] POKey [' + @c_POKey + ']. (isp_POTOASN01) (SQLErr=' + CONVERT(NVARCHAR(20),@n_err) + ')'
           , @n_err      = 91548
      GOTO QUIT
   END
   
   GOTO QUIT
END

/*======================================================================*/
/* 6b. ADD  (PO.ExternStatus = '0')                                      */
/*======================================================================*/
IF @c_ReceiptKey = ''
BEGIN
   -- No open ASN: create the header, this PO becomes the first line
   SET @c_ExternReceiptKey = @c_ChosenKey
   
   EXEC dbo.nspg_GetKey @KeyName     = N'RECEIPT'
                            , @fieldlength = 10
                            , @keystring   = @c_Receiptkey OUTPUT
                            , @b_Success   = @b_Success    OUTPUT
                            , @n_err       = @n_err        OUTPUT
                            , @c_errmsg    = @c_errmsg      OUTPUT

   IF @b_Success = 0 OR @n_err <> 0 OR LTRIM(RTRIM(ISNULL(@c_ReceiptKey,''))) = ''
   BEGIN
      SELECT @n_Continue = 3
           , @c_errmsg   = 'NSQL' + CONVERT(CHAR(5),91549) + ': Generate ReceiptKey failed. (isp_POTOASN01) (' + LTRIM(RTRIM(ISNULL(@c_errmsg,''))) + ')'
           , @n_err      = 91549
      GOTO QUIT
   END

   INSERT INTO RECEIPT
      (  ReceiptKey
      ,  StorerKey
      ,  POKey
      ,  ExternReceiptKey
      ,  ContainerKey
      ,  Facility
      ,  Signatory
      ,  UserDefine03
      ,  Status
      ,  DocType
      )
   VALUES
      (  @c_ReceiptKey
      ,  @c_StorerKey
      ,  @c_POKey
      ,  @c_ExternReceiptKey
      ,  @c_ContainerKeyH
      ,  @c_FacilityH
      ,  @c_UserDefine10                -- Signatory    = PO.UserDefine10
      ,  @c_UserDefine04                -- UserDefine03 = PO.UserDefine04
      ,  '0'
      ,  @c_DocType
      )

   SELECT @n_err = @@ERROR
   IF @n_err <> 0
   BEGIN
      SELECT @n_Continue = 3
           , @c_errmsg   = 'NSQL' + CONVERT(CHAR(5),91550) + ': INSERT RECEIPT header failed. ReceiptKey [' + @c_ReceiptKey + ']. (isp_POTOASN01) (SQLErr=' + CONVERT(NVARCHAR(20),@n_err) + ')'
           , @n_err      = 91550
      GOTO QUIT
   END
END

-- Current max detail line number on this ASN
SELECT @n_MaxLine = ISNULL(MAX(CONVERT(INT, ReceiptLineNumber)), 0)
FROM   RECEIPTDETAIL WITH (UPDLOCK, HOLDLOCK)
WHERE  ReceiptKey = @c_ReceiptKey

-- Always add a new ASN line per PO line.  
INSERT INTO RECEIPTDETAIL
   (  ReceiptKey
   ,  ReceiptLineNumber
   ,  ExternReceiptKey
   ,  ExternLineNo
   ,  StorerKey
   ,  POKey
   ,  POLineNumber
   ,  ExternPoKey
   ,  Sku
   ,  Status
   ,  QtyExpected
   ,  UOM
   ,  PackKey
   ,  ContainerKey
   ,  ToLoc
   ,  ToId
   ,  ConditionCode
   ,  PalletType
   ,  Lottable01
   ,  Lottable02
   ,  Lottable03
   ,  Lottable06
   ,  Lottable07
   ,  Lottable08
   ,  Lottable09
   ,  Lottable10
   ,  Lottable11
   ,  Lottable12
   ,  UserDefine01
   ,  UserDefine02
   ,  UserDefine04
   ,  UserDefine05
   ,  UserDefine08
   ,  UserDefine09
   ,  UserDefine10
   ,  GrossWgt
   ,  Cube
   ,  Notes
   )
SELECT
      @c_ReceiptKey
   ,  RIGHT('00000' + CONVERT(NVARCHAR(5), @n_MaxLine + ROW_NUMBER() OVER (ORDER BY PD.POLineNumber)), 5)
   ,  @c_ExternReceiptKey                                                                 -- Shipment Number
   ,  ISNULL(PD.ExternLineNo,' ')
   ,  @c_StorerKey
   ,  PD.POKey                                                                            
   ,  ISNULL(PD.POLineNumber,' ')                                                         
   ,  @c_ExternPOKey
   ,  ISNULL(PD.Sku,' ')
   ,  '0'
   ,  QtyOrdered                                                                          
   ,  ISNULL(NULLIF(PD.UOM,''),' ')
   ,  ISNULL(NULLIF(PD.PackKey,''),'STD')
   ,  @c_ContainerKeyD
   ,  @c_ToLocD
   ,  ISNULL(PD.ToId,' ')                                                            
   ,  @c_ConditionCodeD
   ,  ISNULL(PD.MarksContainer,'')                                                        -- PalletType
   ,  ISNULL(PD.Lottable01,' ')                                                           -- SHIPTO 
   ,  CASE WHEN UPPER(LTRIM(RTRIM(ISNULL(PD.Sku,'')))) = 'SEMIX'  AND UPPER(LTRIM(ISNULL(PD.MarksContainer,''))) LIKE 'P%' THEN 'MONO'   -- JH02
           WHEN UPPER(LTRIM(RTRIM(ISNULL(PD.Sku,'')))) = 'SEMIX'                                                          THEN 'MIX'
           WHEN UPPER(LTRIM(RTRIM(ISNULL(PD.Sku,'')))) = 'SEFULL' AND UPPER(LTRIM(ISNULL(PD.MarksContainer,''))) LIKE 'S%' THEN 'MIX'
           WHEN UPPER(LTRIM(RTRIM(ISNULL(PD.Sku,'')))) = 'SEFULL'                                                         THEN 'MONO'
           WHEN UPPER(LTRIM(RTRIM(ISNULL(PD.Sku,'')))) = 'SEDANG'                                                         THEN 'MONO'
           ELSE '' END                                                                    -- Lottable02: MIX / MONO (FCR v1.3)
   ,  ISNULL(PD.Lottable03,' ')                                                           -- Overpack LPN or Cartion SSCC depend of Mix/ Mono Flag
   ,  ISNULL(PD.Lottable06,' ')                                                           -- SBK
   ,  @c_ExternPOKey                                                                      -- SBK
   ,  ISNULL(PD.UserDefine03,' ')                                                         -- IBDLV number
   ,  ISNULL(PD.Lottable09,' ')                                                           -- Overpack LPN
   ,  ISNULL(PD.Lottable10,' ')                                                           -- Carton LPN
   ,  ISNULL(PD.Lottable11,' ')                                                           -- Pilot Code
   ,  ISNULL(PD.Lottable12,' ')                                                           -- DG Item No
   ,  @c_UserDefine01D                                                                    -- FRSCHNEIDERCFS (hardcoded)
   ,  ISNULL(PD.UserDefine02,' ')                                                         -- ReceiptLineNumber / Ext Line Number
   ,  ISNULL(PD.UserDefine04,' ')                                                         -- Ship from
   ,  ISNULL(PD.UserDefine05,' ')                                                         -- SHIPTO-SiteID 
   ,  ISNULL(PD.UserDefine08,' ')                                                         -- Pallet Height
   ,  ISNULL(PD.UserDefine09,' ')                                                         -- Pallet Width
   ,  ISNULL(PD.UserDefine10,' ')                                                         -- Pallet Length
   ,  ISNULL(TRY_CONVERT(FLOAT, NULLIF(LTRIM(RTRIM(PD.Lottable07)),'')), 0)               -- Pallet Weight 
   ,  ISNULL(TRY_CONVERT(FLOAT, NULLIF(LTRIM(RTRIM(PD.Lottable08)),'')), 0)               -- Pallet Volume
   ,  ISNULL(PD.Notes,'')                                                                 -- CustomerExternLinekey
FROM   PODETAIL PD WITH (NOLOCK)
WHERE  PD.POKey = @c_POKey

SELECT @n_err = @@ERROR
IF @n_err <> 0
BEGIN
   SELECT @n_Continue = 3
        , @c_errmsg   = 'NSQL' + CONVERT(CHAR(5),91551) + ': INSERT RECEIPTDETAIL failed. ReceiptKey [' + @c_ReceiptKey + '] POKey [' + @c_POKey + ']. (isp_POTOASN01) (SQLErr=' + CONVERT(NVARCHAR(20),@n_err) + ')'
        , @n_err      = 91551
   GOTO QUIT
END

QUIT:
IF @n_Continue = 3   -- Error Occured - Process And Return
BEGIN
   SELECT @b_Success = 0
   IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
   BEGIN
      ROLLBACK TRAN
   END
   ELSE
   BEGIN
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
   EXECUTE nsp_logerror @n_err, @c_errmsg, 'isp_POTOASN01'
   RAISERROR (@c_errmsg, 16, 1) WITH SETERROR
   RETURN
END
ELSE
BEGIN
   SELECT @b_Success = 1
   WHILE @@TRANCOUNT > @n_StartTCnt
   BEGIN
      COMMIT TRAN
   END
   RETURN
END
GO
GRANT EXECUTE ON [dbo].[isp_POTOASN01] TO [NSQL]
GO
