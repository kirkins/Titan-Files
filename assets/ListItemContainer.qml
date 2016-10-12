import bb.cascades 1.0
import bb.system 1.0
import bb.cascades.pickers 1.0
import my.library 1.0

Container {
    id: listItemContainer
    property bool isHighlighted: ListItem.active || ListItem.selected
    property int defaultPadding: 21
    property string fileIconSrc
    property string internalType
    property string internalName
    property string internalId
    property string selectedFile
    property string internalFileId
    layout: DockLayout {

    }
    verticalAlignment: VerticalAlignment.Fill
    horizontalAlignment: HorizontalAlignment.Fill
    Divider {
        verticalAlignment: VerticalAlignment.Bottom
    }

    Container {
        layout: DockLayout {

        }
        verticalAlignment: VerticalAlignment.Fill
        horizontalAlignment: HorizontalAlignment.Fill
        background: Color.create("#42b8dd")
        opacity: isHighlighted ? 0.8 : 0
    }

    Container {
        topPadding: defaultPadding
        leftPadding: defaultPadding
        bottomPadding: defaultPadding
        rightPadding: defaultPadding
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }

        ImageView {
            id: fileIcon
            imageSource: fileIconSrc
            verticalAlignment: VerticalAlignment.Center
            onCreationCompleted: {
                var tempFileExtensionArray = ListItemData.name.split(".");
                var fileType = tempFileExtensionArray.pop();
                console.log(fileType.toUpperCase())
                switch(fileType.toUpperCase())
                {
                    case "PNG":
                    case "JPG":
                    case "JPEG":
                    case "GIF":
                        fileIconSrc = "asset:///images/fileTypeJPG.png";
                        break;
                    case "AVI":
                        fileIconSrc = "asset:///images/fileTypeAVI.png";
                        break;
                    case "DOC":
                    case "DOCX":
                        fileIconSrc = "asset:///images/fileTypeDOC.png";
                        break;
                    case "MP3":
                    case "M4A":
                        fileIconSrc = "asset:///images/fileTypeMP3.png";
                        break;
                    case "PDF":
                        fileIconSrc = "asset:///images/fileTypePDF.png";
                        break;
                    case "PPT":
                        fileIconSrc = "asset:///images/fileTypePPT.png";
                        break;
                    case "XLS":
                        fileIconSrc = "asset:///images/fileTypeXLS.png";
                        break;
                    case "ZIP":
                        fileIconSrc = "asset:///images/fileTypeZIP.png";
                        break;
                    default:
                        fileIconSrc = "asset:///images/fileTypeTXT.png";
                        break;
                }
            }
        }

        Container {
            leftPadding: defaultPadding
            verticalAlignment: VerticalAlignment.Center
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }

            Label {
                text: ListItemData.name
                verticalAlignment: VerticalAlignment.Center
                textStyle {
                    base: SystemDefaults.TextStyles.TitleText
                }
            }

            Container {
                layout: DockLayout {

                }
                horizontalAlignment: HorizontalAlignment.Fill
                Label {
                    text: "Date Created: " + Qt.formatDate(new Date(ListItemData.date_created.split("-")[0], ListItemData.date_created.split("-")[1] - 1, ListItemData.date_created.split("-")[2]), "MMM dd, yyyy") //ListItemData.fileCreated
                    textStyle {
                        base: SystemDefaults.TextStyles.SubtitleText
                    }
                    verticalAlignment: VerticalAlignment.Center
                }
                Label {
                    text: parseInt(ListItemData.size) > 999999 ? parseInt(ListItemData.size) / 1000000 + " MB" : parseInt(ListItemData.size) > 999 ? parseInt(ListItemData.size) / 1000 + " KB" : parseInt(ListItemData.size) + " B"
                    textStyle {
                        base: SystemDefaults.TextStyles.SubtitleText
                    }
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Right
                }
            }

        }
    }

    contextActions: [
        ActionSet {
            title: ListItemData.name
            ActionItem {
                title: "Properties"
                imageSource: "asset:///images/actionProperties.png"
                onTriggered: {
                    var typeArray = ListItemData.name.split(".");
                    var type = typeArray.pop();
                    listItemContainer.ListItem.view.openFilePropertiesPage(ListItemData.name, type, ListItemData.date_created, ListItemData.size)
                }
            }
//            ActionItem {
//                id: invokeShare
//                title: "Share"
//                imageSource: "asset:///images/share.png"
//                onTriggered: {
//                    Qt.processing = true
//                    var encryptedFile = Qt.app.getHomePath() + ListItemData.id + ".aes";
//                    var tempFile = Qt.app.getTempPath() + ListItemData.name;
//                    console.log("Encrypted file: "+encryptedFile);
//                    console.log("Temp file: " + tempFile);
//                    Qt.crypto.decryptFile(encryptedFile, tempFile);
//                    //uri = tempFile;
//                    invokeShareQuery.query.uri = tempFile
//                    invokeShareQuery.trigger("bb.action.SHARE");
//                    Qt.processing = false
//                }
//                attachedObjects: [
//                    Invocation {
//                        id: invokeShareQuery
//                        query {
//                            uri: Qt.app.getTempPath() + ListItemData.name;
//                            invokeActionId: "bb.action.SHARE"
//                            mimeType: "image"
//                            onQueryChanged: invokeShareQuery.query.updateQuery();
//                        }
//                    }
//                ]
//            }
            ActionItem {
                title: "Move"
                imageSource: "asset:///images/move.png"
                onTriggered: {
                    movePicker.defaultSaveFileNames = [ListItemData.name]
                    movePicker.internalFileId = ListItemData.id
                    movePicker.open(); 
                }
                attachedObjects: [
	                FilePicker {
	                    id: movePicker
	                    mode: FilePickerMode.Saver
	                    title: "Move File"
	                    directories: [ "/accounts/1000/shared" ]
	                    property int internalFileId
	                    onFileSelected: {
                            Qt.processingMessage = "Decrypting file"
                            Qt.processingDialog.open()
                            moveTimer.start()
                            selectedFile = selectedFiles[0]
	                    }
	                }
                ]
            }
            ActionItem {
                title: "Copy"
                imageSource: "asset:///images/copy.png"
                onTriggered: {
                    copyPicker.defaultSaveFileNames = [ListItemData.name]
                    internalFileId = ListItemData.id
                    copyPicker.open();
                
                }
                attachedObjects: [
                    FilePicker {
                        id: copyPicker
                        mode: FilePickerMode.Saver
                        title: "Move File"
                        directories: [ "/accounts/1000/shared" ]
                        property int internalFileId
                        onFileSelected: {
                            Qt.processingMessage = "Decrypting file"
                            Qt.processingDialog.open()
                            copyTimer.start()
                            selectedFile = selectedFiles[0]
                        }
                    },
                    QTimer {
                        id: invokeTimer
                        interval: 0
                        onTimeout: {
                            var encryptedFile = Qt.app.getHomePath() + ListItemData.id + ".aes";
                            var tempFile = Qt.app.getTempPath() + ListItemData.name;
                            console.log("Encrypted file: "+encryptedFile);
                            console.log("Temp file: " + tempFile);
                            Qt.crypto.decryptFile(encryptedFile, tempFile);
                            
                            Qt.app.invokeFile(tempFile);
                            Qt.processingDialog.close()
                            invokeTimer.stop()
                        }
                    },
                    QTimer {
                        id: copyTimer
                        interval: 0
                        onTimeout: {
                            console.log("Copying file: " + Qt.app.getHomePath() + internalFileId + ".aes");
                            Qt.crypto.decryptFile(Qt.app.getHomePath() + internalFileId + ".aes", selectedFile);
                            Qt.toast.body = "File Copied"
                            Qt.toast.show()
                            Qt.processingDialog.close()
                            copyTimer.stop()
                        }
                    },
                    QTimer {
                        id: moveTimer
                        interval: 0
                        onTimeout: {
                            console.log("Moving file: " + Qt.app.getHomePath() + internalFileId + ".aes");
                            Qt.crypto.decryptFile(Qt.app.getHomePath() + internalFileId + ".aes", selectedFile);
                            Qt.app.deleteFile(Qt.app.getHomePath() + internalFileId + ".aes")
                            Qt.dataSource.execute("DELETE FROM files WHERE id=?;", [ internalFileId ]);
                            Qt.dataSource.load()
                            Qt.toast.body = "File Moved"
                            Qt.toast.show()
                            Qt.processingDialog.close()
                            moveTimer.stop()
                        }
                    }
                ]
            }
            ActionItem {
                title: "Rename"
                onTriggered: {
                    var fileName = ListItemData.name.split(".")
                    internalType = fileName.pop()
                    internalName = fileName[0]
                    internalId = ListItemData.id
                    renamePrompt.show()
                }
                attachedObjects: [
                    SystemPrompt {
                        id: renamePrompt
                        title: "Rename file"
                        body: "Choose a new file name. (File type extension added automatically)"
                        confirmButton.label: "OK"
                        confirmButton.enabled: true
                        cancelButton.label: "Cancel"
                        cancelButton.enabled: true
                        onFinished: {
                            if (result == SystemUiResult.ConfirmButtonSelection) {
                                var nameWithExtension = inputFieldTextEntry() + "." + internalType
                                Qt.dataSource.executeAndWait("UPDATE files SET name=? WHERE id=?;", [nameWithExtension,internalId])
                                Qt.toast.body = "File Renamed"
                                Qt.toast.show()
                                Qt.dataSource.load()
                            }
                        }
                    }
                ]
            }
            DeleteActionItem {
                title: "Delete"
                imageSource: "asset:///images/actionDelete.png"
                onTriggered: {
                    deleteDialog.show()
                }
            }
        }
    ]
    gestureHandlers: [
        TapHandler {
            onTapped: {
                Qt.processingMessage = "Decrypting file"
                Qt.processingDialog.open()
                invokeTimer.start()
            }
        }
    ]
    attachedObjects: [
        SystemDialog {
            id: deleteDialog
            title: "Delete File?"
            body: "Warning: You cannot undo this action."
            onFinished: {
                if (result == SystemUiResult.ConfirmButtonSelection) {
                    Qt.dataSource.executeAndWait("DELETE FROM files WHERE id=?;", [ListItemData.id]);
                    Qt.app.deleteFile(Qt.app.getHomePath() + ListItemData.id + ".aes");
                    //Update List
                    Qt.toast.body = "File Deleted"
                    Qt.toast.show()
                    Qt.dataSource.load()
                }
            }
        }
    ]
}
