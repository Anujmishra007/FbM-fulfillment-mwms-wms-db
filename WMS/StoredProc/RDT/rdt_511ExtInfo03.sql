SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************************************************/
/* Store procedure: rdt_511ExtInfo03                                                                        */
/* Purpose: Move By ID Extended Validate                                                                    */
/*                                                                                                          */
/* Called from: rdtfnc_Move_ID                                                                              */
/*                                                                                                          */
/* Modifications log:                                                                                       */
/*                                                                                                          */
/* Date        Rev  Author     Purposes                                                                     */
/* 23/12/2025  1.0  PSJ036     UWP-48074 - Created - Suggest to LOC                                         */
/* 25/02/2026  1.1  PSJ036     UWP-49555 INC9014812 - Adjust Suggest loc                                    */
/* 25/02/2026  1.2  PSJ036     UWP-49555 RITM8667192 - MovebyID to correct PTW location                     */
/* 05/03/2026  1.3  PSJ036     UWP-50167 INC9037843 - validate Storerkey and Status in Pickdetail.          */
/************************************************************************************************************/

CREATE OR ALTER     PROC [RDT].[rdt_511ExtInfo03] (
   @nMobile          INT,
   @nFunc            INT, 
   @cLangCode        NVARCHAR( 3), 
   @nStep            INT, 
   @nInputKey        INT, 
   @cStorerKey       NVARCHAR( 15),
   @cFromID          NVARCHAR( 18),    
   @cFromLOC         NVARCHAR( 10),
   @cToLOC           NVARCHAR( 10),
   @cToID            NVARCHAR( 18),
   @cSKU             NVARCHAR( 20),
   @cExtendedInfo    NVARCHAR( 20) OUTPUT
)
AS
BEGIN
   -- IDENTIFY TYPE PROCESS TO VALIDATE TOLOC
   DECLARE @cB2BnoVas        NVARCHAR(10)
   DECLARE @cB2BVas          NVARCHAR(10)
   DECLARE @cB2CSingle       NVARCHAR(10)
   DECLARE @cB2CMulti        NVARCHAR(10)

   -- ORDER LEVEL
   DECLARE @cDocType         NVARCHAR(1)
   DECLARE @cOrderSingleFlag NVARCHAR(1)
   DECLARE @cVasInfo         NVARCHAR(10)
   DECLARE @cPTWMulti        NVARCHAR(10) --PSJ036 REV1.2

   SELECT @cExtendedInfo = ''

   IF @nStep IN ( 2, 3)  --ToLoc
   BEGIN
      IF @nInputKey = 1
      BEGIN
         IF NOT EXISTS ( SELECT 1 
                        FROM dbo.CODELKUP AS CD WITH (NOLOCK)
                        WHERE CD.LISTNAME = 'ONBRMVOUT'
                           AND CD.Storerkey = @cStorerKey
                           AND CD.CODE = @cFromLOC 
                        )
         BEGIN
            GOTO QUIT
         END
         ELSE
         BEGIN --CUSTOM VALIDATION
            SELECT 
               @cB2BnoVas  = CD.UDF01,
               @cB2BVas    = CD.UDF02,
               @cB2CSingle = CD.UDF03,
               @cB2CMulti  = CD.UDF04
            FROM dbo.CODELKUP AS CD WITH (NOLOCK)
            WHERE CD.LISTNAME = 'ONBRMVOUT'
               AND CD.Storerkey = @cStorerKey
               AND CD.CODE = @cFromLOC

            -- DocType = 'E'/'B2C'
            -- DocType = 'N'/'B2B'
            -- SingleFlag = 'S'/'SINGLE'
            -- SingleFlag = 'M'/'MULTI'

            SELECT TOP 1 
               @cDocType         = ISNULL(DocType,''),
               @cOrderSingleFlag  = ISNULL(ECOM_SINGLE_Flag,''),
               @cPTWMulti         = ISNULL(USERDEFINE04,'')  --PSJ036 REV1.2
            FROM dbo.ORDERS WITH (NOLOCK) 
            WHERE STORERKEY = @cStorerKey
            AND OrderKey = ( SELECT TOP 1 OrderKey 
                        FROM dbo.PICKDETAIL WITH (NOLOCK)
                        WHERE ID = @cFromID AND STORERKEY = @cStorerKey AND Status = '3')  --PSJ036 REV1.1 REV1.3

            -- B2C ORDER
            IF @cDocType = 'E' and @cFromLOC = 'ONESTEIRA'
            BEGIN
               IF @cOrderSingleFlag = 'S' --AND @cToLOC <> @cB2CSingle
               BEGIN
                  SET @cExtendedInfo = 'Sugg LOC: ' + @cB2CSingle
                  GOTO QUIT
               END
               ELSE IF @cOrderSingleFlag = 'M' --AND @cToLOC <> @cB2CMulti
               BEGIN
                  SET @cExtendedInfo = 'Sugg LOC: ' + @cPTWMulti   --PSJ036 REV1.2
                  GOTO QUIT
               END
            END -- END B2C
            ELSE  IF @cDocType = 'N' -- B2B ORDER  --PSJ036 REV1.1
            BEGIN
               IF @cFromLOC = 'ONESTEIRA'
               BEGIN
                  IF EXISTS( SELECT 1 
                        FROM dbo.ORDERS WITH (NOLOCK) 
                        LEFT JOIN dbo.OrderInfo WITH (NOLOCK) 
                        ON ORDERS.OrderKey = OrderInfo.OrderKey
                        WHERE (isnull(ORDERS.Notes,'') <> '' OR isnull(ORDERS.Notes2,'') <> '' OR isnull(OrderInfo.Notes,'') <> '')
                        AND ORDERS.OrderKey IN (
                           SELECT DISTINCT PD.OrderKey 
                           FROM dbo.PICKDETAIL AS PD WITH (NOLOCK) 
                           WHERE PD.Status = '3' AND PD.STORERKEY = @cStorerKey AND PD.ID = @cFromID))  --PSJ036 REV1.1 REV1.3
                  BEGIN
                     SET @cExtendedInfo = 'Sugg LOC: ' + @cB2BVas
                     GOTO QUIT
                  END
                  ELSE 
                  BEGIN
                     SET @cExtendedInfo = 'Sugg LOC: ' + @cB2BnoVas
                     GOTO QUIT
                  END
               END
            END

            IF @cFromLOC = 'ONVASOUT'
            BEGIN
               SET @cExtendedInfo = 'Sugg LOC: ' + @cB2BnoVas
            END
         END --END B2B 
      END -- END VALIDATION
   END
QUIT:
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [RDT].[rdt_511ExtInfo03] TO [NSQL]
GO