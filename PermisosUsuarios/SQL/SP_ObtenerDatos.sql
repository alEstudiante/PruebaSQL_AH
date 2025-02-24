USE [ProyectoBD]
GO
/****** Object:  StoredProcedure [dbo].[ObtenerDatos]    Script Date: 23/02/2025 7:17:46 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- Crear el procedimiento almacenado para consultar registros con permisos
ALTER PROCEDURE [dbo].[ObtenerDatos] 
    @UserID INT,				-- ID del usuario
    @TableName NVARCHAR(100),   -- Nombre de la tabla a consultar
    @Condition NVARCHAR(255)	-- Enviar All para que muestre todos los datos
AS

	-- Declarar variables
    DECLARE @SQL NVARCHAR(MAX),
			@RoleID INT,
			@TablaID INT,
			@ConditionQuery NVARCHAR(MAX) = ''


BEGIN

    
    -- Obtener el RoleID del usuario
    SELECT @RoleID = RoleID
    FROM Users U
    WHERE UserID = @UserID;
    
    -- Obtener el ID de la tabla
    SELECT @TablaID = TablaID
    FROM Tablas
    WHERE NombreTabla = @TableName;
    
    -- Verificar que el usuario tiene permisos para la tabla
    IF NOT EXISTS (SELECT 1 FROM [Permissions] WHERE RoleID = @RoleID AND TablaID = @TablaID)
    BEGIN
        PRINT 'El usuario no tiene permisos para acceder a esta tabla.';
        RETURN;
    END

    -- Si se pasan condiciones, construir la cláusula WHERE dinámica
    IF @Condition <> 'ALL'
    BEGIN

        -- Crear la consulta dinámica para las condiciones
        DECLARE @Condiciones TABLE (ConditionCode INT);
        
			
        -- Declarar las variables correspondientes
		DECLARE @FieldName NVARCHAR(100),
        @Operator NVARCHAR(10),
        @ConditionValue NVARCHAR(255),
		@Opening_Delimiter NVARCHAR(10),
		@Closing_Delimiter NVARCHAR(10)


	--  Cursor para seleccionar las columnas correctas
		DECLARE condition_cursor CURSOR FOR 
		SELECT c.FieldName, c.Operator, c.ConditionValue, c.Opening_Delimiter, C.Closing_Delimiter
		FROM ConditionCodes c
		JOIN UserConditionCodes cc ON c.ConditionCode = cc.ConditionCode
		WHERE c.TableID = @TablaID;

		OPEN condition_cursor;

		-- Recuperar los datos dentro del cursor
		FETCH NEXT FROM condition_cursor INTO @FieldName, @Operator, @ConditionValue, @Opening_Delimiter, @Closing_Delimiter

		-- Loop para recorrer todas las filas
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
		-- Aquí agregamos la condición a la consulta dinámica
		SET @ConditionQuery = @ConditionQuery + ' AND ' + @FieldName + ' '+ @Operator  +' ' + @Opening_Delimiter + ''''+ @ConditionValue+'''' + @Closing_Delimiter + '';
		
		-- Obtener el siguiente valor
		FETCH NEXT FROM condition_cursor INTO @FieldName, @Operator, @ConditionValue, @Opening_Delimiter, @Closing_Delimiter;
		END;

		CLOSE condition_cursor;
		DEALLOCATE condition_cursor;
    END
    
    -- Construir la consulta final con las condiciones
    SET @SQL = 'SELECT * FROM ' + @TableName + ' WHERE 1=1' + @ConditionQuery;
    

    -- Ejecutar la consulta dinámica
    EXEC sp_executesql @SQL;
END;