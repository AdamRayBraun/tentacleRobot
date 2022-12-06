#define EEPROM_ADDRESS 0

struct EEPFormat {
  int lastXpos;
  int lastYpos;
};

EEPFormat lastPositions = {
  0,
  0
};

void updateLastSavedPosition()
{
// THIS DEFFO CAUSES A DROP OUT BUG

  // lastPositions.lastXpos = bottomX.currentPosition();
  // lastPositions.lastYpos = bottomY.currentPosition();
  // EEPROM.put(EEPROM_ADDRESS, lastPositions);
}

void resetFromLastSavedPosition()
{
  // EEPROM.get(EEPROM_ADDRESS, lastPositions);
  //
  // bottomX.setCurrentPosition(lastPositions.lastXpos);
  // bottomY.setCurrentPosition(lastPositions.lastYpos);
}
