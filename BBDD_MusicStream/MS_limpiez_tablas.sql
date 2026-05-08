-- ============================================================
-- LIMPIEZA Y NORMALIZACIÓN - bbdd_music_stream
-- ============================================================

USE bbdd_music_stream;

-- ============================================================
-- 1. TABLA: artists (antes: artistas)
-- ============================================================

-- Renombrar tabla
RENAME TABLE artistas TO artists;

-- Renombrar columnas al inglés y añadir restricciones
ALTER TABLE artists
CHANGE id_artista artist_id INT NOT NULL,
CHANGE artista artist_name VARCHAR(100) NOT NULL;

-- Asegurar restricción en artist_name (por si no quedó aplicada)
ALTER TABLE artists
MODIFY artist_name VARCHAR(100) NOT NULL;

-- Añadir clave primaria
ALTER TABLE artists
ADD PRIMARY KEY (artist_id);

-- Verificación
SELECT * FROM artists;
DESCRIBE artists;


-- ============================================================
-- 2. TABLA: deezer_songs
-- ============================================================

-- Eliminar columnas no necesarias (id de API y género por id)
ALTER TABLE deezer_songs
DROP COLUMN id_artista,
DROP COLUMN genre_id;

-- Renombrar track_title para evitar confusión y añadir restricciones
ALTER TABLE deezer_songs
CHANGE track_title song_title VARCHAR(150) NOT NULL;

-- Añadir restricciones a todas las columnas existentes
ALTER TABLE deezer_songs
MODIFY artist_id INT NOT NULL,
MODIFY artist_name VARCHAR(150) NOT NULL,
MODIFY song_title VARCHAR(150) NOT NULL,
MODIFY album_title VARCHAR(200) NOT NULL,
MODIFY track_type VARCHAR(100) NOT NULL,
MODIFY genre VARCHAR(100) NOT NULL,
MODIFY release_year YEAR NOT NULL;

-- Añadir song_id como clave primaria autoincremental al inicio
ALTER TABLE deezer_songs
ADD COLUMN song_id INT AUTO_INCREMENT PRIMARY KEY FIRST;

-- Eliminar artist_id de la API (no coincide con nuestros IDs de artists)
ALTER TABLE deezer_songs
DROP COLUMN artist_id;

-- Añadir columna artist_id vacía para enlazar con nuestra tabla artists
ALTER TABLE deezer_songs
ADD COLUMN artist_id VARCHAR(100) FIRST;

-- Poblar artist_id haciendo JOIN por nombre de artista
UPDATE deezer_songs
JOIN artists ON deezer_songs.artist_name = artists.artist_name
SET deezer_songs.artist_id = artists.artist_id;

-- Revisar si hay nulos (nombres que no coincidieron)
SELECT artist_name
FROM deezer_songs
WHERE artist_id IS NULL;

-- Corregir nombre mal escrito (Tyler)
UPDATE deezer_songs
SET artist_name = 'Tyler the Creator'
WHERE artist_name = 'Tyler, The Creator';

-- Volver a ejecutar el UPDATE para rellenar el ID que quedó nulo
UPDATE deezer_songs
JOIN artists ON deezer_songs.artist_name = artists.artist_name
SET deezer_songs.artist_id = artists.artist_id;

-- Confirmar que no quedan nulos
SELECT *
FROM deezer_songs
WHERE artist_id IS NULL;

-- Corregir tipo de dato de artist_id para que coincida con artists
ALTER TABLE deezer_songs
MODIFY artist_id INT NOT NULL;

-- Reordenar columnas: artist_id, artist_name, song_id y el resto igual
ALTER TABLE deezer_songs
MODIFY COLUMN artist_id INT FIRST,
MODIFY COLUMN artist_name VARCHAR(150) AFTER artist_id,
MODIFY COLUMN song_id INT AFTER artist_name;

-- Verificación
SELECT * FROM deezer_songs;
DESCRIBE deezer_songs;


-- ============================================================
-- 3. TABLA: lastfm_metrics (antes: lastfm_popularidad)
-- ============================================================

-- Renombrar tabla
RENAME TABLE lastfm_popularidad TO lastfm_metrics;

-- Renombrar columnas al inglés y añadir restricciones
ALTER TABLE lastfm_metrics
CHANGE id_artista artist_id VARCHAR(100) NOT NULL,
CHANGE nombre_artista artist_name VARCHAR(150) NOT NULL,
CHANGE n_oyentes listeners BIGINT NOT NULL,
CHANGE n_playcount playcount BIGINT NOT NULL,
CHANGE ratio_popularidad popularity_ratio DECIMAL(4,1) NOT NULL;

-- Verificación
SELECT * FROM lastfm_metrics;


-- ============================================================
-- 4. TABLA: lastfm_similar_artists (antes: lastfm_similares)
-- ============================================================

-- Renombrar tabla
RENAME TABLE lastfm_similares TO lastfm_similar_artists;

-- Renombrar columnas al inglés y añadir restricciones
ALTER TABLE lastfm_similar_artists
CHANGE id_artista_principal artist_id VARCHAR(100) NOT NULL,
CHANGE nombre_artista artist_name VARCHAR(150) NOT NULL,
CHANGE id_artista_similar similar_artist_id VARCHAR(100) NULL,
CHANGE nombre_artista_similar similar_artist_name VARCHAR(150) NOT NULL;

-- Añadir ID de relación como clave primaria para poder identificar y limpiar duplicados
ALTER TABLE lastfm_similar_artists
ADD COLUMN similar_relation_id INT AUTO_INCREMENT PRIMARY KEY FIRST;

-- Revisar duplicados
SELECT artist_name, similar_artist_name, COUNT(*) AS duplicates
FROM lastfm_similar_artists
GROUP BY artist_name, similar_artist_name
HAVING COUNT(*) > 1;

-- Eliminar duplicados conservando el de menor similar_relation_id
DELETE t1
FROM lastfm_similar_artists t1
JOIN lastfm_similar_artists t2
ON t1.artist_id = t2.artist_id
AND t1.artist_name = t2.artist_name
AND t1.similar_artist_name = t2.similar_artist_name
AND t1.similar_relation_id > t2.similar_relation_id;

-- Confirmar que no quedan duplicados
SELECT artist_name, similar_artist_name, COUNT(*) AS duplicates
FROM lastfm_similar_artists
GROUP BY artist_name, similar_artist_name
HAVING COUNT(*) > 1;

-- Eliminar columna similar_artist_id (de la API, ya no necesaria)
ALTER TABLE lastfm_similar_artists
DROP COLUMN similar_artist_id;

-- Verificación
SELECT * FROM lastfm_similar_artists;


-- ============================================================
-- 5. TABLA: lastfm_country_rankings (antes: lastfm_top50_pais)
-- ============================================================

-- Corregir nombre mal escrito antes de renombrar la tabla
UPDATE lastfm_top50_pais
SET nombre_artista = 'Tyler the Creator'
WHERE nombre_artista = 'Tyler, The Creator';

-- Confirmar la corrección
SELECT *
FROM lastfm_top50_pais
WHERE nombre_artista = 'Tyler the Creator';

-- Renombrar tabla
RENAME TABLE lastfm_top50_pais TO lastfm_country_rankings;

-- Añadir ID de ranking como clave primaria
ALTER TABLE lastfm_country_rankings
ADD COLUMN country_ranking_id INT AUTO_INCREMENT PRIMARY KEY FIRST;

-- Renombrar columnas al inglés y añadir restricciones
ALTER TABLE lastfm_country_rankings
CHANGE pais country VARCHAR(50) NOT NULL,
CHANGE ranking ranking_position INT NOT NULL,
CHANGE id_artista artist_id INT NULL,
CHANGE nombre_artista artist_name VARCHAR(150) NOT NULL,
CHANGE oyentes listeners BIGINT NOT NULL;

-- Revisar duplicados en el ranking
SELECT country, ranking_position, artist_name, COUNT(*) AS duplicates
FROM lastfm_country_rankings
GROUP BY country, ranking_position, artist_name
HAVING COUNT(*) > 1;

-- Revisar artistas del ranking que NO están en nuestra tabla artists
SELECT DISTINCT lastfm_country_rankings.artist_name
FROM lastfm_country_rankings
LEFT JOIN artists ON lastfm_country_rankings.artist_name = artists.artist_name
WHERE artists.artist_name IS NULL
ORDER BY lastfm_country_rankings.artist_name;

-- Añadir FK hacia artists (permite NULL para artistas fuera de nuestros 30)
ALTER TABLE lastfm_country_rankings
ADD CONSTRAINT fk_country_rankings_artists
FOREIGN KEY (artist_id) REFERENCES artists(artist_id);

-- Revisar cuántos registros tienen artist_id nulo
SELECT COUNT(*) AS total_null_artist_id
FROM lastfm_country_rankings
WHERE artist_id IS NULL;

-- Ver qué artistas tienen artist_id nulo
SELECT DISTINCT artist_name
FROM lastfm_country_rankings
WHERE artist_id IS NULL
ORDER BY artist_name;

-- Verificación final
SELECT * FROM lastfm_country_rankings;
DESCRIBE lastfm_country_rankings;

-- ============================================================
-- VERIFICACIÓN GENERAL DE TODAS LAS TABLAS
-- ============================================================

SELECT * FROM artists;
SELECT * FROM deezer_songs;
SELECT * FROM lastfm_metrics;
SELECT * FROM lastfm_similar_artists;
SELECT * FROM lastfm_country_rankings;
