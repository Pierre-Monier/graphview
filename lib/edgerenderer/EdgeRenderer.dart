part of graphview;

abstract class EdgeRenderer {
  void render(Canvas canvas, Graph graph, Paint paint);
  void renderHouseHoldEdge(
    Canvas canvas,
    Node husband,
    Node wife,
    double householdSeparation,
    Paint paint,
  );
}
