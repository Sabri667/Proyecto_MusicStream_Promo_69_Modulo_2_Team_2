# 🎵 MusicStream Analytics — Proyecto de Integración de Datos
> *"De datos dispersos a decisiones estratégicas: construyendo puentes entre la información y el negocio."*

---

## 📖 El contexto

**MusicStream**, una plataforma de streaming musical, quiere entender mejor las tendencias musicales actuales y mejorar la experiencia de sus usuarios. Han detectado que ciertos artistas latinos y globales tienen comportamientos muy distintos en cada país, y necesitan entender los patrones de consumo para optimizar playlists, campañas de marketing y recomendaciones personalizadas.

**El problema era claro:** los datos estaban dispersos entre el top 50 de cada país, estadísticas de Last.fm, relaciones de similitud entre artistas y catálogos de Deezer. No existía ninguna vista unificada que permitiera cruzar esa información y responder preguntas estratégicas.

**Este proyecto resuelve eso.**

---

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
git clone https://github.com/tu-equipo/da-project-promo-XX-modulo-2-team-XX
```

2. Instala las dependencias
```bash
pip install -r requirements.txt
```

3. Configura tus claves de API en un archivo `.env`
```
LASTFM_API_KEY=tu_clave_aqui
```

4. Ejecuta los notebooks de extracción en orden:
   - `01_extraccion_deezer.ipynb`
   - `02_extraccion_lastfm.ipynb`

5. Crea la base de datos y ejecuta los scripts SQL:
```bash
MS_limpieza_tablas.sql   # Crea y normaliza las tablas
MS_consultas_finales.sql # Consultas de análisis
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
da-project-promo-XX-modulo-2-team-XX/
│
├── notebooks/
│   ├── 01_extraccion_deezer.ipynb
│   └── 02_extraccion_lastfm.ipynb
│
├── data/
│   ├── songs.csv
│   ├── artistas_stats_ratio.csv
│   ├── top_artistas_esp_arg_usa.csv
│   └── artistas_similares.csv
│
├── sql/
│   ├── MS_limpieza_tablas.sql
│   └── MS_consultas_finales.sql
│
├── requirements.txt
└── README.md
```

---

## 👥 Sobre el proyecto

Este proyecto fue desarrollado como ejercicio completo de ingeniería y análisis de datos en la industria musical, integrando APIs reales, modelado relacional y consultas orientadas a decisiones de negocio.

Desarrollado por el equipo XX · Promoción XX · Adalab Data Analytics

---

*¿Preguntas o sugerencias? Abre un issue o contacta por LinkedIn.*
