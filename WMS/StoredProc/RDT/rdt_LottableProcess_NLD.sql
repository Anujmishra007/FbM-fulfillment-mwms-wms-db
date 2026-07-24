SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Store procedure: rdt_LottableProcess_NLD                                   */
/* Copyright      : Maersk                                                    */
/*                                                                            */
/* Purpose: Dynamic lottable                                                  */
/*                                                                            */
/* Date         Ver  Author   Purposes                                        */
/* 10-07-2026   1.0  MBI165   FCR-14667                                       */
/******************************************************************************/

CREATE OR ALTER PROCEDURE [RDT].[rdt_LottableProcess_NLD]
   @nMobile          INT
   ,@nFunc            INT
   ,@cLangCode        NVARCHAR( 3)
   ,@nInputKey        INT
   ,@cStorerKey       NVARCHAR( 15)
   ,@cSKU             NVARCHAR( 20)
   ,@cLottableCode    NVARCHAR( 30)
   ,@nLottableNo      INT
   ,@cLottable        NVARCHAR( 30)
   ,@cType            NVARCHAR( 10)
   ,@cSourceKey       NVARCHAR( 15)
   ,@cLottable01Value NVARCHAR( 18)
   ,@cLottable02Value NVARCHAR( 18)
   ,@cLottable03Value NVARCHAR( 18)
   ,@dLottable04Value DATETIME
   ,@dLottable05Value DATETIME
   ,@cLottable06Value NVARCHAR( 30)
   ,@cLottable07Value NVARCHAR( 30)
   ,@cLottable08Value NVARCHAR( 30)
   ,@cLottable09Value NVARCHAR( 30)
   ,@cLottable10Value NVARCHAR( 30)
   ,@cLottable11Value NVARCHAR( 30)
   ,@cLottable12Value NVARCHAR( 30)
   ,@dLottable13Value DATETIME
   ,@dLottable14Value DATETIME
   ,@dLottable15Value DATETIME
   ,@cLottable01      NVARCHAR( 18) OUTPUT
   ,@cLottable02      NVARCHAR( 18) OUTPUT
   ,@cLottable03      NVARCHAR( 18) OUTPUT
   ,@dLottable04      DATETIME      OUTPUT
   ,@dLottable05      DATETIME      OUTPUT
   ,@cLottable06      NVARCHAR( 30) OUTPUT
   ,@cLottable07      NVARCHAR( 30) OUTPUT
   ,@cLottable08      NVARCHAR( 30) OUTPUT
   ,@cLottable09      NVARCHAR( 30) OUTPUT
   ,@cLottable10      NVARCHAR( 30) OUTPUT
   ,@cLottable11      NVARCHAR( 30) OUTPUT
   ,@cLottable12      NVARCHAR( 30) OUTPUT
   ,@dLottable13      DATETIME      OUTPUT
   ,@dLottable14      DATETIME      OUTPUT
   ,@dLottable15      DATETIME      OUTPUT
   ,@nErrNo           INT           OUTPUT
   ,@cErrMsg          NVARCHAR( 20) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cKITKey NVARCHAR(10)
   DECLARE @cSQL           NVARCHAR( MAX)
   DECLARE @cSQLParam      NVARCHAR( MAX)
   DECLARE @cCondition   NVARCHAR(1000)   
   DECLARE @cWhereCondition     NVARCHAR(1000)
   DECLARE @cShort        NVARCHAR( 18)
   DECLARE @cRDLottable01        NVARCHAR( 18)
   DECLARE @cRDLottableVAR       NVARCHAR( 30)
   DECLARE @dRDLottableDATE      DATETIME
   DECLARE @cRDLot               NVARCHAR( 30)

   IF @cType='PRE'
   BEGIN
      SELECT @cKITKey = V_String1 FROM rdt.rdtMobRec WITH (NOLOCK) WHERE Mobile = @nMobile
      
      /* short = lottable number */
      /* long = field value to extract */
      /* notes = dymanic clause */
      /* short = field extract logic SQL or DEFAULT */

      SELECT @cRDLot  = Long
      ,@cShort = Short
      ,@cCondition = Notes
      FROM dbo.codelkup WITH (NOLOCK)
      WHERE LISTNAME = '663LOTSP'
      AND Storerkey = @cStorerKey
      AND Code = @nLottableNo


      IF @cShort = 'DEFAULT' 
      BEGIN 
         SET @cRDLottableVAR = @cRDLot
      END

      IF @cShort = 'GETDATE'
      BEGIN
         SET @cRDLottableVAR = CONVERT(NVARCHAR(8), GETDATE(), 112)
      END

      
      IF @cShort = 'SQL'
      BEGIN
         SET @cSQL = 
                  ' SELECT TOP 1 @cRDLottableVAR = CONVERT(NVARCHAR(30),' + @cRDLot  + ')' +
                  ' FROM dbo.KIT WITH (NOLOCK) ' +
                  ' INNER JOIN dbo.KITDETAIL WITH (NOLOCK) ON KIT.KITKEY = KITDETAIL.KITKEY AND KIT.STORERKEY = KITDETAIL.STORERKEY ' +
                  ' INNER JOIN dbo.SKU WITH (NOLOCK) ON SKU.SKU = KITDETAIL.SKU AND SKU.STORERKEY = KITDETAIL.STORERKEY ' +
                  ' WHERE KIT.KITKEY = @cKITKey ' 

         IF ISNULL(@cCondition,'') <> ''  
         BEGIN  
            SET @cCondition = REPLACE(LEFT(@cCondition,5),'AND ','AND (') + SUBSTRING(@cCondition,6,LEN(@cCondition)-5)  
            SET @cCondition = REPLACE(LEFT(@cCondition,4),'OR ','OR (') + SUBSTRING(@cCondition,5,LEN(@cCondition)-4)  
            SET @cSQL = @cSQL + master.dbo.fnc_GetCharASCII(13) + CASE WHEN LEFT(LTRIM(@cCondition),3) NOT IN ('AND','OR ') AND ISNULL(@cCondition,'') <> '' THEN ' AND (' ELSE ' ' END + RTRIM(@cCondition)  + ')' 
         END

         SET @cSQLParam = 
                     ' @cKITKey NVARCHAR( 10), ' + 
                     ' @cRDLot NVARCHAR( 30), ' + 
                     ' @cRDLottableVAR NVARCHAR( 30) OUTPUT '

         EXEC sp_ExecuteSQL @cSQL, @cSQLParam, 
               @cKITKey, 
               @cRDLot, 
               @cRDLottableVAR OUTPUT
      END

      IF @nLottableNo = 1  SET @cLottable01 = @cRDLottableVAR
      IF @nLottableNo = 2  SET @cLottable02 = @cRDLottableVAR
      IF @nLottableNo = 3  SET @cLottable03 = @cRDLottableVAR
      IF @nLottableNo = 4  SET @dLottable04 = @cRDLottableVAR
      IF @nLottableNo = 5  SET @dLottable05 = @cRDLottableVAR
      IF @nLottableNo = 6  SET @cLottable06 = @cRDLottableVAR
      IF @nLottableNo = 7  SET @cLottable07 = @cRDLottableVAR
      IF @nLottableNo = 8  SET @cLottable08 = @cRDLottableVAR
      IF @nLottableNo = 9  SET @cLottable09 = @cRDLottableVAR
      IF @nLottableNo = 10  SET @cLottable10 = @cRDLottableVAR
      IF @nLottableNo = 11  SET @cLottable11 = @cRDLottableVAR
      IF @nLottableNo = 12  SET @cLottable12 = @cRDLottableVAR
      IF @nLottableNo = 13  SET @dLottable13 = @cRDLottableVAR
      IF @nLottableNo = 14  SET @dLottable14 = @cRDLottableVAR
      IF @nLottableNo = 15  SET @dLottable15 = @cRDLottableVAR
   END

QUIT:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_LottableProcess_NLD TO NSQL
GO
