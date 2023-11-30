SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/******************************************************************************/
/* Copyright: IDS                                                             */
/* Purpose: isp_Bartender_KR_SSCCLABEL_GetParm                                */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2023-09-01 1.0  CSCHONG    Devops Scripts Combine & Created(WMS-23531)     */
/******************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_Bartender_KR_SSCCLABEL_GetParm]
(  @c_Sparm01            NVARCHAR(250),
   @c_Sparm02            NVARCHAR(250),
   @c_Sparm03            NVARCHAR(250),
   @c_Sparm04            NVARCHAR(250),
   @c_Sparm05            NVARCHAR(250),
   @c_Sparm06            NVARCHAR(250),
   @c_Sparm07            NVARCHAR(250),
   @c_Sparm08            NVARCHAR(250),
   @c_Sparm09            NVARCHAR(250),
   @c_Sparm10            NVARCHAR(250),
   @b_debug           INT = 0
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

  DECLARE @d_Trace_StartTime   DATETIME,
           @d_Trace_EndTime    DATETIME,
           @c_Trace_ModuleName NVARCHAR(20),
           @d_Trace_Step1      DATETIME,
           @c_Trace_Step1      NVARCHAR(20),
           @c_UserName         NVARCHAR(20),
           @c_getcID           NVARCHAR(60),
           @c_getUdef09        NVARCHAR(30),
           @c_ExecStatements   NVARCHAR(4000),
           @c_ExecArguments    NVARCHAR(4000),
           @c_Pickdetkey       NVARCHAR(50),
           @c_storerkey        NVARCHAR(20),
           @n_Pqty             INT,
           @n_rowno            INT

   SET @d_Trace_StartTime = GETDATE()
   SET @c_Trace_ModuleName = ''

    -- SET RowNo = 0

    SET @c_ExecStatements = ''
    SET @c_ExecArguments = ''
    SET @c_getcID = '' 


   IF LEN(@c_Sparm01)  = 18
   BEGIN
      SET  @c_getcID  = @c_Sparm01
   END 
   ELSE IF LEN(@c_Sparm01)  >= 20
   BEGIN
      SET  @c_getcID  = Substring(@c_Sparm01, 3, 18)
   END
   ELSE
   BEGIN
          SET @c_getcID = '' 
   END



    IF @c_getcID <> ''
    BEGIN

    SELECT DISTINCT PARM1 = lli.lot ,PARM2 = lli.loc,PARM3= lli.id,PARM4 = lli.SKU,PARM5 = '',PARM6 ='',PARM7 = '' ,PARM8 = '',PARM9 = '',PARM10 = '',Key1 = '',Key2 = '',Key3 = '',Key4 = '',Key5 = ''  
    FROM  LotxLocxID lli WITH (NOLOCK)    
    WHERE  lli.id = @c_getcID  
    AND lli.Qty > 0

    END


   EXIT_SP:

      SET @d_Trace_EndTime = GETDATE()
      SET @c_UserName = SUSER_SNAME()

   END -- procedure

GO
GRANT EXECUTE ON  [dbo].[isp_Bartender_KR_SSCCLABEL_GetParm] TO [NSQL]
GO
