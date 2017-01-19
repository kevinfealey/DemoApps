#!/usr/bin/env bash
updateRepos="true"
installOracleJDK8="true"
downloadApps="true"
installTomcat="true"
unzipApps="true"

#webgoatDownloadURL="https://github.com/WebGoat/WebGoat/releases/download/7.0.1/webgoat-container-7.0.1-war-exec.jar"
bodgeitDownloadURL="https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/bodgeit/bodgeit.1.4.0.zip"
liferayDownloadURL="http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/7.0.2%20GA3/liferay-ce-portal-tomcat-7.0-ga3-20160804222206210.zip?r=https%3A%2F%2Fwww.liferay.com%2Fdownloads&ts=1476036271&use_mirror=pilotfiber"
jspwikiDownloadURL="http://apache.claz.org/jspwiki/2.10.2/binaries/webapp/JSPWiki.war"
jenkinsDownloadURL="http://mirror.xmission.com/jenkins/war/2.25/jenkins.war"
jforumDownloadURL="http://jforum.net/jforum-2.1.9.zip"
dotCMSDownloadURL="http://dotcms.com/contentAsset/raw-data/fa9c69c4-4a67-42a3-9558-cc1dfbc664c2/zip/dotcms-2015-09-02_16-41.zip"

if  [ "$updateRepos" = "true" ]; then
	echo 'Updating repos'
	apt-get update
	echo 'Finished updating repos'
fi

#install Oracle JDK 8
if [ "$installOracleJDK8" = "true" ]; then	
	echo "Installing Java"
	add-apt-repository ppa:webupd8team/java
	apt-get update
	echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
	apt-get -y install oracle-java8-installer
fi

if [ "$installTomcat" = "true" ]; then
	curl -O http://apache.mirrors.ionfish.org/tomcat/tomcat-8/v8.5.5/bin/apache-tomcat-8.5.5.tar.gz
	mkdir /opt/tomcat
	tar xzvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1
fi

if [ "$downloadApps" = "true" ]; then
	echo "Downloading Apps..."
	mkdir /downloadedApps
	cd /downloadedApps
#	wget -cN --progress=bar:force ${webgoatDownloadURL}
	wget -cN --progress=bar:force ${bodgeitDownloadURL}
	wget -cN --progress=bar:force ${liferayDownloadURL} -O liferay-ce-portal-tomcat-7.0-ga3-20160804222206210.zip
	wget -cN --progress=bar:force ${jspwikiDownloadURL}
	wget -cN --progress=bar:force ${jenkinsDownloadURL}
	wget -cN --progress=bar:force ${jforumDownloadURL}
	wget -cN --progress=bar:force ${dotCMSDownloadURL}
fi

if [ "$unzipApps" = "true" ]; then
	echo "Unzipping apps"
	apt-get -y install unzip
	cd /downloadedApps
	unzip bodgeit.1.4.0.zip -d bodgeit.1.4.0
	unzip liferay-ce-portal-tomcat-7.0-ga3-20160804222206210.zip -d liferay-ce-portal-tomcat-7.0-ga3-20160804222206210
	unzip jforum-2.1.9.zip
	unzip dotcms-2015-09-02_16-41.zip -d dotcms-3.2.4
fi


echo "Installing WAR files (some downloaded applications are not WARs)"
cp -v /downloadedApps/bodgeit.1.4.0/bodgeit.war /opt/tomcat/webapps
cp -v /downloadedApps/*.war /opt/tomcat/webapps
cp -rv /downloadedApps/jforum-2.1.9 /opt/tomcat/webapps/
cp -v /vagrant/jspwiki-custom.properties /opt/tomcat/lib/jspwiki-custom.properties
echo "starting Tomcat"
sh /opt/tomcat/bin/startup.sh

echo "starting dotCMS"
chmod a+x /downloadedApps/dotcms-3.2.4/bin/*.sh #not sure why these aren't executable already, but they aren't...
chmod a+x /downloadedApps/dotcms-3.2.4/dotserver/tomcat-8.0.18/bin/*.sh #not sure why these aren't executable already, but they aren't...
sed -i  's/port="8080"/port="8081"/' /downloadedApps/dotcms-3.2.4/dotserver/tomcat-8.0.18/conf/server.xml #change the tomcat port 
#sed -i  's/Host name="localhost"/Host name="myHost"/' /downloadedApps/dotcms-3.2.4/dotserver/tomcat-8.0.18/conf/server.xml #update hostname for this tomcat instance

sh /downloadedApps/dotcms-3.2.4/bin/startup.sh

	echo 'Application should be accessible at http://<hostname>:8080/bodgeit'
	echo 'Application should be accessible at http://<hostname>:8080/jforum-2.1.9'
	echo 'Application should be accessible at http://<hostname>:8080/JSPWiki'
	echo 'Application should be accessible at http://<hostname>:8080/jenkins'
	echo 'Application should be accessible at http://<hostname>:8081/'
	echo 'Script finished.'