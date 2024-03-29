// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain

class Blob {
  float minx;
  float miny;
  float maxx;
  float maxy;
  int maxLife = 30;
  int id = 0;
  float distThreshold = 2;

  int lifespan = maxLife;

  boolean taken = false;

  Blob(float x, float y) {
    minx = x;
    miny = y;
    maxx = x;
    maxy = y;
  }

  boolean checkLife() {
    lifespan--;
    if (lifespan < 0) {
      return true;
    } else {
      return false;
    }
  }

  void show() {
    blobDetector.blobCanvas.beginDraw();
    blobDetector.blobCanvas.stroke(0, 0, 255);
    blobDetector.blobCanvas.strokeWeight(6);
    blobDetector.blobCanvas.noFill();
    blobDetector.blobCanvas.rectMode(CORNERS);
    blobDetector.blobCanvas.rect(minx, miny, maxx, maxy);
    blobDetector.blobCanvas.fill(0, 255, 0);
    blobDetector.blobCanvas.textSize(20);
    blobDetector.blobCanvas.text((maxx - minx) * 0.5 + minx + ", " + (maxy - miny) * 0.5 + miny, minx - 20, miny - 20);
    blobDetector.blobCanvas.endDraw();
  }

  void add(float x, float y) {
    minx = min(minx, x);
    miny = min(miny, y);
    maxx = max(maxx, x);
    maxy = max(maxy, y);
  }

  void become(Blob other) {
    minx = other.minx;
    maxx = other.maxx;
    miny = other.miny;
    maxy = other.maxy;
    lifespan = maxLife;
  }

  float size() {
    return (maxx - minx) * (maxy - miny);
  }

  PVector getCenter() {
    float x = (maxx - minx) * 0.5 + minx;
    float y = (maxy - miny) * 0.5 + miny;
    return new PVector(x, y);
  }

  boolean isNear(float x, float y) {
    float centerX = max(min(x, maxx), minx);
    float centerY = max(min(y, maxy), miny);
    float d = distSq(centerX, centerY, x, y);

    if (d < distThreshold * distThreshold) {
      return true;
    } else {
      return false;
    }
  }

  float distSq(float x1, float y1, float x2, float y2) {
    return (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);
  }
}
