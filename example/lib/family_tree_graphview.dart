import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

class FamilyTreeViewPage extends StatefulWidget {
  @override
  _FamilyTreeViewPageState createState() => _FamilyTreeViewPageState();
}

class _FamilyTreeViewPageState extends State<FamilyTreeViewPage> {
  final Graph graph = Graph();
  BuchheimWalkerConfiguration configuration = BuchheimWalkerConfiguration();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: GraphView(
            nodeSize: Size(50, 50),
            graph: graph,
            configuration: configuration,
            paint: Paint()
              ..color = Colors.green
              ..strokeWidth = 1
              ..style = PaintingStyle.stroke,
            builder: (Node node) {
              return rectangleWidget(node);
            },
          ),
        ));
  }

  Random r = Random();

  Widget rectangleWidget(Node node) {
    return InkWell(
      onTap: () {
        graph.setEdges(_renderThreeGenerationFamily(r.nextInt(50)));
      },
      child: CircleAvatar(
        radius: 40,
        backgroundColor: node.isARelativeDescendant ? Colors.green : Colors.red,
        child: Text(node.key.value.toString()),
      ),
    );
  }

  @override
  void initState() {
    graph.setEdges(_renderThreeGenerationFamily(0));

    configuration
      ..siblingSeparation = (100)
      ..levelSeparation = (150)
      ..subtreeSeparation = (150)
      ..houseHoldSeparation = (50)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);

    super.initState();
  }

  List<Edge> _renderThreeGenerationFamily(int initialId) {
    var i = initialId;
    final husband1 = Node.Id(i);
    i++;

    final wife1 = Node.Id(i);
    i++;

    final houseHold1 = HouseholdNode.Id(i, husband1, wife1);
    i++;

    final generationA = GenerationNode.Id(i, [
      houseHold1,
    ]);
    i++;

    final child1a = Node.Id(i);
    i++;

    final child1b = Node.Id(i);
    i++;

    final child1c = Node.Id(i);
    i++;

    final child1cWife = Node.Id(i);
    i++;

    final child1aWife = Node.Id(i);
    i++;

    final child1aHouseHold = HouseholdNode.Id(i, child1a, child1aWife);
    i++;

    final child1cHouseHold = HouseholdNode.Id(i, child1c, child1cWife);
    i++;

    final generationB = GenerationNode.Id(i, [
      child1aHouseHold,
      child1b,
      child1cHouseHold,
    ]);
    i++;

    final child2a = Node.Id(i);
    i++;

    final child2b = Node.Id(i);
    i++;

    final child2c = Node.Id(i);
    i++;

    final generationC = GenerationNode.Id(i, [
      child2a,
      child2b,
      child2c,
    ]);
    i++;

    final child3a = Node.Id(i);
    i++;

    final generationD = GenerationNode.Id(i, [child3a]);
    i++;

    return [
      Edge(
        ancestors: generationA,
        descendants: generationB,
        relativeAncestor: houseHold1,
        relativeDescendant: child1a,
      ),
      Edge(
        ancestors: generationA,
        descendants: generationB,
        relativeAncestor: houseHold1,
        relativeDescendant: child1b,
      ),
      Edge(
        ancestors: generationA,
        descendants: generationB,
        relativeAncestor: houseHold1,
        relativeDescendant: child1c,
      ),
      Edge(
        ancestors: generationB,
        descendants: generationC,
        relativeAncestor: child1cHouseHold,
        relativeDescendant: child2a,
      ),
      Edge(
        ancestors: generationB,
        descendants: generationC,
        relativeAncestor: child1cHouseHold,
        relativeDescendant: child2b,
      ),
      Edge(
        ancestors: generationB,
        descendants: generationC,
        relativeAncestor: child1cHouseHold,
        relativeDescendant: child2c,
      ),
      Edge(
        ancestors: generationB,
        descendants: generationD,
        relativeAncestor: child1aHouseHold,
        relativeDescendant: child3a,
      ),
    ];
  }
}
