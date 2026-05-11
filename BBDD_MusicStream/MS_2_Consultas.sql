
-- ============================================================
-- CONSULTAS DE ANÁLISIS FINAL - bbdd_music_stream
-- ============================================================

USE bbdd_music_stream;

-- ============================================================
-- LISTADO TOP 50 POR PAÍS
-- ============================================================

-- 1. Artistas que aparecen en el Top 50 de los 3 países

SELECT 
    artist_name,
    GROUP_CONCAT(DISTINCT country ORDER BY country SEPARATOR ', ') AS countries,
    ROUND(AVG(ranking_position), 1) AS avg_ranking
FROM lastfm_country_rankings
WHERE artist_id IS NOT NULL  -- solo nuestros 30 artistas
GROUP BY artist_name
HAVING COUNT(DISTINCT country) = 3
ORDER BY avg_ranking ASC;


-- 2. Artistas que aparecen en el Top 50 de un solo país

SELECT 
    artist_name,
    country,
    ranking_position
FROM lastfm_country_rankings
WHERE artist_id IS NOT NULL  -- solo nuestros 30 artistas
GROUP BY artist_name, country, ranking_position
HAVING artist_name NOT IN (
    SELECT artist_name
    FROM lastfm_country_rankings
    GROUP BY artist_name
    HAVING COUNT(DISTINCT country) > 1
)
ORDER BY country, ranking_position ASC;


-- 3. País que concentra más oyentes en su Top 50

SELECT 
    country,
    SUM(listeners) AS total_listeners,
    ROUND(AVG(listeners), 0) AS avg_listeners_per_artist
FROM lastfm_country_rankings
GROUP BY country
ORDER BY total_listeners DESC;


-- ============================================================
-- POPULARIDAD
-- ============================================================

-- 1. Top 3 artistas por total de reproducciones (playcount)

SELECT 
    artist_name,
    playcount AS total_reproducciones
FROM lastfm_metrics
ORDER BY playcount DESC
LIMIT 3;


-- 2. Top 3 artistas con más oyentes

SELECT 
    artist_name,
    listeners AS total_oyentes
FROM lastfm_metrics
ORDER BY listeners DESC
LIMIT 3;


-- 3. Fans más fieles: popularity_ratio más alto
SELECT 
    artist_name,
    listeners,
    playcount,
    ROUND(popularity_ratio, 1) AS popularity_ratio
FROM lastfm_metrics
ORDER BY popularity_ratio DESC
LIMIT 5;


-- 4. Oyentes más casuales: popularity_ratio más bajo

SELECT 
    artist_name,
    listeners,
    playcount,
    ROUND(popularity_ratio, 1) AS popularity_ratio
FROM lastfm_metrics
ORDER BY popularity_ratio ASC
LIMIT 5;


-- ============================================================
-- ARTISTAS SIMILARES
-- ============================================================

-- 1. Artistas similares a uno en concreto
-- (cambia 'Taylor Swift' por el artista que queráis)

SELECT 
    similar_artist_name
FROM lastfm_similar_artists
WHERE artist_name = 'Taylor Swift'
ORDER BY similar_artist_name;

SELECT 
    similar_artist_name
FROM lastfm_similar_artists
WHERE artist_name = 'Bad Bunny'
ORDER BY similar_artist_name;

SELECT 
    similar_artist_name
FROM lastfm_similar_artists
WHERE artist_name = 'Melendi'
ORDER BY similar_artist_name;

SELECT 
    similar_artist_name
FROM lastfm_similar_artists
WHERE artist_name = 'Shakira'
ORDER BY similar_artist_name;


-- 2. Artistas que comparten artistas similares
-- (qué pares de artistas tienen al menos un similar en común)

SELECT 
    s1.artist_name AS artista_1,
    s2.artist_name AS artista_2,
    COUNT(*) AS similares_en_comun,
    GROUP_CONCAT(DISTINCT s1.similar_artist_name ORDER BY s1.similar_artist_name SEPARATOR ', ') AS similares_compartidos
FROM lastfm_similar_artists s1
JOIN lastfm_similar_artists s2 
    ON s1.similar_artist_name = s2.similar_artist_name
    AND s1.artist_name < s2.artist_name
GROUP BY s1.artist_name, s2.artist_name
ORDER BY similares_en_comun DESC
LIMIT 30;


-- ============================================================
-- GÉNEROS
-- ============================================================

-- 1. Género dominante en nuestra selección de artistas
SELECT 
    genre,
    COUNT(*) AS total_canciones,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS porcentaje
FROM deezer_songs
WHERE genre != 'Unknown'
GROUP BY genre
ORDER BY total_canciones DESC;


-- 2. Artista con más variedad de género
SELECT 
    artist_name,
    COUNT(DISTINCT genre) AS total_generos,
    GROUP_CONCAT(DISTINCT genre ORDER BY genre SEPARATOR ', ') AS generos
FROM deezer_songs
WHERE genre != 'Unknown'
GROUP BY artist_name
ORDER BY total_generos DESC;


-- 3. Género dominante por país (limitado a nuestros 30 artistas)

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
