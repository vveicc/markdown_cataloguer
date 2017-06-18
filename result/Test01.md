# App 自动化测试实践【01】

# _使用 Monkey 对 Android App 进行自动化测试_



# 目录


- [1. 相关资源](#1-相关资源)
  - [1.1 文档](#11-文档)
  - [1.2 源码](#12-源码)

- [2. Monkey 压测实践](#2-monkey-压测实践)
  - [2.1 Monkey 压测步骤](#21-monkey-压测步骤)
  - [2.2 Monkey 选项参数](#22-monkey-选项参数)
     - [2.2.1 常用选项参数](#221-常用选项参数)
     - [2.2.2 事件选项参数](#222-事件选项参数)
     - [2.2.3 约束选项参数](#223-约束选项参数)
     - [2.2.4 调试选项参数](#224-调试选项参数)

- [3. Monkey Script 压测实践](#3-monkey-script-压测实践)
  - [3.1 Monkey Script 常用命令](#31-monkey-script-常用命令)
  - [3.2 使用 UI Automator Viewer 工具](#32-使用-ui-automator-viewer-工具)
  - [3.3 编写 Monkey Script 脚本](#33-编写-monkey-script-脚本)
  - [3.4 拷贝 Monkey Script 脚本到手机](#34-拷贝-monkey-script-脚本到手机)
  - [3.5 执行 Monkey Script 脚本](#35-执行-monkey-script-脚本)

- [4. Monkey Runner 压测实践](#4-monkey-runner-压测实践)
  - [4.1 Monkey Runner 三大模块](#41-monkey-runner-三大模块)
  - [4.2 Monkey Runner 常用 API](#42-monkey-runner-常用-api)
     - [4.2.1 MonkeyRunner API](#421-monkeyrunner-api)
     - [4.2.2 MonkeyDevice API](#422-monkeydevice-api)
     - [4.2.3 MonkeyImage API](#423-monkeyimage-api)
  - [4.3 编写 Monkey Runner 脚本](#43-编写-monkey-runner-脚本)
  - [4.4 执行 Monkey Runner 脚本](#44-执行-monkey-runner-脚本)

- [5. 写在最后](#5-写在最后)



## 1. 相关资源

### 1.1 文档

- [Android Debug Bridge](http://www.android-doc.com/tools/help/adb.html)
- [UI/Application Exerciser Monkey](http://www.android-doc.com/tools/help/monkey.html)
- [monkeyrunner](http://www.android-doc.com/tools/help/monkeyrunner_concepts.html)

### 1.2 源码

- [Monkey 源码](https://github.com/android/platform_development/tree/master/cmds/monkey)

## 2. Monkey 压测实践

### 2.1 Monkey 压测步骤

1. 在手机的 `开发者选项` 中打开 `USB 调试` 。

2. 建立手机与电脑的连接，并通过下面的指令验证是否连接成功。

```tex
$ adb devices
```

3. 安装测试 App。

```tex
$ adb install [-lrtsdg] PACKAGE
$ adb install-multiple [-lrtsdpg] PACKAGE...
     push package(s) to the device and install them
     -l: forward lock application
     -r: replace existing application
     -t: allow test packages
     -s: install application on sdcard
     -d: allow version code downgrade (debuggable packages only)
     -p: partial application install (install-multiple only)
     -g: grant all runtime permissions
$ adb uninstall [-k] PACKAGE
     remove this app package from the device
     '-k': keep the data and cache directories

e.g.
$ adb install testapp.apk
```

4. 获取 App 包名。

```tex
$ adb logcat | grep START
```
输入上面的指令后，打开目标 App。

获取所有应用的包名：

```tex
$ adb shell pm list packages
```

5. 对指定包进行压力测试。

```tex
$ adb shell monkey [-p ALLOWED_PACKAGE [-p ALLOWED_PACKAGE] ...] COUNT

e.g.
$ adb shell monkey -p com.android.calculator2 1000
```

### 2.2 Monkey 选项参数

标准的 Monkey 命令：

```tex
$ adb shell monkey [options] COUNT
```

#### 2.2.1 常用选项参数

1. **-v** 参数

指定日志输出的详细级别，默认级别为 0，一个 `-v` 增加一个级别，最高为 3。

```tex
$ adb shell monkey [-v [-v] ...] COUNT

e.g.
$ adb shell monkey -v -p com.android.calculator2 100
```

2. **>** 参数

指定日志输出的文件位置，如果该文件已存在，则会覆盖原文件内容。

```tex
$ adb shell monkey [-v [-v] ...] COUNT >FILE_NAME.txt

e.g.
$ adb shell monkey -v -p com.android.calculator2 100 >log.txt
```

#### 2.2.2 事件选项参数

1. **-s** 参数

指定产生随机事件的 seed 值，相同的 seed 值产生相同的事件序列。

多次在 App 状态相同的情况下，输入不带 **-s** 参数的指令进行压测，压测结束的状态各不相同；而多次在 App 状态相同的情况下，输入带有相同 **-s** 参数的指令进行压测，压测结束的状态均相同。

```tex
$ adb shell monkey [-s SEED] COUNT

e.g.
$ adb shell monkey -s 36 -p com.android.calculator2 100
```

2. **--throttle** & **--randomize-throttle** 参数

指定事件之间的间隔，以降低系统的压力。如果不指定，系统会尽快的发送事件序列。

```tex
$ adb shell monkey [--throttle MILLISEC] [--randomize-throttle] COUNT

e.g.
$ adb shell monkey --throttle 1000 -p com.android.calculator2 36
```

3. **--pct-touch** 参数

指定触摸事件的百分比（触摸事件是一个 down-up 事件，它发生在屏幕上的某单一位置），即点按

```tex
$ adb shell monkey [--pct-touch PERCENT] COUNT

e.g.
$ adb shell monkey -v --pct-touch 100 -p com.android.calculator2 100
```

4. 类似设置事件百分比的参数还有：

- **--pct-motion** 参数
指定动作事件的百分比（动作事件由屏幕上某处的一个 down 事件、一系列的伪随机事件和一个 up 事件组成），即滑动。

- **--pct-trackball** 参数
指定轨迹球事件的百分比（轨迹球事件由一个或几个随机的移动组成，有时还伴随有点击）。

- **--pct-syskeys**
指定系统按键事件的百分比（这些按键通常被保留，由系统使用，如 Home、Back、Start Call、End Call 及音量控制键）。

- **--pct-nav**
指定基本导航事件的百分比（基本导航事件由来自方向输入设备的 up/down/left/right 组成）。

- **--pct-majornav**
指定主要导航事件的百分比（主要导航事件通常引发图形界面中的动作，如：键盘的中间按键、回退按键、菜单按键）。

- **--pct-appswitch**
指定启动 Activity 事件的百分比。在随机间隔里，Monkey 将执行一个 startActivity() 调用，作为最大程度覆盖包中全部 Activity 的一种方法。

- **--pct-flip**
指定键盘翻转事件的百分比。

- **--pct-anyevent**
指定其它类型事件的百分比（所有其它类型的事件，如：按键、其它不常用的设备按钮等等）。

- **--pct-pinchzoom**
指定捏合缩放事件的百分比。

#### 2.2.3 约束选项参数

1. **-p** 参数

指定测试的 package ，一个 `-p` 对应一个测试 package 。指定后，则只对指定的 package 进行测试；如果不指定，则对系统中所有 package 进行测试。

```tex
$ adb shell monkey [-p ALLOWED_PACKAGE [-p ALLOWED_PACKAGE] ...] COUNT

e.g.
$ adb shell monkey -p com.android.calculator2 -p com.android.calendar 100
```

2. **-c** 参数

指定测试的 category ，一个 `-c` 对应一个测试 category 。指定后，则只对指定 category 对应的 activity 进行测试；如果不指定，则对 `android.intent.category.LAUNCHER` 和 `android.intent.category.MONKEY` 对应的所有 activity 进行测试。

```tex
$ adb shell monkey [-c MAIN_CATEGORY [-c MAIN_CATEGORY] ...] COUNT

e.g.
$ adb shell monkey -c android.intent.category.LAUNCHER -c android.intent.category.HOME 100
```

#### 2.2.4 调试选项参数

1. **--hprof** 参数

指定是否在事件序列发送前后立即生成分析报告。如果设置此项，Monkey 将会在事件序列前后立刻生成 report，大小约 5Mb，存储在 data/misc 。

```tex
$ adb shell monkey [--hprof] COUNT

e.g.
$ adb shell monkey --hprof 100
```

2. **--ignore-crashes** 参数

指定是否忽略崩溃和异常。通常情况下，Monkey 在遇到了应用程序崩溃或是任何其他类型的非可控异常时会停止运行。如果设置此项，即使应用程序崩溃，Monkey 依然会发送事件，直到事件计数完成。

```tex
$ adb shell monkey [--ignore-crashes] COUNT

e.g.
$ adb shell monkey --ignore-crashes 100
```

3. **--ignore-timeouts** 参数

指定是否忽略超时（ANR）。通常情况下，Monkey 在遇到了应用程序ANR（Application No Responding）错误时会停止运行。如果设置此项，即使应用程序发生 ANR 错误，Monkey 依然会发送事件，直到事件计数完成。

```tex
$ adb shell monkey [--ignore-timeouts] COUNT

e.g.
$ adb shell monkey --ignore-timeouts 100
```

4. **--ignore-security-exceptions** 参数

指定是否忽略权限错误。通常情况下，Monkey 在遇到了应用程序权限错误时会停止运行。如果设置此项，即使应用程序发生权限错误，Monkey 依然会发送事件，直到事件计数完成。

```tex
$ adb shell monkey [--ignore-security-exceptions] COUNT

e.g.
$ adb shell monkey --ignore-security-exceptions 100
```

5. **--kill-process-after-error** 参数

指定发生异常后是否杀死异常进程。通常情况下，Monkey 因为某个异常停止运行，应用程序还会继续运行。如果设置此项，发生异常时，Monkey 就会通知系统杀死这个进程。

```tex
$ adb shell monkey [--kill-process-after-error] COUNT

e.g.
$ adb shell monkey --kill-process-after-error 100
```

6. **--ignore-native-crashes** 参数

指定是否忽略 Android 系统本地代码发生的异常。

```tex
$ adb shell monkey [--ignore-native-crashes] COUNT

e.g.
$ adb shell monkey --ignore-native-crashes 100
```

7. **--monitor-native-crashes** 参数

指定是否监控和报告 Android 系统本地代码发生的异常。如果此项和 --kill-process-after-error 参数同时设置，则系统将会终止。

```tex
$ adb shell monkey [--monitor-native-crashes] COUNT

e.g.
$ adb shell monkey --monitor-native-crashes 100
```

## 3. Monkey Script 压测实践

### 3.1 Monkey Script 常用命令

1. **DispatchPointer** 命令

```java
/**
 * 发送在点 (x, y) 处的按下、抬起事件
 * 只需要关注 action、x、y 三个参数即可
 *
 * @param action 事件类型，0 表示按下，1 表示抬起
 * @param x      事件触发点的 x 坐标
 * @param y      事件触发点的 y 坐标
 */
DispatchPointer(long downTime, long eventTime, int action, float x, float y, float pressure, float size, int metaState, float xPrecision, float yPrecision, int device, int edgeFlags);

e.g.
// 发送在点 (300, 600) 处的按下事件
DispatchPointer(10, 10, 0, 300, 600, 1, 1, -1, 1, 1, 0, 0);
```

2. **DispatchTrackball** 命令

用法同 **DispatchPointer** 命令。

```java
e.g.
// 发送在点 (300, 600) 处的抬起事件
DispatchTrackball(10, 10, 1, 300, 600, 1, 1, -1, 1, 1, 0, 0);
```

3. **Tap** 命令

```java
/**
 * 发送在点 (x, y) 处的点击事件
 *
 * @param x 事件触发点的 x 坐标
 * @param y 事件触发点的 y 坐标
 */
Tap(float x, float y);

e.g.
// 发送在点 (300, 600) 处的按下事件
Tap(300, 600);
```

4. **DispatchKey** 命令

```java
/**
 * 发送按下、抬起系统按键的事件
 * 只需要关注 action、code 两个参数即可
 *
 * @param action 事件类型，0 表示按下，1 表示抬起
 * @param code   按键的编码，对应 KeyEvent 中的 KEYCODE
 */
DispatchKey(long downTime, long eventTime, int action, int code, int repeat, int metaState, int device, int scancode);

e.g.
// 发送按下返回键事件
DispatchKey(-1, -1, 0, 4, 0, 0, -1, 0);
// 发送按下 Home 键事件
DispatchKey(-1, -1, 0, 3, 0, 0, -1, 0);
// 发送抬起 App 切换键事件
DispatchKey(-1, -1, 1, 187, 0, 0, -1, 0);
```

5. **DispatchPress** 命令

```java
/**
 * 发送点击按键的事件
 *
 * @param code 按键的编码，对应 KeyEvent 中的 KEYCODE
 */
DispatchPress(int code);

e.g.
// 发送按下返回键事件
DispatchPress(4);
// 发送按下 Home 键事件
DispatchPress(3);
// 发送抬起 App 切换键事件
DispatchPress(187);
// 发送键盘回车键事件
DispatchPress(66);
```

6. **DispatchString** 命令

```java
/**
 * 发送输入字符串事件，传入的 text 不要使用 ""，否则会一起输入
 */
DispatchString(String text);
```

7. **LaunchActivity** 命令

```java
/**
 * 发送启动 Activity 的事件
 * 如果没有启动，请尝试给 Activity 配置 `android:exported="true"`
 *
 * @param pkg_name 包名
 * @param cl_name  Activity 的全类名
 */
LaunchActivity(String pkg_name, String cl_name);

e.g.
LaunchActivity(com.android.calculator2, com.android.calculator2.Calculator);
```

8. **UserWait** 命令

```java
/**
 * 发送等待事件
 *
 * @param sleeptime 等待毫秒数
 */
UserWait(long sleeptime);
```

### 3.2 使用 UI Automator Viewer 工具

**UI Automator Viewer** 工具能够获取控件的位置信息。

1. 前往 UI Automator Viewer 工具所在目录

```tex
$ cd $ANDROID_HOME/tools
// 如果 tools 目录下没有 uiautomatorviewer 文件，则前往 tools 目录下的 bin 目录
$ cd bin
```

2. 启动 UI Automator Viewer 工具

```tex
$ ./uiautomatorviewer
```

3. 在手机或模拟器上打开目标页面，点击 UI Automator Viewer 工具左上角第一个 `手机` 图标，等待屏幕信息获取完成后即可查看控件位置信息。

### 3.3 编写 Monkey Script 脚本

```tex
type= raw events
count= 10
speed= 1.0
start data >>

Monkey Script 命令;
Monkey Script 命令;
......
```

e.g.

```tex
type= raw events
count= 10
speed= 1.0
start data >>

UserWait(2000);
Tap(888, 166);
DispatchString(www.apple.com);
UserWait(1000);
DispatchPress(66);
UserWait(6000);
Tap(888, 166);
DispatchString(www.baidu.com);
UserWait(1000);
DispatchPress(66);
UserWait(6000);
DispatchPress(4);
```

### 3.4 拷贝 Monkey Script 脚本到手机

Monkey 是手机端的工具，只能执行存储在手机上的 Monkey Script 脚本，因此我们需要将编写好的 Monkey Script 脚本拷贝到手机上。

```tex
$ adb push SCRIPT.script /data/local/tmp
```

### 3.5 执行 Monkey Script 脚本

```tex
$ adb shell monkey [-f scriptfile [-f scriptfile] ...] COUNT

e.g.
$ adb shell monkey -v -f /data/local/tmp/test.script 6 >~/Desktop/log-test.txt
```

## 4. Monkey Runner 压测实践

### 4.1 Monkey Runner 三大模块

1. [MonkeyDevice](http://www.android-doc.com/tools/help/MonkeyDevice.html)

2. [MonkeyImage](http://www.android-doc.com/tools/help/MonkeyImage.html)

3. [MonkeyRunner](http://www.android-doc.com/tools/help/MonkeyRunner.html)

### 4.2 Monkey Runner 常用 API

Monkey Runner 工具使用 Jython 语言。Jython 是一种使用 Java 编程语言的 Python 实现，允许 Monkey Runner API 与 Android 框架进行便捷的交互，同时能够使用 Python 语法访问 API 的常量、类和方法。

#### 4.2.1 MonkeyRunner API

1. alert

```python
'''
在运行当前程序的进程弹出模态的警告对话框，程序暂停，直到用户点击对话框上的按钮
message 显示的消息内容
title   对话框标题
okTitle 对话框按钮的标题
'''
string alert(string message, string title, string okTitle)
```

2. waitForConnection

```python
'''
等待设备连接
@param timeout  等待超时时间，单位：秒，默认一直等待
@param deviceId 设备 Id，有多台设备时需要指明
'''
MonkeyDevice waitForConnection(float timeout, string deviceId)
```

3. sleep

```python
'''
暂停当前程序
seconds 暂停秒数
'''
void sleep(float seconds)
```

#### 4.2.2 MonkeyDevice API

1. touch

```python
'''
发送在点 (x, y) 处的按下、抬起或点击事件
x    x 坐标
y    y 坐标
type 按键事件类型，对应 MonkeyDevice 的 DOWN、UP 和 DOWN_AND_UP
'''
void touch(integer x, integer y, integer type)
```

2. press

```python
'''
在设备屏幕上发送按键事件
name 按键名，对应 KeyEvent 中的 KEYCODE 名称，注意不是整型值
type 按键事件类型，对应 MonkeyDevice 的 DOWN、UP 和 DOWN_AND_UP
'''
void press(string name, integer type)

e.g.
# 发送按下返回键事件
device.press('KEYCODE_BACK', MonkeyDevice.DOWN)
# 发送抬起 Home 键事件
device.press('KEYCODE_HOME', MonkeyDevice.UP)
# 发送点击 App 切换键事件
device.press('KEYCODE_APP_SWITCH', MonkeyDevice.DOWN_AND_UP)
# 发送点击键盘回车键事件
device.press('KEYCODE_ENTER', MonkeyDevice.DOWN_AND_UP)
```

3. drag

```python
'''
在设备屏幕上发送拖动手势事件
start    手势起始点，元组 (x, y)
end      手势结束点，元组 (x, y)
duration 手势持续的时间，默认 1.0 秒
steps    插值点的步数，默认 10 步
'''
void drag(tuple start, tuple end, float duration, integer steps)
```

4. startActivity

```python
# 发送启动 Activity 事件
void startActivity(string uri, string action, string data, string mimetype, iterable categories dictionary extras, component component, iterable flags)

e.g.
package = 'com.android.calculator2'
activity = 'com.android.calculator2.Calculator'
runComponent = package + '/' + activity
device.startActivity(component=runComponent)
```

5. type

```python
# 发送输入字符串事件
void type(string message)
```

6. takeSnapshot

```python
# 发送截屏事件
MonkeyImage takeSnapshot()
```

#### 4.2.3 MonkeyImage API

1. sameAs

```python
'''
根据像素进行图像对比
other   进行对比的另一个图像
percent 相似度，0.0 ~ 1.0，默认是 1.0
'''
boolean sameAs(MonkeyImage other, float percent)
```

2. writeToFile

```python
'''
保存图像文件
path   保存路径
format 保存格式
'''
void writeToFile(string path, string format)
```

### 4.3 编写 Monkey Runner 脚本

```python
# !usr/bin/python
# -*- coding: utf-8 -*-

from com.android.monkeyrunner import MonkeyRunner, MonkeyDevice, MonkeyImage

调用 Monkey Runner API
调用 Monkey Runner API
......
```

e.g.

```python
# !usr/bin/python
# -*- coding: utf-8 -*-

from com.android.monkeyrunner import MonkeyRunner, MonkeyDevice, MonkeyImage

# 连接设备
device = MonkeyRunner.waitForConnection(1, '192.168.56.101:5555')

# 启动 App
package = 'com.android.browser'
activity = 'com.android.browser.BrowserActivity'
runComponent = package + '/' + activity
device.startActivity(component=runComponent)

MonkeyRunner.sleep(2)

# 点击输入框
device.touch(888, 166, MonkeyDevice.DOWN_AND_UP)

# 输入苹果官网网址
appleUrl = 'www.apple.com'
device.type(appleUrl)
MonkeyRunner.sleep(1)

# 点击回车键
device.press('KEYCODE_ENTER', MonkeyDevice.DOWN_AND_UP)
MonkeyRunner.sleep(6)

# 截屏并保存到执行 monkeyrunner 命令所在目录
appleWebsiteImage = device.takeSnapshot()
appleWebsiteImageSavePath = './apple_website.png'
appleWebsiteImageSaveFormat = 'png'
appleWebsiteImage.writeToFile(appleWebsiteImageSavePath, appleWebsiteImageSaveFormat)
MonkeyRunner.sleep(1)

# 点击输入框
device.touch(888, 166, MonkeyDevice.DOWN_AND_UP)

# 输入百度官网网址
baiduUrl = 'www.baidu.com'
device.type(baiduUrl)
MonkeyRunner.sleep(1)

# 点击回车键
device.press('KEYCODE_ENTER', MonkeyDevice.DOWN_AND_UP)
MonkeyRunner.sleep(6)

# 截屏并保存到执行 monkeyrunner 命令所在目录
baiduWebsiteImage = device.takeSnapshot()
baiduWebsiteImageSavePath = './baidu_website.png'
baiduWebsiteImageSaveFormat = 'png'
baiduWebsiteImage.writeToFile(baiduWebsiteImageSavePath, baiduWebsiteImageSaveFormat)
MonkeyRunner.sleep(1)

# 点击返回键
device.press('KEYCODE_BACK', MonkeyDevice.DOWN_AND_UP)

```

### 4.4 执行 Monkey Runner 脚本

```tex
$ monkeyrunner [options] SCRIPT_FILE
    -s   MonkeyServer IP Address.
    -p   MonkeyServer TCP Port.
    -v   MonkeyServer Logging level (ALL, FINEST, FINER, FINE, CONFIG, INFO, WARNING, SEVERE, OFF)

e.g.
$ monkeyrunner -v INFO test.py
```

## 5. 写在最后

本文介绍的自动化测试工具 Monkey 是 Android SDK 自带的工具，只能对 Android App 进行测试。这显然无法满足需求，不过没关系，Appium 能帮我们解决这个问题。

[Appium](http://appium.io) 是一款开源的、跨平台的自动化测试工具，支持模拟器（iOS、FirefoxOS、Android）和真机（iOS、Android、FirefoxOS）上的原生应用，混合应用以及移动 web 应用。

