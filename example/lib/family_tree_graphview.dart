import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

class FamilyTreeViewPage extends StatefulWidget {
  @override
  _FamilyTreeViewPageState createState() => _FamilyTreeViewPageState();
}

class _FamilyTreeViewPageState extends State<FamilyTreeViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Wrap(
              children: [
                Container(
                  width: 100,
                  child: TextFormField(
                    initialValue: configuration.siblingSeparation.toString(),
                    decoration:
                        InputDecoration(labelText: 'Sibling Separation'),
                    onChanged: (text) {
                      configuration.siblingSeparation =
                          int.tryParse(text) ?? 100;
                      this.setState(() {});
                    },
                  ),
                ),
                Container(
                  width: 100,
                  child: TextFormField(
                    initialValue: configuration.levelSeparation.toString(),
                    decoration: InputDecoration(labelText: 'Level Separation'),
                    onChanged: (text) {
                      configuration.levelSeparation = int.tryParse(text) ?? 100;
                      this.setState(() {});
                    },
                  ),
                ),
                Container(
                  width: 100,
                  child: TextFormField(
                    initialValue: configuration.subtreeSeparation.toString(),
                    decoration:
                        InputDecoration(labelText: 'Subtree separation'),
                    onChanged: (text) {
                      configuration.subtreeSeparation =
                          int.tryParse(text) ?? 100;
                      this.setState(() {});
                    },
                  ),
                ),
                Container(
                  width: 100,
                  child: TextFormField(
                    initialValue: configuration.orientation.toString(),
                    decoration: InputDecoration(labelText: 'Orientation'),
                    onChanged: (text) {
                      configuration.orientation = int.tryParse(text) ?? 100;
                      this.setState(() {});
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Make this great again
                    // final node12 = Node.Id(r.nextInt(100));
                    // var edge =
                    //     graph.getNodeAtPosition(r.nextInt(graph.nodeCount()));
                    // print(edge);
                    // graph.addEdge(edge, node12);
                    setState(() {});
                  },
                  child: Text('Add'),
                )
              ],
            ),
            Expanded(
              child: InteractiveViewer(
                  alignment: Alignment.center,
                  constrained: false,
                  boundaryMargin: EdgeInsets.all(100),
                  minScale: 0.01,
                  maxScale: 5.6,
                  child: GraphView(
                    graph: graph,
                    configuration: configuration,
                    paint: Paint()
                      ..color = Colors.green
                      ..strokeWidth = 1
                      ..style = PaintingStyle.stroke,
                    builder: (Node node) {
                      // I can decide what widget should be shown here based on the id
                      return rectangleWidget(node);
                    },
                  )),
            ),
          ],
        ));
  }

  Random r = Random();

  Widget rectangleWidget(Node node) {
    final a = node.key.value as int?;
    final nodeType = node.runtimeType.toString();

    return InkWell(
      onTap: () {
        print('clicked');
      },
      child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text('${nodeType} ${a}')),
    );
    // return CircleAvatar(
    //   radius: 10,
    //   backgroundColor: Colors.green,
    // );
  }

  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration configuration = BuchheimWalkerConfiguration();

  @override
  void initState() {
    final husband1 = Node.Id(1);
    final wife1 = Node.Id(2);
    final houseHold1 = HouseholdNode.Id(3, husband1, wife1);
    final child1a = Node.Id(4);
    final child1b = Node.Id(5);
    final child1c = Node.Id(6);
    graph.addEdge(houseHold1, child1a);
    graph.addEdge(houseHold1, child1b);
    graph.addEdge(houseHold1, child1c);

    configuration
      ..siblingSeparation = (100)
      ..levelSeparation = (150)
      ..subtreeSeparation = (150)
      ..houseHoldSeparation = (200)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);

    super.initState();
  }
}
