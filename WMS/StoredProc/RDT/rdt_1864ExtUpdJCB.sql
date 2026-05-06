
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*************************************************************************************/
/* Store procedure: [rdt_1864ExtUpdJCB]                                              */
/* Copyright: Maersk                                                                 */
/*                                                                                   */
/* Date         Rev   Author   Purposes                                              */
/* 10/09/2025   1.0   SKE140   Unlock middle locaton from double pallet              */
/*************************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1864ExtUpdJCB]
(
    @nMobile       INT,                    
    @nFunc         INT,
    @cLangCode     NVARCHAR(3), 
    @nStep         INT,         
    @nInputKey     INT,         
    @cFacility     NVARCHAR(5), 
    @cStorerKey    NVARCHAR(15), 
    @cPickSlipNo   NVARCHAR(10), 
    @cPickZone     NVARCHAR(10),
    @cLOC          NVARCHAR(10), 
    @cID           NVARCHAR(18), 
    @cSKU          NVARCHAR(20), 
    @cLottable01   NVARCHAR(18), 
    @cLottable02   NVARCHAR(18), 
    @cLottable03   NVARCHAR(18), 
    @dLottable04   DATETIME,     
    @dLottable05   DATETIME,       
    @cLottable06   NVARCHAR(30),
    @cLottable07   NVARCHAR(30), 
    @cLottable08   NVARCHAR(30), 
    @cLottable09   NVARCHAR(30), 
    @cLottable10   NVARCHAR(30), 
    @cLottable11   NVARCHAR(30), 
    @cLottable12   NVARCHAR(30), 
    @dLottable13   DATETIME,      
    @dLottable14   DATETIME,      
    @dLottable15   DATETIME,      
    @nTaskQTY      INT,            
    @cToLOC        NVARCHAR(10), 
    @cOption       NVARCHAR(1),  
    @nErrNo        INT OUTPUT, 
    @cErrMsg       NVARCHAR(20) OUTPUT   
)
AS
BEGIN
   SET NOCOUNT ON;

   -- Variable declarations
   DECLARE 
      @nRowCount    INT,
      @cActLoc      NVARCHAR(20),
      --@cID        NVARCHAR(50),
      @cPalType     NVARCHAR(10),
      @cLocRoom     NVARCHAR(20),
      @cLocCat      NVARCHAR(20),
      @cMidLoc      NVARCHAR(20),
      @cFstLoc      NVARCHAR(20),
      @cTrdLoc      NVARCHAR(20),
      @cUser        NVARCHAR(50),
      @cLocPAZ      NVARCHAR(20)

   -- Initial retrieval of values from mobility record
   SELECT 
      @cStorerKey = storerkey,
      @cFacility  = Facility,
      @cID        = V_String2,
      @cUser      = UserName
   FROM RDT.RDTMobrec WITH (NOLOCK)
   WHERE Mobile = @nMobile;

   IF @nFunc = 1864 
   BEGIN
      IF @nStep = 5 
      BEGIN
         IF @nInputKey = 1 -- Enter pressed
         BEGIN
            -- Retrieve pallet type
            SELECT TOP 1 
               @cPalType = ISNULL(PalletType, 'U')
            FROM dbo.Pallet WITH (NOLOCK)
            WHERE StorerKey = @cStorerKey
               AND PalletKey = @cID;

            -- Retrieve the location's room and category
            SELECT TOP 1 
               @cLocRoom = LocationRoom,
               @cLocCat  = LocationCategory
            FROM dbo.Loc WITH (NOLOCK)
            WHERE Loc = @cLOC
               AND Facility = @cFacility;

            -- Retrieve positions of the Loc beam (first, middle, third)
            SELECT 
               @cFstLoc = MAX(CASE WHEN RIGHT(LOC,1) = '1' THEN LOC END),
               @cMidLoc = MAX(CASE WHEN RIGHT(LOC,1) = '2' THEN LOC END),
               @cTrdLoc = MAX(CASE WHEN RIGHT(LOC,1) = '3' THEN LOC END)
            FROM dbo.Loc WITH (NOLOCK)
            WHERE LocationRoom = @cLocRoom 
               AND Facility = @cFacility;

            -- If pallet is double and category is WA
            IF @cPalType LIKE 'D%' 
			   AND @cLocCat = 'WA'
            BEGIN
               -- Picked from first location
               IF @cLOC = @cFstLoc
               BEGIN
                  -- Check if no other holds except 'DoublePal' on middle location
                  IF NOT EXISTS (
                     SELECT 1 
                     FROM dbo.InventoryHold WITH (NOLOCK)
                     WHERE Loc = @cMidLoc 
                        AND Hold = 1 
                        AND Status <> 'DoublePal'
                  )
                  BEGIN
                  -- Unhold middle location
                     UPDATE dbo.Loc WITH(ROWLOCK)
                     SET 
                        Status = 'OK', 
                        LocationFlag = 'NONE' 
                     WHERE Loc = @cMidLoc;

                     -- Clear 'DoublePal' holds in InventoryHold for middle location
                     UPDATE dbo.InventoryHold WITH(ROWLOCK)
                     SET Hold = 0
                     WHERE Hold = 1
                        AND Status = 'DoublePal'
                        AND Loc = @cMidLoc;
                  END
               END
               
			   -- Picked from middle location
               ELSE IF @cLOC = @cMidLoc
               BEGIN
                  -- Check if no other holds except 'DoublePal' on third location
                  IF NOT EXISTS (
                     SELECT 1 
                     FROM dbo.InventoryHold WITH (NOLOCK)
                     WHERE Loc = @cTrdLoc 
                        AND Hold = 1 
                        AND Status <> 'DoublePal'
                  )
                  BEGIN
                     -- Unhold third location
                     UPDATE dbo.Loc WITH(ROWLOCK)
                     SET 
					    Status = 'OK',
                        LocationFlag = 'NONE' 
                     WHERE Loc = @cTrdLoc;

                     -- Clear 'DoublePal' holds in InventoryHold for third location
                     UPDATE dbo.InventoryHold WITH(ROWLOCK)
                     SET Hold = 0
                     WHERE Hold = 1
                        AND Status = 'DoublePal'
                        AND Loc = @cTrdLoc;
                     END
                  END
                    
               -- Picked from third location
               ELSE IF @cLOC = @cTrdLoc
               BEGIN
               -- Check if no other holds except 'DoublePal' on middle location
                  IF NOT EXISTS (
                     SELECT 1 
                     FROM dbo.InventoryHold WITH(NOLOCK)
                     WHERE Loc = @cMidLoc 
                        AND Hold = 1 
                        AND Status <> 'DoublePal'
                  )
                  BEGIN
                     -- Unhold middle location
                     UPDATE dbo.Loc WITH(ROWLOCK)
                     SET 
                        Status = 'OK',
                        LocationFlag = 'NONE' 
                     WHERE Loc = @cMidLoc;

                     -- Clear 'DoublePal' holds in InventoryHold for middle location
                     UPDATE dbo.InventoryHold WITH(ROWLOCK)
                     SET Hold = 0
                     WHERE Hold = 1
                        AND Status = 'DoublePal'
                        AND Loc = @cMidLoc;
                  END
               END
            END
         END
      END
   END
QUIT:
END
GO

GRANT EXECUTE ON rdt_1864ExtUpdJCB TO NSQL
GO

