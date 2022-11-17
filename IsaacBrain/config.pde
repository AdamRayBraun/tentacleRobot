JSONObject config, motorConfig, PCBConfig, puppetConfig;

boolean KINECT_EN, MOTORS_EN, PCBS_EN, PUPPET_EN;

void loadConfig(){
  config = loadJSONObject("config.json");

  motorConfig  = config.getJSONObject("Motors");
  PCBConfig    = config.getJSONObject("PCBs");
  puppetConfig = config.getJSONObject("Puppet");

  KINECT_EN = config.getBoolean("KINECT_ENABLED");
  MOTORS_EN = motorConfig.getBoolean("MOTORS_ENABLED");
  PCBS_EN   = PCBConfig.getBoolean("PCBS_ENABLEDD");
  PUPPET_EN = puppetConfig.getBoolean("PUPPET_ENABLED");
}
