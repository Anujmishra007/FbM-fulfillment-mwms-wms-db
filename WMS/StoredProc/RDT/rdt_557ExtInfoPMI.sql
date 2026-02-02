SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: rdt_557ExtInfoPMI                                         */
/* Copyright: Maersk                                                          */
/*                                                                            */
/* Purpose:                                                                   */
/*                                                                            */
/* Date        Author    Ver.  Purposes                                       */
/* 2025-5-19   PYU015    1.0   WMS FCR-3400. Created                          */
/******************************************************************************/      
    
CREATE OR ALTER PROCEDURE rdt.rdt_557ExtInfoPMI    
   @nMobile    INT,           
   @nFunc      INT,           
   @cLangCode  NVARCHAR( 3),  
   @nStep      INT,            
   @cStorerKey NVARCHAR( 15),  
   @cUCC       NVARCHAR( 20),  
   @coFieled01 NVARCHAR( 60) OUTPUT
AS    
BEGIN    
   SET NOCOUNT ON    
   SET QUOTED_IDENTIFIER OFF    
   SET ANSI_NULLS OFF    
   SET CONCAT_NULL_YIELDS_NULL OFF    
   
   DECLARE @Col01  NVARCHAR(100) , @Col02 NVARCHAR(100)

   SET @Col01 = ''
   SET @Col02 = ''
   
   SELECT @Col01 = 'Status:' + UCC.Status + '-' + ISNULL(CODELKUP.Description,''),
          @Col02 = PICKDETAIL.OrderKey
   FROM dbo.UCC WITH (NOLOCK) 
   LEFT JOIN CODELKUP WITH(NOLOCK) ON UCC.Status = CODELKUP.Code AND CODELKUP.LISTNAME = 'UCCStatus'
   LEFT JOIN PICKDETAIL WITH(NOLOCK) ON UCC.PickDetailKey = PICKDETAIL.PickDetailKey
   WHERE UCC.StorerKey = @cStorerKey
   AND UCC.UCCNo = @cUCC
   
   IF @Col02 IS NOT NULL 
   BEGIN
     SET @coFieled01 = @Col01 + ' ' + 'order:' + @Col02
   END
   ELSE
   BEGIN
     SET @coFieled01 = @Col01
   END
        

END -- End Procedure    
GO

GRANT EXECUTE ON  rdt.rdt_557ExtInfoPMI TO NSQL
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
