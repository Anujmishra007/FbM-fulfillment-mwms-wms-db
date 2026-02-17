SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*********************************************************************************/
/* Store procedure: rdt_684AutoGenJCB                                            */
/* Copyright      : Maersk                                                       */
/* Customer       : JCB                                                          */
/*                                                                               */
/*                                                                               */
/* Date         Rev   Author   Purposes                                          */
/* 11/03/2025   1.0   PPA374   Providing automatic LPN ID                        */
/* 19/09/2025   1.1   PPA374   Adding check against the UDF01 = @nMobile         */
/* 17/02/2026   2.0   PPA374   Updated to avoid any chance of a duplicated LPN.  */
/*********************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_684AutoGenJCB2] (
   @nMobile     INT,
   @nFunc       INT,
   @nStep       INT,
   @cLangCode   NVARCHAR(3),
   @tExtData    VariableTable READONLY,
   @cAutoID     NVARCHAR(18) OUTPUT,
   @nErrNo      INT OUTPUT,
   @cErrMsg     NVARCHAR(20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cReceiptKey NVARCHAR(50),
      @cPOKey      NVARCHAR(50),
      @cLoc        NVARCHAR(50),
      @dAddDate    DATETIME = GETDATE(),
      @cAddUser    NVARCHAR(20),
      @cStorerKey  NVARCHAR(20),
      @nInputKey   INT,
      @MaxLPN      NVARCHAR(18),
      @NextNumber  BIGINT,
      @nCounter    INT = 1,
      @dStart      DATETIME = GETDATE(),
      @MaxRetries  INT = 1000000,  -- retry limit
      @MaxSeconds  INT = 20;       -- timeout in seconds

   ------------------------------------------------------------------
   -- Get Mobile Context
   ------------------------------------------------------------------
   SELECT TOP 1 
      @nInputKey = InputKey,
      @cStorerKey = StorerKey,
      @cReceiptKey = V_ReceiptKey,
      @cPOKey = V_POKey,
      @cLoc = V_Loc,
      @cAddUser = UserName
   FROM RDT.RDTMOBREC WITH (NOLOCK)
   WHERE Mobile = @nMobile;

   ------------------------------------------------------------------
   -- Reuse existing NOT RECEIVED LPN
   ------------------------------------------------------------------
   IF EXISTS (
      SELECT 1
      FROM dbo.ReceiptJCBLPNCounter WITH (NOLOCK)
      WHERE AddUser = @cAddUser
        AND UDF01 = @nMobile
        AND ISNULL(Status,'') IN ('NOT RECEIVED','')
        AND LPN LIKE 'L_________'
   )
   BEGIN
      SELECT TOP 1 @cAutoID = MAX(LPN)
      FROM dbo.ReceiptJCBLPNCounter WITH (NOLOCK)
      WHERE AddUser = @cAddUser
        AND UDF01 = @nMobile
        AND ISNULL(Status,'') IN ('NOT RECEIVED','')
        AND LPN LIKE 'L_________';

      GOTO HOUSEKEEPING;
   END

   ------------------------------------------------------------------
   -- Concurrency-safe LPN generation with loop protection
   ------------------------------------------------------------------
   WHILE 1 = 1
   BEGIN
      BEGIN TRAN;

      -- Serialize allocation (cannot use NOLOCK here)
      SELECT @MaxLPN = MAX(LPN)
      FROM dbo.ReceiptJCBLPNCounter WITH (UPDLOCK, HOLDLOCK)
      WHERE LPN LIKE 'L_________';

      SET @NextNumber = ISNULL(CAST(RIGHT(@MaxLPN,9) AS BIGINT),0) + 1;
      IF @NextNumber > 999999999
         SET @NextNumber = 1;

      SET @cAutoID = 'L' + RIGHT('000000000' + CAST(@NextNumber AS VARCHAR(9)),9);

      ------------------------------------------------------------------
      -- Check if LPN is blocked
      ------------------------------------------------------------------
      IF EXISTS (
         SELECT 1
         FROM dbo.LOTXLOCXID WITH (NOLOCK)
         WHERE ID = @cAutoID
           AND StorerKey = @cStorerKey
           AND (Qty > 0 OR PendingMoveIN > 0 OR QtyReplen > 0)
      )
      OR EXISTS (
         SELECT 1
         FROM dbo.RECEIPTDETAIL RD WITH (NOLOCK)
         INNER JOIN dbo.RECEIPT R WITH (NOLOCK)
            ON R.ReceiptKey = RD.ReceiptKey
         WHERE RD.ToId = @cAutoID
           AND R.StorerKey = @cStorerKey
           AND R.Status < '9'
      )
      BEGIN
         -- Mark as skipped so it won't be reused
         INSERT INTO dbo.ReceiptJCBLPNCounter (
            PO, ASN, LOC, LPN, AddDate, AddUser,
            UDF01, STATUS
         )
         VALUES (
            @cPOKey,
            @cReceiptKey,
            '',
            @cAutoID,
            @dAddDate,
            @cAddUser,
            @nMobile,
            'SKIPPED'
         );

         COMMIT;

         -- Increment counter and check for timeout / max retries
         SET @nCounter = @nCounter + 1;
         IF @nCounter > @MaxRetries OR DATEDIFF(SECOND, @dStart, GETDATE()) > @MaxSeconds
         BEGIN
            SET @nErrNo = -4;
            SET @cErrMsg = 'No available LPN';
			SET @cAutoID = '';
            RETURN;
         END

         CONTINUE;
      END

      ------------------------------------------------------------------
      -- Safe insert as NOT RECEIVED
      ------------------------------------------------------------------
      INSERT INTO dbo.ReceiptJCBLPNCounter (
         PO, ASN, LOC, LPN, AddDate, AddUser,
         UDF01, STATUS
      )
      VALUES (
         @cPOKey,
         @cReceiptKey,
         '',
         @cAutoID,
         @dAddDate,
         @cAddUser,
         @nMobile,
         'NOT RECEIVED'
      );

      COMMIT;
      BREAK;
   END

   ------------------------------------------------------------------
   -- HOUSEKEEPING
   ------------------------------------------------------------------
   HOUSEKEEPING:

   IF (
      SELECT COUNT(1)
      FROM dbo.ReceiptJCBLPNCounter WITH (NOLOCK)
   ) >= 2000
   BEGIN
      DELETE FROM dbo.ReceiptJCBLPNCounter
      WHERE LPN IN (
         SELECT TOP 1000 LPN
         FROM dbo.ReceiptJCBLPNCounter WITH (NOLOCK)
         ORDER BY AddDate ASC
      );
   END

   IF @cAutoID = 'L000000001'
   BEGIN
      DELETE FROM dbo.ReceiptJCBLPNCounter;
   END
END
GO
GRANT EXECUTE ON [RDT].[rdt_684AutoGenJCB2] TO [NSQL]
GO
