SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1766ExtUpd05                                    */
/* Purpose: Release inventory by LOC/LOT/ID once CC is done             */
/* Customer: Chile PUMA                                                 */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date       Rev    Author    Purposes                                 */
/* 2025-07-15 1..00  NickT     FCR-4885. Created                        */
/************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_1766ExtUpd05] (
   @nMobile     INT,
   @nFunc       INT, 
   @cLangCode   NVARCHAR( 3), 
   @nStep       INT, 
   @nInputKey   INT, 
   @cFacility       NVARCHAR( 15), 
   @cStorerKey      NVARCHAR( 15), 
   @cTaskdetailkey  NVARCHAR( 20), 
   @cFromLoc        NVARCHAR( 20), 
   @cID             NVARCHAR( 20), 
   @cPickMethod     NVARCHAR( 20), 
   @nErrNo          INT           OUTPUT, 
   @cErrMsg         NVARCHAR( 20) OUTPUT  
)
AS
BEGIN

   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF 

   DECLARE
      @cUserName        NVARCHAR(18),
      @cOptions         NVARCHAR(60),
      @cHoldType        NVARCHAR(60),
      @cLoc             NVARCHAR(10),
      @cLot             NVARCHAR(10),
      @nRowCount        INT,
      @bSuccess         INT

   SELECT 
      @cUserName = UserName,
      @cOptions = I_Field02
   FROM rdt.RDTMOBREC (NOLOCK) WHERE Mobile = @nMobile

   IF @nFunc = 1766 -- Handle CC & CCSUP
   BEGIN
      IF @nStep IN (4, 7)
      BEGIN
         IF @nInputKey = 1
         BEGIN
            IF (@nStep = 4 AND ISNULL(@cOptions, '') = '1') OR @nStep = 7
            BEGIN
               SELECT @cLoc = FromLoc,
                  @cHoldType = Message01,
                  @cLot = Lot,
                  @cID = FromID,
                  @cLoc = FromLoc
               FROM dbo.TaskDetail WITH (NOLOCK)
               WHERE TaskDetailKey = @cTaskdetailkey
                  AND Status = '9'
                  AND SourceType = 'rdt_ActionByReason'
                  AND Holdkey = 'UNHOLD'

               SELECT @nRowCount = @@RowCount

               IF ISNULL(@nRowCount, 0) = 1
               BEGIN
                  IF ISNULL(@cHoldType,'') IN ('LOC','LOT','ID')
                  BEGIN
                     IF @cHoldType = 'LOC'
                     BEGIN
                        SET @cLot = ''
                        SET @cID = ''
                     END
                     ELSE IF @cHoldType = 'ID'
                     BEGIN
                        SET @cLoc = ''
                        SET @cLot = ''
                     END
                     ELSE IF @cHoldType = 'LOT'
                     BEGIN
                        SET @cLoc = ''
                        SET @cID = ''
                     END
                     
                     EXEC dbo.nspInventoryHoldWrapper
                        @c_lot = @cLot
                        ,@c_Loc = @cLoc
                        ,@c_ID  = @cID
                        ,@c_StorerKey    = @cStorerKey
                        ,@c_SKU          = ''
                        ,@c_Lottable01   = ''
                        ,@c_Lottable02   = ''
                        ,@c_Lottable03   = ''
                        ,@dt_Lottable04  = NULL
                        ,@dt_Lottable05  = NULL
                        ,@c_Lottable06   = ''
                        ,@c_Lottable07   = ''
                        ,@c_Lottable08   = ''
                        ,@c_Lottable09   = ''
                        ,@c_Lottable10   = ''
                        ,@c_Lottable11   = ''
                        ,@c_Lottable12   = ''
                        ,@dt_Lottable13  = NULL
                        ,@dt_Lottable14  = NULL
                        ,@dt_Lottable15  = NULL
                        ,@c_Status = 'CCUNHOLD'
                        ,@c_Hold = 0
                        ,@b_success = @bSuccess OUTPUT
                        ,@n_Err = @nErrNo OUTPUT
                        ,@c_Errmsg = @cErrMsg OUTPUT
                        ,@c_Remark  = ''
                  END
                  
                  IF @nErrNo <> 0
                  BEGIN
                     GOTO Quit 
                  END
               END
            END
         END
      END
   END --Func

   Quit:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXECUTE ON RDT.rdt_1766ExtUpd05 TO NSQL
GO