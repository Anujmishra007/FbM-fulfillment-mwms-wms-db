SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO



/******************************************************************************/
/* Copyright: IDS                                                             */
/* Purpose: isp_Bartender_SG_UCCLABEL06_GetParm                               */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date       Rev  Author     Purposes                                        */
/* 2023-12-12 1.0  CSCHONG    DevOps Scripts Combine & WMS-24117              */
/******************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_Bartender_SG_UCCLBLSG06_GetParm]
(  @parm01            NVARCHAR(250),
   @parm02            NVARCHAR(250),
   @parm03            NVARCHAR(250),
   @parm04            NVARCHAR(250),
   @parm05            NVARCHAR(250),
   @parm06            NVARCHAR(250),
   @parm07            NVARCHAR(250),
   @parm08            NVARCHAR(250),
   @parm09            NVARCHAR(250),
   @parm10            NVARCHAR(250),
   @b_debug           INT = 0
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @c_ReceiptKey        NVARCHAR(10),
      @c_ExternOrderKey  NVARCHAR(10),
      @c_Deliverydate    DATETIME,
      @n_intFlag         INT,
      @n_CntRec          INT,
      @c_SQL             NVARCHAR(4000),
      @c_SQLSORT         NVARCHAR(4000),
      @c_SQLJOIN         NVARCHAR(4000),
      @c_condition1      NVARCHAR(150) ,
      @c_condition2      NVARCHAR(150),
      @c_SQLGroup        NVARCHAR(4000),
      @c_SQLOrdBy        NVARCHAR(150)


  DECLARE @d_Trace_StartTime   DATETIME,
           @d_Trace_EndTime    DATETIME,
           @c_Trace_ModuleName NVARCHAR(20),
           @d_Trace_Step1      DATETIME,
           @c_Trace_Step1      NVARCHAR(20),
           @c_UserName         NVARCHAR(20),
           @n_cntsku           INT,
           @c_mode             NVARCHAR(1),
           @c_sku              NVARCHAR(20),
           @c_getUCCno         NVARCHAR(20),
           @c_getUdef09        NVARCHAR(30),
           @c_ExecStatements   NVARCHAR(4000),
           @c_ExecArguments    NVARCHAR(4000),
           @n_FromCtn          INT,
           @n_ToCtn            INT   

   SET @d_Trace_StartTime = GETDATE()
   SET @c_Trace_ModuleName = ''

    -- SET RowNo = 0
    SET @n_FromCtn = 1
    SET @n_ToCtn = 1

   IF ISNULL(@Parm02,'') <> ''
   BEGIN
         SET @n_FromCtn = CONVERT(INT,@Parm02)
   END

   IF ISNULL(@Parm03,'') <> ''
   BEGIN
         SET @n_ToCtn = CONVERT(INT,@Parm03)
   END
   ELSE
   BEGIN
        SET @n_ToCtn = 999
   END

               SELECT DISTINCT PARM1= PD.Pickslipno,PARM2=PD.CartonNo,PARM3= '' ,PARM4= '',PARM5='',PARM6='',PARM7='', 
						   PARM8='',PARM9='',PARM10='',Key1='',Key2='',Key3='',
						    Key4='' ,Key5= '' 
							 FROM PACKHEADER PH WITH (NOLOCK) 
							 JOIN PACKDETAIL PD WITH (NOLOCK) ON PD.PickSlipNo = PH.PickSlipNo
							 LEFT JOIN ORDERS O WITH (NOLOCK) ON O.Orderkey = pH.orderkey 
							 WHERE PH.Pickslipno = @Parm01
							 AND PD.CartonNo >= @n_FromCtn AND PD.CartonNo <= @n_ToCtn
 
   EXIT_SP:

      SET @d_Trace_EndTime = GETDATE()
      SET @c_UserName = SUSER_SNAME()


   END -- procedure


GO
GRANT EXECUTE ON  [dbo].[isp_Bartender_SG_UCCLBLSG06_GetParm] TO [NSQL]
GO
