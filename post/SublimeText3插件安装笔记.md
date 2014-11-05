#### Sublime Text 3插件安装笔记

推荐一份[Sublime Text 3 文档](http://feliving.github.io/Sublime-Text-3-Documentation/)。  

###### 1. 安装`Package Control`
* 自动安装
菜单`View`-`Show Console`，输入如下代码后运行（代码[参考](https://sublime.wbond.net/installation)）。  
```
import urllib.request,os,hashlib; h = '7183a2d3e96f11eeadd761d777e62404' + 'e330c659d4bb41d3bdf022e94cab3cd0'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://sublime.wbond.net/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); print('Error validating download (got %s instead of %s), please try manual install' % (dh, h)) if dh != h else open(os.path.join( ipp, pf), 'wb' ).write(by)
```
  
* 手动安装
对于公司内网采用代理访问外网的情况，默认安装方式无效，只能手动安装。  
  1. 菜单项`Preferences`-`Browse Packages…`；  
  2. 返回上级目录，进入`Installed Packages`目录；  
  3. 下载[`Package Control.sublime-package`](https://sublime.wbond.net/Package%20Control.sublime-package)，保存到`Installed Packages`目录（可能需要覆盖原`Package Control.sublime-package`文件）；  
  4. 重启Sublime Text 3。  
  
**注意：**`Package Control`公司内网同样需要配置代理才可以下载插件，配置示例如下：
```
{
	"http_proxy": "http://web-proxyhk.oa.com:8080"
}

```
  
###### 2. `SideBarEnhancements`
增强`Side Bar`。  
  
###### 3. `All Autocomplete`
自动完成-扩展至所有打开的文件，而不是局限于当前编辑的文件。  
  
###### 4. `SublimeCodeIntel`
通用型代码智能提示。  
  
用法：For Windows  
* Jump to definition = ``Alt+Click``  
* Jump to definition = ``Control+Windows+Alt+Up``  
* Go back = ``Control+Windows+Alt+Left``  
* Manual Code Intelligence = ``Control+Shift+space``  
  
智能提示配置文件需安装在`用户目录`，如Windows存储路径`C:\Users\wwang\.codeintel`（先删除现有目录）。  
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
  
###### 5. `BracketHighlighter`
括号、引号、标签等匹配。  
  
###### 6. `TrailingSpaces`
高亮每一行末尾空格、tab。  
  
执行删除操作， 一是菜单项`Edit`-`Trailing Spaces`，二是自己配置快捷键`Preferences`-`Key Bindings - User`，如下：  
```
{ "keys": ["ctrl+alt+d"], "command": "delete_trailing_spaces" },
{ "keys": ["ctrl+alt+o"], "command": "toggle_trailing_spaces" }

```
  
###### 7. `Markdown Preview`
包含两种`Markdown`解析器：`python-markdown`、`github markdown API`，但整体来说还是没有`Haroopad`编辑器方便。  
  
自己配置快捷键，预览时由用户自己选择解析器，如下：  
```
{ "keys": ["alt+m"], "command": "markdown_preview_select", "args": {"target": "browser"} }
```
  
###### 8. `JsFormat`
格式化`js`代码或者`json`数据！  
  
###### 9. `LineEndings`
转换`行尾`换行符。  
  
###### 10. `ConvertToUTF8`
由于Sublime Text对中文编码支持不好，国人开发`ConvertToUTF8`专用于解决该问题。  
打开文件将`中文编码`转换为`utf-8`；保存文件将`utf-8`转换为打开文件时检测到的`中文编码`。  
同时支持文件编码转换，菜单项`File`-`Set File Encoding to`。  
  
###### 11. `sublimeTmpl`
html/js/css/php/python/ruby代码创建模板。  
菜单项`File`-`New File (SublimeTmpl)`，或者命令`cmd+shift+p`-`tmpl`。  

###### 12. `AAAPackageDev`
简化开发Sublime Text的`syntax definitions`，实现自定义语法高亮。  
本人用于实现日志的高亮，方便浏览查找。  
具体如何开发，请参看[参考一](http://docs.sublimetext.info/en/latest/extensibility/syntaxdefs.html)、[参考二](http://manual.macromates.com/en/language_grammars#naming_conventions)。  

###### 13. `MarkdownEditing`
编辑`Markdown`。

###### 14. `IMESupport`
解决Sublime Text输入法不跟随bug。

###### 参考
1. [Packsge Control](https://sublime.wbond.net/)
2. [SideBarEnhancements](https://github.com/titoBouzout/SideBarEnhancements)
3. [All Autocomplete](https://github.com/alienhard/SublimeAllAutocomplete)
4. [SublimeCodeIntel](http://sublimecodeintel.github.io/SublimeCodeIntel/)
5. [BracketHighlighter](https://github.com/facelessuser/BracketHighlighter)
6. [TrailingSpaces](https://github.com/SublimeText/TrailingSpaces)
7. [Markdown Preview](https://github.com/revolunet/sublimetext-markdown-preview)
8. [JsFormat](https://github.com/jdc0589/JsFormat)
9. [LineEndings](https://github.com/SublimeText/LineEndings)
10. [ConvertToUTF8](https://github.com/seanliang/ConvertToUTF8)
11. [sublimeTmpl](https://github.com/kairyou/sublimeTmpl)
12. [AAAPackageDev](https://github.com/SublimeText/AAAPackageDev)
13. [MarkdownEditing](http://ttscoff.github.io/MarkdownEditing)
14. [IMESupport](https://github.com/chikatoike/IMESupport)
