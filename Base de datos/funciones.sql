
-- To Base64 string
CREATE FUNCTION [dbo].[fn_str_TO_BASE64]
(
    @STRING VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    RETURN (
        SELECT
            CAST(N'' AS XML).value(
                  'xs:base64Binary(xs:hexBinary(sql:column("bin")))'
                , 'VARCHAR(MAX)'
            )   Base64Encoding
        FROM (
            SELECT CAST(@STRING AS VARBINARY(MAX)) AS bin
        ) AS bin_sql_server_temp
    )
END
GO

-- From Base64 string
CREATE FUNCTION [dbo].[fn_str_FROM_BASE64]
(
    @BASE64_STRING VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    RETURN (
        SELECT 
            CAST(
                CAST(N'' AS XML).value('xs:base64Binary(sql:variable("@BASE64_STRING"))', 'VARBINARY(MAX)') 
            AS VARCHAR(MAX)
            )   UTF8Encoding
    )
END