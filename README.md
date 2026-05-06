# 🎵 Music Streaming Analytics — Data Integration Project

> *"De datos dispersos a decisiones estratégicas: construyendo puentes entre la información y el negocio."*

---

## 📖 El contexto

Una plataforma de streaming musical quiere expandir su mercado en **Estados Unidos, Argentina y España**. Han notado que ciertos artistas latinos y globales tienen comportamientos muy distintos en cada país y necesitan entender los patrones de consumo para optimizar playlists, campañas de marketing y recomendaciones personalizadas.

**El problema era claro:** los datos estaban dispersos entre el top 50 de cada país, estadísticas de Last.fm, relaciones de similitud entre artistas y catálogos de Deezer. No existía ninguna vista unificada que permitiera cruzar esa información y responder preguntas estratégicas.

**Este proyecto resuelve eso.**

---

## 🎯 ¿Qué hace este proyecto?

Integra datos de múltiples fuentes (Deezer, Last.fm, rankings semanales) en una base de datos relacional limpia y normalizada, capaz de responder preguntas de negocio que antes requerían trabajo manual.

Con este sistema, la empresa puede:

- Identificar artistas populares en un país pero no en otro
- Detectar talentos emergentes con alto engagement pero fuera del top 50
- Analizar géneros dominantes y tendencias por año en cada región
- Mejorar el motor de recomendaciones usando similitudes reales entre artistas

---

## 🗃️ Fuentes de datos

| Fuente | Descripción |
|--------|-------------|
| **Deezer API** | Catálogo de canciones por artista (hasta 50 por artista), género, álbum, año |
| **Last.fm API** | Oyentes, playcount, ratio de popularidad, artistas similares, Top 50 de España, Argentina y Estados Unidos |

**Volumen integrado:** ~30 artistas · ~1500 canciones · 3 países · métricas de popularidad completas

---

## 🧱 Modelo de datos

```
artistas           (id_artista, nombre_artista)
deezer_canciones   (id_cancion, id_artista, titulo, album, año, genero, genero_id)
top50_pais         (pais, ranking, id_artista, artista_nombre, oyentes)
lastfm_popularidad (id_artista, n_oyentes, n_playcount, ratio_popularidad)
lastfm_similares   (id_artista_principal, id_artista_similar)
```

---

## ❓ Preguntas de negocio que respondemos

1. ¿Qué artistas están en el top 50 de los 3 países simultáneamente?
2. ¿Hay artistas con alto ratio playcount/oyentes que no aparecen en rankings? *(talentos emergentes)*
3. ¿Qué géneros dominan el top 50 en cada país?
4. ¿Qué año de lanzamiento concentra más canciones en los rankings? ¿Cambia por país?
5. ¿Qué artista tiene más artistas similares dentro de la base? *(influencia)*
6. ¿Quién tiene el ratio de popularidad más alto y más bajo?
7. ¿Qué canciones de un artista específico están en el top 50?
8. ¿Existe correlación entre número de oyentes y posición en el ranking?
9. ¿Qué artista es el más recomendado como "similar" por otros? *(centralidad)*
10. ¿Cuál es el promedio de oyentes: artistas en top 50 vs. los que no están?

---

## 🔍 Consultas SQL destacadas

COMPLETAR CON ESTRUCTURA FINAL
---

## 🚀 Cómo usar este proyecto

```
COMPLETAR CON ESTRUCTURA FINAL
```

---

## 🛠️ Stack técnico

- **Python** — ingesta y normalización de datos
- **SQL (PostgreSQL / SQLite)** — modelo relacional y consultas analíticas
- **Deezer API & Last.fm API** — fuentes de datos
- **Pandas** — limpieza y transformación

---

## 📁 Estructura del proyecto

```
COMPLETAR CON ESTRUCTURA FINAL
```

---

## 👤 Sobre el proyecto

Este proyecto fue desarrollado como ejercicio completo de ingeniería y análisis de datos en la industria musical, integrando APIs reales, modelado relacional y consultas orientadas a decisiones de negocio.

---

*¿Preguntas o sugerencias? Abre un issue o contacta por LinkedIn.*
