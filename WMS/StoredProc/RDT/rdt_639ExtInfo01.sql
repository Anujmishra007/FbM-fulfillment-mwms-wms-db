if exists (select * from dbo.sysobjects where id = object_id(N'[rdt].[rdt_639ExtInfo01]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [rdt].[rdt_639ExtInfo01]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO 
         
/******************************************************************************/          
/* Store procedure: rdt_639ExtInfo01                                          */          
/* Copyright      : LF Logistics                                              */          
/*                                                                            */          
/* Purpose: Show sku packkey                                                  */          
/*                                                                            */          
/* Date         Author    Ver.  Purposes                                      */          
/* 2020-02-21   James     1.0   WMS-12070. Created                            */        
/******************************************************************************/          
          
CREATE PROCEDURE [RDT].[rdt_639ExtInfo01]            
   @nMobile         INT, 
   @nFunc           INT, 
   @cLangCode       NVARCHAR(3), 
   @nStep           INT, 
   @nInputKey       INT, 
   @cStorerKey      NVARCHAR(15), 
   @cFacility       NVARCHAR(5), 
   @cToLOC          NVARCHAR(10), 
   @cToID           NVARCHAR(18), 
   @cFromLOC        NVARCHAR(10), 
   @cFromID         NVARCHAR(18), 
   @cSKU            NVARCHAR(20), 
   @nQTY            INT, 
   @cUCC            NVARCHAR(20), 
   @tExtInfoVar     VariableTable READONLY, 
   @cExtendedInfo   NVARCHAR( 20) OUTPUT          
AS          
BEGIN          
   SET NOCOUNT ON          
   SET QUOTED_IDENTIFIER OFF          
   SET ANSI_NULLS OFF          
   SET CONCAT_NULL_YIELDS_NULL OFF          
          
   DECLARE @cPackKey    NVARCHAR( 10)          

   IF @nStep IN ( 5, 6) -- SKU, QTY
   BEGIN          
      IF @nInputKey = 1 -- ESC          
      BEGIN          
         SELECT @cPackKey = PackKey
         FROM dbo.SKU WITH (NOLOCK)
         WHERE StorerKey = @cStorerKey
         AND   Sku = @cSKU
         
         SET @cExtendedInfo = 'PACKKEY: ' + @cPackKey
      END          
   END          
          
Quit:          
          
END          
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXEC ON [RDT].[rdt_639ExtInfo01] TO NSQL
GO