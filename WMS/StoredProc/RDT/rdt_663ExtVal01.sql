SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store procedure: rdt_663ExtVal01                                     */
/* Copyright: Maersk                                                    */
/*                                                                      */
/* Purpose: Cold Store Kitting Validation                               */
/*                                                                      */
/* Date       Rev  Author     Purposes                                  */
/* 2026-07-13 1.0  MBI165     FCR-14667                                 */
/* 2026-08-31 1.1  NickT      FCR-16001 Add Step1 KIT HOLD validation   */
/************************************************************************/

CREATE OR ALTER   PROC [RDT].[rdt_663ExtVal01] (
   @nMobile             INT,
   @nFunc               INT,
   @cLangCode           NVARCHAR( 3),
   @nStep               INT,
   @nInputKey           INT,
   @cFacility           NVARCHAR( 5),
   @cStorerKey          NVARCHAR( 15),
   @cKitKey             NVARCHAR( 10),
   @cExtKitKey          NVARCHAR( 20),
   @cLOC                NVARCHAR( 10),
   @cID                 NVARCHAR( 18),
   @cSKU                NVARCHAR( 20),
   @cLottable01         NVARCHAR( 18),
   @cLottable02         NVARCHAR( 18),
   @cLottable03         NVARCHAR( 18),
   @dLottable04         DATETIME,
   @dLottable05         DATETIME,
   @cLottable06         NVARCHAR( 30),
   @cLottable07         NVARCHAR( 30),
   @cLottable08         NVARCHAR( 30),
   @cLottable09         NVARCHAR( 30),
   @cLottable10         NVARCHAR( 30),
   @cLottable11         NVARCHAR( 30),
   @cLottable12         NVARCHAR( 30),
   @dLottable13         DATETIME,
   @dLottable14         DATETIME,
   @dLottable15         DATETIME,
   @nQTY                INT,            
   @cPalletType         NVARCHAR( 10),
   @cDefaultToLoc       NVARCHAR( 10),
   @cKitDtlLineNumber   NVARCHAR( 10),
   @nErrNo              INT            OUTPUT,
   @cErrMsg             NVARCHAR( 20)  OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE 
   @cTableName       NVARCHAR(30),   
   @cDescription     NVARCHAR(250),   
   @cColumnName      NVARCHAR(250),  
   @cRecFound        INT,   
   @cCondition       NVARCHAR(1000),   
   @cType            NVARCHAR(10),  
   @cColName         NVARCHAR(128),   
   @cColType         NVARCHAR(128),  
   @cWhereCondition  NVARCHAR(1000), 
   @bInValid         BIT,
   @nSuccess         INT,  
   @cSPName          NVARCHAR(100),  --NJOW04          
   @nErr             INT --NJOW04 ,
          
DECLARE 
   @cSQL                NVARCHAR(Max),  
   @cSQLArg             NVARCHAR(Max), --(jay01)  
   @c_StorerKey         NVARCHAR(30),
   @c_ValidateCodelkup  NVARCHAR( 30),
   @cExternStatus       NVARCHAR( 30)

   IF @nFunc = 663 -- Normal receiving
   BEGIN
      IF @nStep = 1 -- Kit Key scan
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN
            SELECT @cExternStatus = ExternStatus
            FROM dbo.KIT WITH (NOLOCK)
            WHERE KITKey = @cKitKey

            IF ISNULL(@cExternStatus, '') = '7'
            BEGIN
               SET @nErrNo = 279401
               SET @cErrMsg = rdt.rdtgetmessage(@nErrNo, @cLangCode, 'DSP') -- KIT ON HOLD
               GOTO QUIT
            END
         END
      END --st1

      IF @nStep = 4 -- SKU
      BEGIN
         IF @nInputKey = 1 -- ENTER
         BEGIN 
            
            SET @c_ValidateCodelkup = rdt.RDTGetConfig( @nFunc, 'ValidateCodelkup', @cStorerKey)  

            DECLARE CUR_KIT_CONDITION CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
            SELECT Code, Description, Long, Notes, SHORT, ISNULL(Notes2,'')     
            FROM   dbo.CODELKUP WITH (NOLOCK)
            WHERE  ListName = @c_ValidateCodelkup
            AND    SHORT    IN ('CONDITION')  
            AND    STORERKEY = @cStorerKey
            OPEN CUR_KIT_CONDITION  

            FETCH NEXT FROM CUR_KIT_CONDITION INTO @cTableName, @cDescription, @cColumnName, @cCondition, @cType, @cWhereCondition  

            WHILE @@FETCH_STATUS <> -1  
            BEGIN  
               SET @cSQL = N'SELECT @cRecFound = COUNT(1) '  
                        +'FROM dbo.KIT WITH (NOLOCK) '
                        +'JOIN dbo.KITDETAIL WITH (NOLOCK) ON KIT.KITKey = KITDETAIL.KITKey '
                        +'JOIN dbo.SKU WITH (NOLOCK) ON KITDETAIL.Storerkey = SKU.Storerkey AND KITDETAIL.Sku = SKU.Sku '
                        +'JOIN RDT.RDTMOBREC RDTMOBREC WITH (NOLOCK)  ON RDTMOBREC.V_String1 = KIT.KITKey '
                        +'WHERE KIT.KITKey =  @cKitKey AND RDTMOBREC.MOBILE = @nMobile '  
            
               IF @cType = 'CONDITION'
               BEGIN  
                  IF ISNULL(@cCondition,'') <> ''  
                  BEGIN  
                     SET @cCondition = REPLACE(LEFT(@cCondition,5),'AND ','AND (') + SUBSTRING(@cCondition,6,LEN(@cCondition)-5)  
                     SET @cCondition = REPLACE(LEFT(@cCondition,4),'OR ','OR (') + SUBSTRING(@cCondition,5,LEN(@cCondition)-4)  
                     SET @cSQL = @cSQL + master.dbo.fnc_GetCharASCII(13) + CASE WHEN LEFT(LTRIM(@cCondition),3) NOT IN ('AND','OR ') AND ISNULL(@cCondition,'') <> '' THEN ' AND (' ELSE ' ' END + RTRIM(@cCondition)  
                     SET @cSQL = @cSQL + master.dbo.fnc_GetCharASCII(13) + CASE WHEN LEFT(LTRIM(@cWhereCondition),3) NOT IN ('AND','OR ') AND ISNULL(@cWhereCondition,'') <> '' THEN ' AND ' ELSE ' ' END + RTRIM(@cWhereCondition) + ')'  
                  END
               END

               SET @cSQLArg = N'@cRecFound int OUTPUT, '  
                     +'@cKitKey   NVARCHAR(10), '  
                     +'@nMobile INT ' 
         
               EXEC sp_executesql @cSQL, @cSQLArg , @cRecFound OUTPUT, @cKitKey,@nMobile 

               IF @cRecFound = 0 AND @cType <> 'CONDITION'
               BEGIN
                  --SET @bInValid = 1
                  SET @nErrNo = 218280
                  SET @cErrMsg = ISNULL(TRY_CAST(@nErrNo AS NVARCHAR(20)),'') + ' ' + @cErrMsg + RTRIM(@cDescription) + master.dbo.fnc_GetCharASCII(13)
                  GOTO QUIT
               END
               ELSE IF @cRecFound > 0 AND @cType = 'CONDITION' AND @cColumnName = 'NOT EXISTS'
               BEGIN
                  --SET @bInValid = 1
                  SET @nErrNo = 218280
                  SET @cErrMsg = ISNULL(TRY_CAST(@nErrNo AS NVARCHAR(20)),'') + ' ' + @cErrMsg + RTRIM(@cDescription) + master.dbo.fnc_GetCharASCII(13)
                  GOTO QUIT
               END
               ELSE IF @cRecFound = 0 AND @cType = 'CONDITION' AND
                        (ISNULL(RTRIM(@cColumnName),'') = '' OR @cColumnName = 'EXISTS')
               BEGIN
                  --SET @bInValid = 1
                  SET @nErrNo = 218280
                  SET @cErrMsg = ISNULL(TRY_CAST(@nErrNo AS NVARCHAR(20)),'') + ' ' + @cErrMsg + RTRIM(@cDescription)  + master.dbo.fnc_GetCharASCII(13)
                  GOTO QUIT
               END   
               FETCH NEXT FROM CUR_KIT_CONDITION INTO @cTableName, @cDescription, @cColumnName, @cCondition, @cType, @cWhereCondition    
            END  -- cursor loop 

            CLOSE CUR_KIT_CONDITION  
            DEALLOCATE CUR_KIT_CONDITION     
         END-- Inputkey = 1
      END --st4
   END -- Fn663

   QUIT: 
   IF CURSOR_STATUS('LOCAL','CUR_KIT_CONDITION') >= -1
   BEGIN
      CLOSE CUR_KIT_CONDITION
      DEALLOCATE CUR_KIT_CONDITION
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON rdt.rdt_663ExtVal01 TO NSQL
GO
