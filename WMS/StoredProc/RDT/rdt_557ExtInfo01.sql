IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[RDT].[rdt_557ExtInfo01]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE [RDT].[rdt_557ExtInfo01]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/    
/* Store procedure: rdt_557ExtInfo01                                    */    
/* Copyright      : IDS                                                 */    
/*                                                                      */    
/* Purpose: Decode Label No Scanned                                     */    
/*                                                                      */    
/* Called from:                                                         */    
/*                                                                      */    
/* Exceed version: 5.4                                                  */    
/*                                                                      */    
/* Modifications log:                                                   */    
/*                                                                      */    
/* Date        Rev  Author      Purposes                                */    
/* 08-12-2014  1.0  ChewKP      SOS#322322. Created                     */   
/************************************************************************/    
    
CREATE PROCEDURE rdt.rdt_557ExtInfo01    
   @nMobile    INT,           
   @nFunc      INT,           
   @cLangCode  NVARCHAR( 3),  
   @nStep      INT,            
   @cStorerKey NVARCHAR( 15),  
   @cUCC       NVARCHAR( 20),  
   @coFieled01 NVARCHAR( 20) OUTPUT
AS    
BEGIN    
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
   
   SET @coFieled01 = ''
   
   SELECT @coFieled01 = UserDefined01
   FROM dbo.UCC WITH (NOLOCK) 
   WHERE StorerKey = @cStorerKey
   AND UCCNo = @cUCC
   
   SET @coFieled01 = 'UDF1: ' + @coFieled01
        

END -- End Procedure    
GO
GRANT EXECUTE ON  rdt.rdt_557ExtInfo01 TO NSQL
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
