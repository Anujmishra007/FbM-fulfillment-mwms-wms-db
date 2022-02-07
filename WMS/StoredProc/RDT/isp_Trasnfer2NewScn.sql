IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[isp_Trasnfer2NewScn]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
   DROP PROCEDURE [dbo].[isp_Trasnfer2NewScn]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***************************************************************************/  
/* Stored Procedure: isp_Trasnfer2NewScn                                   */  
/* Creation Date: 29-Mar-2010                                              */  
/* Copyright: IDS                                                          */  
/* Written by: Shong                                                       */  
/*                                                                         */  
/* Purpose: Convert from rdt.scn to rdt.scndetail                          */  
/*                                                                         */  
/*                                                                         */  
/* Input Parameters: Mobile No                                             */  
/*                                                                         */  
/* Output Parameters: NIL                                                  */  
/*                                                                         */  
/* Return Status:                                                          */  
/*                                                                         */  
/* Usage:                                                                  */  
/*                                                                         */  
/*                                                                         */  
/* Called By: isp_Trasnfer2NewScn                                          */  
/*                                                                         */  
/* PVCS Version: 1.0                                                       */  
/*                                                                         */  
/* Version: 5.4                                                            */  
/*                                                                         */  
/* Data Modifications:                                                     */  
/*                                                                         */  
/* Updates:                                                                */  
/* Date         Ver. Author   Purposes                                     */  
/* 2013-10-01   1.1  Ung      Support multi language                       */
/* 2018-10-02   1.2  Ung      INC0383981 Hide output, make error obvious   */
/***************************************************************************/  

CREATE PROC [dbo].[isp_Trasnfer2NewScn] 
(
  @n_Scn INT,
  @n_Func INT = 0 ,
  @c_ConverAll NVARCHAR(50) = '', 
  @c_ShowOutput NVARCHAR(1) = ''
)
AS
BEGIN
    
SET NOCOUNT ON
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS OFF
SET CONCAT_NULL_YIELDS_NULL OFF

DECLARE @Format  TABLE (
            [mobile] INT
           ,[typ] [nvarchar] (20) NULL DEFAULT ''
           ,[x] [nvarchar] (10) NULL DEFAULT ''
           ,[y] [nvarchar] (10) NULL DEFAULT ''
           ,[length] [nvarchar] (10) NULL DEFAULT ''
           ,[id] [nvarchar] (20) NULL DEFAULT ''
           ,[default] [nvarchar] (60) NULL DEFAULT ''
           ,[type] [nvarchar] (20) NULL DEFAULT ''
           ,[value] [nvarchar] (125) NULL DEFAULT ''
           ,[func]  [nvarchar] (4) NULL DEFAULT ''
        )



DECLARE @cLine   NVARCHAR(125)
       ,@nLine   INT
       ,@cSQL    NVARCHAR(1000)
       ,@y       NVARCHAR(10)
       ,@scn     INT 
       ,@c_lang_code NVARCHAR(3)
       ,@c_func  NVARCHAR(4)

IF @c_ConverAll = 'ALL'
BEGIN
   
      DELETE rdt.RDTSCNDETAIL
       

      DECLARE cur1  CURSOR LOCAL FAST_FORWARD READ_ONLY 
      FOR

          SELECT r.scn, r.lang_code, r.func
          FROM   rdt.RDTScn r WITH (NOLOCK)
          Order by r.Scn


   
END
ELSE
BEGIN
   IF @n_Func = 0 
   BEGIN
      DELETE rdt.RDTSCNDETAIL WHERE scn = @n_Scn
       

      DECLARE cur1  CURSOR LOCAL FAST_FORWARD READ_ONLY 
      FOR

          SELECT r.scn, r.lang_code, r.func
          FROM   rdt.RDTScn r WITH (NOLOCK)
          WHERE  r.Scn =@n_Scn
          Order by r.Scn

   END 
   ELSE 
   BEGIN
      DELETE rdt.RDTSCNDETAIL WHERE func  = @n_Func
       

      DECLARE cur1  CURSOR LOCAL FAST_FORWARD READ_ONLY 
      FOR

          SELECT r.scn, r.lang_code, r.func
          FROM   rdt.RDTScn r WITH (NOLOCK)
          WHERE  r.Func =@n_Func
          Order by r.Scn
   END
END
  
OPEN cur1

FETCH NEXT FROM cur1 INTO @scn, @c_lang_code, @c_func

WHILE @@FETCH_STATUS<>-1
BEGIN
    --SELECT @scn '@scn' 
    DELETE FROM @Format 
    IF @c_ShowOutput = '1'
    BEGIN
        PRINT @scn
        PRINT @c_lang_code
    END
    
    SELECT @nLine = 1
    
    WHILE @nLine<=60
    BEGIN
        SELECT @cSQL = N'SELECT @cLine = Line'+RIGHT('0'+RTRIM(CAST(@nLine AS NVARCHAR(2))) ,2) +
               ' FROM RDT.RDTScn (NOLOCK) WHERE Scn = ' + CONVERT(VARCHAR(10), @scn)  +
               ' AND Lang_Code = ''' + @c_lang_code + ''''
        
        EXEC sp_executesql @cSQL
            ,N'@cLine NVARCHAR(125) output'
            ,@cLine OUTPUT
        
        IF RTRIM(@cLine) IS NOT NULL
           AND RTRIM(@cLine)<>''
        BEGIN
            IF @c_ShowOutput = '1'
                PRINT @cLine
           
            SET @y = RIGHT('0'+RTRIM(CAST(@nLine AS NVARCHAR(2))) ,2)
            
            INSERT INTO @Format
            EXEC isp_OldScn_to_NewScn 
                 @y=@y
                ,@cMsg=@cLine
                ,@cDefaultFromCol='OUT'
                
            -- SELECT * FROM @Format
        END
        
        SET @nLine = @nLine+1
    END
    
    IF NOT EXISTS(
           SELECT 1
           FROM   [RDT].[RDTSCNDETAIL] WITH (NOLOCK)
           WHERE  scn = @scn
           AND    Lang_Code = @c_lang_code
       )
    BEGIN
        INSERT INTO [RDT].[RDTSCNDETAIL]
          (
            [scn], [fieldno], [xcol], [yrow], [textcolor], [coltype],
            [coltext], [colvalue], [colvaluelength],[func],[lang_code]
          )
        SELECT @scn
              ,f.id
              ,f.x
              ,f.y
              ,'white'
              ,f.[typ]
              ,f.[value]
              ,''
              ,f.length
              ,@c_func
              ,@c_lang_code
        FROM   @Format f
    END

    FETCH NEXT FROM cur1 INTO @scn, @c_lang_code, @c_func
END
DEALLOCATE cur1

END

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT EXECUTE ON isp_Trasnfer2NewScn TO NSQL
GO
