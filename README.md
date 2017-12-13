# iOSCodeSign.rb

###需要的文件：
appName.ipa: 要重签名的ipa

embedded.mobileprovision: 用来签名的provision文件

entitlements.plist: 授权机制

distributionName: 指该签名对应的证书的名字，在keychain中可以找到对应证书的名称

###步骤：
步骤一：将ipa包、mobileprovision文件、plist文件、iOSCodeSign.rb放在同一目录下。

步骤二：更改entitlements.plist文件，其中application-identifier中的BundleID必须是用来签名的证书下的BundleID，不然会出现安装ipa包不成功。

步骤三：更改iOSCodeSign.rb脚本，第一部分的内容需要填写，IPA为ipa包的名字，PROVISION为mobileprovision文件的名字，PLIST文件必须命名为entitlements.plist，KEY为证书名字，BUNDLEID为BundleID，如果不修改则不填。

步骤四：运行脚本 ruby iOSCodeSign.rb。