SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: rdt_1812ExtVal05                                    */
/* Copyright      : Maersk                                              */
/*                                                                      */
/* Purpose: For JCB                                                     */
/*                                                                      */
/* Date        Rev     Author      Purposes                             */
/* 2025-06-09  1.0.0   JACKC       FCR-3959                             */
/* 2025-10-20  1.0.1   Dennis      FCR-3959                             */ 
/* 2025-10-20  1.0.2   SOMA        Added ID Zero Weight validation      */ 
/* 2026-02-12  1.0.3   PPA374      Adding 'INLOCKED' flag for picking   */
/* 2026-02-17  1.0.4   PPA374      Only allowing to enter required qty  */
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
            @nToLocMaxPallet     INT,
            @cFacility           NVARCHAR(20),
            @cOrderKey           NVARCHAR(20),
            @cCompany            NVARCHAR(20),
            @cVID                NVARCHAR(20); 

   --GET task info
   

   IF @nDebugFlag = 1
      SELECT 'Executing rdt_1812ExtVal05'

   SELECT
      @cSuggToLOC   = ToLOC,
      @nTaskQty     = QTY,
      @cStorerKey   = Storerkey,
      @cOrderKey    = OrderKey
   FROM dbo.TaskDetail WITH (NOLOCK)
   WHERE TaskDetailKey = @cTaskDetailKey
   
   SELECT TOP 1 @cFacility = Facility, @cVID = V_ID FROM RDT.RDTMOBREC WITH(NOLOCK) WHERE Mobile = @nMobile
   SELECT TOP 1 @cCompany = C_Company FROM dbo.ORDERS WITH(NOLOCK) WHERE StorerKey = @cStorerKey AND OrderKey = @cOrderKey

   IF @nFunc = 1812 -- PickSKU
   BEGIN
      --Step 3 FromID validation--
      IF @nStep = 3 --FromID
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'St3, FromID scn';

         IF @nInputKey = 1
         BEGIN
            IF EXISTS(
		    SELECT 1 
			FROM SKU S WITH(NOLOCK) 
			   INNER JOIN LOTxLOCxID LLI WITH(NOLOCK) 
			      ON LLI.SKU = S.SKU 
				  AND LLI.StorerKey = S.StorerKey
			WHERE ISNULL(STDGROSSWGT,0) = 0 
			   AND LLI.Qty > 0 
			   AND LLI.StorerKey = @cStorerKey
			   AND LLI.ID = @cVID
			   AND ID <> ''
			)

            BEGIN
               SET @nErrNo = 218264
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- '218264^ID got 0 weight SKU' 
               GOTO Quit;
            END
         END
      END
      --Step 3  validation END--

      IF @nStep = 4 --SKU/Qty
      BEGIN
         IF @nDebugFlag = 1
            SELECT 'St4, SKUQty scn'

         IF @nInputKey = 1 --Enter
         BEGIN
            --Qty can only be 0 or = TaskQty
            IF @nDebugFlag = 1
               SELECT @nQty AS Qty, @nTaskQty AS TaskQty
            
            IF /*@nQty <> 0 AND*/ @nQty <> @nTaskQTY
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
            SELECT @cSuggToLocCategory = LocationCategory FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cSuggToLOC AND Facility = @cFacility
            SELECT @cToLocCategory = LocationCategory,
                   @nToLocMaxPallet = MaxPallet
            FROM dbo.LOC WITH (NOLOCK) WHERE LOC = @cToLOC AND Facility = @cFacility

            IF @cToLoc <> @cSuggToLOC
            AND NOT EXISTS (
                  SELECT 1
                  FROM dbo.CODELKUP AS C WITH (NOLOCK)
                     INNER JOIN dbo.ORDERS AS O WITH (NOLOCK)
                        ON O.C_Company = C.Long
                        AND O.StorerKey = @cStorerKey
                     INNER JOIN dbo.TaskDetail AS TD WITH (NOLOCK)
                        ON TD.OrderKey = O.OrderKey
                        AND TD.TaskDetailKey = @cTaskdetailKey
                        AND TD.StorerKey = @cStorerKey
                     INNER JOIN dbo. LOC AS L WITH (NOLOCK)
                        ON L.LOC = C.Short
                        AND L.Facility = @cFacility
                        AND L.Status = 'OK'
                        AND L.LocationFlag IN ('', 'NONE', 'INLOCKED')
                  WHERE C.Short = @cToLOC
                 AND C.LISTNAME = 'JCBCOMPML'
            )
            BEGIN
               IF (CHARINDEX('LIFT',@cSuggToLOC)>0)
               BEGIN
                  GOTO QUIT
               END--LIFT LOC
               IF EXISTS ( SELECT 1 
                           FROM dbo.LOC WITH (NOLOCK)
                           WHERE LOC = @cSuggToLOC
                     AND Facility = @cFacility
                           AND (Status <> 'OK' OR LocationFlag NOT IN ('','NONE', 'INLOCKED')) 
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
                    AND L.Facility = @cFacility
                          AND (L.Status = 'OK' AND (L.LocationFlag = '' OR L.LocationFlag = 'NONE' OR L.LocationFlag = 'INLOCKED'))
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
                    AND L.Facility = @cFacility
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
                      AND L.Facility = @cFacility
                             AND (L.LocationFlag = '' OR L.LocationFlag = 'NONE' OR L.LocationFlag = 'INLOCKED')
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
                  AND LOC.Facility = @cFacility
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
                    AND L.Facility = @cFacility
                          AND (L.LocationFlag = '' OR L.LocationFlag = 'NONE' OR L.LocationFlag = 'INLOCKED')
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
                    AND L.Facility = @cFacility
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
                       AND LOC.Facility = @cFacility
                              AND (LOC.LocationFlag = '' OR LOC.LocationFlag = 'NONE' OR LOC.LocationFlag = 'INLOCKED')
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
                AND Facility = @cFacility
               )--check location capacity
               BEGIN
                  IF @nToLocMaxPallet > 0
                  BEGIN
                     DECLARE @nIDCount INT

                     SELECT @nIDCount = COUNT (DISTINCT ID) 
                     FROM dbo.LOTxLOCxID LLI WITH (NOLOCK)
                     WHERE LOC = @cToLOC
                     AND QTY - QtyPicked > 0

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

         IF EXISTS (SELECT 1 FROM dbo.CODELKUP C WITH(NOLOCK) WHERE LISTNAME = 'JCBCOMPML' AND Short = @cToLOC AND Storerkey = @cStorerKey)
               AND EXISTS (
                     SELECT 1
                     FROM dbo.LOC AS L1 WITH (NOLOCK)
                     WHERE L1.Facility = @cFacility
                        AND L1.Loc = @cToLOC
                        AND (
                              L1.LocationFlag NOT IN ('', 'NONE', 'INLOCKED')
                              OR L1.Status <> 'OK'
                           )
                  )
               AND EXISTS (
                     SELECT 1
                     FROM dbo.LOC AS L2 WITH (NOLOCK)
                        INNER JOIN dbo.CODELKUP AS C WITH (NOLOCK)
                           ON  L2.LOC = C.Short
                           AND C.StorerKey = @cStorerKey
                           AND C.Long = @cCompany
                           AND C.ListName = 'JCBCOMPML'
                     WHERE L2.Facility = @cFacility
                        AND (
                              L2.LocationFlag IN ('', 'NONE', 'INLOCKED')
                              AND L2.Status = 'OK'
                           )
                  )
            BEGIN
               SET @nErrNo = 218249
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') --'218249^Use open ML'
               GOTO Quit
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
