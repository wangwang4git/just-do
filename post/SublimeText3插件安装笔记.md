#### Sublime Text 3插件安装笔记

###### 1. 手动安装`Package Control`
菜单`View`-`Show Console`，输入如下代码后运行。  
```
import urllib.request,os; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); open(os.path.join(ipp, pf), 'wb').write(urllib.request.urlopen( 'http://sublime.wbond.net/' + pf.replace(' ','%20')).read())
```
  
###### 2. 安装`SideBarEnhancements`
增强`Side Bar`。  
  
###### 3. 安装`All Autocomplete`
自动完成-扩展至所有打开的文件，而不是局限于当前编辑的文件。  
  
###### 4. 安装`SublimeCodeIntel`
通用型代码智能提示。  
  
用法：For Windows  
* Jump to definition = ``Alt+Click``  
* Jump to definition = ``Control+Windows+Alt+Up``  
* Go back = ``Control+Windows+Alt+Left``  
* Manual Code Intelligence = ``Control+Shift+space``  
  
智能提示配置文件需安装在`用户目录`，如Windows存储路径`C:\Users\wwang\.codeintel`。  
Python配置文件如下：  
```
{
	"Python": {
 		"python":"D:/Python27/python.exe",
 		"pythonExtraPaths":
 		[
 			"D:/Python27",
 			"D:/Python27/DLLs",
 			"D:/Python27/Lib",
 			"D:/Python27/Lib/lib-tk",
 		"D:/Python27/Lib/site-packages"
		]
	}
}
```
  

###### 参考
1. [Packsge Control官网](https://sublime.wbond.net/)
2. [SublimeCodeIntel官网](http://sublimecodeintel.github.io/SublimeCodeIntel/)
