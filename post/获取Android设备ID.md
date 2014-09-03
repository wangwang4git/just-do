#### 获取Android设备ID

获取Android设备Unique ID，麻烦困难，原因是Google官方就不认可该行为。  
> This worries us, because we think that tracking such identifiers isn’t a good idea, and that there are better ways to achieve developers’ goals.
  
但是如果确实需要获取，可以结合如下方式。  
  
###### 1. Identifying Devices
```java
TelephonyManager tm = (TelephonyManager) this.getSystemService(Context.TELEPHONY_SERVICE);
String imei = tm.getDeviceId();
```
对于不同制式手机，返回不同格式ID，官方描述如下：  
  
<center>![alt text](../img/Android_UniqueId01.png "getDeviceId()")</center>
  
该方法存在问题：  
* 非手机设备：对于`wifi-only`、`music players`等设备，无`device id`；
* `刷机`、`恢复出厂值`会重置`device id`；
* 需要`权限`，`READ_PHONE_STATE`；
* `Bug`，少数手机返回垃圾信息，如`zeros`、`asterisks`。
  
###### 2. Mac Address
```java
WifiManager wifiManager = (WifiManager) this.getSystemService(Context.WIFI_SERVICE);
WifiInfo wifiInfo = wifiManager.getConnectionInfo();
String mac = wifiInfo.getMacAddress()；
```
返回`wifi`或者`bluetooth`硬件地址。  
  
该方法存在问题：  
* `无Wifi`设备；
* `Wifi`关闭，可能不返回；
* 需要`权限`，`ACCESS_WIFI_STATE`。
  
###### 3. Serial Number
```java
String serial = android.os.Build.SERIAL;
```
该方法存在问题：  
* Android 2.3+才可用。
  
###### 4. ANDROID_ID
```java
String androidId = Secure.getString(this.getBaseContext().getContentResolver(), Secure.ANDROID_ID);
```
Android设备第一次启动产生、存储的`64-bit`。  
  
该方法存在问题：  
* Android <= 2.1 / Android >= 2.3可靠、稳定，但在`2.2`并非100%可靠；
* 主流厂商的设备，`2.2`有一个bug，就是每个设备都会产生`相同ANDROID_ID`：9774d56d682e549c；
* `刷机`会重置。
  
###### 5. Tracking Installations
Google官方给出的框架，获取`installation ID`：  
```java
public class Installation {
    private static String sID = null;
    private static final String INSTALLATION = "INSTALLATION";

    public synchronized static String id(Context context) {
        if (sID == null) {  
            File installation = new File(context.getFilesDir(), INSTALLATION);
            try {
                if (!installation.exists())
                    writeInstallationFile(installation);
                sID = readInstallationFile(installation);
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }
        return sID;
    }

    private static String readInstallationFile(File installation) throws IOException {
        RandomAccessFile f = new RandomAccessFile(installation, "r");
        byte[] bytes = new byte[(int) f.length()];
        f.readFully(bytes);
        f.close();
        return new String(bytes);
    }

    private static void writeInstallationFile(File installation) throws IOException {
        FileOutputStream out = new FileOutputStream(installation);
        String id = UUID.randomUUID().toString();
        out.write(id.getBytes());
        out.close();
    }
}
```
  
###### 6. 网上给出的获取设备ID框架
```java
import android.content.Context;
import android.content.SharedPreferences;
import android.provider.Settings.Secure;
import android.telephony.TelephonyManager;

import java.io.UnsupportedEncodingException;
import java.util.UUID;

public class DeviceUuidFactory {
    protected static final String PREFS_FILE = "device_id.xml";
    protected static final String PREFS_DEVICE_ID = "device_id";

    protected static UUID uuid;

    public DeviceUuidFactory(Context context) {
        if( uuid ==null ) {
            synchronized (DeviceUuidFactory.class) {
                if( uuid == null) {
                    final SharedPreferences prefs = context.getSharedPreferences( PREFS_FILE, 0);
                    final String id = prefs.getString(PREFS_DEVICE_ID, null );

                    if (id != null) {
                        // Use the ids previously computed and stored in the prefs file
                        uuid = UUID.fromString(id);
                    } else {
                        final String androidId = Secure.getString(context.getContentResolver(), Secure.ANDROID_ID);

                        // Use the Android ID unless it's broken, in which case fallback on deviceId,
                        // unless it's not available, then fallback on a random number which we store
                        // to a prefs file
                        try {
                            if (!"9774d56d682e549c".equals(androidId)) {
                                uuid = UUID.nameUUIDFromBytes(androidId.getBytes("utf8"));
                            } else {
                                final String deviceId = ((TelephonyManager) context.getSystemService( Context.TELEPHONY_SERVICE )).getDeviceId();
                                uuid = deviceId!=null ? UUID.nameUUIDFromBytes(deviceId.getBytes("utf8")) : UUID.randomUUID();
                            }
                        } catch (UnsupportedEncodingException e) {
                            throw new RuntimeException(e);
                        }

                        // Write the value out to the prefs file
                        prefs.edit().putString(PREFS_DEVICE_ID, uuid.toString() ).commit();
                    }
                }
            }
        }
    }


    /**
     * Returns a unique UUID for the current android device.  As with all UUIDs, this unique ID is "very highly likely"
     * to be unique across all Android devices.  Much more so than ANDROID_ID is.
     *
     * The UUID is generated by using ANDROID_ID as the base key if appropriate, falling back on
     * TelephonyManager.getDeviceID() if ANDROID_ID is known to be incorrect, and finally falling back
     * on a random UUID that's persisted to SharedPreferences if getDeviceID() does not return a
     * usable value.
     *
     * In some rare circumstances, this ID may change.  In particular, if the device is factory reset a new device ID
     * may be generated.  In addition, if a user upgrades their phone from certain buggy implementations of Android 2.2
     * to a newer, non-buggy version of Android, the device ID may change.  Or, if a user uninstalls your app on
     * a device that has neither a proper Android ID nor a Device ID, this ID may change on reinstallation.
     *
     * Note that if the code falls back on using TelephonyManager.getDeviceId(), the resulting ID will NOT
     * change after a factory reset.  Something to be aware of.
     *
     * Works around a bug in Android 2.2 for many devices when using ANDROID_ID directly.
     *
     * @see http://code.google.com/p/android/issues/detail?id=10603
     *
     * @return a UUID that may be used to uniquely identify your device for most purposes.
     */
    public UUID getDeviceUuid() {
        return uuid;
    }
}
```


#### 参考文献
1. [Identifying App Installations][1]
2. [How can I get the UUID of my Android phone in an application?][2]


[1]: http://android-developers.blogspot.com/2011/03/identifying-app-installations.html
[2]: http://stackoverflow.com/questions/5088474/how-can-i-get-the-uuid-of-my-android-phone-in-an-application