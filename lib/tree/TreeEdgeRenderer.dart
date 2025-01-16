part of graphview;

class TreeEdgeRenderer extends EdgeRenderer {
  BuchheimWalkerConfiguration configuration;

  TreeEdgeRenderer(this.configuration);

  var linePath = Path();

  @override
  void render(Canvas canvas, Graph graph, Paint paint) {
    var levelSeparationHalf = configuration.levelSeparation / 2;

    for (final generation in graph.generations) {
      var nextGeneration = graph.getNextGeneration(generation);
      if (nextGeneration == null) {
        break;
      }

      var edges = graph.getEdgesBetween(generation, nextGeneration);

      for (final edge in edges) {
        var edgePaint = (edge.paint ?? paint)..style = PaintingStyle.stroke;

        final descendant = edge.relativeDescendant;
        linePath.reset();
        switch (configuration.orientation) {
          case BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM:
            // position at the middle-top of the descendant
            linePath.moveTo(
                (descendant.x + descendant.width / 2), descendant.y);
            // draws a line from the descendant's middle-top halfway up to its parent
            linePath.lineTo(descendant.x + descendant.width / 2,
                descendant.y - levelSeparationHalf);
            // draws a line from the previous point to the middle of the parents width
            linePath.lineTo(generation.x + generation.width / 2,
                descendant.y - levelSeparationHalf);

            // position at the middle of the level separation under the parent
            linePath.moveTo(generation.x + generation.width / 2,
                descendant.y - levelSeparationHalf);
            // draws a line up to the parents middle
            linePath.lineTo(generation.x + generation.width / 2,
                generation.height + (generation.height / 2));

            break;
        }

        canvas.drawPath(linePath, edgePaint);
      }
    }
  }

  @override
  void renderHouseHoldEdge(
      Canvas canvas, Node husband, Node wife, Paint paint) {
    final startOfTheLine = Offset(husband.x + husband.width, husband.height);
    final endOfTheLine = Offset(wife.x, wife.height);

    canvas.drawLine(startOfTheLine, endOfTheLine, paint);
  }
}
