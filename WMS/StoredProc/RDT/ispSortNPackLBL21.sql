if exists (select * from  dbo.sysobjects where id = object_id(N'[dbo].[ispSortNPackLBL21]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [dbo].[ispSortNPackLBL21]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: ispSortNPackLBL21                                   */  
/* Copyright      : LF Logistics                                        */  
/*                                                                      */  
/* Date       Rev  Author   Purposes                                    */  
/* 2020-05-31 1.0  Ung      WMS-13538 Created                           */  
/* 2020-09-01 1.1  Ung      WMS-14197 Consignee to 7 chars              */
/************************************************************************/  

CREATE PROCEDURE [dbo].[ispSortNPackLBL21]
   @nMobile       INT,   
   @nFunc         INT,   
   @cLangCode     NVARCHAR(3),  
   @cLoadKey      NVARCHAR(10),  
   @cConsigneeKey NVARCHAR(15),  
   @cStorerKey    NVARCHAR(15),  
   @cSKU          NVARCHAR(20),  
   @cLabelNo      NVARCHAR(20),  
   @nErrNo        INT          OUTPUT,   
   @cErrMsg       NVARCHAR(20) OUTPUT  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @cChkConsigneeKey NVARCHAR(20)  
   DECLARE @cChkRunningNo    NVARCHAR(10)  
  
   IF LEN( RTRIM( @cLabelNo)) <> 12   
   BEGIN
      SET @nErrNo = 1  
      GOTO Quit
   END
   
   -- Decode LabelNo
   SET @cChkConsigneeKey = SUBSTRING( @cLabelNo, 1, 7)
   SET @cChkRunningNo = SUBSTRING( @cLabelNo, 8, 5)
   
   -- Remove leading 0 from Consignee
   WHILE LEFT( @cChkConsigneeKey, 1) = '0'
      SET @cChkConsigneeKey = SUBSTRING( @cChkConsigneeKey, 2, LEN( @cChkConsigneeKey))
   
   -- Check consignee valid
   IF @cChkConsigneeKey <> @cConsigneeKey
   BEGIN
      SET @nErrNo = 1  
      GOTO Quit
   END
   
   -- Check running no
   IF rdt.rdtIsInteger( @cChkRunningNo) = 0
   BEGIN
      SET @nErrNo = 1  
      GOTO Quit
   END
   
Quit: 
 
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON dbo.ispSortNPackLBL21 TO NSQL
GO