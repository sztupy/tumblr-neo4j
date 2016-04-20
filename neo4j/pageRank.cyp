match (node)
with
  collect(distinct node) as pages
unwind pages as dest
  match (source)-[:REBLOG]->(dest)
  with
    collect(distinct source) as sources,
    dest as dest
    unwind sources as src
      match (src)-[r:REBLOG]->()
      with
        src.reblogRank / count(r) as points,
        dest as dest
      with
        sum(points) as p,
        dest as dest
      set dest.reblogRank = 0.15 + 0.85 * p;

MATCH (source) RETURN source.name, source.reblogRank ORDER BY source.reblogRank desc LIMIT 25;



match (node)
with
  collect(distinct node) as pages
unwind pages as dest
  match (source)-[:ORIGINAL]->(dest)
  with
    collect(distinct source) as sources,
    dest as dest
    unwind sources as src
      match (src)-[r:ORIGINAL]->()
      with
        src.originalRank / count(r) as points,
        dest as dest
      with
        sum(points) as p,
        dest as dest
      set dest.originalRank = 0.15 + 0.85 * p;

MATCH (source) RETURN source.name, source.originalRank ORDER BY source.originalRank desc LIMIT 25;
