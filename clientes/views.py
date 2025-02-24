# clientes/views.py
from django.http import JsonResponse
from django.shortcuts import render
import pyodbc

def ejecutar_procedimiento(request):
    try:
        # Establece la conexión con la base de datos
        conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};'
                              'SERVER=localhost;'
                              'DATABASE=EmpresaBD;'
                              'UID=admin;'
                              'PWD=IncTest2025**')
        cursor = conn.cursor()

        # Ejecuta el procedimiento almacenado
        cursor.execute("EXEC ProyectoBD.[dbo].[ObtenerDatos] 3, 'Productos', 'All'")

        # Obtén los resultados
        resultados = cursor.fetchall()

        # Convierte los resultados a un formato adecuado (por ejemplo, lista de diccionarios)
        datos = [dict(zip([column[0] for column in cursor.description], row)) for row in resultados]

        # Cierra la conexión
        cursor.close()
        conn.close()

        return JsonResponse(datos, safe=False)

    except Exception as e:
        return JsonResponse({'error': str(e)})




