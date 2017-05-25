from mod_pbxproj import XcodeProject
import sys
import os
import shutil

    # PLATFORM_AISI=1001,//爱思
    # PLATFORM_XY=1002,//XY助手
    # PLATFORM_HAIMA=1003,//海马
    # PLATFORM_ITOOLS=1004,//itools
    # PLATFORM_TONGBU=1005,//同步助手
    # PLATFORM_BAIDU91=1006,//百度91
    # PLATFORM_KUAIYONG=1007,//快用
    # PLATFORM_PP=1008,//PP猪手

class Parsing():

	def __init__(self,baseProjectPath):
		self.baseProjectPath=baseProjectPath
		self.projectPath=''
		self.xcodeproject=None

	def loadProjectPath(self, projectPath):
		print "projectPath:",projectPath
		self.projectPath = projectPath
		self.xcodeproject = XcodeProject.Load(projectPath)

	def copyAndPointCopyFile(self):
		file_path = os.path.dirname(self.baseProjectPath)
		file_name = os.path.basename(self.baseProjectPath)
		file_name = file_name.split('.')
		file_name = file_name[0]+"-dddddddd."+file_name[1]
		print "file_path:",file_path
		print "file_name:",file_name
		new_file_path = file_path+"/"+file_name
		self.projectPath=new_file_path+"/project.pbxproj";

		if not os.path.exists(new_file_path):
			shutil.copytree(self.baseProjectPath,new_file_path)

		return new_file_path
		
	def addSysFramework(self,frameworkName):
		print "添加库：",frameworkName
		self.xcodeproject.add_file_if_doesnt_exist('System/Library/Frameworks/'+frameworkName+'.framework', parent='', weak=True, tree='SDKROOT')

	def addFolder(self, folder):
		print "添加文件夹：",folder
		self.xcodeproject.add_folder(folder)




if __name__ == '__main__':

    if len(sys.argv)<=0:
        print "缺少参数"
        sys.exit(0);

    file = sys.argv[1];

    pars=Parsing(file)
    new_file=pars.copyAndPointCopyFile()
    pars.loadProjectPath(new_file+"/project.pbxproj")
    pars.addFolder('/forksdk');
    pars.addSysFramework("CoreLocation.framework")


