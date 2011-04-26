# Cranberry - Attempt to get Nokogiri work on Android

## Conclusion

As a result, Nokogiri was loaded on Android successfully but didn't work on it. When I tried to parse XML document, I got tons of errors something like:
<pre>
W/dalvikvm(  374): Unable to resolve superclass of Lorg/apache/xerces/dom/DeferredDocumentImpl; (2008)
W/dalvikvm(  374): Link of class 'Lorg/apache/xerces/dom/DeferredDocumentImpl;' failed
</pre>
I'm pretty sure this sort of error messages complain there aren't enough interefaces of org.w3c packages defined in Android SDK. Actucally, Android SDK's org.w3c package is a subset of JDK's. This is the problem. Pure Java Nokogiri needs a fullset of org.w3c API since Nokogiri heavily relies on Xerces, nekoHTML and nekoDTD to keep compatibility with libxml2 backed, CRuby version. Xerces needs the fullset of org.w3c API to work. This is why Nokogiri ended up raising an exception as in below:
<pre>
W/dalvikvm(  374): threadid=10: thread exiting with uncaught exception (group=0x40014760)
E/AndroidRuntime(  374): FATAL EXCEPTION: runWithLargeStack
E/AndroidRuntime(  374): java.lang.NoClassDefFoundError: org.apache.xerces.dom.DeferredDocumentImpl
E/AndroidRuntime(  374): 	at org.apache.xerces.parsers.AbstractDOMParser.startDocument(Unknown Source)
E/AndroidRuntime(  374): 	at org.apache.xerces.impl.dtd.XMLDTDValidator.startDocument(Unknown Source)
(snip)
</pre>


Is this avoidable? Might be. Googling led me some discussions about replacing org.w3c and other packages. If I can include Xerces' xml-apis.jar (defines org.w3c/org.w3c.xxx, javax.xml.xxx, org.xml.xxx) in my Android app and override core package, Nokogiri will start working exactly the same as a web app on Rails. But, it should not be a good workaround. Surgery on SDK might incur other applications that use replaced packages.


Probably, the best answer will create a subset of Nokogiri for Android. I'm not sure such limited version of Nokogiri still attracts users. But, I think it's better than nothing.



## Thoughts on Ruboto and Android

Although my small Nokogiri app didn't work, I'm going to write about what I learned and did. This might help some poeple who want to make Ruby gems to work. 



### JDK should be 1.6.0_24 on OS X

Ruboto people might not develop JRuby on Rails on Google App Engine, but I do. Just before I tried Ruboto, I had to downgrade JDK version for Google App Engine gem. So, when I started, my JDK was 1.6.0_22. I spent pretty much time to figure out why ruboto didn't work on my PC at all. Once the JDK got back to the latest, ruboto worked like a magic. Make sure what version of JDK you are using.



### Android API level should be 11

Not all Ruboto samples needs level 11 API. For example, samples of https://www.ibm.com/developerworks/web/library/wa-ruby/ worked on level 8. But, Nokogiri needs level 11. I'm not sure the reason, but, the activerecord (and jdbc) sample, https://github.com/ruboto/ruboto-core/wiki/Tutorial%3A-Using-an-SQLite-database-with-ActiveRecord-and-RubyGems, was also tested on level 11, which is Java backed rubygems like Nokogiri.



### Jar archives should be moved to project's libs directory

This happens on an environmrnt that uses custom cloaderloader, for example, Google App Engine. So, I have all jars in my project's libs directory, https://github.com/yokolet/cranberry/tree/master/libs, so that custom classloader can load all jars. If those jars failed to be loaded, Nokogiri raises a mysterious, "undefined method `next_sibling' for class `Nokogiri::XML::Node'," error. I didn't get that error, so jars should be loaded.

Also, I commented line 18-24 out from nokogiri.rb (https://github.com/yokolet/cranberry/blob/master/assets/vendor/gems/1.8/gems/nokogiri-1.5.0.beta.4-java/lib/nokogiri.rb) so that Nokogiri doesn't try to load those jars again.



### Configuration and setup are key to load gems

Loading gems on Ruboto was trickey. In the article, https://www.ibm.com/developerworks/web/library/wa-ruby/, the author rearranged all ruby files into single directory. This might work for small rubygems but never does for Nokogiri. For example, Nokogiri has nokogiri/html/document.rb and nokogiri/xml/document.rb. Instead, the way described in https://github.com/ruboto/ruboto-core/wiki/Tutorial%3A-Using-an-SQLite-database-with-ActiveRecord-and-RubyGems worked well. It looks complicated, but I realized that the thread based gem loading way was really necessary while I was trying other stuff. My config.rb is https://github.com/yokolet/cranberry/blob/master/assets/scripts/config.rb if you want look at it. Also, I edited src/irg/ruboto/Script.java (https://github.com/yokolet/cranberry/blob/master/src/org/ruboto/Script.java) and added "vendor" directory.

When I clicked on "Cranberry" Ruboto icon right after "rake install" said "Success," all Nokogiri files were copied to /data/data/.... directory. To cut down the time for copying, I deleted Nokogiri's test and ext directories, which are unnecessary to run Nokogiri.



### Needs threads to become a nifty app

Android expects develpers' "responsiveness" (http://developer.android.com/guide/practices/design/responsiveness.html). Accroding the document, database or network accesse should not be performed on a main thread. In my Nokogiri sample, I tried to get rss feed, on the main thread firstly, so I got the error:
<pre>
W/System.err(  343): org.jruby.exceptions.RaiseException: Native Exception: 'class android.os.NetworkOnMainThreadException'; Message: null; StackTrace: android.os.NetworkOnMainThreadException
W/System.err(  343): 	at android.os.StrictMode$AndroidBlockGuardPolicy.onNetwork(StrictMode.java:1077)
W/System.err(  343): 	at java.net.InetAddress.lookupHostByName(InetAddress.java:481)
(snip)
</pre>
This is why config.rb uses threads to require rubygems.



### No need to reinstall app when scripts are updated

"rake update_scripts" updates Ruby scripts of installed app. So, you don't need reinstall the app. This was a great help for me since an installing process took many many minutes. 



### ... but, it doesn't work. What's going on ???

As an Android newbie, I very often fell into troubles to get Android SDK and the app to work. Sometimes, app icons didn't show up, or rake install failed. The troubleshooting, https://github.com/ruboto/ruboto-core/wiki/Troubleshooting, was so helpful. Especially, "adb kill-server; adb start-server" commands were the best. Also, I made a rule to type "ruby -v" before I started something. As you know, rake tasks start working on CRuby. But, those won't complete tasks as you expect.

I'd like to add "uninstall" the app to the troubleshooting. You can uninstall the app on emulator as well as adb uninstall command. On the emulator, do the long-click on the icon you want to uninstall. Then, trash bin and the word "uninstall" appears. Draggin the icon on trash bin will delete the app. Or adb uninstall [package name of app] will delete the app. For example, my app's package name is com.servletgarden.ruboto.cranberry, so "adb uninstall  com.servletgarden.ruboto.cranberry" deleted my app from emulator. In case you forget the package name, look at the path to XXXActivity.java file. That path corresponds to package layer.



#### How I made this app

In the end, I'm going to add how I made this app and how to start it. This app won't work, but for myself, to try this app in future again, I'll leave this memo.

1. install ruboto-core gem
   <pre>
   $ ruby -v    (double check I'm on JRuby)
   $ gem install ruboto-core
   </pre>

2. set path to android tools
   <pre>
   $ cd path/to/android-sdk-mac_x86
   $ PATH=`pwd`/tools:`pwd`/platform-tools:$PATH
   </pre>

3. create emulator image
   <pre>
   $ android -s create avd -f -n cranberry-11 -t android-11 
   </pre>
   This possibly creates it. Actually, I created my virtual image using Eclipse's ADT. It's way easy.
   Prior to useing android command, I intalled platforms. I also used Eclipse's ADT for that.

4. create ruboto app
   <pre>
   ruboto gen app --package com.servletgarden.ruboto.cranberry --target android-11 
   </pre>
   This generated cranberry directory and whole stuff under that.

5. add emulator task to Rakefile
   <pre>
   $ cd cranberry
   $ [edit Rakefile]
   (line 42-45 of https://github.com/yokolet/cranberry/blob/master/Rakefile)
   </pre>
   Since my virutal image name is cranberry-11 (step 3) "-avd cranberry-11" is there. If the app is small, you don't need -partiion-size option.


6. install nokogiri gem
   <pre>
   $ mkdir -p assets/vendor/gems/1.8
   $ gem install --install-dir assets/vendor/gems/1.8 nokogiri -v 1.5.0.beta.4 
   $ rm -rf assets/vendor/gems/1.8/cache
   $ rm -rf assets/vendor/gems/1.8/doc
   $ pushd assets/vendor/gems/1.8/gems/nokogiri-1.5.0.beta.4-java
   $ rm -rf ext test
   $ popd
   </pre>

7. add config.rb file, one line in assets/scripts/cranberry_activity.rb and edit Script.java
   https://github.com/yokolet/cranberry/blob/master/assets/scripts/config.rb
   line 2 of https://github.com/yokolet/cranberry/blob/master/assets/scripts/cranberry_activity.rb
   line 186-188 of https://github.com/yokolet/cranberry/blob/master/src/org/ruboto/Script.java

8. start emulator
   <pre>
   $ rake emulator
   </pre>
   The emulator took many minutes to boot up on my MacBook. Ocasionally, it showed up without dark blue hexagons. In such case, emulator didn't work correctly. I tried a couple of times "adb kill-server" and "adb start-server." When that attempt didn't work, I shut the emulator down and did "adb kill-server," then restarted the emulator.

9. start log monitor
   <pre>
   $ adb logcat
   </pre>
   This prints out verbose infos, errors, and others. It is a bit noisy, but a great help to figure out what's going on.

10. install app
   <pre>
   $ rake install
   </pre>
   Be patient.

10. click Cranberry ruboto icon
   Be patient again. JRuby needs long time to activate.
   Ruboto default app, Figure 4 of https://www.ibm.com/developerworks/web/library/wa-ruby/ will show up.

11. edit ruby files and do "rake update_scripts"
   Then, back to Apps view and clock ruboto icon. Updated version should work, or troubleshooting time starts.


Whew...!
