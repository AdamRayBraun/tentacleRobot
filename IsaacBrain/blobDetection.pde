BlobDetector blobDetector;

void setupBlobDetection(){
  blobDetector = new BlobDetector();
}

void runBlobDetection(){
  presenceSensor.run();
  blobDetector.processBlobs();
}

class BlobDetector {
  public ArrayList<Blob> blobs = new ArrayList<Blob>();
  private PGraphics blobCanvas;
  private final int trackColor = 255;
  private int blobCounter;
  private int threshold = 10;
  private int minBlobSize = 3300;

  BlobDetector(){
    blobCanvas = createGraphics(kinectDepthW, kinectDepthH, P3D);
  }

  void processBlobs(){
    blobCanvas.beginDraw();
    blobCanvas.clear();
    blobCanvas.endDraw();

    ArrayList<Blob> currentBlobs = new ArrayList<Blob>();

    presenceSensor.depthSlice.loadPixels();

    // Begin loop to walk through every pixel
    for (int x = 0; x < kinectDepthW; x++){
      for (int y = 0; y < kinectDepthH; y++){
        int loc = x + y * kinectDepthW;

        color currentColour = presenceSensor.depthSlice.pixels[loc];
        float colourDiff = this.distSq(red(currentColour),
                                  green(currentColour),
                                  blue(currentColour),
                                  red(this.trackColor),
                                  green(this.trackColor),
                                  blue(this.trackColor)
                                 );

        if (colourDiff < this.threshold) {
          boolean found = false;
          for (Blob b : currentBlobs) {
            if (b.isNear(x, y)) {
              b.add(x, y);
              found = true;
              break;
            }
          }

          if (!found) {
            Blob b = new Blob(x, y);
            currentBlobs.add(b);
          }
        }
      }
    }

    for (int i = currentBlobs.size() - 1; i >= 0; i--) {
      if (currentBlobs.get(i).size() < this.minBlobSize) {
        currentBlobs.remove(i);
      }
    }

    // There are no blobs!
    if (blobs.isEmpty() && currentBlobs.size() > 0) {
      for (Blob b : currentBlobs) {
        b.id = this.blobCounter;
        blobs.add(b);
        this.blobCounter++;
      }
    } else if (blobs.size() <= currentBlobs.size()) {
      // Match whatever blobs you can match
      for (Blob b : blobs) {
        float recordD = 1000;
        Blob matched = null;
        for (Blob cb : currentBlobs) {
          PVector centerB = b.getCenter();
          PVector centerCB = cb.getCenter();
          float d = PVector.dist(centerB, centerCB);
          if (d < recordD && !cb.taken) {
            recordD = d;
            matched = cb;
          }
        }
        matched.taken = true;
        b.become(matched);
      }

      // Whatever is leftover make new blobs
      for (Blob b : currentBlobs) {
        if (!b.taken) {
          b.id = this.blobCounter;
          blobs.add(b);
          this.blobCounter++;
        }
      }
    } else if (blobs.size() > currentBlobs.size()) {
      for (Blob b : blobs) {
        b.taken = false;
      }

      // Match whatever blobs you can match
      for (Blob cb : currentBlobs) {
        float recordD = 1000;
        Blob matched = null;
        for (Blob b : blobs) {
          PVector centerB = b.getCenter();
          PVector centerCB = cb.getCenter();
          float d = PVector.dist(centerB, centerCB);
          if (d < recordD && !b.taken) {
            recordD = d;
            matched = b;
          }
        }
        if (matched != null) {
          matched.taken = true;
          matched.become(cb);
        }
      }

      for (int i = blobs.size() - 1; i >= 0; i--) {
        Blob b = blobs.get(i);
        if (!b.taken) {
          if (b.checkLife()) blobs.remove(i);
        }
      }
    }
  }

  float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
    return (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) + (z2 - z1) * (z2 - z1);
  }
}
