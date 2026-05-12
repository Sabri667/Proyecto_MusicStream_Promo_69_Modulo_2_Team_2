# 🎵 MusicStream Analytics — Proyecto de Integración de Datos

> *"De datos dispersos a decisiones estratégicas: construyendo puentes entre la información y el negocio."*

---

## 📖 El contexto

**MusicStream**, una plataforma de streaming musical, quiere entender mejor las tendencias musicales actuales y mejorar la experiencia de sus usuarios. Han detectado que ciertos artistas latinos y globales tienen comportamientos muy distintos en cada país, y necesitan entender los patrones de consumo para optimizar playlists, campañas de marketing y recomendaciones personalizadas.

**El problema era claro:** los datos estaban dispersos entre el top 50 de cada país, estadísticas de Last.fm, relaciones de similitud entre artistas y catálogos de Deezer. No existía ninguna vista unificada que permitiera cruzar esa información y responder preguntas estratégicas.

**Este proyecto resuelve eso.**


## 🎯 Alcance del proyecto

El presente proyecto se centra en el análisis de datos de streaming musical, limitando deliberadamente el conjunto de datos a un subconjunto representativo y manejable para responder a las preguntas de negocio planteadas por el cliente.

### Criterios de inclusión de artistas

- Se seleccionan exclusivamente **10 artistas por país** de entre los más populares (según métricas de streaming o rankings locales) en cada una de las siguientes tres regiones:
  - **España**
  - **Argentina**
  - **Estados Unidos**

Por lo tanto, el análisis cubre un total de **30 artistas** (10 españoles + 10 argentinos + 10 estadounidenses).


## 🎯 ¿Qué hace este proyecto?

Integra datos de múltiples fuentes (Deezer, Last.fm, rankings por país) en una base de datos relacional limpia y normalizada, capaz de responder preguntas de negocio que antes requerían trabajo manual.

Con este sistema, MusicStream puede:

- Identificar artistas populares en un país pero no en otro
- Detectar qué géneros dominan en cada mercado
- Analizar qué artistas tienen comunidades más fieles vs. oyentes casuales
- Mejorar el motor de recomendaciones usando similitudes reales entre artistas

---

## 🗃️ Fuentes de datos

| Fuente | Descripción |
|--------|-------------|
| **Deezer API** | Catálogo de canciones por artista (hasta 50 por artista), género, álbum, año de lanzamiento |
| **Last.fm API** | Oyentes, playcount, ratio de popularidad, artistas similares, Top 50 de España, Argentina y Estados Unidos |

**Volumen integrado:** 30 artistas · 1.500 canciones · 3 países · métricas de popularidad completas

---

## 🧱 Modelo de datos

Las tablas originales fueron renombradas al inglés, normalizadas y conectadas mediante claves foráneas:

```
artists                  (artist_id PK, artist_name)
deezer_songs             (song_id PK, artist_id FK, artist_name, song_title, album_title, track_type, genre, release_year)
lastfm_metrics           (artist_id FK, artist_name, listeners, playcount, popularity_ratio)
lastfm_similar_artists   (similar_relation_id PK, artist_id FK, artist_name, similar_artist_name)
lastfm_country_rankings  (country_ranking_id PK, artist_id FK, country, ranking_position, artist_name, listeners)
```

**Claves foráneas:**
- `deezer_songs.artist_id` → `artists.artist_id`
- `lastfm_metrics.artist_id` → `artists.artist_id`
- `lastfm_similar_artists.artist_id` → `artists.artist_id`
- `lastfm_country_rankings.artist_id` → `artists.artist_id` (permite NULL para artistas fuera de nuestros 30)

---

## ❓ Preguntas de negocio que respondemos

### 🌍 Top 50 por país
1. ¿Qué artistas de nuestros 30 aparecen en el Top 50 de los 3 países simultáneamente?
2. ¿Qué artistas de nuestros 30 aparecen tan solo en el Top 50 de un país?
3. ¿Qué país concentra más oyentes en su Top 50?

### 📊 Popularidad
1. Top 3 de artistas con más reproducciones totales (playcount)
2. Top 3 de artistas con más oyentes únicos
3. ¿Qué artistas tienen más reproducciones por oyente? (fans más fieles)
4. ¿Qué artistas tienen menos reproducciones por oyente? (oyentes más casuales)

### 🔗 Artistas similares
1. ¿Qué artistas similares podríamos escuchar si nos gusta un artista en concreto?
2. ¿Qué artistas comparten artistas similares entre sí?

### 🎸 Géneros
1. ¿Qué género domina en nuestra selección de artistas?
2. ¿Cuál es el artista con más variedad de géneros?
3. ¿Qué géneros dominan en el Top 50 de cada país? (limitado a nuestros 30 artistas)

---

## 🔍 Consultas SQL destacadas

### Artistas en el Top 50 de los 3 países
```sql
SELECT 
    artist_name,
    GROUP_CONCAT(DISTINCT country ORDER BY country SEPARATOR ', ') AS countries,
    ROUND(AVG(ranking_position), 1) AS avg_ranking
FROM lastfm_country_rankings
WHERE artist_id IS NOT NULL
GROUP BY artist_name
HAVING COUNT(DISTINCT country) = 3
ORDER BY avg_ranking ASC;
```

### Fans más fieles (popularity_ratio más alto)
```sql
SELECT artist_name, listeners, playcount, ROUND(popularity_ratio, 1) AS popularity_ratio
FROM lastfm_metrics
ORDER BY popularity_ratio DESC
LIMIT 5;
```

### Top 3 géneros por país (solo nuestros 30 artistas)
```sql
SELECT country, genre, total_canciones, avg_ranking
FROM (
    SELECT 
        r.country,
        d.genre,
        COUNT(*) AS total_canciones,
        ROUND(AVG(r.ranking_position), 1) AS avg_ranking,
        RANK() OVER (PARTITION BY r.country ORDER BY COUNT(*) DESC) AS rnk
    FROM lastfm_country_rankings r
    JOIN artists a ON r.artist_id = a.artist_id
    JOIN deezer_songs d ON a.artist_id = d.artist_id
    WHERE d.genre != 'Unknown'
    GROUP BY r.country, d.genre
) ranked
WHERE rnk <= 3
ORDER BY country, total_canciones DESC;
```

---

## 🚀 Cómo usar este proyecto

1. Clona el repositorio
```bash
git clone https://github.com/Sabri667/Proyecto_MusicStream_Promo_69_Modulo_2_Team_2
```

2. Configura tus claves de API para ingresar en los documento de extracción
```
LASTFM_API_KEY=tu_clave_aqui
```

3. Ejecuta los notebooks de extracción en orden:
   - `Extracción_DeezerAPI.ipynb`
   - `Extracción_LastfmAPI.ipynb`

4. Ejecuta el script BBDD_music_stream con tu clave de SQL:

   - `BBDD_music_stream.ipynb`  

4. Crea la base de datos y ejecuta los scripts SQL:
```bash
    - `MS_1_Limpieza_tablas.sql`   # Crea y normaliza las tablas
    - `MS_2_Consultas.sql` # Consultas de análisis
```

---

## 🛠️ Stack técnico

| Herramienta | Uso |
|-------------|-----|
| **Python** | Extracción de datos desde APIs |
| **Pandas** | Limpieza y transformación de datos |
| **MySQL 9.6** | Base de datos relacional y consultas analíticas |
| **MySQL Workbench** | Gestión y visualización de la base de datos |
| **Deezer API** | Catálogo de canciones y géneros |
| **Last.fm API** | Métricas de popularidad y rankings por país |
| **Git / GitHub** | Control de versiones y entrega del proyecto |

---

## 📁 Estructura del proyecto

```  
Proyecto_MusicStream_Promo_69_Modulo_2_Team_2/
│
├── notebooks/
│   ├── Extracción_DeezerAPI.ipynb
│   └── Extracción_LastfmAPI.ipynb
│   └── BBDD_music_stream.ipynb
│
├── data/
│   ├── songs.csv
│   ├── artistas_stats_ratio.csv
│   ├── top_artistas_esp_arg_usa.csv
│   └── artistas_similares.csv
│
├── sql/
│   ├── MS_1_Limpieza_tablas.sql
│   └── MS_2_Consultas.sql
│
└── README.md
```

---

## 👥 Sobre el proyecto

Este proyecto fue desarrollado como ejercicio completo de ingeniería y análisis de datos en la industria musical, integrando APIs reales, modelado relacional y consultas orientadas a decisiones de negocio.

Desarrollado por el equipo 2· Promoción 69 · Adalab Data Analytics

---

## 🛠️ Nota sobre la implementación

El código desarrollado opera sobre una **lista de diccionarios** en Python. Esto permite que, en el futuro, la fuente de datos pueda ser reemplazada fácilmente por otro origen (por ejemplo, consultas SQL a una base de datos, un archivo JSON, o una API) sin modificar la lógica principal del análisis.

