import pandas as pd
import sqlite3

#1 Importar datos de origen
Ventas_path = r"C:\Users\hp\Documents\ESTUDIOS BI\practicas sqlite\3. Simulación mejorada Consecionaria\Ventas.csv"
Inventario_path = r"C:\Users\hp\Documents\ESTUDIOS BI\practicas sqlite\3. Simulación mejorada Consecionaria\Inventario.csv"

# 2 ruta bd 
ruta_BD = r"C:\Users\hp\Documents\ESTUDIOS BI\practicas sqlite\3. Simulación mejorada Consecionaria\Concesionaria_R.db"

# 3 cargar los datos
df_Ventas = pd.read_csv(Ventas_path)
df_Inventario = pd.read_csv(Inventario_path)

# 4 conectar con la BD. 
conn = sqlite3.connect(ruta_BD)

# 5. Exportación a SQL
df_Inventario.to_sql('Inventario', conn, if_exists='replace', index= False)
df_Ventas.to_sql('Ventas', conn, if_exists= 'replace', index= False)

# 6. Cierre de seguridad
conn.close()

