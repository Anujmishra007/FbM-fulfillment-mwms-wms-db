
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/*********************************************************************************/
/* Store procedure: rdt_1157DropList01                                           */
/* Copyright      : Maersk                                                       */
/*                                                                               */
/* Purpose: DropList Test SP                                                     */
/* This SP will be called from rdtScr2XMLHttp                                    */
/*                                                                               */
/* Date        Rev  Author      Purposes                                         */
/* 30-10-2024  1.0  Cuize       FCR-1057 Created                                 */
/*********************************************************************************/

CREATE OR ALTER PROCEDURE rdt.rdt_1157DropList01
   @nMobile          INT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @nFunc            INT,
      @nScn             INT,
      @nStep            INT,
      @cStorerKey       NVARCHAR( 15),
      @cOrderKey        NVARCHAR( 18),              -- Pick Order Key
      @cSUSR1    NVARCHAR( 20)

   DECLARE @tDropDown TABLE
    (
       RowRef INT IDENTITY(1,1),
       ColText   NVARCHAR (125) NULL,
       ColValue  NVARCHAR (125) NULL,
       Selected  bit   -- 'True'
    )

   --GET SESSION
   SELECT
      @nFunc            = Func,
      @nScn             = Scn,
      @nStep            = Step,
      @cStorerKey       = V_StorerKey,
      @cOrderKey        = V_String10
   FROM rdt.rdtMobRec WITH (NOLOCK)
      WHERE Mobile = @nMobile

   --Start
   IF @nFunc = 1157
   BEGIN
      IF @nStep = 1
      BEGIN

         IF ISNULL(@cOrderKey,'') <> ''
         BEGIN

            SELECT TOP 1
               @cSUSR1 = s.SUSR1
            FROM dbo.STORER s (NOLOCK)
               JOIN dbo.ORDERS (NOLOCK) o ON o.consigneekey = s.storerkey
            WHERE o.OrderKey = @cOrderKey


            INSERT INTO @tDropDown (coltext, colvalue)
            SELECT
               code2+'-'+Description as coltext,
               code2 as colvalue
            FROM dbo.CODELKUP WITH(NOLOCK)
            WHERE Storerkey     = @cStorerKey
              AND Code         = @cSUSR1

         END

      END
   END


Quit:

   SELECT
      coltext,
      colvalue,
      CASE WHEN selected = 1
         THEN 'TRUE'
         ELSE 'FALSE'
      END as selected
   FROM @tDropDown

END
GO

GRANT EXECUTE ON rdt.rdt_1157DropList01 TO NSQL
GO   

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
