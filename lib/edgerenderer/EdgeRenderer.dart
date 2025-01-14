part of graphview;

abstract class EdgeRenderer {
  void render(Canvas canvas, Graph graph, Paint paint);
  void renderHouseHoldEdge(Canvas canvas, Size size, Paint paint);
}
