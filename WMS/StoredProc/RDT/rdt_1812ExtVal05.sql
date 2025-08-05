
/************************************************************************/
/* Store procedure: rdt_1812ExtVal05                                     */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: For JCB                                                     */
/*                                                                      */
/* Date        Rev     Author      Purposes                             */
/* 2025-06-09  1.0.0   JACKC       FCR-3959                             */ 
/************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_1812ExtVal05]
    @nMobile         INT 
   ,@nFunc           INT 
   ,@cLangCode       NVARCHAR( 3) 
   ,@nStep           INT 
   ,@nInputKey       INT
   ,@cTaskdetailKey  NVARCHAR( 10)
   ,@cDropID         NVARCHAR( 20)
   ,@nQTY            INT
   ,@cToLOC          NVARCHAR( 10)
   ,@nErrNo          INT           OUTPUT 
   ,@cErrMsg         NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @nDebugFlag INT = 0

   DECLARE  @cSuggToLOC          NVARCHAR(10),
            @cSuggToLocCategory  NVARCHAR(10),
            @cToLocCategory      NVARCHAR(10),
            @cOrderType          NVARCHAR(10),
            @cOrdCompany         NVARCHAR(100),
            @cStorerKey          NVARCHAR(15),
            @nTaskQTY            INT,
            @nToLocMaxPallet     INT

   --GET task info
   

   IF @nDebugFlag = 1
      SELECT 'Executing rdt_1812ExtVal05'

   SELECT
      @cSuggToLOC   = ToLOC,
      @nTaskQty     = QTY,
      @cStorerKey   = Storerkey
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE TaskDetailKey = @cTaskDetailKey
   
   IF @nFunc = 1812 -- PickSKU
   BEGIN
      IF @nStep = 4 --SKU/Qty
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'St4, SKUQty scn'

         IF @nInputKey = 1 --Enter
         BEGIN
            --Qty can only be 0 or = TaskQty
            IF @nDebugFlag = 1
               SELECT @nQty AS Qty, @nTaskQty AS TaskQty
            
            IF @nQty <> 0 AND @nQty <> @nTaskQTY
            BEGIN
               SET @nErrNo = 239651
               SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP')
               GOTO Quit
            END
         END --Inputkey = 1
      END --st4
      IF @nStep = 6 --ToLoc
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'ST6, ToLoc Scn'
         IF @nInputKey = 1 --Enter
         BEGIN
            --Get SuggToLoc and to loc info
            SELECT @cSuggToLocCategory = LocationCategory FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cSuggToLOC
            SELECT @cToLocCategory = LocationCategory,
                   @nToLocMaxPallet = MaxPallet
            FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cToLOC

            IF @cToLoc <> @cSuggToLOC
            BEGIN
               IF EXISTS ( SELECT 1 
                           FROM dbo.LOC WITH (NOLOCK)
                           WHERE LOC = @cSuggToLOC
                           AND (Status <> 'OK' OR LocationFlag NOT IN ('','NONE')) 
                           )
               BEGIN--only allow to overwrithe when SuggToLoc is on hold
                  IF @nDebugFlag = 1
                     SELECT 'SuggToLoc is on hold'

                  --Get Order info
                  SELECT TOP 1
                     @cOrderType = [type],
                     @cOrdCompany = c_company
                  FROM dbo.TaskDetail TD WITH (NOLOCK)
                  JOIN dbo.PickDetail PD WITH (NOLOCK)
                     ON TD.TaskDetailKey = PD.TaskDetailKey
                  JOIN dbo.ORDERS ORD WITH (NOLOCK)
                     ON PD.OrderKey = ORD.OrderKey
                  WHERE TD.TaskDetailKey = @cTaskDetailKey

                  --if the suggToLoc is a Marshalling lane
                  /******************************************************************************************************/
                  /* 1. All lane for the same company are hold, then only the one has lowest logical sequence is valid. */
                  /* 2. The lane must be a marshalling lane of the same company, and not on hold.                       */
                  /******************************************************************************************************/
                  IF EXISTS (SELECT 1
                             FROM dbo.CODELKUP WITH (NOLOCK)
                             WHERE LISTNAME = 'JCBCOMPML'
                             AND SHORT = @cSuggToLOC
                             AND Storerkey = @cStorerKey)
                  BEGIN
                     IF @nDebugFlag = 1
                        SELECT 'SuggToLoc is marshalling lane', @cToLOC AS ToLoc, @cSuggToLOC AS SuggToLoc, @cOrdCompany AS Company

                     -- Check if all marshalling lanes for the company are on hold
                     IF NOT EXISTS (
                        SELECT 1
                        FROM dbo.CODELKUP CL WITH (NOLOCK)
                        JOIN dbo.LOC L WITH (NOLOCK) ON CL.SHORT = L.LOC
                        WHERE CL.LISTNAME = 'JCBCOMPML'
                          AND CL.LONG = @cOrdCompany
                          AND CL.Storerkey = @cStorerKey
                          AND (L.Status = 'OK' AND (L.LocationFlag = '' OR L.LocationFlag = 'NONE'))
                     )
                     BEGIN
                        IF @nDebugFlag = 1
                           SELECT 'All lanes for the company on hold'

                        -- All lanes for the company are on hold, only allow the one with the lowest logicalloc
                        DECLARE @cDefaultMarshLane NVARCHAR(10)

                        SELECT TOP 1  @cDefaultMarshLane = L.LOC
                        FROM dbo.CODELKUP CL WITH (NOLOCK)
                        JOIN dbo.LOC L WITH (NOLOCK) ON CL.SHORT = L.LOC
                        WHERE CL.LISTNAME = 'JCBCOMPML'
                          AND CL.LONG = @cOrdCompany
                          AND CL.Storerkey = @cStorerKey
                          AND L.LocationFlag <> 'INACTIVE' --INACTIVE loc is not acceptable.
                        ORDER BY L.LogicalLocation ASC

                        IF ISNULL(@cDefaultMarshLane, '') = ''
                        BEGIN
                           SET @nErrNo = 239663
                           SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Scan the lowest logical loc
                           GOTO Quit
                        END

                        IF @cToLOC <>  @cDefaultMarshLane
                        BEGIN
                           SET @nErrNo = 239655
                           SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Scan the lowest logical loc
                           GOTO Quit
                        END
                     END -- all lane on hold
                     ELSE
                     BEGIN
                        IF @nDebugFlag = 1
                           SELECT 'Available lane exists'

                        IF NOT EXISTS (
                           SELECT 1
                           FROM dbo.CODELKUP CL WITH (NOLOCK)
                           JOIN dbo.LOC L WITH (NOLOCK) ON CL.SHORT = L.LOC
                           WHERE CL.LISTNAME = 'JCBCOMPML'
                             AND CL.SHORT = @cToLOC
                             AND CL.LONG = @cOrdCompany
                             AND L.Status = 'OK'
                             AND (L.LocationFlag = '' OR L.LocationFlag = 'NONE')
                        ) -- ToLoc must be a marshalling lane of the same company and not on hold
                        BEGIN
                           SET @nErrNo = 239654
                           SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Invalid Marshalling lane
                           GOTO Quit
                        END
                     END -- available lane exists
                  END --Marshalling lane logic
                  ELSE IF EXISTS (
                     SELECT 1
                     FROM dbo.CodeLKUP CL WITH (NOLOCK)
                     JOIN dbo.LOC WITH (NOLOCK)
                        ON CL.LONG = LOC.LocationCategory
                     WHERE CL.LISTNAME = 'JCBKITORDT'
                        AND CL.Short = 'Y'
                        AND LOC.LOC = @cSuggToLOC
                        AND CL.Code = @cOrderType
                  ) -- kitting loc logic
                  /**********************************************************************************************/
                  /* 1. All locations for the kitting order type are hold, then only the one has lowest logical */
                  /*    sequence is valid.                                                                      */
                  /* 2. The toLoc must in the kitting location category and not on hold                         */
                  /**********************************************************************************************/
                  BEGIN
                     IF @nDebugFlag = 1
                        SELECT 'SuggToLoc is kitting loc', @cToLOC AS ToLoc, @cSuggToLOC AS SuggToLoc, @cToLocCategory AS ToLocCategory,
                               @cSuggToLocCategory AS SuggToLocCatetory

                     -- Get all kitting LocationCategory for this ordertype from CodeLKUP, and check if all locations in these categories are on hold
                     IF NOT EXISTS (
                        SELECT 1
                        FROM dbo.CodeLKUP CL WITH (NOLOCK)
                        JOIN dbo.LOC L WITH (NOLOCK) ON CL.LONG = L.LocationCategory
                        WHERE CL.Short = 'Y'
                          AND CL.Code = @cOrderType
                          AND L.Status = 'OK'
                          AND (L.LocationFlag = '' OR L.LocationFlag = 'NONE')
                     )
                     BEGIN-- All locations in these kitting location categories are on hold
                        IF @nDebugFlag = 1
                           SELECT 'All kitting the category on hold', @cOrderType AS OrderType


                        DECLARE @cDefaultKittingLoc NVARCHAR(10)

                        SELECT TOP 1 @cDefaultKittingLoc = L.LOC
                        FROM dbo.CodeLKUP CL WITH (NOLOCK)
                        JOIN dbo.LOC L WITH (NOLOCK) ON CL.LONG = L.LocationCategory
                        WHERE CL.Short = 'Y'
                          AND CL.Code = @cOrderType
                          AND L.LocationFlag <> 'INACTIVE' --Inactive location is inacceptable.
                        ORDER BY L.LogicalLocation ASC

                        IF ISNULL(@cDefaultKittingLoc, '') = ''
                        BEGIN
                           SET @nErrNo = 239664
                           SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Scan the lowest logical loc in kitting category
                           GOTO Quit
                        END

                        IF @cToLOC <> @cDefaultKittingLoc
                        BEGIN
                           SET @nErrNo = 239656
                           SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Scan the lowest logical loc in kitting category
                           GOTO Quit
                        END
                     END --all kitting loc on hold
                     ELSE
                     BEGIN
                        IF @nDebugFlag = 1
                           SELECT 'Available kitting loc exists'

                        IF NOT EXISTS (
                           SELECT 1
                           FROM dbo.CodeLKUP CL WITH (NOLOCK)
                           JOIN dbo.LOC WITH (NOLOCK)
                              ON CL.LONG = LOC.LocationCategory
                           WHERE CL.Short = 'Y'
                              AND LOC.LOC = @cToLOC
                              AND CL.Code = @cOrderType
                              AND LOC.[Status] = 'OK'
                              AND (LOC.LocationFlag = '' OR LOC.LocationFlag = 'NONE')
                        )
                        BEGIN
                           SET @nErrNo = 239657
                           SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- Invalid Kitting loc
                           GOTO Quit
                        END
                     END -- there is availabe kitting loc
                  END -- kitting loc logic
                  ELSE --other type of locations
                  BEGIN
                     IF @nDebugFlag = 1
                        SELECT 'Other types of SuggLoc, cannot override'

                     SET @nErrNo = 239659
                     SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Cannot overwrite
                     GOTO Quit
                  END --othertype of locations
               END --Suggloc on hold
               ELSE
               BEGIN -- SuggLoc not on hold
                  SET @nErrNo = 239652
                  SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Cannot overwrite
                  GOTO Quit
               END
            END --ToLoc <> SuggToLoc
            ELSE -- Toloc = SuggToLoc
            BEGIN
               IF @nDebugFlag = 1
                  SELECT 'ToLoc = SuggToLoc'

               IF EXISTS (
                  SELECT 1 FROM dbo.LOC WITH (NOLOCK) 
                  WHERE LOC = @cToLOC 
                     AND LocationCategory = 'PND_OUT'
               )--check location capacity
               BEGIN
                  IF @nToLocMaxPallet > 0
                  BEGIN
                     DECLARE @nIDCount INT

                     SELECT @nIDCount = COUNT (DISTINCT ID) 
                     FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
                     WHERE LOC = @cToLOC

                     IF @nDebugFlag = 1
                        SELECT 'Check PND capacity', @cToLOC AS ToLoc, @nIDCount AS IDCount, @nToLocMaxPallet AS ToLocMaxPallet

                     IF @nIDCount >= @nToLocMaxPallet
                     BEGIN
                        SET @nErrNo = 239658
                        SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode, 'DSP') --Cannot overwrite
                        GOTO Quit
                     END
                  END
               END
            END     
         END --inputkey = 1
      END--St6
   END --830
   
Quit:

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON rdt.rdt_1812ExtVal05 TO NSQL 
GO   


