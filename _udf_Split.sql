IF EXISTS(SELECT 1 FROM sysobjects WHERE id = object_id(N'_udf_Split') AND xtype IN(N'FN', N'IF', N'TF')) DROP FUNCTION _udf_Split 
GO 

CREATE FUNCTION [dbo].[_udf_Split] (@String NVARCHAR(4000), @Delimiter NCHAR(1))
RETURNS TABLE
AS
RETURN
(
    WITH Split(stpos,endpos)
    AS(
        SELECT 0 AS stpos, CHARINDEX(@Delimiter,@String) AS endpos
        UNION ALL
        SELECT endpos+1, CHARINDEX(@Delimiter,@String,endpos+1)
            FROM Split
            WHERE endpos > 0
    )
    SELECT 'Id' = ROW_NUMBER() OVER (ORDER BY (SELECT 1)),
        'Data' = SUBSTRING(@String,stpos,COALESCE(NULLIF(endpos,0),LEN(@String)+1)-stpos)
      FROM Split
)
GO  
GRANT ALL ON _udf_Split to public
GO
