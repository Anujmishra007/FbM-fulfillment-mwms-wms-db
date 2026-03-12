
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/******************************************************************************/
/* Store procedure: [rdt_511ExtUpdJCB]                                        */
/* Copyright      : MAERSK                                                    */
/*                                                                            */
/* Purpose: Change the task status from 9 to 'X'                              */
/*                                                                            */
/* Date        Rev  Author     Purposes                                       */
/* 30-07-2025  1.0  PPA374     SP Created                                     */
/* 05-08-2025  2.0  PPA374     Adding hold and unhld for DoublPal             */
/******************************************************************************/

CREATE OR ALTER PROC [RDT].[rdt_511ExtUpdJCB] (
@nMobile    INT,
@nFunc      INT,
@cLangCode  NVARCHAR( 3),
@nStep      INT,
@nInputKey  INT,
@cFacility  NVARCHAR( 5),
@cStorerKey NVARCHAR( 15),
@cFromID    NVARCHAR( 18),
@cFromLOC   NVARCHAR( 10),
@cToLOC     NVARCHAR( 10),
@nErrNo     INT           OUTPUT,
@cErrMsg    NVARCHAR( 20) OUTPUT
) AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cToLocCat    AS NVARCHAR(20)
   DECLARE @cToLocZone   AS NVARCHAR(20)
   DECLARE @cToLocArea   AS NVARCHAR(20)
   DECLARE @cPalType     AS NVARCHAR(15)
   DECLARE @cLocRoom     AS NVARCHAR(20)
   DECLARE @cMidLoc      AS NVARCHAR(10)
   DECLARE @cTrdLoc      AS NVARCHAR(10)
   DECLARE @cFstLoc      AS NVARCHAR(10)
   DECLARE @cUserKey     AS NVARCHAR(20)
   DECLARE @cFromLocCat  AS NVARCHAR(20)
   DECLARE @cFromLOCRoom AS NVARCHAR(20)
   DECLARE @cLocOnDHold  AS NVARCHAR(20)
   DECLARE @nCounter     AS INT

   DECLARE @b_Success INT;
   DECLARE @n_Err INT;
   DECLARE @c_ErrMsg NVARCHAR(250);

   SET @nCounter = 1

   SELECT @cUserKey = UserName
   FROM RDT.RDTMobrec (NOLOCK)
   WHERE Mobile = @nMobile

   IF @nFunc = 511 -- Move by ID
   BEGIN
      IF @nStep = 3 -- To LOC
	  BEGIN
	     IF @nInputKey = 1 -- ENTER
		 BEGIN
			--Get PalletType
			SELECT TOP 1 @cPalType = ISNULL(PalletType,'U') 
		    FROM dbo.PALLET WITH(NOLOCK)
		    WHERE StorerKey = @cStorerkey
		       AND PalletKey = @cFromID

		    --Finding From Loc category
		    SELECT TOP 1 @cFromLocCat = LocationCategory
			FROM dbo.LOC WITH(NOLOCK) 
			WHERE LOC = @cFromLOC 
			   AND Facility = @cFacility

			--Finding From Loc beam
		    SELECT TOP 1 @cFromLOCRoom = LocationRoom
		    FROM dbo.LOC WITH(NOLOCK)
		    WHERE LOC = @cFromLOC
		       AND Facility = @cFacility

			--Finding if there is a location with "DoublePal" hold in the beam TRY 1
			IF @cFromLocCat = 'WA' AND @cPalType LIKE 'D%'
			BEGIN
			   SELECT TOP 1 @cLocOnDHold = LOC
			   FROM dbo.INVENTORYHOLD IH WITH(NOLOCK)
			   WHERE Hold = '1'
			      AND Status = 'DoublePal'
				  AND LOC LIKE @cFromLOCRoom+'%'

			   EXEC [WM].[lsp_Inventoryhold_Wrapper]
                  @c_StorerKey   = @cStorerkey
                  ,@c_SKU         = N''
                  ,@c_lot         = N''
                  ,@c_Loc         = @cLocOnDHold
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
                  ,@c_Hold        = 0
                  ,@c_Remark      = N'DoublePal'
                  ,@b_Success     = @b_Success OUTPUT
                  ,@n_Err         = @n_Err OUTPUT
                  ,@c_ErrMsg      = @c_ErrMsg OUTPUT
                  ,@c_UserName    = @cUserKey
			END

			--Finding if there is a location with "DoublePal" hold in the beam TRY 2
			IF @cFromLocCat = 'WA' AND @cPalType LIKE 'D%'
			BEGIN
			   SELECT TOP 1 @cLocOnDHold = LOC
			   FROM dbo.INVENTORYHOLD IH WITH(NOLOCK)
			   WHERE Hold = '1'
			      AND Status = 'DoublePal'
				  AND LOC LIKE @cFromLOCRoom+'%'

			   EXEC [WM].[lsp_Inventoryhold_Wrapper]
                  @c_StorerKey   = @cStorerkey
                  ,@c_SKU         = N''
                  ,@c_lot         = N''
                  ,@c_Loc         = @cLocOnDHold
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
                  ,@c_Hold        = 0
                  ,@c_Remark      = N'DoublePal'
                  ,@b_Success     = @b_Success OUTPUT
                  ,@n_Err         = @n_Err OUTPUT
                  ,@c_ErrMsg      = @c_ErrMsg OUTPUT
                  ,@c_UserName    = @cUserKey
			END

		    --Finding To Loc category, zone and area
		    SELECT TOP 1 @cToLocCat = LocationCategory, 
			   @cToLocZone = PutawayZone 
			FROM dbo.LOC WITH(NOLOCK) 
			WHERE LOC = @cToLoc 
			   AND Facility = @cFacility

			SELECT TOP 1 @cToLocArea = AreaKey 
			FROM dbo.AreaDetail WITH(NOLOCK) 
			WHERE PutawayZone = @cToLocZone

			--Identifying location numbers for the location beam (TOLOC)
		    SELECT TOP 1 @cLocRoom = LocationRoom
		    FROM dbo.LOC WITH(NOLOCK)
		    WHERE LOC = @cToLOC
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

		    --Apply "DoublePal" to a loc if required
		    IF @cPalType LIKE ('D%') 
		       AND @cToLocCat = 'WA' 
			   AND @cToLOC <> @cMidLoc
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
		       AND @cToLocCat = 'WA' 
		       AND @cToLOC = @cMidLoc 
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
		       AND @cToLocCat = 'WA' 
			   AND @cToLOC = @cMidLoc
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

			--Check if location that Move By ID is for is in the list of locs to check and task for the ID exists
            IF EXISTS (
			   SELECT 1
               FROM dbo.LOC L WITH(NOLOCK)
                  INNER JOIN dbo.AreaDetail AD WITH(NOLOCK)
                     ON L.PutawayZone = AD.PutawayZone 
	                    AND L.Facility = @cFacility
                  INNER JOIN dbo.CODELKUP C WITH(NOLOCK)
                     ON C.UDF02 = AD.AreaKey
	                    AND C.Short = L.LocationCategory
		                AND C.Long = L.PutawayZone
		                AND L.Facility = @cFacility
		                AND C.Storerkey = @cStorerKey
		                AND C.LISTNAME = 'JCBMBIRTML'
		                AND C.UDF01 = '1'
               WHERE C.Storerkey = @cStorerKey
                  AND L.Facility = @cFacility
                  AND C.LISTNAME = 'JCBMBIRTML'
                  AND C.UDF01 = '1'
			      AND L.Loc = @cToLOC
			)
			   AND EXISTS (
			      SELECT 1 
                  FROM dbo.TaskDetail TD WITH(NOLOCK)
                  WHERE TD.Storerkey = @cStorerKey
                     AND TD.Status = '9'
	                 AND TD.FromID = @cFromID
	                 AND TaskType IN ('PA1','PAF')
			   )
			--Update task to "cancelled"
            BEGIN
			   UPDATE dbo.TaskDetail WITH(ROWLOCK)
               SET Status = 'X', TrafficCop = NULL
               WHERE StorerKey = @cStorerKey
                  AND FromID = @cFromID 
			END

            --Check if location that Move By ID is for is in the list of locs to check and receiptdetail for the ID exists
			IF EXISTS (
			   SELECT 1
               FROM dbo.LOC L WITH(NOLOCK)
                  INNER JOIN dbo.AreaDetail AD WITH(NOLOCK)
                     ON L.PutawayZone = AD.PutawayZone 
	                    AND L.Facility = @cFacility
                  INNER JOIN dbo.CODELKUP C WITH(NOLOCK)
                     ON C.UDF02 = AD.AreaKey
	                    AND C.Short = L.LocationCategory
		                AND C.Long = L.PutawayZone
		                AND L.Facility = @cFacility
		                AND C.Storerkey = @cStorerKey
		                AND C.LISTNAME = 'JCBMBIRTML'
		                AND C.UDF01 = '1'
               WHERE C.Storerkey = @cStorerKey
                  AND L.Facility = @cFacility
                  AND C.LISTNAME = 'JCBMBIRTML'
                  AND C.UDF01 = '1'
			      AND L.Loc = @cToLOC
			)
			   AND EXISTS (
			      SELECT 1 
			      FROM RECEIPTDETAIL WITH(NOLOCK)
			      WHERE ToId = @cFromID
			         AND StorerKey = @cStorerKey
			   )
			--Update receipt for the ID to the location it is moved to
			BEGIN
			   UPDATE dbo.RECEIPTDETAIL WITH(ROWLOCK)
               SET ToLoc = @cToLoc
               WHERE StorerKey = @cStorerKey
                  AND ToID = @cFromID
			END
		 END
	  END
   END
END
QUIT:

GO
GRANT EXECUTE ON [RDT].[rdt_511ExtUpdJCB] TO [NSQL]
GO
