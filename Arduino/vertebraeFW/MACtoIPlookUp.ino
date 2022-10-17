/*
"50:24", "1"
"40:A0", "2"
"46:FC", "3"
"41:50", "4"
"47:18", "5"
"4C:B8", "6"
"43:2C", "7"
"50:C0", "8"
"50:3C", "9"
"3A:04", "10"
"50:54", "11"
"3C:34", "12"
"35:DC", "13"
"32:64", "14"
"4F:A8", "15"
"41:0C", "16"
"48:BC", "17"
"31:EC", "18"
"44:70", "19"
"50:08", "20"
"31:DC", "21"
"3F:60", "22"
"36:94", "23"
"50:B8", "24"
"34:64", "25"

*/

int id;

const String MACtoID[25] = {
                             "50:24",
                             "40:A0",
                             "46:FC",
                             "41:50",
                             "47:18",
                             "4C:B8",
                             "43:2C",
                             "50:C0",
                             "50:3C",
                             "3A:04",
                             "50:54",
                             "3C:34",
                             "35:DC",
                             "32:64",
                             "4F:A8",
                             "41:0C",
                             "48:BC",
                             "31:EC",
                             "44:70",
                             "50:08",
                             "31:DC",
                             "3F:60",
                             "36:94",
                             "50:B8",
                             "34:64"
                           };

int getIDfromMac()
{
  String uniqueMACending = WiFi.macAddress().substring(12, 17);

  for (int i = 0; i < 25; i++){
    if (uniqueMACending.equals(MACtoID[i])){
      id = i + 1;
      return id;
    }
  }

  Serial.print("ERR: MAC not found in look up: ");
  Serial.println(WiFi.macAddress());
  return -1;
}
