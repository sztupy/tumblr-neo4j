CYPHER CALL pagerank.calculate('Blog','REBLOGGED_BLOG','reblogRank');
MATCH (source:Blog) RETURN source.name, source.reblogRank ORDER BY source.reblogRank desc LIMIT 25;

CYPHER CALL pagerank.calculate('Blog','LIKED_BLOG','likeRank');
MATCH (source:Blog) RETURN source.name, source.likeRank ORDER BY source.likeRank desc LIMIT 25;

CYPHER CALL pagerank.calculate('Blog','REBLOGGED_COMMENT_OF','commentRank');
MATCH (source:Blog) RETURN source.name, source.commentRank ORDER BY source.commentRank desc LIMIT 25;

CYPHER CALL pagerank.calculate('Blog','REBLOGGED_THREAD_OF','threadRank');
MATCH (source:Blog) RETURN source.name, source.threadRank ORDER BY source.threadRank desc LIMIT 25;
