
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1871ExtUpd01                                    */
/* Purpose:                                                             */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2025-05-20   Dennis    1.0   FCR-3954 Created                        */
/* 2025-07-24   PPA374    1.1   Adding middle loc hold for D type LPN   */
/* 2025-07-31   PPA374	  1.2   Adding third loc hold for D type LPN    */
/************************************************************************/
CREATE OR ALTER PROCEDURE [RDT].[rdt_1871ExtUpd01]
    @nMobile         INT 
   ,@nFunc           INT 
   ,@cLangCode       NVARCHAR( 3) 
   ,@nStep           INT
   ,@nScn            INT
   ,@cEquipmentProfileKey NVARCHAR( 10)
   ,@cNewEquipmentProfileKey NVARCHAR( 10)
   ,@cTaskdetailKey  NVARCHAR( 10)
   ,@nErrNo          INT           OUTPUT 
   ,@cErrMsg         NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   DECLARE @PAPath               NVARCHAR(10)
   DECLARE @ToLOC                NVARCHAR(20)
   DECLARE @FinalLOC             NVARCHAR(20)
   DECLARE @TMFromPutaway        NVARCHAR(10)
   DECLARE @cNewTaskDetailKey    NVARCHAR(10)
   DECLARE @nSuccess             INT
   DECLARE @cStorerkey           NVARCHAR(10)
   DECLARE @cFacility            NVARCHAR(5)
   DECLARE @cListKey             NVARCHAR(10)
   DECLARE @cSourceType          NVARCHAR( 30),
   @cAreaKey                     NVARCHAR(10),
   @cSuggToLoc          NVARCHAR(10),
   @cSuggFinalLoc       NVARCHAR(10),
   @cSuggID             NVARCHAR(18),
   @cPalType            NVARCHAR(15),
   @cLocCat             NVARCHAR(20),
   @cUserKey            NVARCHAR(30),
   @cMidLoc             NVARCHAR(10),
   @cLocRoom            NVARCHAR(20),
   @cTrdLoc             NVARCHAR(10),
   @cFstLoc             NVARCHAR(10)

   SELECT @cStorerkey = storerkey,
      @cFacility = Facility,
      @cAreaKey = V_String32,
      @cUserKey = UserName
   FROM RDT.RDTMobrec (NOLOCK)
   WHERE Mobile = @nMobile
   

   IF @nFunc = 1871
   BEGIN
      IF @nStep = 2
	  BEGIN
		 UPDATE RDT.RDTMOBREC
         SET C_DateTime1 = GETDATE()
         WHERE Mobile = @nMobile 
	  END
	  
	  IF @nStep = 4 -- To loc
      BEGIN
         -- Get task info
         SELECT 
            @cListKey      = ListKey, 
            @cSourceType   = 'rdt_TM_PutawayFrom_CreateTask',
            @cSuggToLoc = ToLoc,
            @cSuggFinalLoc = FinalLoc,
            @cSuggID = FromID,
            @cAreaKey = AD.AreaKey,
			@cLocCat = Message03
         FROM dbo.TaskDetail TD WITH (NOLOCK)
         LEFT JOIN dbo.LOC LOC WITH (NOLOCK)
            ON LOC.LOC = ToLoc
         LEFT JOIN dbo.AREADETAIL AD WITH (NOLOCK)
            ON AD.PutawayZone = LOC.PutawayZone
         WHERE TaskDetailKey = @cTaskdetailKey

		 UPDATE RDT.RDTMOBREC
         SET C_DateTime1 = GETDATE()
         WHERE Mobile = @nMobile 

         UPDATE dbo.TaskDetail WITH (ROWLOCK)
         SET AreaKey = @cAreaKey
         WHERE  StorerKey = @cStorerKey
            AND TaskDetailKey <> @cTaskDetailKey
            AND TaskType = 'PA1'
            AND Status = '0'
            AND FromID = @cSuggID
            AND FromLoc = @cSuggToLoc
            AND ToLoc = @cSuggFinalLoc
            AND SourceType = @cSourceType

		 SELECT TOP 1 @cPalType = ISNULL(PalletType,'U') 
		 FROM dbo.PALLET WITH(NOLOCK)
		 WHERE StorerKey = @cStorerkey
		    AND PalletKey = @cSuggID

		 SELECT TOP 1 @cLocRoom = LocationRoom
		 FROM dbo.LOC WITH(NOLOCK)
		 WHERE LOC = @cSuggToLoc
		    AND Facility = @cFacility
		 
		 SELECT TOP 1 @cMidLoc = LOC
		 FROM dbo.LOC WITH(NOLOCK)
		 WHERE LocationRoom = @cLocRoom
		    AND Facility = @cFacility
			AND RIGHT(SUBSTRING(LOC,1,7),1) = '2'

		 SELECT TOP 1 @cTrdLoc = LOC
		 FROM dbo.LOC WITH(NOLOCK)
		 WHERE LocationRoom = @cLocRoom
		    AND Facility = @cFacility
			AND RIGHT(SUBSTRING(LOC,1,7),1) = '3'

		 SELECT TOP 1 @cFstLoc = LOC
		 FROM dbo.LOC WITH(NOLOCK)
		 WHERE LocationRoom = @cLocRoom
		    AND Facility = @cFacility
			AND RIGHT(SUBSTRING(LOC,1,7),1) = '1'

	     DECLARE @b_Success INT;
         DECLARE @n_Err INT;
         DECLARE @c_ErrMsg NVARCHAR(250);

		 IF @cPalType LIKE ('D%') 
		    AND @cLocCat = 'WA' 
			AND @cSuggToLoc <> @cMidLoc
		 BEGIN
            EXEC [WM].[lsp_Inventoryhold_Wrapper]
               @c_StorerKey   = @cStorerkey
               ,@c_SKU         = N''
               ,@c_lot         = N''
               ,@c_Loc         = @cMidLoc
               ,@c_ID          = N''
               ,@c_lottable01  = N''
               ,@c_lottable02  = N''
               ,@c_lottable03  = N''
               ,@dt_lottable04 = ''
               ,@dt_lottable05 = ''
               ,@c_lottable06  = N''
               ,@c_lottable07  = N''
               ,@c_lottable08  = N''
               ,@c_lottable09  = N''
               ,@c_lottable10  = N''
               ,@c_lottable11  = N''
               ,@c_lottable12  = N''
               ,@dt_lottable13 = ''
               ,@dt_lottable14 = ''
               ,@dt_lottable15 = ''
               ,@c_Status      = N'DoublePal'
               ,@c_Hold        = 1
               ,@c_Remark      = N'DoublePal'
               ,@b_Success     = @b_Success OUTPUT
               ,@n_Err         = @n_Err OUTPUT
               ,@c_ErrMsg      = @c_ErrMsg OUTPUT
               ,@c_UserName    = @cUserKey
		 END

		 IF @cPalType LIKE ('D%') 
		    AND @cLocCat = 'WA' 
		    AND @cSuggToLoc = @cMidLoc 
		    AND NOT EXISTS (
			   SELECT 1 
			   FROM LOTxLOCxID WITH(NOLOCK)
			   WHERE Loc = @cFstLoc
			      AND Qty + PendingMoveIN > 0
				  AND StorerKey = @cStorerkey
			)
		 BEGIN
            EXEC [WM].[lsp_Inventoryhold_Wrapper]
               @c_StorerKey   = @cStorerkey
               ,@c_SKU         = N''
               ,@c_lot         = N''
               ,@c_Loc         = @cFstLoc
               ,@c_ID          = N''
               ,@c_lottable01  = N''
               ,@c_lottable02  = N''
               ,@c_lottable03  = N''
               ,@dt_lottable04 = ''
               ,@dt_lottable05 = ''
               ,@c_lottable06  = N''
               ,@c_lottable07  = N''
               ,@c_lottable08  = N''
               ,@c_lottable09  = N''
               ,@c_lottable10  = N''
               ,@c_lottable11  = N''
               ,@c_lottable12  = N''
               ,@dt_lottable13 = ''
               ,@dt_lottable14 = ''
               ,@dt_lottable15 = ''
               ,@c_Status      = N'DoublePal'
               ,@c_Hold        = 1
               ,@c_Remark      = N'DoublePal'
               ,@b_Success     = @b_Success OUTPUT
               ,@n_Err         = @n_Err OUTPUT
               ,@c_ErrMsg      = @c_ErrMsg OUTPUT
               ,@c_UserName    = @cUserKey
		 END

		 ELSE IF @cPalType LIKE ('D%') 
		    AND @cLocCat = 'WA' 
			AND @cSuggToLoc = @cMidLoc
		 BEGIN
            EXEC [WM].[lsp_Inventoryhold_Wrapper]
               @c_StorerKey   = @cStorerkey
               ,@c_SKU         = N''
               ,@c_lot         = N''
               ,@c_Loc         = @cTrdLoc
               ,@c_ID          = N''
               ,@c_lottable01  = N''
               ,@c_lottable02  = N''
               ,@c_lottable03  = N''
               ,@dt_lottable04 = ''
               ,@dt_lottable05 = ''
               ,@c_lottable06  = N''
               ,@c_lottable07  = N''
               ,@c_lottable08  = N''
               ,@c_lottable09  = N''
               ,@c_lottable10  = N''
               ,@c_lottable11  = N''
               ,@c_lottable12  = N''
               ,@dt_lottable13 = ''
               ,@dt_lottable14 = ''
               ,@dt_lottable15 = ''
               ,@c_Status      = N'DoublePal'
               ,@c_Hold        = 1
               ,@c_Remark      = N'DoublePal'
               ,@b_Success     = @b_Success OUTPUT
               ,@n_Err         = @n_Err OUTPUT
               ,@c_ErrMsg      = @c_ErrMsg OUTPUT
               ,@c_UserName    = @cUserKey
		 END
      END
   END

GOTO Quit

Quit:

END
    
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_1871ExtUpd01 TO NSQL
GO




