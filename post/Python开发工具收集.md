#### Python开发利器

###### 1. `pip`
安装Python Package便捷工具，[参考][1]。  
  
Windows执行`pip`指令如下：
```
python -m pip <command> [options]
```
  
* install
从`PyPi`安装，[PyPi][3]就是Python的中央仓库。  
```
pip install SomePackage            # latest version
pip install SomePackage==1.0.4     # specific version
pip install 'SomePackage>=1.0.4'     # minimum version
```
pip默认安装`Wheels`格式package，只有在找不到`Wheels`时才进行`source`安装。  
对于没有`Wheels`格式package，可以使用`pip wheel`工具打包，[参考][5]。  
同时可以从`依赖列表`文件安装依赖项。
```
pip freeze > requirements.txt
pip install -r requirements.txt
```
`依赖列表`文件适用场景，四种，参考[requirements-files][4]。
  
* uninstall
顾名思义，卸载package。  
```
pip uninstall SomePackage
```
  
* list
输出当前已安装package。  
```
pip list
pip list --outdated
```
  
* show
显示package详细信息。  
```
pip show pip
```
  
* search
搜索package。  
```
pip search "query"
```
  
* 配置
pip配置，可以采用`命令行参数`、`环境变量`、`配置文件`，其中`配置文件`参考[Config file][6]。  
配置优先级：  
```
Command line options have precedence over environment variables, which have precedence over the config file.  
Within the config file, command specific sections have precedence over the global section.  
```
  
###### 2. `virtualenv`
Python沙盒，[参考][2]。   
注意：Python安装目录不能包含空格，不然`virtualenv`使用会有问题！  
  
Windows执行`virtualenv`指令如下：
```
python -m virtualenv [OPTIONS] DEST_DIR
```
  
Windows指令如下：
```
.\Scripts\activate
.\Scripts\deactivate
```
  
测试沙盒安装`django`，`pip install django`。  
  
  
#### 参考文献
1. [pip][1]
2. [virtualenv][2]
3. [pip wheel][5]


[1]: https://pip.pypa.io/en/latest/quickstart.html
[2]: https://virtualenv.pypa.io/en/latest/virtualenv.html
[3]: https://pypi.python.org/pypi/
[4]: https://pip.pypa.io/en/latest/user_guide.html#requirements-files
[5]: https://pip.pypa.io/en/latest/reference/pip_wheel.html
[6]: https://pip.pypa.io/en/latest/user_guide.html#config-file
