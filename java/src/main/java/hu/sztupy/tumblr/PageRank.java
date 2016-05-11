package hu.sztupy.tumblr;

import org.neo4j.graphdb.*;
import org.neo4j.helpers.collection.Iterables;
import org.neo4j.logging.Log;
import org.neo4j.procedure.Context;
import org.neo4j.procedure.Name;
import org.neo4j.procedure.PerformsWrites;
import org.neo4j.procedure.Procedure;

public class PageRank
{
    static double PAGE_RANK_DAMPING = 0.15;

    @Context
    public GraphDatabaseService db;

    @Context
    public Log log;

    /***
     * Performs one iteration of the pageRank algorithm.
     *
     * @param nodeLabel The label for which the algorithm needs to be calcualted
     * @param relationship The relationship to use to check if the nodes are related or not
     * @param property The property to update with the new pagerank
     */
    @Procedure("pagerank.calculate")
    @PerformsWrites
    public void calculate( @Name("nodeLabel") String nodeLabel,
                           @Name("relationship") String relationship,
                           @Name("property") String property )
    {
        Label label = Label.label(nodeLabel);
        RelationshipType relationshipType = RelationshipType.withName(relationship);

        try (ResourceIterator<Node> nodes = db.findNodes(label)) {
            while (nodes.hasNext()) {
                Node destination = nodes.next();

                Iterable<Relationship> relationships = destination.getRelationships(Direction.INCOMING, relationshipType);

                double points = 0;

                for (Relationship r : relationships) {
                    Node source = r.getStartNode();
                    if (!source.hasLabel(label)) {
                        continue;
                    }
                    if (source.equals(destination)) {
                        continue;
                    }

                    // TODO: this will calculate relations which hav an outgoing link to a node that doesn't have the
                    //       needed label as well, but checking this might make the code less performant
                    //       it will also calculate relations which go back to the original node, which also skews the result
                    long sourceRelationshipCount = Iterables.count(source.getRelationships(Direction.OUTGOING, relationshipType));

                    if (source.hasProperty(property) && source.getProperty(property) instanceof Double) {
                        points += (Double)source.getProperty(property) / sourceRelationshipCount;
                    }
                }

                destination.setProperty(property, PAGE_RANK_DAMPING + (1-PAGE_RANK_DAMPING)*points);
            }
        }
    }

    @Procedure("pagerank.calculateMultiple")
    @PerformsWrites
    public void calculateMultiple( @Name("nodeLabel") String nodeLabel,
                                   @Name("relationship") String relationship,
                                   @Name("property") String property,
                                   @Name("iterations") Long iterations)
    {
        for (long i = 0; i < iterations; i++) {
            try (Transaction transaction = db.beginTx()) {
                calculate(nodeLabel, relationship, property);
                transaction.success();
            }
        }
    }
}
