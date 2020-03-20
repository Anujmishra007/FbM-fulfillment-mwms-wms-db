if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ids_sp_generate_script]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ids_sp_generate_script]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

create procedure ids_sp_generate_script -- 28.nov.2001
 @objname nvarchar(776)
 as
   SET NOCOUNT ON 
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF
   
 declare @dbname sysname
 ,@BlankSpaceAdded	int
 ,@BasePos		int
 ,@CurrentPos	int
 ,@TextLength	int 
 ,@LineId		int
 ,@AddOnLen		int
 ,@LFCR			int --lengths of line feed carriage return
 ,@DefinedLength	int
 /* NOTE: Length of @SyscomText is 4000 to replace the length of
 ** text column in syscomments. 
 ** lengths on @Line, #CommentText Text column and
 ** value for @DefinedLength are all 4000. These need to all have
 ** the same values. 4000 was selected in order for the max length
 ** display using down level clients
 */
 ,@SyscomText	nvarchar(4000)
 ,@Line			nvarchar(4000)
 Select @DefinedLength = 4000
 SELECT @BlankSpaceAdded = 0 /*Keeps track of blank spaces at end of lines. Note Len function ignores
 							 trailing blank spaces*/
 CREATE TABLE #CommentText
 (LineId	int
  ,Text  nvarchar(4000))
 /*
 **  Make sure the @objname is local to the current database.
 */
 select @dbname = parsename(@objname,3)
 if @dbname is not null and @dbname <> db_name()
         begin
                 raiserror(15250,-1,-1)
                 return (1)
         end
 /*
 **  See if @objname exists.
 */
 if (object_id(@objname) is null)
         begin
 		select @dbname = db_name()
 		raiserror(15009,-1,-1,@objname,@dbname)
                 return (1)
         end
 /*
 **  Find out how many lines of text are coming back,
 **  and return if there are none.
 */
 if (select count(*) from syscomments c, dbo.sysobjects o where o.xtype not in ('S', 'U')
 	and o.id = c.id and o.id = object_id(@objname)) = 0 
         begin
                 raiserror(15197,-1,-1,@objname)
                 return (1)
         end
 if (select count(*) from syscomments where id = object_id(@objname)
 	and encrypted = 0) = 0
         begin
                 raiserror(15471,-1,-1)
                 return (0)
         end
 /*
 **  Else get the text.
 */
 SELECT @LFCR = 2
 SELECT @LineId = 1
 DECLARE SysComCursor  CURSOR
 FOR SELECT text FROM syscomments WHERE id = OBJECT_ID(@objname) and encrypted = 0 ORDER BY number, colid
 FOR READ ONLY
 OPEN SysComCursor
 FETCH NEXT FROM SysComCursor into @SyscomText
 WHILE @@fetch_status >= 0
 BEGIN
 	SELECT  @BasePos	= 1
 	SELECT  @CurrentPos	= 1
 	SELECT	@TextLength = LEN(@SyscomText)
 	WHILE @CurrentPos  != 0
 	BEGIN
 		--Looking for end of line followed by carriage return
 		SELECT @CurrentPos =   CHARINDEX(master.dbo.fnc_GetCharASCII(13)+master.dbo.fnc_GetCharASCII(10), @SyscomText, @BasePos)
 		--If carriage return found
 		IF @CurrentPos != 0
 		BEGIN
 			/*If new value for @Lines length will be > then the
 			**set length then insert current contents of @line
 			**and proceed.
 			*/
 			While (isnull(LEN(@Line),0) + @BlankSpaceAdded + @CurrentPos-@BasePos + @LFCR) > @DefinedLength
 			BEGIN
 				SELECT @AddOnLen = @DefinedLength-(isnull(LEN(@Line),0) + @BlankSpaceAdded)
 				INSERT #CommentText VALUES
 				( @LineId, 
 				  isnull(@Line, N'') + isnull(SUBSTRING(@SyscomText, @BasePos, @AddOnLen), N''))
 				SELECT @Line = NULL, @LineId = @LineId + 1,
 					   @BasePos = @BasePos + @AddOnLen, @BlankSpaceAdded = 0
 			END
 			SELECT @Line	= isnull(@Line, N'') + isnull(SUBSTRING(@SyscomText, @BasePos, @CurrentPos-@BasePos + @LFCR), N'')
 			SELECT @BasePos = @CurrentPos+2
 			INSERT #CommentText VALUES( @LineId, @Line )
 			SELECT @LineId = @LineId + 1
 			SELECT @Line = NULL
 		END
 		ELSE
 		--else carriage return not found
 		BEGIN
 			IF @BasePos < @TextLength
 			BEGIN
 				/*If new value for @Lines length will be > then the
 				**defined length
 				*/
 				While (isnull(LEN(@Line),0) + @BlankSpaceAdded + @TextLength-@BasePos+1 ) > @DefinedLength
 				BEGIN
 					SELECT @AddOnLen = @DefinedLength - (isnull(LEN(@Line),0)  + @BlankSpaceAdded )
 					INSERT #CommentText VALUES
 					( @LineId, 
 					  isnull(@Line, N'') + isnull(SUBSTRING(@SyscomText, @BasePos, @AddOnLen), N''))
 					SELECT @Line = NULL, @LineId = @LineId + 1,
 						@BasePos = @BasePos + @AddOnLen, @BlankSpaceAdded = 0
 				END
 				SELECT @Line = isnull(@Line, N'') + isnull(SUBSTRING(@SyscomText, @BasePos, @TextLength-@BasePos+1 ), N'')
 				if charindex(' ', @SyscomText, @TextLength+1 ) > 0
 				BEGIN
 					SELECT @Line = @Line + ' ', @BlankSpaceAdded = 1
 				END
 				BREAK
 			END
 		END
 	END
 	FETCH NEXT FROM SysComCursor into @SyscomText
 END 
 IF @Line is NOT NULL
 	INSERT #CommentText VALUES( @LineId, @Line )
 select Text from #CommentText order by LineId
 CLOSE  SysComCursor
 DEALLOCATE 	SysComCursor
 DROP TABLE 	#CommentText
 return (0) -- sp_helptext

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

GRANT EXECUTE ON ids_sp_generate_script to nSQL
GO
