/*
 * Crypto.cpp
 *
 *  Created on: 2013-09-27
 *      Author: Taylor
 */

#include "Crypto.hpp"

#include <QDebug>
#include <QFile>

Crypto::Crypto(QObject *parent = 0) : QObject(parent) {
	passwordPlaintext = QString("Success").toUtf8();

}

Crypto::~Crypto() {
	// TODO Auto-generated destructor stub
}

bool Crypto::checkPassword(const QString &password) {

	if (!settings.contains("Crypto.PasswordSalt")) {
		return false;
	}

	QCA::PBKDF2 kdf ("sha1");

	QCA::SecureArray passwordArray(password.toUtf8());
	QCA::InitializationVector salt (settings.value("Crypto.PasswordSalt").toByteArray());

	QCA::SymmetricKey tempKey = kdf.makeKey(passwordArray, salt, 128, 15000);

	QCA::InitializationVector iv (settings.value("Crypto.PasswordIV").toByteArray());

	QCA::Cipher cipher(QString("aes128"),QCA::Cipher::CBC,
		// use Default padding, which is equivalent to PKCS7 for CBC
		QCA::Cipher::DefaultPadding,
		// this object will decrypt
		QCA::Decode,
		tempKey, iv);

	QByteArray encrypted = settings.value("Crypto.PasswordCiphertext").toByteArray();

	QByteArray decrypted;

	decrypted.append(cipher.update(encrypted).toByteArray());
	decrypted.append(cipher.final().toByteArray());

	if (decrypted == passwordPlaintext) {
		qDebug() << "Password-derived key successfully decrypted the stored value, password is correct.";
		key = tempKey;
		return true;
	} else {
		qDebug() << "Error, bad password";
		return false;
	}
}

bool Crypto::setPassword(const QString &password) {

	if (!QCA::isSupported("aes128-cbc-pkcs7")) {
		qDebug() << "Encryption not supported";
		return false;
	}

	QCA::PBKDF2 kdf ("sha1");

	QCA::SecureArray passwordArray(password.toUtf8());

	QCA::InitializationVector salt (16);
	settings.setValue("Crypto.PasswordSalt", salt.toByteArray());

	QCA::SymmetricKey tempKey;

	tempKey = kdf.makeKey(passwordArray, salt, 128, 15000);

	QCA::InitializationVector iv(16);
	settings.setValue("Crypto.PasswordIV", iv.toByteArray());

	QCA::Cipher cipher(QString("aes128"),QCA::Cipher::CBC,
		// use Default padding, which is equivalent to PKCS7 for CBC
		QCA::Cipher::DefaultPadding,
		// this object will encrypt
		QCA::Encode,
		tempKey, iv);

	QByteArray encrypted;

	encrypted.append(cipher.update(passwordPlaintext).toByteArray());
	encrypted.append(cipher.final().toByteArray());

	settings.setValue("Crypto.PasswordCiphertext", encrypted);

	return true;
}

bool Crypto::decryptFile(const QString &source, const QString &destination) {
	QFile sourceFile(source);
	QFile outputFile(destination);

	if(!sourceFile.open(QIODevice::ReadOnly)) {
		qDebug() << "Error opening input file";
	    return false;
	}

	if(!outputFile.open(QIODevice::WriteOnly)) {
		qDebug() << "Error opening output file";
		return false;
	}

	//The first 16 bytes of a file contain the Initialization Vector
	QCA::InitializationVector iv(sourceFile.read(16));

	QCA::Cipher cipher(QString("aes128"),QCA::Cipher::CBC,
		// use Default padding, which is equivalent to PKCS7 for CBC
		QCA::Cipher::DefaultPadding,
		// this object will decrypt
		QCA::Decode,
		key, iv);

	QByteArray encryptedData;
	QByteArray decryptedData;
	//while (sourceFile.bytesAvailable() > 16) {
		encryptedData = sourceFile.readAll();

		decryptedData = cipher.update(encryptedData).toByteArray();
		//outputFile.write(decryptedData);
	//}

	decryptedData.append(cipher.final().toByteArray());
	outputFile.write(decryptedData);

	sourceFile.close();
	outputFile.close();

	return true;
}

bool Crypto::encryptFile(const QString &source, const QString &destination) {
	QFile sourceFile(source);
	QFile outputFile(destination);

	if(!sourceFile.open(QIODevice::ReadOnly)) {
		qDebug() << "Error opening input file";
		return false;
	}

	if(!outputFile.open(QIODevice::WriteOnly)) {
		qDebug() << "Error opening output file";
		return false;
	}

	QCA::InitializationVector iv(16);

	qDebug() << iv.toByteArray().toHex();

	outputFile.write(iv.toByteArray());

	QCA::Cipher cipher(QString("aes128"),QCA::Cipher::CBC,
		// use Default padding, which is equivalent to PKCS7 for CBC
		QCA::Cipher::DefaultPadding,
		// this object will encrypt
		QCA::Encode,
		key, iv);

	QByteArray encryptedData;
	QByteArray sourceData;
	//while (sourceFile.bytesAvailable() > 0) {
		sourceData = sourceFile.readAll();

		encryptedData = cipher.update(sourceData).toByteArray();
		//outputFile.write(encryptedData);
	//}

	encryptedData.append(cipher.final().toByteArray());
	outputFile.write(encryptedData);

	sourceFile.close();
	outputFile.close();

	return true;
}

