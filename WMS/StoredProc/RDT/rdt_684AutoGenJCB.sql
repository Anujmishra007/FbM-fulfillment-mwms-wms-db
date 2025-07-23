
/****** Object:  StoredProcedure [RDT].[rdt_684AutoGenJCB]    Script Date: 7/11/2025 10:40:25 PM ******/
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
/*********************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_684AutoGenJCB] (
   @nMobile     INT,           
   @nFunc       INT,           
   @nStep       INT,           
   @cLangCode   NVARCHAR( 3),  
   @tExtData    VariableTable READONLY,
   @cAutoID     NVARCHAR( 18) OUTPUT, 
   @nErrNo      INT           OUTPUT,  
   @cErrMsg     NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @cReceiptKey AS NVARCHAR(50),
      @cPOKey      AS NVARCHAR(50),
      @cLoc        AS NVARCHAR(50),
      @dAddDate    AS DATETIME,
      @cAddUser    AS NVARCHAR(20),
      @cUDF01      AS NVARCHAR(50),
      @cUDF02      AS NVARCHAR(50),
      @cUDF03      AS NVARCHAR(50),
      @cUDF04      AS NVARCHAR(50),
      @cUDF05      AS NVARCHAR(50),
      @cUDF06      AS NVARCHAR(50),
      @cUDF07      AS NVARCHAR(50),
      @cUDF08      AS NVARCHAR(50),
      @cUDF09      AS NVARCHAR(50),
      @cUDF10      AS NVARCHAR(50),
      @cUDF11      AS NVARCHAR(50),
      @cUDF12      AS NVARCHAR(50),
      @nInputKey   AS INT,
	  @cMAXLPN     AS NVARCHAR(50),
	  @cStorerKey  AS NVARCHAR(20),
	  @nCounter    AS INT = 1,
	  @dNow        AS DATETIME = GETDATE()

   SELECT TOP 1 
      @nInputKey = InputKey, 
	  @cStorerKey = StorerKey 
   FROM RDT.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile

   SELECT TOP 1
      @cReceiptKey = V_ReceiptKey,
      @cPOKey = V_POKey,
      @cLoc = V_Loc,
      @dAddDate = GETDATE(),
      @cAddUser = UserName,
      @cUDF01 = '',
      @cUDF02 = '',
      @cUDF03 = '',
      @cUDF04 = '',
      @cUDF05 = '',
      @cUDF06 = '',
      @cUDF07 = '',
      @cUDF08 = '',
      @cUDF09 = '',
      @cUDF10 = '',
      @cUDF11 = '',
      @cUDF12 = ''
   FROM RDT.RDTMOBREC WITH(NOLOCK)
   WHERE Mobile = @nMobile 

   /*SELECT TOP 1 @cMAXLPN = MAX(ID) FROM
   (SELECT ID FROM LOTxLOCxID WITH(NOLOCK)
   WHERE StorerKey = 'JCB'
   AND ID LIKE 'L_________'

   UNION ALL

   SELECT ToId FROM RECEIPTDETAIL WITH(NOLOCK)
   WHERE StorerKey = 'JCB'
   AND ToId LIKE 'L_________')T1*/

   IF EXISTS (
      SELECT 1 
	  FROM dbo.ReceiptJCBLPNCounter WITH(NOLOCK) 
	  WHERE AddUser = @cAddUser 
	     AND ISNULL(STATUS,'') IN ('NOT RECEIVED','') 
		 AND LPN LIKE 'L_________'
   )
   BEGIN
      SELECT TOP 1 @cAutoID = (
	     SELECT MAX(LPN) 
		 FROM dbo.ReceiptJCBLPNCounter WITH(NOLOCK) 
	     WHERE AddUser = @cAddUser 
		    AND ISNULL(STATUS,'') IN ('NOT RECEIVED','') 
			AND LPN LIKE 'L_________'
	  )
      GOTO HOUSEKEEPING
   END

   IF @nStep = 2 
      OR NOT EXISTS (
	     SELECT 1 
		 FROM dbo.ReceiptJCBLPNCounter WITH(NOLOCK) 
         WHERE AddUser = @cAddUser 
		    AND ISNULL(STATUS,'') IN ('NOT RECEIVED','') 
			AND LPN LIKE 'L_________'
   )
   BEGIN
      BEGIN
         SELECT TOP 1 
		    @cAutoID = CASE WHEN MAX(LPN) IS NULL 
			   OR MAX(LPN) = 'L999999999' 
			THEN 'L000000001' 
			ELSE 'L'+RIGHT('000000000'+convert(NVARCHAR(10),right(MAX(LPN),9)+1),9) 
			END 
		 FROM ReceiptJCBLPNCounter WITH(NOLOCK) 
		 WHERE LPN LIKE 'L_________'

		 TryAgain:
		 IF (
		    EXISTS (
		       SELECT 1 
			   FROM dbo.LOTXLOCXID WITH(NOLOCK) 
		       WHERE ID = @cAutoID 
			      AND StorerKey = @cStorerKey 
			      AND (Qty > 0 OR PendingMoveIN > 0 
			      OR QtyReplen > 0)
		       ) --'L'+RIGHT('000000000'+convert(NVARCHAR(10),right(@cMAXLPN,9)+1),9) > @cAutoID
		    OR EXISTS (
			   SELECT 1 
			   FROM dbo.RECEIPTDETAIL RD WITH(NOLOCK) 
			      INNER JOIN dbo.RECEIPT R WITH(NOLOCK) 
			   ON R.ReceiptKey = RD.ReceiptKey 
			   WHERE ToId = @cAutoID 
		          AND R.StorerKey = @cStorerKey 
				  AND R.Status < '9')
		       )
		    AND @nCounter <= 100000 
		    AND DATEDIFF(SECOND, @dNow, GETDATE()) <= 20
		 BEGIN
		    SET @cAutoID = 'L'+RIGHT('000000000'+convert(NVARCHAR(10),RIGHT(@cAutoID,9)+1),9)
			SET @nCounter = @nCounter+1
			GOTO TryAgain
		 END

         INSERT INTO ReceiptJCBLPNCounter (
		    PO, ASN, LOC, LPN, AddDate, AddUser, UDF01, UDF02, UDF03, UDF04, UDF05, UDF06, UDF07, UDF08, UDF09, UDF10, UDF11, UDF12, STATUS
		 )
         VALUES (
            @cPOKey, @cReceiptKey, ''/*@cLoc*/, @cAutoID, @dAddDate, @cAddUser, @cUDF01, @cUDF02, @cUDF03, @cUDF04, @cUDF05, @cUDF06, @cUDF07, @cUDF08, @cUDF09, @cUDF10, @cUDF11, @cUDF12, 'NOT RECEIVED'
         );
         GOTO HOUSEKEEPING
      END

      --Keeping no more than 1000 records in the table
      HOUSEKEEPING:
      IF (
	     SELECT COUNT(1) 
	     FROM ReceiptJCBLPNCounter WITH(NOLOCK)
	  ) >= 2000
      BEGIN
         DELETE FROM ReceiptJCBLPNCounter
         WHERE LPN IN (
            SELECT TOP 1000 LPN
            FROM ReceiptJCBLPNCounter
            ORDER BY AddDate ASC
         );
      END

	  IF @cAutoID = 'L000000001' --Resetting whole table
	  BEGIN
         DELETE FROM ReceiptJCBLPNCounter
	  END
   END
END
GO
GRANT EXECUTE ON [RDT].[rdt_684AutoGenJCB] TO [NSQL]
GO
