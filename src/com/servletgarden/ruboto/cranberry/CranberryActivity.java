package com.servletgarden.ruboto.cranberry;

public class CranberryActivity extends org.ruboto.RubotoActivity {
	public void onCreate(android.os.Bundle arg0) {
    try {
      setSplash(Class.forName("com.servletgarden.ruboto.cranberry.R$layout").getField("splash").getInt(null));
    } catch (Exception e) {}

    setScriptName("cranberry_activity.rb");
    super.onCreate(arg0);
  }
}
