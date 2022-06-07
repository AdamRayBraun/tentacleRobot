// Adapted from Daniel Shiffman's BlobTracking
// https://github.com/CodingTrain/website/tree/main/Tutorials/Processing/11_video/sketch_11_10_BlobTracking_lifespan

ArrayList<Blob> blobs = new ArrayList<Blob>();

int blobCounter = 0;
int maxLife = 30;
color trackColor;
float threshold = 10;
float distThreshold = 2;
int minBlobSize = 7500;

void setupBlobDetection(){
  trackColor = color(255);
  blobCanvas = createGraphics(kinectDepthW, kinectDepthH, P3D);
}

void detectBlobs(){
  blobCanvas.beginDraw();
  blobCanvas.clear();
  blobCanvas.endDraw();

  ArrayList<Blob> currentBlobs = new ArrayList<Blob>();

  kinectCanvas.loadPixels();

  // Begin loop to walk through every pixel
  for (int x = 0; x < kinectDepthW; x++){
    for (int y = 0; y < kinectDepthH; y++){
      int loc = x + y * kinectCanvas.width;

      color currentColour = kinectCanvas.pixels[loc];
      float colourDiff = distSq(red(currentColour),
                                green(currentColour),
                                blue(currentColour),
                                red(trackColor),
                                green(trackColor),
                                blue(trackColor)
                               );

      if (colourDiff < threshold) {
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
    if (currentBlobs.get(i).size() < minBlobSize) {
      currentBlobs.remove(i);
    }
  }

  // There are no blobs!
  if (blobs.isEmpty() && currentBlobs.size() > 0) {
    for (Blob b : currentBlobs) {
      b.id = blobCounter;
      blobs.add(b);
      blobCounter++;
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
        b.id = blobCounter;
        blobs.add(b);
        blobCounter++;
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

void drawBlobs(){
  for (Blob b : blobs){
    b.show();
  }
}

float distSq(float x1, float y1, float x2, float y2) {
  return (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);
}

float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  return (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) + (z2 - z1) * (z2 - z1);
}
