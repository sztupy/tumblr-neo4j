package hu.sztupy.tumblr;

import org.junit.Rule;
import org.junit.Test;
import org.neo4j.driver.v1.*;
import org.neo4j.driver.v1.types.Node;
import org.neo4j.harness.junit.Neo4jRule;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.core.IsEqual.equalTo;
import static org.hamcrest.number.IsCloseTo.closeTo;

public class PageRankTest
{
    @Rule
    public Neo4jRule neo4j = new Neo4jRule()
            .withProcedure( PageRank.class );

    @Test
    public void shouldCalculateOneIterationProperly() throws Throwable
    {
        // In a try-block, to make sure we close the driver after the test
        try( Driver driver = GraphDatabase.driver( neo4j.boltURI() , Config.build().withEncryptionLevel( Config.EncryptionLevel.NONE ).toConfig() ) )
        {
            // Given I've started Neo4j with the PageRank procedure class
            //       which my 'neo4j' rule above does.
            try (Session session = driver.session()) {

                // And I have some nodes in the database
                generateSimpleNodes(session);

                // When I use the pageRank procedure to calculate the pageRank
                session.run("CALL pagerank.calculate('Blog','LINK','pageRank')");

                // Then I have initial results saved against the appropriate properties

                List<Double> pageRankValues = getPageRankValues(session);

                assertThat(pageRankValues.size(), equalTo(2));
                assertThat(pageRankValues.get(0), closeTo(0.15, 0.01));
                assertThat(pageRankValues.get(1), closeTo(0.277, 0.01));
            }
        }
    }

    @Test
    public void shouldCalculateMultipleIterationProperly() throws Throwable
    {
        // In a try-block, to make sure we close the driver after the test
        try( Driver driver = GraphDatabase.driver( neo4j.boltURI() , Config.build().withEncryptionLevel( Config.EncryptionLevel.NONE ).toConfig() ) )
        {
            // Given I've started Neo4j with the PageRank procedure class
            //       which my 'neo4j' rule above does.
            try (Session session = driver.session()) {

                // And I have some nodes in the database
                generateSimpleNodes(session);

                // When I use the pageRank procedure to calculate the pageRank multiple times
                session.run("CALL pagerank.calculateMultiple('Blog','LINK','pageRank', 100)");

                // Then I have the final approximate results saved against the appropriate properties
                List<Double> pageRankValues = getPageRankValues(session);

                assertThat(pageRankValues.size(), equalTo(2));
                assertThat(pageRankValues.get(0), closeTo(1, 0.01));
                assertThat(pageRankValues.get(1), closeTo(1, 0.01));
            }
        }
    }

    @Test
    public void shouldOnlyCheckNodesAndRelationsWhichAreSet() throws Throwable
    {
        // In a try-block, to make sure we close the driver after the test
        try( Driver driver = GraphDatabase.driver( neo4j.boltURI() , Config.build().withEncryptionLevel( Config.EncryptionLevel.NONE ).toConfig() ) )
        {
            // Given I've started Neo4j with the PageRank procedure class
            //       which my 'neo4j' rule above does.
            try (Session session = driver.session()) {

                // And I have some nodes in the database
                generateSimpleNodes(session);
                session.run("CREATE (:Blog{id:3});");

                session.run("CREATE (:Brag{id:4});");
                session.run("CREATE (:Brag{id:5});");

                session.run("MATCH (a:Blog{id:3}),(b:Blog{id:1}) MERGE (a)-[:ANCHOR]->(b);");
                session.run("MATCH (a:Blog{id:3}),(b:Blog{id:2}) MERGE (a)-[:ANCHOR]->(b);");

                session.run("MATCH (a:Brag{id:4}),(b:Brag{id:5}) MERGE (a)-[:LINK]->(b);");

                session.run("MATCH (a:Brag{id:4}),(b:Blog{id:1}) MERGE (a)-[:LINK]->(b);");
                // see TODO in PageRank
                // session.run( "MATCH (a:Blog{id:1}),(b:Brag{id:4}) MERGE (a)-[:LINK]->(b);");

                // When I use the pageRank procedure to calculate the pageRank multiple times
                session.run("CALL pagerank.calculateMultiple('Blog','LINK','pageRank', 100)");

                // Then I have the final approximate results saved against the appropriate properties
                List<Double> pageRankValues = getPageRankValues(session);

                assertThat(pageRankValues.size(), equalTo(3));
                assertThat(pageRankValues.get(0), closeTo(0.15, 0.01));
                assertThat(pageRankValues.get(1), closeTo(1, 0.01));
                assertThat(pageRankValues.get(2), closeTo(1, 0.01));
            }
        }
    }

    @Test
    public void shouldCalculatePageRankForMoreComplexScenario() throws Throwable
    {
        // In a try-block, to make sure we close the driver after the test
        try( Driver driver = GraphDatabase.driver( neo4j.boltURI() , Config.build().withEncryptionLevel( Config.EncryptionLevel.NONE ).toConfig() ) )
        {
            // Given I've started Neo4j with the PageRank procedure class
            //       which my 'neo4j' rule above does.
            try (Session session = driver.session()) {

                // And I have some nodes in the database - See Example #1 in http://www.cs.princeton.edu/~chazelle/courses/BIB/pagerank.htm
                session.run( "CREATE (:Blog{id:1});");
                session.run( "CREATE (:Blog{id:2});");
                session.run( "CREATE (:Blog{id:3});");
                session.run( "CREATE (:Blog{id:4});");

                session.run( "MATCH (a:Blog{id:1}),(b:Blog{id:2}) MERGE (a)-[:LINK]->(b);");
                session.run( "MATCH (a:Blog{id:2}),(b:Blog{id:3}) MERGE (a)-[:LINK]->(b);");
                session.run( "MATCH (a:Blog{id:3}),(b:Blog{id:1}) MERGE (a)-[:LINK]->(b);");
                session.run( "MATCH (a:Blog{id:1}),(b:Blog{id:3}) MERGE (a)-[:LINK]->(b);");
                session.run( "MATCH (a:Blog{id:4}),(b:Blog{id:3}) MERGE (a)-[:LINK]->(b);");

                // When I use the pageRank procedure to calculate the pageRank multiple times
                session.run( "CALL pagerank.calculateMultiple('Blog','LINK','pageRank', 100)" );

                // Then I have the final approximate results saved against the appropriate properties
                List<Double> pageRankValues = getPageRankValues(session);

                assertThat( pageRankValues.size(), equalTo(4) );
                assertThat( pageRankValues.get(0), closeTo(0.15, 0.01) );
                assertThat( pageRankValues.get(1), closeTo(0.78, 0.01) );
                assertThat( pageRankValues.get(2), closeTo(1.49, 0.01) );
                assertThat( pageRankValues.get(3), closeTo(1.58, 0.01) );
            }
        }
    }

    private void generateSimpleNodes(Session session) {
        session.run( "CREATE (:Blog{id:1});");
        session.run( "CREATE (:Blog{id:2});");

        session.run( "MATCH (a:Blog{id:1}),(b:Blog{id:2}) MERGE (a)-[:LINK]->(b);");
        session.run( "MATCH (a:Blog{id:2}),(b:Blog{id:1}) MERGE (a)-[:LINK]->(b);");
    }

    private List<Double> getPageRankValues(Session session) {
        List<Double> pageRankValues = new ArrayList<>();
        StatementResult result = session.run( "MATCH (n:Blog) RETURN n;" );
        while (result.hasNext()) {
            Record record = result.next();
            Node node = record.get("n").asNode();
            pageRankValues.add(node.get("pageRank").asDouble());
        }
        Collections.sort(pageRankValues);
        return pageRankValues;
    }
}
