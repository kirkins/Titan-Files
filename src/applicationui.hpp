#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include <QObject>
#include <bb/system/InvokeManager>
#include <bb/cascades/Invocation>

#include "RegistrationHandler.hpp"
#include "InviteToDownload.hpp"
#include "Crypto.hpp"

namespace bb
{
    namespace cascades
    {
        class Application;
        class LocaleHandler;
    }
}

class QTranslator;

/*!
 * @brief Application object
 *
 *
 */

class ApplicationUI : public QObject
{
    Q_OBJECT
public:
    ApplicationUI(bb::cascades::Application *app);
    virtual ~ApplicationUI() { }
	Q_INVOKABLE bool moveFile(const QString &fromPath, const QString &toPath);
	Q_INVOKABLE bool exportFile(const QString &fromPath, const QString &toPath);
	Q_INVOKABLE bool copyFile(const QString &fromPath, const QString &toPath);
    Q_INVOKABLE QString getValueFor(const QString &objectName, const QString &defaultValue);
	Q_INVOKABLE void saveValueFor(const QString &objectName, const QString &inputValue);
	Q_INVOKABLE QString getFiles();
	Q_INVOKABLE QString getFileSize(const QString &filePath);
	Q_INVOKABLE bool deleteFile(const QString &fromPath);
	Q_INVOKABLE void invokeFile(const QString &fileName);
	Q_INVOKABLE void importSample();
	Q_INVOKABLE QString getHomePath();
	Q_INVOKABLE QString getTempPath();

private slots:
    void onSystemLanguageChanged();
private:
    QTranslator* m_pTranslator;
    bb::cascades::LocaleHandler* m_pLocaleHandler;

	RegistrationHandler *registrationHandler;
	InviteToDownload *inviteToDownload;
	bb::cascades::Invocation *m_pInvocation;

	Crypto *crypto;
};

#endif /* ApplicationUI_HPP_ */
