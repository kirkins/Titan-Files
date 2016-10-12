#include "applicationui.hpp"

#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/LocaleHandler>
#include <bb/cascades/pickers/FilePickerMode>

#include <bb/system/InvokeManager>
#include <bb/system/InvokeAction>
#include <bb/system/InvokeReply>
#include <bb/system/InvokeRequest>
#include <bb/system/InvokeTarget>
#include <bb/system/InvokeTargetReply>

#include <bb/device/DisplayInfo>
#include <bb/device/HardwareInfo>

#include <bb/system/SystemToast>
#include <bb/system/SystemDialog>
#include <bb/system/SystemPrompt>
#include <bb/system/SystemUiInputField>
#include <bb/system/SystemUiInputMode>

#include <bb/cascades/SceneCover>

#include <QFile>
#include <QIODevice>
#include <QDir>
#include <QFileInfo>

#include "RegistrationHandler.hpp"
#include "InviteToDownload.hpp"

#include "customsqldatasource.hpp"

using namespace bb::cascades;
using namespace bb::system;
using namespace bb::device;

ApplicationUI::ApplicationUI(bb::cascades::Application *app) :
        QObject(app)
{

    // prepare the localization
    m_pTranslator = new QTranslator(this);
    m_pLocaleHandler = new LocaleHandler(this);
    if(!QObject::connect(m_pLocaleHandler, SIGNAL(systemLanguageChanged()), this, SLOT(onSystemLanguageChanged()))) {
        // This is an abnormal situation! Something went wrong!
        // Add own code to recover here
        qWarning() << "Recovering from a failed connect()";
    }
    // initial load
    onSystemLanguageChanged();

    crypto = new Crypto(this);

    qmlRegisterType<QTimer>("my.library", 1, 0, "QTimer");
    qmlRegisterType<CustomSqlDataSource>("com.doclocker", 1, 0, "CustomSqlDataSource");

    // Create scene document from main.qml asset, the parent is set
    // to ensure the document gets destroyed properly at shut down.
    QmlDocument *qml = QmlDocument::create("asset:///main.qml").parent(this);
	qml->setContextProperty("app", this);
	qml->setContextProperty("crypto", crypto);

	DisplayInfo displayInfo;
	HardwareInfo hardwareInfo;
	QDeclarativePropertyMap* deviceProperties = new QDeclarativePropertyMap;
	deviceProperties->insert("width", displayInfo.pixelSize().width());
	deviceProperties->insert("height", displayInfo.pixelSize().height());
	deviceProperties->insert("pin", hardwareInfo.pin().right(8));
	deviceProperties->insert("keyboarded", hardwareInfo.isPhysicalKeyboardDevice());
	qml->setContextProperty("DeviceInfo", deviceProperties);

	// Register with BBM. - Replace YOUR_GUID with a guid from http://www.guidgenerator.com/
	const QUuid uuid(QLatin1String("50fd1267-6b59-4828-a313-47d67a8de310"));
	registrationHandler = new RegistrationHandler(uuid, app);
	inviteToDownload = new InviteToDownload(&registrationHandler->context());
	qml->setContextProperty("inviteToDownload", inviteToDownload);
	// End BBM



	qmlRegisterType<SceneCover>("bb.cascades", 1, 0, "SceneCover");
	qmlRegisterUncreatableType<AbstractCover>("bb.cascades", 1, 0,
			"AbstractCover", "An AbstractCover cannot be created");

    // Create root object for the UI
    AbstractPane *root = qml->createRootObject<AbstractPane>();

    // Set created root object as the application scene
    app->setScene(root);
}

QString ApplicationUI::getValueFor(const QString &objectName, const QString &defaultValue){
    QSettings settings;

    // If no value has been saved, return the default value.
    if (settings.value(objectName).isNull()) {
        return defaultValue;
    }

    // Otherwise, return the value stored in the settings object.
    return settings.value(objectName).toString();
}

void ApplicationUI::saveValueFor(const QString &objectName, const QString &inputValue){
    // A new value is saved to the application settings object.
    QSettings settings;
    settings.setValue(objectName, QVariant(inputValue));
}

QString ApplicationUI::getHomePath(){
	QString homePath = QDir::homePath() + "/";
	//qDebug() << homePath;
    return homePath;
}

QString ApplicationUI::getTempPath() {
	return QDir::tempPath() + "/";
}


bool ApplicationUI::moveFile(const QString &fromPath, const QString &toPath){
	QString newToPath = QDir::homePath()+ "/"+ toPath;
	qDebug() << "Attempting to copy from " << fromPath << "to " << newToPath;
	bool result = QFile::copy(fromPath, newToPath);
	if(result){
		QFile(fromPath).remove();
	}else{
		qDebug() << "Failed to copy";
	}

	return result;
}

bool ApplicationUI::exportFile(const QString &fromPath, const QString &toPath){
	qDebug() << "Attempting to copy from " << QDir::homePath()+"/"+fromPath << "to " << toPath;
	bool result = QFile::copy(fromPath, toPath);
	if(result){
		QFile(fromPath).remove();
	}

	return result;
}

bool ApplicationUI::copyFile(const QString &fromPath, const QString &toPath){
	qDebug() << "Attempting to copy from " << +"/"+fromPath << "to " << toPath;
	bool result = QFile::copy(+"/"+fromPath, toPath);

	return result;
}

bool ApplicationUI::deleteFile(const QString &fromPath){

	bool result = QFile(fromPath).remove();
	return result;
}

void ApplicationUI::invokeFile(const QString &fileName) {
	InvokeManager* invokeManager = new InvokeManager();
	InvokeRequest cardRequest;
	cardRequest.setUri("file://"+fileName);
	qDebug() << "Attempting to open file://" + fileName;
	InvokeReply* reply = invokeManager->invoke(cardRequest);
	qDebug() << invokeManager->invoke(cardRequest);
	reply->setParent(this);
}

QString ApplicationUI::getFiles(){

	QDir mDir(QDir::homePath());

	QString fileArray;
	int fileCount = 0;

	fileArray.append("[");
	foreach(QFileInfo mitm, mDir.entryInfoList(QDir::Files)){
		fileArray.append("{\"filePath\": \"");
		fileArray.append(mitm.absoluteFilePath());
		fileArray.append("\",");
		fileArray.append("\"fileCreated\": \"");
		fileArray.append(mitm.created().toString("yyyy-MM-dd"));
		fileArray.append("\",");
        fileArray.append("\"fileSize\": \"");
        fileArray.append(QString::number(mitm.size()));
        fileArray.append("\"}");
		if(fileCount!=mDir.entryInfoList(QDir::Files).count()-1){ fileArray.append(","); }
		fileCount++;
	}
	fileArray.append("]");

	qDebug() << fileArray;

	return fileArray;
}

QString ApplicationUI::getFileSize(const QString &filePath){

	//QDir mDir(QDir::homePath());
	//QFile* file = new QFile(filePath);
	QString infoReturn;
	QString size;
	QString fileName;

	QString test;

	QFile mio_f(filePath);
	if (!mio_f.open(QIODevice::ReadOnly))
	                return "failed";    //when file doesnt open.
	  size = QString::number(mio_f.size());  //when file does open.
	  fileName = mio_f.fileName();

	return size;
}



void ApplicationUI::importSample() {
	const QString workingDir = QDir::currentPath();
	const QString dirPaths = QString::fromLatin1("file://%1/app/public/").arg(workingDir);
	qDebug() << dirPaths+"getting_started.docx";
	QFileInfo fi(dirPaths+"getting_started.docx");
	bool exists = fi.exists();
	qDebug() << exists;
	bool result = QFile::copy(dirPaths+"getting_started.docx", QDir::homePath()+"/getting_started.docx");
	if(!result){
		qDebug() << "Failed to copy";
	}
}

void ApplicationUI::onSystemLanguageChanged()
{
    QCoreApplication::instance()->removeTranslator(m_pTranslator);
    // Initiate, load and install the application translation files.
    QString locale_string = QLocale().name();
    QString file_name = QString("DocumentLocker_%1").arg(locale_string);
    if (m_pTranslator->load(file_name, "app/native/qm")) {
        QCoreApplication::instance()->installTranslator(m_pTranslator);
    }
}
