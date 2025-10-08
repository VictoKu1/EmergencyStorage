# Storage Requirements

## Estimated Storage by Source

- **Kiwix Mirror**: Usually +7TB for all ZIM files (typically several GB to TB depending on content)
- **OpenZIM**: Usually +1TB for all files (typically several GB to TB, includes Wikipedia and educational content)
- **OpenStreetMap Planet**: ~70GB+ (compressed PBF format)
- **Internet Archive Software**: 50GB - 500GB (depending on collections selected)
- **Internet Archive Music**: 100GB - 1TB (depending on collections selected)
- **Internet Archive Movies**: 500GB - 5TB (depending on collections selected)
- **Internet Archive Texts**: 100GB - 2TB (depending on collections selected)
- **Recommended**: At least 1TB+ free space for comfortable operation with all sources

## What Gets Downloaded

### Kiwix Mirror

The script creates a `kiwix-mirror/` directory and syncs content from:
```
master.download.kiwix.org::download.kiwix.org/
```

**Content**: Complete Kiwix library mirror with ZIM files containing offline Wikipedia, educational materials, and reference content.

### OpenZIM

The script creates an `openzim/` directory and syncs content from:
```
download.openzim.org::download.openzim.org/
```

**Content**: ZIM files containing offline content such as Wikipedia, educational materials, and other reference content in compressed format.

### OpenStreetMap

The script creates an `openstreetmap/` directory and downloads:
```
https://planet.openstreetmap.org/pbf/planet-latest.osm.pbf
```

**Content**: The complete OpenStreetMap planet file in PBF format, containing global mapping data.

### Internet Archive Software

The script creates an `internet-archive-software/` directory and downloads:
- MS-DOS Games and Software
- Windows 3.x Software Library
- Historical Software Collections
- Open Source Software
- Console Living Room (Game Console Software)

**Content**: Preserved software, games, and applications from various platforms and eras.

### Internet Archive Music  

The script creates an `internet-archive-music/` directory and downloads:
- Open Source Audio Collections
- Community Audio
- Net Labels
- Live Concert Archive (etree.org)
- Radio Programs
- Audio Books & Poetry

**Content**: Music, podcasts, audiobooks, and live performances.

### Internet Archive Movies

The script creates an `internet-archive-movies/` directory and downloads:
- Prelinger Archives (industrial/educational films)
- Classic TV Shows
- Public Domain Feature Films
- Animation Films
- Documentaries

**Content**: Movies, documentaries, TV shows, and educational films.

### Internet Archive Texts

The script creates an `internet-archive-texts/` directory and downloads:
- Project Gutenberg (public domain literature)
- Biodiversity Heritage Library (biological sciences)
- Medical Heritage Library (historical medical texts)
- Academic papers and research materials
- Open access texts and technical documentation
- Government documents (public domain)
- Subject-specific collections (mathematics, physics, chemistry, biology, etc.)

**Content**: Books, research papers, academic texts, and historical documents.

## Planning Your Storage

### For All Sources (~10-15TB+)

Use a large external drive or NAS with at least 15TB of space for comfortable operation with all sources.

### For Selective Sources

Choose specific sources based on your needs and available storage:
- **Essential Knowledge**: Kiwix + OpenZIM + OpenStreetMap (~8TB)
- **Software Preservation**: Internet Archive Software (~500GB)
- **Entertainment**: Internet Archive Music + Movies (~2-6TB)
- **Academic**: Internet Archive Texts + OpenZIM (~2-3TB)

### Future Growth

Consider that these sizes may increase over time as collections grow. Leave extra space for updates and new content.
