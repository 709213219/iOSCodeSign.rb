=begin
需要的文件：
appName.ipa: 要重签名的ipa
embedded.mobileprovision: 用来签名的provision文件
entitlements.plist: 授权机制
distributionName: 指该签名对应的证书的名字，在keychain中可以找到对应证书的名称

步骤：
步骤一：将ipa包、mobileprovision文件、plist文件、iOSCodeSign.rb放在同一目录下。
步骤二：更改entitlements.plist文件，其中application-identifier中的BundleID必须是用来签名的证书下的BundleID，不然会出现安装ipa包不成功。
步骤三：更改iOSCodeSign.rb脚本，第一部分的内容需要填写，IPA为ipa包的名字，PROVISION为mobileprovision文件的名字，PLIST文件必须命名为entitlements.plist，KEY为证书名字，BUNDLEID为BundleID，如果不修改则不填。
步骤四：运行脚本 ruby iOSCodeSign.rb。
=end

# 需要填写
IPA = "example.ipa"	# 用来重签名的ipa包
PROVISION = "example.mobileprovision" # 用来重签名的provision，可自定义命名
PLIST = "entitlements.plist" # entitlements文件，必须命名为entitlements.plist
KEY = "" # 用来重签名的证书，在钥匙串可以获得
BUNDLEID = "" # BundleID，如果不需要改BundleID则不填


@ipa = Dir.pwd + "/" + IPA
@provision = Dir.pwd + "/" + PROVISION
@plist = Dir.pwd + "/" + PLIST
@payLoad = Dir.pwd + "/" + "Payload"

# 解压ipa包
def unzipIPA
	if Dir.exist? @payLoad
		`rm -rf #{@payLoad}` # 删除非空的文件夹
	end

	`unzip #{@ipa}`
end

# 修改BundleID
def changeBundleID
	if BUNDLEID.length > 0 # 需要修改BundleID
		appName = getAppName
		infoPlist = "#{@payLoad}/#{appName}/Info.plist"

		if File.exist? infoPlist # 可以更改BundleID
			`/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier #{BUNDLEID}' #{infoPlist}`
		else
			puts "Info.plist文件不存在"
		end
	end
end

# 更换证书
def changeProvision
	oldProvision = @provision
	newProvision = "#{@payLoad}/#{getAppName}/embedded.mobileprovision"
	`cp #{oldProvision} #{newProvision}`
end

# 重签名
def reSign
	reSignFrameWork
	reSignApp
end

# 对framework重签名
def reSignFrameWork
	frameworks = "#{@payLoad}/#{getAppName}/Frameworks"
	if Dir.exist? frameworks
		Dir.foreach frameworks do |framework|
			if framework.end_with? ".framework"
				`codesign -fs "#{KEY}" --no-strict --entitlements #{@plist} #{frameworks}/#{framework}`
			end
		end
	end
end

# 对app重签名
def reSignApp
	`codesign -fs "#{KEY}" --no-strict --entitlements #{@plist} #{@payLoad}/#{getAppName}`
end

# 打包
def zipIPA
	newAppName = getAppName.gsub(".app", "") + "_resign.ipa"

	`zip -r #{newAppName} Payload`
end

# 获取appName
def getAppName
	appName = ""
	 Dir.foreach @payLoad do |file|
	 	if file.end_with? "app"
	 		appName = file
	 		break
	 	end
	 end
	 appName
end

# 程序开始
if File.exist? @ipa
	if File.exist? @provision
		if File.exist? @plist
			if KEY.length > 0
				unzipIPA
				changeBundleID
				changeProvision
				reSign
				zipIPA
			else
				puts "证书为空"
			end
		else
			puts "entitlements.plist文件不存在"
		end
	else
		puts "provision文件不存在"
	end
else
	puts "ipa包不存在"
end

