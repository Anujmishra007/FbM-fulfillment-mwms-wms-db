SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/    
/* Stored procedure: rdt_513ExtValJCB                                   */    
/* Copyright      : MAERSK                                              */    
/*                                                                      */    
/* Purpose: Validate FromLOC and ToLOC for Move SKU function            */    
/*   - Step 1: Check if FromLOC has flag (HOLD, DAMAGED, etc.)          */    
/*   - Step 6: Check if LPN has open task                               */    
/*   - Step 6: Check if location has max pallet reached                 */    
/*   - Step 6: Check if location status is OK and flag is NONE          */    
/*                                                                      */    
/* Called from: rdtfnc_Move_SKU (Function 513)                          */    
/*                                                                      */    
/* Modifications log:                                                   */    
/* Date         Rev  Author      Purposes                               */    
/* 03-Dec-2025  1.0  SKE140      Created for FromLOC/ToLOC validation   */    
/************************************************************************/    
    
CREATE OR ALTER PROCEDURE [RDT].[rdt_513ExtValJCB]    
   @nMobile         INT,    
   @nFunc           INT,    
   @cLangCode       NVARCHAR(3),    
   @nStep           INT,    
   @nInputKey       INT,    
   @cStorerKey      NVARCHAR(15),    
   @cFacility       NVARCHAR(5),    
   @cFromLOC        NVARCHAR(10),    
   @cFromID         NVARCHAR(18),    
   @cSKU            NVARCHAR(20),    
   @nQTY            INT,    
   @cToID           NVARCHAR(18),    
   @cToLOC          NVARCHAR(10),    
   @nErrNo          INT           OUTPUT,    
   @cErrMsg         NVARCHAR(20)  OUTPUT    
AS    
BEGIN    
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
    
   -- Declare local variables    
   DECLARE     
      @cLocCat      NVARCHAR(10),    
      @cLocStatus   NVARCHAR(10),    
      @cLocFlag     NVARCHAR(20),    
      @cIdFlag     NVARCHAR(20)    
    
   -- Initialize output parameters    
   SET @nErrNo = 0    
   SET @cErrMsg = ''    
    
   -- Only process for Function 513 (Move SKU)    
   IF @nFunc = 513 -- Move by SKU    
   BEGIN    
   /***************************************************************************    
   Step 1: FromLOC Validation    
   - Check if FromLOC has any flag (HOLD, DAMAGED, etc.)    
   ***************************************************************************/    
   IF @nStep = 3    
   BEGIN    
      IF @nInputKey = 1 -- ENTER key pressed    
      BEGIN    
         -- Check if FROMLOC is provided    
         IF ISNULL(@cFromLOC, '') <> ''    
         BEGIN    
            -- Get the LocationFlag from LOC table    
            SELECT @cLocFlag = LocationFlag    
            FROM dbo. LOC WITH (NOLOCK)    
            WHERE Loc = @cFromLOC    
              AND Facility = @cFacility    
    
            -- Check if location has any flag    
            IF --ISNULL(@cLocFlag, '') NOT IN ('', 'NONE')    
            (ISNULL(@cLocFlag,'') = 'HOLD') --OR ISNULL(@cLocFlag,'') = 'INACTIVE' OR ISNULL(@cLocFlag,'') = 'DAMAGED' OR ISNULL(@cLocFlag,'') = 'DAMAGE' OR ISNULL(@cLocFlag,'') = 'INLOCKED' )    
            BEGIN    
               SET @nErrNo = 218236    
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')    
                   
               -- If message doesn't exist, set default message    
               IF ISNULL(@cErrMsg, '') = ''    
                  SET @cErrMsg = 'FROMLOC has flag'    
                   
               GOTO Quit    
            END    
         END    
    
         IF ISNULL(@cFromID, '') <> ''    
         BEGIN    
            -- Get the LocationFlag from LOC table    
            SELECT @cIdFlag = [Status]    
            FROM dbo. ID WITH (NOLOCK)    
            WHERE ID = @cFromID    
    
      -- Check if location has any flag    
            IF @cIdFlag = 'HOLD'    
            BEGIN    
               SET @nErrNo = 62558    
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')    
                   
               -- If message doesn't exist, set default message    
               IF ISNULL(@cErrMsg, '') = ''    
                  SET @cErrMsg = 'FROMID has HOLD status'    
                   
               GOTO Quit    
            END    
         END    
    
         --Validate ID exists in LOTxLOCxID table and have movable stock    
  IF NOT EXISTS ( SELECT 1     
  FROM dbo.LOTxLOCxID LOTxLOCxID (NOLOCK) , dbo.LOT LOT (NOLOCK)     
  WHERE LOTxLOCxID.StorerKey = @cStorerKey    
  AND LOTxLOCxID.StorerKey = LOT.StorerKey    
  AND LOTxLOCxID.SKU = LOT.SKU    
  AND LOTxLOCxID.LOT = LOT.LOT    
  AND ID = @cFromID    
  AND (LOTxLOCxID.QTY - LOTxLOCxID.QTYAllocated - LOTxLOCxID.QTYPicked) > 0    
  AND LOT.STATUS <> 'HOLD'    
  )    
  BEGIN    
   SET @nErrNo = 69151    
   SET @cErrMsg = rdt.rdtgetmessage( 69151, @cLangCode, 'DSP') --'Lot on Hold'    
   GOTO Quit    
  END    
    
      END    
   END    
    
   /***************************************************************************    
   Step 6: ToLOC Validation    
   - Check if LPN has open task    
   - Check if location has max pallet reached    
   - Check if location status is OK and flag is NONE    
   ***************************************************************************/    
   IF @nStep = 6    
   BEGIN    
      IF @nInputKey = 1 -- ENTER key pressed    
      BEGIN    
         -- Get location info for ToLOC    
         SELECT @cLocCat = LocationCategory,     
                @cLocStatus = Status,    
                @cLocFlag = LocationFlag    
         FROM dbo.LOC WITH (NOLOCK)    
         WHERE LOC = @cToLOC    
           AND Facility = @cFacility    
    
         -- Validation 1: Check if LPN has open task    
         IF ISNULL(@cFromID, '') <> ''   
         BEGIN  
         IF EXISTS (    
            SELECT 1     
            FROM dbo.TaskDetail WITH (NOLOCK)     
            WHERE FromID = @cFromID           
              AND Status NOT IN ('X', '9')    
              AND StorerKey = @cStorerKey    
         )    
          
            BEGIN    
                SET @nErrNo = 218233    
                SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')    
                    
                IF ISNULL(@cErrMsg, '') = ''    
                   SET @cErrMsg = 'LPN has open task'    
                    
                GOTO Quit    
            END  
         END    
    
         -- Validation 2: Check if location has max pallet reached    
         IF (    
            SELECT L.MaxPallet - ISNULL(COUNT(DISTINCT LLI.ID), 0)     
            FROM dbo.LOC L WITH (NOLOCK)    
            LEFT JOIN dbo.LOTxLOCxID LLI WITH (NOLOCK)    
               ON L. Loc = LLI. Loc     
              AND LLI.StorerKey = @cStorerKey     
              AND L.Facility = @cFacility    
            WHERE L.Loc = @cToLOC    
              AND (LLI.Qty + ISNULL(LLI.PendingMoveIN, 0) > 0 OR LLI.Loc IS NULL)    
              AND L. Facility = @cFacility    
            GROUP BY L.MaxPallet    
         ) <= 0    
         AND EXISTS (    
            SELECT 1    
            FROM dbo.CODELKUP C WITH (NOLOCK)    
            WHERE C.Code = @cLocCat    
              AND C.LISTNAME = 'JCBMBILOC'    
              AND C.Short = 1    
              AND C.StorerKey = @cStorerKey    
         )    
         BEGIN    
            SET @nErrNo = 218234    
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')    
                
            IF ISNULL(@cErrMsg, '') = ''    
               SET @cErrMsg = 'Loc max pallet'    
                
            GOTO Quit    
         END    
    
         -- Validation 3: Check if location status is not OK or has flag    
         IF (ISNULL(@cLocStatus, '') <> 'OK'     
            OR ISNULL(@cLocFlag, '') NOT IN ('', 'NONE'))    
         AND EXISTS (    
            SELECT 1    
            FROM dbo.CODELKUP C WITH (NOLOCK)    
            WHERE C.Code = @cLocCat    
              AND C.LISTNAME = 'JCBMBILOC'    
              AND C.Short = 1    
              AND C.StorerKey = @cStorerKey    
         )    
         BEGIN    
            SET @nErrNo = 218236    
            SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')    
                
            IF ISNULL(@cErrMsg, '') = ''    
               SET @cErrMsg = 'Loc hold or flag'    
                
            GOTO Quit    
         END    
    
          IF ISNULL(@cToID, '') <> ''    
         BEGIN    
            -- Get the LocationFlag from LOC table    
            SELECT @cIdFlag = [Status]    
            FROM dbo. ID WITH (NOLOCK)    
            WHERE ID = @cToID    
    
            -- Check if location has any flag    
            IF @cIdFlag = 'HOLD'    
            BEGIN    
               SET @nErrNo = 62558    
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP')    
                   
               -- If message doesn't exist, set default message    
               IF ISNULL(@cErrMsg, '') = ''    
                  SET @cErrMsg = 'TOID has HOLD status'    
                   
               GOTO Quit    
            END    
         END    
    
      END    
   END    
END    
Quit:    
   RETURN    
    
END
GO
GRANT EXECUTE ON rdt_513ExtValJCB TO NSQL
GO
