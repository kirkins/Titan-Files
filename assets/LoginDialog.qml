import bb.cascades 1.0
import my.library 1.0

Dialog {
    id: dialog
    property alias passwordField: passwordField
    Container {
        background: Color.Black
        layout: DockLayout {
        
        }
        ImageView {
            imageSource: "asset:///images/metalBg.png"
            verticalAlignment: VerticalAlignment.Fill
            horizontalAlignment: HorizontalAlignment.Fill
        }
        verticalAlignment: VerticalAlignment.Fill
        horizontalAlignment: HorizontalAlignment.Fill
        Container {
            topPadding: defaultPadding * 2
            horizontalAlignment: HorizontalAlignment.Center
            leftPadding: defaultPadding * 2
            rightPadding: defaultPadding * 2
            Container {
                horizontalAlignment: HorizontalAlignment.Center
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                ImageView {
                    imageSource: "asset:///images/titanFilesText.png"
                    scalingMethod: ScalingMethod.AspectFit
                    verticalAlignment: VerticalAlignment.Center
                }
                Label {
                    text: "  "
                }
                ImageView {
                    imageSource: "asset:///images/keyhole.png"
                    preferredHeight: 81*1.5
                    scalingMethod: ScalingMethod.AspectFit
                    verticalAlignment: VerticalAlignment.Center
                }
                bottomPadding: defaultPadding * 2
            }
            Label {
                multiline: true
                text: "<html><i>Warning: Files will be encrypted with your password, if you lose the password it will be impossible to unencrypt the files. <span style='font-weight:bold'>Deleting Titan Files will remove all files within this app.</span></i></html>"
                horizontalAlignment: HorizontalAlignment.Center
                textStyle {
                    textAlign: TextAlign.Center
                    fontSize: FontSize.PointValue
                    fontSizeValue: 8
                }
            }
            
            Container {
                topPadding: defaultPadding * 2
                horizontalAlignment: HorizontalAlignment.Center
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                TextField {
                    id: passwordField
                    hintText: app.getValueFor("Crypto.PasswordCiphertext","") == "" ? "Create New Password" : "Enter Password"
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    inputMode: TextFieldInputMode.Password
                    onTextChanging: {
                        okButton.enabled = text != ""
                    }
                    input {
                        submitKey: appPassword == "" ? SubmitKey.Submit : SubmitKey.Go
                        onSubmitted: {
                            processingMessage = "Decrypting File System"
                            processing = true
                            timer.start()
                        }
                    }
                }
                Button {
                    id: okButton
                    text: "OK"
                    enabled: false
                    preferredWidth: 0
                    horizontalAlignment: HorizontalAlignment.Center
                    onClicked: {
                        processingMessage = "Decrypting File System"
                        processing = true
                        timer.start()
                    }
                }
            }
        }
    }
    attachedObjects: [
        QTimer {
            id: timer
            interval: 0
            onTimeout: {
                var passText = app.getValueFor("Crypto.PasswordCiphertext","");
                if (passwordField.text != "") {
                    if (passText == "") {
                        crypto.setPassword(passwordField.text);
                    }
                        var result = crypto.checkPassword(passwordField.text) 
                        if (result) {
                            dialog.close()
                            Qt.dataSource.source = app.getTempPath() + "Rewards.db"
                        } else {
                            toast.body = "Incorrect Password"
                            toast.show()
                            passwordField.requestFocus()
                        }
                    processing = false
                }
                timer.stop()
            }
        }
    ]
}
