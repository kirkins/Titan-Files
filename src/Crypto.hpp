/*
 * Crypto.hpp
 *
 *  Created on: 2013-09-27
 *      Author: Taylor
 */

#ifndef CRYPTO_HPP_
#define CRYPTO_HPP_

#include <qobject.h>

#include <QSettings>

#include <QtCrypto/QtCrypto>

class Crypto: public QObject {
	Q_OBJECT

public:
	Crypto(QObject *parent);
	virtual ~Crypto();
	Q_INVOKABLE bool checkPassword(const QString &password);
	Q_INVOKABLE bool setPassword(const QString &password);
	Q_INVOKABLE bool decryptFile(const QString &source, const QString &destination);
	Q_INVOKABLE bool encryptFile(const QString &source, const QString &destination);

private:
	QCA::SymmetricKey key;
	QSettings settings;
	QByteArray passwordPlaintext;
	QCA::Initializer init;
};

#endif /* CRYPTO_HPP_ */
