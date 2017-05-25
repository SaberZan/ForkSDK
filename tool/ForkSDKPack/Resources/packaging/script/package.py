import sys
import os
import shutil
import project

#打包  python package.py /user/doctment/project/peoject.pbproject 1001
#1.拷贝文件到 root/forksdk 
#(每个平台复制修改info.plist，sdk文件，icon512*512.png,developerInfo.xml文件，各个icons)
#2.拷贝 root/test.xcodeproj到root/test-{渠道标示}.xcodeproj 并且修改依赖，工程配置等
# PLATFORM_AISI=1001,//爱思
# PLATFORM_XY=1002,//XY助手
# PLATFORM_HAIMA=1003,//海马
# PLATFORM_ITOOLS=1004,//itools
# PLATFORM_TONGBU=1005,//同步助手
# PLATFORM_BAIDU91=1006,//百度91
# PLATFORM_KUAIYONG=1007,//快用
# PLATFORM_PP=1008,//PP猪手
#def
FORKSDK_VERSION = '1.0'
FORKSDK_CHANNEL_CONFIG_PLIST = sys.path[0]+'/config/FKConfig.plist'
FORKSDK_CHANNEL_ICON_ORIGIN = sys.path[0]+'/resources/icon.png'
PROJECT_NAME = 'project.pbxproj'
PROJECT_SDK_PATH_NAME = 'ForkSDK'
PROJECT_CHANNEL_ID = [1001:'1001',1002:'1002',1003:'1003',1004:'1004',1005:'1005',1006:'1006',1007:'1007',1008:'1008']

class Package():

	def __init__(self,baseProjectPath):
		#工程项目包路径
		self.baseProjectPath=baseProjectPath
		#工程配置文件路径
		self.baseProjectConfigPath=self.baseProjectPath+PROJECT_NAME
		#工程路径
		self.basePath=os.path.dirname(baseProjectPath)
		#工程配置配置包名称test.xcodeproj
		self.baseProjectPackName=os.path.basename(baseProjectPath)
		#工程SDK路径
		self.baseSDKPath=self.basePath+'/'+PROJECT_SDK_PATH_NAME
		self.projectUtil=None

	def pack(self):
		#step 1:拷贝

	def make_or_copy_sdk(self):
		if not os.path.exists(self.baseSDKPath):
			shutil.copytree(self.baseProjectPath,new_file_path)


def help():
    print("\n%s %s - forksdk console: A command line tool for ForkSDK" %
          (sys.argv[0], FORKSDK_VERSION))
    print("\nAvailable commands:")
    parse = Cocos2dIniParser()
    classes = parse.parse_plugins()
    max_name = max(len(classes[key].plugin_name(
    ) + classes[key].plugin_category()) for key in classes.keys())
    max_name += 4
    for key in classes.keys():
        plugin_class = classes[key]
        category = plugin_class.plugin_category()
        category = (category + ' ') if len(category) > 0 else ''
        name = plugin_class.plugin_name()
        print("\t%s%s%s%s" % (category, name,
                              ' ' * (max_name - len(name + category)),
                              plugin_class.brief_description()))

    print("\nAvailable arguments:")
    print("\t-h, --help\tShow this help information")
    print("\t-v, --version\tShow the version of this command tool")
    print("\nExample:")
    print("\t%s new --help" % sys.argv[0])
    print("\t%s run --help" % sys.argv[0])

if __name__ == "__main__":


