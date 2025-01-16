import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:graphview/HouseholdView.dart';

class GenerationView extends StatelessWidget {
  const GenerationView(
      {required this.nodes,
      required this.builder,
      required this.graph,
      required this.algorithm,
      required this.houseHoldSeparation,
      required this.siblingSeparation,
      required this.renderer,
      required this.edgePaint,
      Key? key})
      : super(key: key);

  final List<Node> nodes;
  final Graph graph;
  final Algorithm algorithm;
  final NodeWidgetBuilder builder;
  final double houseHoldSeparation;
  final double siblingSeparation;
  final EdgeRenderer renderer;
  final Paint edgePaint;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: nodes
          .mapIndexed((i, node) => node is HouseholdNode
              ? HouseholdView(
                  husband: node.husband,
                  wife: node.wife,
                  builder: builder,
                  graph: graph,
                  algorithm: algorithm,
                  edgePaint: edgePaint,
                  houseHoldSeparation: houseHoldSeparation,
                )
              : builder(node))
          .toList(),
    );
  }
}
