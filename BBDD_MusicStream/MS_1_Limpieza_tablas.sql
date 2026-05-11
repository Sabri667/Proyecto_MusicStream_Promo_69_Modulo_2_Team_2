-- ============================================================
-- LIMPIEZA, NORMALIZACIÓN Y CLAVES FORÁNEAS - bbdd_music_stream
-- ============================================================

USE bbdd_PRUEBA;

-- ============================================================
-- 1. TABLA: artists (antes: artistas)
-- ============================================================

-- Renombrar tabla y columnas, y definir clave primaria
RENAME TABLE artistas TO artists;

ALTER TABLE artists
CHANGE id_artista artist_id INT NOT NULL,
CHANGE artista artist_name VARCHAR(100) NOT NULL;

ALTER TABLE artists ADD PRIMARY KEY (artist_id);

-- Evitar duplicados por nombre
ALTER TABLE artists
    ADD CONSTRAINT uq_artist_name UNIQUE (artist_name);


-- Verificación
SELECT * FROM artists;
DESCRIBE artists;


-- ============================================================
-- 2. TABLA: deezer_songs
-- ============================================================

-- ============================================================
-- 2. TABLA: deezer_songs
-- ============================================================

-- Eliminar columnas innecesarias
ALTER TABLE deezer_songs
    DROP COLUMN id_artista,
    DROP COLUMN genre_id;

-- Renombrar columna
ALTER TABLE deezer_songs
    CHANGE track_title song_title VARCHAR(150) NOT NULL;

-- Corregir nombre mal escrito antes del JOIN
UPDATE deezer_songs
SET artist_name = 'Tyler the Creator'
WHERE artist_name = 'Tyler, The Creator';

-- Ajustar tipos de columnas
ALTER TABLE deezer_songs
    MODIFY artist_id INT,
    MODIFY artist_name VARCHAR(150) NOT NULL,
    MODIFY song_title VARCHAR(150) NOT NULL,
    MODIFY album_title VARCHAR(200) NOT NULL,
    MODIFY track_type VARCHAR(100) NOT NULL,
    MODIFY genre VARCHAR(100) NOT NULL,
    MODIFY release_year YEAR NOT NULL;

-- Crear clave primaria autoincremental
ALTER TABLE deezer_songs
    ADD COLUMN song_id INT AUTO_INCREMENT PRIMARY KEY FIRST;

-- Actualizar artist_id usando la tabla artists
UPDATE deezer_songs
JOIN artists
    ON deezer_songs.artist_name = artists.artist_name
SET deezer_songs.artist_id = artists.artist_id;

-- Confirmar que no quedan nulos
SELECT *
FROM deezer_songs
WHERE artist_id IS NULL;

-- Definir artist_id como NOT NULL
ALTER TABLE deezer_songs
    MODIFY artist_id INT NOT NULL;

-- Reordenar columnas
ALTER TABLE deezer_songs
    MODIFY COLUMN artist_id INT AFTER song_id,
    MODIFY COLUMN artist_name VARCHAR(150) AFTER artist_id,
    MODIFY COLUMN song_title VARCHAR(150) AFTER artist_name;

-- Verificación
SELECT * FROM deezer_songs;
DESCRIBE deezer_songs;


-- ============================================================
-- 3. TABLA: lastfm_metrics (antes: lastfm_popularidad)
-- ============================================================

RENAME TABLE lastfm_popularidad TO lastfm_metrics;

ALTER TABLE lastfm_metrics
CHANGE id_artista artist_id VARCHAR(100) NOT NULL,
CHANGE nombre_artista artist_name VARCHAR(150) NOT NULL,
CHANGE n_oyentes listeners BIGINT NOT NULL,
CHANGE n_playcount playcount BIGINT NOT NULL,
CHANGE ratio_popularidad popularity_ratio DECIMAL(4,1) NOT NULL;

-- Corregir tipo de artist_id para que coincida con artists
ALTER TABLE lastfm_metrics
MODIFY artist_id INT NOT NULL;

-- Verificación
SELECT * FROM lastfm_metrics;
DESCRIBE lastfm_metrics;


-- ============================================================
-- 4. TABLA: lastfm_similar_artists (antes: lastfm_similares)
-- ============================================================

RENAME TABLE lastfm_similares TO lastfm_similar_artists;

ALTER TABLE lastfm_similar_artists
CHANGE id_artista_principal artist_id VARCHAR(100) NOT NULL,
CHANGE nombre_artista artist_name VARCHAR(150) NOT NULL,
CHANGE id_artista_similar similar_artist_id VARCHAR(100) NULL,
CHANGE nombre_artista_similar similar_artist_name VARCHAR(150) NOT NULL;

ALTER TABLE lastfm_similar_artists
ADD COLUMN similar_relation_id INT AUTO_INCREMENT PRIMARY KEY FIRST;

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

ALTER TABLE lastfm_similar_artists
DROP COLUMN similar_artist_id;

-- Corregir tipo de artist_id para que coincida con artists
ALTER TABLE lastfm_similar_artists
MODIFY artist_id INT NOT NULL;

-- Verificación
SELECT * FROM lastfm_similar_artists;
DESCRIBE lastfm_similar_artists;


-- ============================================================
-- 5. TABLA: lastfm_country_rankings (antes: lastfm_top50_pais)
-- ============================================================

-- Corregir nombre mal escrito antes de renombrar la tabla
UPDATE lastfm_top50_pais
SET nombre_artista = 'Tyler the Creator'
WHERE nombre_artista = 'Tyler, The Creator';

RENAME TABLE lastfm_top50_pais TO lastfm_country_rankings;

ALTER TABLE lastfm_country_rankings
ADD COLUMN country_ranking_id INT AUTO_INCREMENT PRIMARY KEY FIRST;

ALTER TABLE lastfm_country_rankings
CHANGE pais country VARCHAR(50) NOT NULL,
CHANGE ranking ranking_position INT NOT NULL,
CHANGE id_artista artist_id INT NULL,
CHANGE nombre_artista artist_name VARCHAR(150) NOT NULL,
CHANGE oyentes listeners BIGINT NOT NULL;

-- Verificación
SELECT * FROM lastfm_country_rankings;
DESCRIBE lastfm_country_rankings;


-- ============================================================
-- 6. CLAVES FORÁNEAS
-- ============================================================

ALTER TABLE deezer_songs
ADD CONSTRAINT fk_deezer_songs_artists
FOREIGN KEY (artist_id) REFERENCES artists(artist_id);

ALTER TABLE lastfm_metrics
ADD CONSTRAINT fk_lastfm_metrics_artists
FOREIGN KEY (artist_id) REFERENCES artists(artist_id);

ALTER TABLE lastfm_similar_artists
ADD CONSTRAINT fk_lastfm_similar_artists_artists
FOREIGN KEY (artist_id) REFERENCES artists(artist_id);

ALTER TABLE lastfm_country_rankings
ADD CONSTRAINT fk_country_rankings_artists
FOREIGN KEY (artist_id) REFERENCES artists(artist_id);

-- Verificar que las 4 FK están creadas
SELECT CONSTRAINT_NAME, TABLE_NAME, REFERENCED_TABLE_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'bbdd_music_stream'
  AND REFERENCED_TABLE_NAME IS NOT NULL;


-- ============================================================
-- VERIFICACIÓN GENERAL DE TODAS LAS TABLAS
-- ============================================================

SELECT * FROM artists;
SELECT * FROM deezer_songs;
SELECT * FROM lastfm_metrics;
SELECT * FROM lastfm_similar_artists;
SELECT * FROM lastfm_country_rankings;
