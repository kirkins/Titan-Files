import bb.cascades 1.0
import bb.system 1.0
import bb.cascades.pickers 1.0
import com.doclocker 1.0
import my.library 1.0

NavigationPane {
    id: nav

    property bool helpPagePushed
    property bool settingsPagePushed

    property bool isCreated
    property string appPassword: app.getValueFor("appPassword", "")
    property bool removeImported: app.getValueFor("removeImported", true)
    property bool listEmpty: true
    property int defaultPadding: 21

    property int displayWidth: DeviceInfo.width
    property int displayHeight: DeviceInfo.height
    property string devicePin: DeviceInfo.pin
    property bool keyboarded: DeviceInfo.keyboarded

    property bool processing: false
    property string processingMessage: ""
    
    property string filesSelected

    onAppPasswordChanged: {
        app.saveValueFor("appPassword", appPassword)
    }
    onPopTransitionEnded: {
        helpPagePushed = false
        settingsPagePushed = false
    }
    onProcessingChanged: {

        processing ? processingDialog.open() : processingDialog.close()

    }
    onCreationCompleted: {
        var home = app.getHomePath();
        console.log("PK - Home is " + home);
        if (appPassword == "") {
            console.log("running move file");
            dataSource.executeAndWait("INSERT INTO files (name, date_created, size) VALUES (gett_started.docx , date(), 49)");
            var fileId = dataSource.executeAndWait("SELECT last_insert_rowid() AS file_id", [])[0].file_id;
            var tempPath = app.getHomePath() + fileId + ".aes";
            crypto.encryptFile(app.getHomePath()+"app/native/assets/getting_started.docx", tempPath);
            dataSource.load()
        }

        listEmpty = myDataModel.isEmpty()

        console.log("PK - " + myDataModel.isEmpty())
        console.log("myDataModel length: " + myDataModel.size())
        Application.fullscreen.connect(onFullscreen);
        Application.thumbnail.connect(onThumbnailed);

        Qt.app = app
        Qt.myDataModel = myDataModel
        Qt.dataSource = dataSource
        Qt.toast = toast
        Qt.defaultPadding = defaultPadding
        Qt.crypto = crypto
        Qt.processing = processing;
        Qt.processingMessage = processingMessage
        Qt.processingDialog = processingDialog

        dialogTimer.start()
    }

    function onFullscreen() {
        Application.cover = null
    }
    function onThumbnailed() {
        Application.cover = appCover.createObject()
    }

    Menu.definition: MenuDefinition {
        //        settingsAction: SettingsActionItem {
        //            onTriggered: {
        //                if (! settingsPagePushed) {
        //                    settingsPagePushed = true
        //                    nav.push(settingsPageDef.createObject())
        //                }
        //            }
        //        }
        helpAction: HelpActionItem {
            onTriggered: {
                if (! helpPagePushed) {
                    helpPagePushed = true
                    nav.push(helpPageDef.createObject())
                }
            }
        }
        actions: [
            ActionItem {
                ActionBar.placement: ActionBarPlacement.OnBar
                title: "Share App"
                imageSource: "images/bbm.png"
                onTriggered: {
                    inviteToDownload.sendInvite();
                }
            }
        ]
    }
    Page {
        titleBar: TitleBar {
            kind: TitleBarKind.FreeForm
            kindProperties: FreeFormTitleBarKindProperties {
                content: CustomTitleBar {
                    titleText: "Titan Files - All Files"
                }
            }
        }
        Container {
            layout: DockLayout {

            }
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            Container {
                layout: StackLayout {

                }
                Container {
                    id: searchContainer
                    visible: false
                    topPadding: defaultPadding
                    leftPadding: defaultPadding
                    bottomPadding: defaultPadding
                    rightPadding: defaultPadding
                    TextField {
                        id: searchField
                        onTextChanging: {
                            console.log("PK - Attempting Search")
                            dataSource.load("SELECT * FROM files WHERE name LIKE ?", [ "%" + searchField.text + "%" ])
                        }
                    }
                }
                Container {
                    id: sortContainer
                    visible: false
                    topPadding: defaultPadding
                    leftPadding: defaultPadding
                    bottomPadding: defaultPadding
                    rightPadding: defaultPadding
                    DropDown {
                        id: sortBy
                        title: "Sort By"
                        selectedIndex: 0
                        Option {
                            text: "File Name"
                            value: "name"
                        }
                        //                        Option {
                        //                            text: "File Type"
                        //                        }
                        Option {
                            text: "File Created"
                            value: "date_created"
                        }
                        Option {
                            text: "File Size"
                            value: "size"
                        }
                        onSelectedIndexChanged: {
                            dataSource.load("SELECT * FROM files ORDER BY " + sortBy.selectedOption.value + " " + orderBy.selectedOption.value, [])
                        }
                    }
                    DropDown {
                        title: "Order"
                        id: orderBy
                        selectedIndex: 0
                        Option {
                            text: "Ascending"
                            value: "ASC"
                        }
                        Option {
                            text: "Descending"
                            value: "DESC"
                        }
                        onSelectedIndexChanged: {
                            dataSource.load("SELECT * FROM files ORDER BY " + sortBy.selectedOption.value + " " + orderBy.selectedOption.value, [])
                        }
                    }
                }
                ListView {
                    leadingVisualSnapThreshold: 1
                    dataModel: ArrayDataModel {
                        id: myDataModel
                        onItemAdded: {
                            listEmpty = myDataModel.isEmpty()
                            console.log("ITEM ADDED " + myDataModel.size())
                        }
                        onItemRemoved: {
                            listEmpty = myDataModel.isEmpty()
                            console.log("ITEM REMOVED " + myDataModel.size())
                        }
                    }
                    onCreationCompleted: {
                        dataSource.load();
                        console.log("dataSource LOADED ")
                    }
                    function openFilePropertiesPage(fileName, fileType, fileModifiedDate, fileSize) {
                        console.log("OPEN FILE PROPERTIES PAGE")
                        filePropertiesPage.fileName = fileName
                        console.log(fileModifiedDate);
                        // filePropertiesPage.date_created = fileModifiedDate
                        filePropertiesPage.constructDataModel(fileType, fileModifiedDate, fileSize)
                        nav.push(filePropertiesPage)
                    }
                    listItemComponents: [
                        ListItemComponent {
                            ListItemContainer {

                            }
                        }
                    ]
                    attachedObjects: [
                        CustomSqlDataSource {
                            id: dataSource
                            source: "sql/files.db"
                            query: "SELECT * FROM files"
                            onDataLoaded: {
                                myDataModel.clear();
                                myDataModel.append(data);
                                console.log("ITEM ADDED " + myDataModel.size())
                                listEmpty = myDataModel.isEmpty()
                                console.log("ITEM ADDED " + myDataModel.size())
                                console.log("LIST EMPTY " + listEmpty)
                            }
                        }
                    ]
                }
            }

            Container {
                visible: listEmpty
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                ImageView {
                    horizontalAlignment: HorizontalAlignment.Center
                    imageSource: "asset:///images/import.png"
                    preferredHeight: 81 * 2
                    preferredWidth: 81 * 2
                }
                Label {
                    text: "Titan File is empty, hit the\nimport button to securely add a file."
                    multiline: true
                    horizontalAlignment: HorizontalAlignment.Center
                    textStyle {
                        textAlign: TextAlign.Center
                        base: SystemDefaults.TextStyles.SubtitleText
                    }
                }
            }
        }
        actions: [
            ActionItem {
                title: "Import"
                imageSource: "asset:///images/import.png"
                onTriggered: {
                    filePicker.open()
                }
                ActionBar.placement: ActionBarPlacement.OnBar

            },
            ActionItem {
                title: "Search"
                imageSource: "asset:///images/search.png"
                onTriggered: {
                    console.log("search triggered")
                    sortContainer.visible = false
                    if (searchContainer.visible) {
                        searchContainer.visible = false
                    } else {
                        searchContainer.visible = true
                        searchField.requestFocus()
                    }
                }
                ActionBar.placement: ActionBarPlacement.OnBar

            },
            ActionItem {
                title: "Sort"
                imageSource: "asset:///images/sort.png"
                onTriggered: {
                    searchContainer.visible = false
                    if (sortContainer.visible) {
                        sortContainer.visible = false
                    } else {
                        sortContainer.visible = true
                    }
                }
                ActionBar.placement: ActionBarPlacement.OnBar

            }
        ]
        attachedObjects: [
            ComponentDefinition {
                id: appCover
                source: "AppCover.qml"
            },
            FilePicker {
                id: filePicker
                mode: FilePickerMode.PickerMultiple
                title: "Select File"
                directories: [ "/accounts/1000/shared" ]
                onFileSelected: {
                    processingMessage = "Moving and encrypting your files"
                    processing = true
                    importTimer.start()
                    filesSelected = JSON.stringify(selectedFiles);
                }
            },
            ComponentDefinition {
                id: helpPageDef
                source: "help.qml"
            },
            ComponentDefinition {
                id: settingsPageDef
                source: "settings.qml"
            },
            SystemToast {
                id: toast
                position: SystemUiPosition.TopCenter
            },
            QTimer {
                id: importTimer
                interval: 0
                onTimeout: {
                    var selectedFiles = JSON.parse(filesSelected)
                    console.log(selectedFiles.length)
                    for (var i = 0; i < selectedFiles.length; i ++) {
                        var fileLocation = selectedFiles[i];
                        var fileName = fileLocation.split("/").pop();
                        var fileSize = app.getFileSize(fileLocation);
                        dataSource.executeAndWait("INSERT INTO files (name, date_created, size) VALUES (? , date(), ?)", [ fileName, fileSize ]);
                        var fileId = dataSource.executeAndWait("SELECT last_insert_rowid() AS file_id", [])[0].file_id;
                        //app.moveFile(fileLocation, fileName);
                        var tempPath = app.getHomePath() + fileId + ".aes";
                        crypto.encryptFile(fileLocation, tempPath);
                        if (removeImported) {
                            Qt.app.deleteFile(fileLocation);
                        }
                        //crypto.encryptFile(fileName,)
                        dataSource.load()
                        //myDataModel.append(JSON.parse(app.getFiles()))
                    }
                    processing = false
                    console.log("processing = " + processing)
                    importTimer.stop()
                }
            }
        ]
        function pagePopped(pageName) {
            if (pageName == "Settings Page") {
                settingsPagePushed = false
            } else if (pageName == "Help Page") {
                helpPagePushed = false
            }
        }
    }
    attachedObjects: [
        QTimer {
            id: dialogTimer
            interval: 0
            onTimeout: {
                var loginDialog = loginDialogDef.createObject()
                loginDialog.open()
                loginDialog.passwordField.requestFocus()
                dialogTimer.stop()
            }
        },
        FilePropertiesPage {
            id: filePropertiesPage

        },
        ComponentDefinition {
            id: loginDialogDef
            source: "LoginDialog.qml"
        },
        ProcessingDialog {
            id: processingDialog
        }
    ]
}
